import coordinate_map
import environment_turn
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import npc_turn
import player
import ship
import title_screen
import trade
import trade_goods
import universe
import utils

// Game state type to represent the game's state
pub type GameState {
  Continue(player: player.Player, universe: universe.Universe)
  Quit
}

fn with_quit_prompt(
  prompt: String,
  on_continue: fn() -> Result(GameState, String),
) -> Result(GameState, String) {
  let input = utils.get_trimmed_line(prompt)
  case string.lowercase(input) {
    "q" -> {
      io.println("Quitting\n")
      Ok(Quit)
    }
    _ -> on_continue()
  }
}

pub fn main() {
  title_screen.display_title_screen_clean()

  // Main game loop
  case
    with_quit_prompt(
      "\n                    Enter any key to play. Q to quit.\n",
      setup,
    )
  {
    Ok(Continue(player, universe)) -> game_loop(player, universe)
    Ok(Quit) -> io.println("Goodbye!")
    Error(e) -> io.println("Error: " <> e)
  }
}

fn setup() -> Result(GameState, String) {
  let universe = universe.create_universe(100, 60)

  // Find the first planet to use as homeworld
  let homeworld = case universe.planets {
    [first_planet, ..] -> first_planet
    _ ->
      // Create a default homeworld if no planets exist
      universe.Planet(
        position: universe.Position(x: 50, y: 50),
        life_supporting: True,
        population: 1000,
        water_percentage: 80,
        oxygen_percentage: 21,
        gravity: 1.0,
        industry: universe.Agra,
        mapping_percentage: 100,
        name: "Default Homeworld",
        moons: 1,
        has_starport: True,
        has_ftl_lane: True,
        trade_allowed: True,
        trade_goods: [],
      )
  }

  // Create a test player for now
  let player =
    player.Player(
      name: "Test Player",
      ship: ship.Ship(
        location: #(0, 0),
        speed: 1,
        max_speed: 10,
        class: ship.Freighter,
        crew_size: 4,
        fuel_units: 100,
        max_fuel_units: 100,
        shields: 0,
        max_shields: 0,
        weapons: 0,
        max_weapons: 5,
        cargo_holds: 0,
        max_cargo_holds: 10,
        passenger_holds: 0,
        max_passenger_holds: 5,
      ),
      homeworld: option.Some(homeworld),
      credits: 1000,
      cargo: [
        #(trade_goods.Protein("Protein", 10, 0), 0),
        #(trade_goods.Hydro("Hydro", 15, 0), 0),
        #(trade_goods.Fuel("Fuel", 5, 0), 0),
        #(trade_goods.SpareParts("Spare Parts", 30, 0), 0),
        #(trade_goods.Mineral("Mineral", 8, 0), 0),
        #(trade_goods.Habitat("Habitat", 50, 0), 0),
        #(trade_goods.Weapons("Weapons", 100, 0), 0),
        #(trade_goods.Shields("Shields", 80, 0), 0),
      ],
    )

  let updated_player =
    player.set_homeworld(player, homeworld)
    |> result.unwrap(player)
  // Fallback to original player if error

  // Move ship to homeworld coordinates
  let final_player =
    player.move_ship(
      updated_player,
      homeworld.position.x,
      homeworld.position.y,
      universe,
    )
    |> result.unwrap(updated_player)
  // Fallback to previous player if error

  // Log starting location
  let coords =
    string.concat([
      "\nStarting at ",
      homeworld.name,
      " at coordinates (",
      int.to_string(homeworld.position.x),
      ":",
      int.to_string(homeworld.position.y),
      ")\n",
    ])
  io.println(coords)

  Ok(Continue(final_player, universe))
}

fn game_loop(player: player.Player, universe: universe.Universe) -> Nil {
  case player_turn(universe, player) {
    Continue(updated_player, updated_universe) -> {
      // Continue with NPC and environment turns
      let next_player = npc_turn.npc_turn(updated_universe, updated_player)
      let #(next_player, updated_universe) =
        environment_turn.environment_turn(updated_universe, next_player)
      game_loop(next_player, updated_universe)
    }
    Quit -> {
      io.println("Returning to main menu...\n")
      main()
    }
  }
}

pub fn turn(universe: universe.Universe, player: player.Player) -> GameState {
  case player_turn(universe, player) {
    Continue(updated_player, updated_universe) -> {
      let next_player = npc_turn.npc_turn(updated_universe, updated_player)
      let #(next_player, updated_universe) =
        environment_turn.environment_turn(updated_universe, next_player)
      Continue(next_player, updated_universe)
    }
    Quit -> Quit
  }
}

fn player_turn(universe: universe.Universe, player: player.Player) -> GameState {
  let player.Player(name, ship, _, credits, cargo) = player
  let #(x, y) = ship.location
  let current_speed = ship.speed
  let max_speed = ship.max_speed
  let fuel = ship.fuel_units

  // Show status
  io.println(
    name
    <> ", your location is "
    <> int.to_string(x)
    <> ":"
    <> int.to_string(y)
    <> ".",
  )
  io.println("Credits: " <> int.to_string(credits))
  io.println(
    "Fuel: " <> int.to_string(fuel) <> "/" <> int.to_string(ship.max_fuel_units),
  )
  let total_cargo =
    cargo
    |> list.map(fn(pair) { pair.1 })
    |> list.fold(0, fn(quantity, acc) { acc + quantity })
  io.println(
    "Cargo: "
    <> int.to_string(total_cargo)
    <> "/"
    <> int.to_string(ship.max_cargo_holds),
  )
  // Show cargo items indented (only those with quantity > 0)
  case list.filter(cargo, fn(pair) { pair.1 > 0 }) {
    [] -> io.println("  (Empty)")
    non_empty_cargo -> {
      let _ =
        list.each(non_empty_cargo, fn(pair) {
          let name = case pair.0 {
            trade_goods.Protein(n, _, _) -> n
            trade_goods.Hydro(n, _, _) -> n
            trade_goods.Fuel(n, _, _) -> n
            trade_goods.SpareParts(n, _, _) -> n
            trade_goods.Mineral(n, _, _) -> n
            trade_goods.Habitat(n, _, _) -> n
            trade_goods.Weapons(n, _, _) -> n
            trade_goods.Shields(n, _, _) -> n
          }
          let qty = pair.1
          io.println("  - " <> name <> ": " <> int.to_string(qty))
        })
    }
  }
  io.println(
    "Current speed: "
    <> int.to_string(current_speed)
    <> "/"
    <> int.to_string(max_speed),
  )
  // Check if player is at a planet with a starport
  let current_planet_result =
    list.find(universe.planets, fn(p) { p.position.x == x && p.position.y == y })

  io.println("\nCommands:")
  io.println("  M - Move")
  io.println("  I - Show ship info")
  io.println("  L - Show location map")

  // Show system info and trade options if at a planet
  case current_planet_result {
    Ok(planet) ->
      case planet.has_starport {
        True -> io.println("  B - Trade at " <> planet.name <> "'s starport")
        False -> io.println("  (No starport in this system)")
      }
    Error(_) -> io.println("  (No planet at current location)")
  }

  io.println("  Q - Quit")
  io.print("> ")

  // Get command and convert to uppercase for case-insensitive matching
  let command = string.uppercase(string.trim(utils.get_line("")))

  // Handle empty input first
  case command == "" {
    True -> Continue(player, universe)
    False -> {
      // Handle commands
      case command {
        // FTL Travel
        "F" -> {
          case current_planet_result {
            Ok(_) -> {
              let destinations = find_ftl_destinations(player, universe)
              case destinations {
                [] -> {
                  io.println(
                    "\nNo FTL travel destinations available from this location.",
                  )
                  io.println(
                    "You must be at or near a planet with an FTL lane to use FTL travel.",
                  )
                  Continue(player, universe)
                }
                _ -> {
                  // Print available destinations
                  io.println("\nAvailable FTL destinations:")
                  let _ =
                    list.index_fold(destinations, 1, fn(i, dest, _) {
                      io.println(
                        string.concat([
                          int.to_string(i),
                          ". ",
                          dest.name,
                          case dest.has_starport {
                            True -> " (Starbase) "
                            False -> ""
                          },
                          " (",
                          int.to_string(dest.position.x),
                          ":",
                          int.to_string(dest.position.y),
                          ")",
                        ]),
                      )
                      i + 1
                    })

                  // Get user selection
                  io.print(
                    "\nEnter destination number (or press Enter to cancel): ",
                  )
                  let input = utils.get_trimmed_line("")

                  case input {
                    "" -> {
                      io.println("FTL travel cancelled.")
                      Continue(player, universe)
                    }
                    _ -> {
                      case int.parse(input) {
                        Ok(choice) -> {
                          // Find the selected destination by dropping the first (choice-1) elements
                          let remaining = list.drop(destinations, choice - 1)
                          case list.first(remaining) {
                            Ok(dest) -> {
                              io.println(
                                "\nInitiating FTL jump to "
                                <> dest.name
                                <> "...",
                              )

                              // Move the player to the destination planet
                              case
                                player.move_ship(
                                  player,
                                  dest.position.x,
                                  dest.position.y,
                                  universe,
                                )
                              {
                                Ok(updated_player) -> {
                                  io.println("Arrived at " <> dest.name <> "!")
                                  Continue(updated_player, universe)
                                }
                                Error(e) -> {
                                  io.println("FTL travel failed: " <> e)
                                  Continue(player, universe)
                                }
                              }
                            }
                            Error(_) -> {
                              io.println(
                                "Invalid selection. FTL travel cancelled.",
                              )
                              Continue(player, universe)
                            }
                          }
                        }
                        Error(_) -> {
                          io.println("Invalid input. Please enter a number.")
                          Continue(player, universe)
                        }
                      }
                    }
                  }
                }
              }
            }
            Error(_) -> {
              io.println(
                "\nYou must be at or near a planet with an FTL lane to use FTL travel.",
              )
              Continue(player, universe)
            }
          }
        }
        // Show ship info
        "I" -> {
          let ship_info = ship.to_string(player.ship)
          io.println("\nShip Status:")
          io.println(ship_info)
          io.println("\nPress Enter to continue...")
          let _ = utils.get_line("")
          Continue(player, universe)
        }
        // Show location map
        "L" -> {
          coordinate_map.show_minimap(player, universe)
          io.println("\nPress Enter to continue...")
          let _ = utils.get_line("")
          Continue(player, universe)
        }
        // Trade at starport
        "B" -> {
          case current_planet_result {
            Ok(planet) -> {
              case planet.has_starport {
                True -> {
                  // Show trade menu
                  io.println("\nDocking at " <> planet.name <> "'s starport...")
                  case trade.show_trade_menu(player, planet) {
                    Ok(updated_player) -> {
                      io.println("\nLeaving starport...")
                      Continue(updated_player, universe)
                    }
                    Error(e) -> {
                      io.println("Error in trade: " <> e)
                      Continue(player, universe)
                    }
                  }
                }
                False -> {
                  io.println("No starport at " <> planet.name <> "!")
                  Continue(player, universe)
                }
              }
            }
            Error(_) -> {
              io.println("No planet at current location!")
              Continue(player, universe)
            }
          }
        }
        // Quit command
        "Q" -> Quit
        // Movement command section
        "M" -> {
          // Show minimap
          coordinate_map.show_minimap(player, universe)

          // Show menu options
          io.println(
            "\n  (C)oordinates - Enter specific coordinates to move to",
          )
          io.println("  (F)TL - Show FTL travel options")
          io.println(
            "  (T)# - Set speed to # (1-"
            <> int.to_string(player.ship.max_speed)
            <> ")",
          )
          io.println("  (H)elp - Show help for movement commands")
          io.println("  (Q)uit - Return to main menu")
          io.print("\n> ")

          // Get user input
          let input = string.trim(utils.get_line(""))

          // Handle menu selection
          case string.uppercase(input) {
            // Coordinates input
            "C" -> {
              io.println("\nEnter target coordinates (X:Y):")
              io.print("> ")
              let coord_input = string.trim(utils.get_line(""))

              // Handle coordinate input with all possible patterns
              case string.split(coord_input, ":") {
                // Handle case with exactly two coordinates
                [x_str, y_str] -> {
                  let x_parsed = int.parse(string.trim(x_str))
                  let y_parsed = int.parse(string.trim(y_str))

                  // Handle both x and y parsing results
                  case x_parsed {
                    Ok(x) -> {
                      case y_parsed {
                        Ok(y) -> {
                          let #(current_x, current_y) = player.ship.location
                          let dx = int.absolute_value(x - current_x)
                          let dy = int.absolute_value(y - current_y)
                          // Using Manhattan distance (sum of x and y differences)
                          let distance = dx + dy

                          case distance <= current_speed && distance > 0 {
                            True ->
                              case player.move_ship(player, x, y, universe) {
                                Ok(updated_player) -> {
                                  io.println(
                                    "\nMoved to "
                                    <> int.to_string(x)
                                    <> ":"
                                    <> int.to_string(y),
                                  )
                                  Continue(updated_player, universe)
                                }
                                Error(e) -> {
                                  io.println("\nError: " <> e)
                                  Continue(player, universe)
                                }
                              }
                            False -> {
                              case distance == 0 {
                                True -> {
                                  io.println(
                                    "Error: You're already at that location!",
                                  )
                                  Continue(player, universe)
                                }
                                False -> {
                                  io.println(
                                    "Error: Cannot move that far! Maximum distance is "
                                    <> int.to_string(current_speed),
                                  )
                                  io.println(
                                    "You tried to move "
                                    <> int.to_string(distance)
                                    <> " units",
                                  )
                                  Continue(player, universe)
                                }
                              }
                            }
                          }
                        }
                        Error(_) -> {
                          io.println("\nError: Invalid Y coordinate")
                          Continue(player, universe)
                        }
                      }
                    }
                    Error(_) -> {
                      io.println("\nError: Invalid X coordinate")
                      Continue(player, universe)
                    }
                  }
                }
                // Handle cases with wrong number of coordinates
                [] -> {
                  io.println(
                    "\nError: Please enter coordinates in the format X:Y",
                  )
                  Continue(player, universe)
                }
                [_] -> {
                  io.println(
                    "\nError: Please enter both X and Y coordinates separated by a colon (X:Y)",
                  )
                  Continue(player, universe)
                }
                _ -> {
                  io.println(
                    "\nError: Too many coordinates. Please enter exactly X:Y",
                  )
                  Continue(player, universe)
                }
              }
            }
            "F" -> {
              // FTL travel
              case current_planet_result {
                Ok(planet) -> {
                  let destinations = find_ftl_destinations(player, universe)
                  case destinations {
                    [] -> {
                      io.println(
                        "\nNo FTL travel destinations available from this location.",
                      )
                      Continue(player, universe)
                    }
                    _ -> {
                      // Show FTL destinations
                      io.println("\nAvailable FTL destinations:")
                      let _ =
                        list.index_fold(destinations, 1, fn(i, dest, _) {
                          io.println(
                            string.concat([
                              int.to_string(i),
                              ". ",
                              dest.name,
                              case dest.has_starport {
                                True -> " (Starbase) "
                                False -> ""
                              },
                              " (",
                              int.to_string(dest.position.x),
                              ":",
                              int.to_string(dest.position.y),
                              ")",
                            ]),
                          )
                          i + 1
                        })

                      // Get user selection
                      io.print(
                        "\nEnter destination number (or press Enter to cancel): ",
                      )
                      let input = utils.get_trimmed_line("")

                      case input {
                        "" -> {
                          io.println("FTL travel cancelled.")
                          Continue(player, universe)
                        }
                        _ -> {
                          case int.parse(input) {
                            Ok(choice) -> {
                              // Find the selected destination by dropping the first (choice-1) elements
                              let remaining =
                                list.drop(destinations, choice - 1)
                              case list.first(remaining) {
                                Ok(dest) -> {
                                  io.println(
                                    "\nInitiating FTL jump to "
                                    <> dest.name
                                    <> "...",
                                  )
                                  // Move the player to the destination planet
                                  case
                                    player.move_ship(
                                      player,
                                      dest.position.x,
                                      dest.position.y,
                                      universe,
                                    )
                                  {
                                    Ok(updated_player) -> {
                                      io.println(
                                        "Arrived at " <> dest.name <> "!",
                                      )
                                      Continue(updated_player, universe)
                                    }
                                    Error(e) -> {
                                      io.println("FTL travel failed: " <> e)
                                      Continue(player, universe)
                                    }
                                  }
                                }
                                Error(_) -> {
                                  io.println(
                                    "Invalid selection. FTL travel cancelled.",
                                  )
                                  Continue(player, universe)
                                }
                              }
                            }
                            Error(_) -> {
                              io.println(
                                "Invalid input. Please enter a number.",
                              )
                              Continue(player, universe)
                            }
                          }
                        }
                      }
                    }
                  }
                }
                Error(_) -> {
                  io.println(
                    "\nFTL travel is only available from planets with FTL lanes.",
                  )
                  Continue(player, universe)
                }
              }
            }
            "H" -> {
              // Show help
              io.println("\n=== Movement Help ===")
              io.println("C - Enter specific coordinates to move to")
              io.println("F - Show FTL travel options")
              io.println(
                "T# - Set speed to # (1-"
                <> int.to_string(player.ship.max_speed)
                <> ")",
              )
              io.println("  Example: 'T3' sets speed to 3")
              io.println("Q - Return to main menu")
              io.println("\nPress Enter to continue...")
              let _ = utils.get_line("")
              Continue(player, universe)
            }
            // Handle Q to quit
            "Q" -> Continue(player, universe)
            // Handle empty input
            "" -> Continue(player, universe)
            // Handle T# command (speed change)
            _ -> {
              case string.slice(input, 0, 1) {
                "T" | "t" -> {
                  let speed_str = string.drop_left(input, 1)
                  case int.parse(speed_str) {
                    Ok(speed) -> {
                      case speed >= 1 && speed <= player.ship.max_speed {
                        True -> {
                          let updated_ship = ship.set_speed(player.ship, speed)
                          let updated_player =
                            player.Player(..player, ship: updated_ship)
                          io.println("\nSpeed set to " <> int.to_string(speed))
                          Continue(updated_player, universe)
                        }
                        False -> {
                          io.println(
                            "\nInvalid speed. Must be between 1 and "
                            <> int.to_string(player.ship.max_speed),
                          )
                          Continue(player, universe)
                        }
                      }
                    }
                    Error(_) -> {
                      io.println(
                        "\nInvalid speed command. Use T# where # is a number.",
                      )
                      Continue(player, universe)
                    }
                  }
                }
                _ -> {
                  io.println("\nUnknown command. Type 'H' for help.")
                  Continue(player, universe)
                }
              }
            }
          }
        }
        // Show system information
        "S" -> {
          case current_planet_result {
            Ok(planet) -> {
              io.println("\n=== " <> planet.name <> " ===")
              io.println(
                "Population: " <> int.to_string(planet.population) <> " million",
              )
              io.println(
                "Water: " <> int.to_string(planet.water_percentage) <> "%",
              )
              io.println(
                "Oxygen: " <> int.to_string(planet.oxygen_percentage) <> "%",
              )
              io.println("Gravity: " <> float.to_string(planet.gravity) <> "G")
              io.println(
                "Industry: " <> universe.industry_to_string(planet.industry),
              )
              io.println("Moons: " <> int.to_string(planet.moons))
              let starport_status = case planet.has_starport {
                True -> "Yes"
                False -> "No"
              }
              io.println("Starport: " <> starport_status)

              // Show trade goods if any
              case planet.trade_goods {
                [] -> io.println("\nNo trade goods available")
                goods -> {
                  io.println("\nAvailable goods:")
                  let _ =
                    list.each(goods, fn(good: trade_goods.TradeGoods) {
                      let name = case good {
                        trade_goods.Protein(n, _, _) -> n
                        trade_goods.Hydro(n, _, _) -> n
                        trade_goods.Fuel(n, _, _) -> n
                        trade_goods.SpareParts(n, _, _) -> n
                        trade_goods.Mineral(n, _, _) -> n
                        trade_goods.Habitat(n, _, _) -> n
                        trade_goods.Weapons(n, _, _) -> n
                        trade_goods.Shields(n, _, _) -> n
                      }
                      let price = case good {
                        trade_goods.Protein(_, p, _) -> p
                        trade_goods.Hydro(_, p, _) -> p
                        trade_goods.Fuel(_, p, _) -> p
                        trade_goods.SpareParts(_, p, _) -> p
                        trade_goods.Mineral(_, p, _) -> p
                        trade_goods.Habitat(_, p, _) -> p
                        trade_goods.Weapons(_, p, _) -> p
                        trade_goods.Shields(_, p, _) -> p
                      }
                      let quantity = case good {
                        trade_goods.Protein(_, _, q) -> q
                        trade_goods.Hydro(_, _, q) -> q
                        trade_goods.Fuel(_, _, q) -> q
                        trade_goods.SpareParts(_, _, q) -> q
                        trade_goods.Mineral(_, _, q) -> q
                        trade_goods.Habitat(_, _, q) -> q
                        trade_goods.Weapons(_, _, q) -> q
                        trade_goods.Shields(_, _, q) -> q
                      }
                      io.println(
                        "  - "
                        <> name
                        <> ": "
                        <> int.to_string(price)
                        <> " credits ("
                        <> int.to_string(quantity)
                        <> " available)",
                      )
                    })
                }
              }

              // Show player's cargo if any
              case player.cargo {
                [] -> {
                  io.println("\nYour cargo is empty.")
                }
                cargo -> {
                  io.println("\nYour cargo:")
                  let _ =
                    list.each(cargo, fn(pair: #(trade_goods.TradeGoods, Int)) {
                      let name = case pair.0 {
                        trade_goods.Protein(n, _, _) -> n
                        trade_goods.Hydro(n, _, _) -> n
                        trade_goods.Fuel(n, _, _) -> n
                        trade_goods.SpareParts(n, _, _) -> n
                        trade_goods.Mineral(n, _, _) -> n
                        trade_goods.Habitat(n, _, _) -> n
                        trade_goods.Weapons(n, _, _) -> n
                        trade_goods.Shields(n, _, _) -> n
                      }
                      let qty = pair.1
                      io.println(
                        "  - " <> name <> ": " <> int.to_string(qty) <> " units",
                      )
                    })
                }
              }

              io.println("\nPress Enter to continue...")
              let _ = utils.get_line("")
              Continue(player, universe)
            }
            Error(_) -> {
              io.println("No planet at current location!")
              Continue(player, universe)
            }
          }
        }
        // Thruster speed settings (dynamic T#)
        _ -> {
          // Check if the command starts with "T"
          case string.slice(command, 0, 1) {
            "T" -> {
              let speed_str = string.drop_left(command, 1)
              case int.parse(speed_str) {
                Ok(speed) -> {
                  let updated_player = player.set_ship_speed(player, speed)
                  io.println("Speed set to " <> int.to_string(speed))
                  io.println(
                    "Current speed: "
                    <> int.to_string(updated_player.ship.speed)
                    <> "/"
                    <> int.to_string(max_speed),
                  )
                  Continue(updated_player, universe)
                }
                Error(_) -> {
                  io.println(
                    "Invalid speed command. Use T# where # is a number.",
                  )
                  Continue(player, universe)
                }
              }
            }
            _ -> {
              io.println("Unknown command: " <> command)
              Continue(player, universe)
            }
          }
        }
      }
    }
  }
}

// Find all planets with FTL lanes that the player can travel to
fn find_ftl_destinations(
  player: player.Player,
  universe: universe.Universe,
) -> List(universe.Planet) {
  let #(x, y) = player.ship.location

  list.filter(universe.planets, fn(planet) {
    planet.has_ftl_lane && { planet.position.x != x || planet.position.y != y }
  })
}
