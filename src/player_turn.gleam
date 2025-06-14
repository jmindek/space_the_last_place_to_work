import coordinate_map
import game_types
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None}
import gleam/string
import player
import ship
import trade
import trade_goods
import universe
import utils

// Find fuel price from planet's trade goods
fn find_fuel_price(planet: universe.Planet) -> Result(Int, String) {
  case
    list.find(planet.trade_goods, fn(good) {
      case good {
        trade_goods.Fuel(_, _, _) -> True
        _ -> False
      }
    })
  {
    Ok(trade_goods.Fuel(_, price, _)) -> Ok(price)
    _ -> Error("Fuel not available at this starport")
  }
}

// Handle ship refueling at a starport
fn handle_refuel(
  player: player.Player,
  universe: universe.Universe,
  current_planet_result: Result(universe.Planet, Nil),
) -> game_types.GameState {
  case current_planet_result {
    Ok(planet) -> {
      case planet.has_starport {
        True -> {
          case find_fuel_price(planet) {
            Ok(price_per_unit) -> {
              let ship = player.ship
              let fuel_needed = ship.max_fuel_units - ship.fuel_units

              case fuel_needed > 0 {
                True -> {
                  let cost = fuel_needed * price_per_unit

                  io.println(
                    "\nRefueling "
                    <> int.to_string(fuel_needed)
                    <> " units of fuel at "
                    <> int.to_string(price_per_unit)
                    <> " credits per unit for a total of "
                    <> int.to_string(cost)
                    <> " credits.",
                  )
                  io.println("Confirm refuel? (Y/N)")
                  io.print("> ")

                  case string.uppercase(utils.get_line("")) {
                    "Y" | "YES" -> {
                      case player.credits >= cost {
                        True -> {
                          let updated_ship = ship.refuel(ship, fuel_needed)
                          let updated_player =
                            player.Player(
                              ..player,
                              ship: updated_ship,
                              credits: player.credits - cost,
                            )
                          io.println(
                            "\nRefueling complete! New fuel level: "
                            <> int.to_string(updated_ship.fuel_units)
                            <> "/"
                            <> int.to_string(updated_ship.max_fuel_units),
                          )
                          io.println(
                            "Remaining credits: "
                            <> int.to_string(updated_player.credits),
                          )
                          game_types.Continue(updated_player, universe, None)
                        }
                        False -> {
                          io.println("\nInsufficient credits for refueling.")
                          game_types.Continue(player, universe, None)
                        }
                      }
                    }
                    _ -> {
                      io.println("\nRefueling cancelled.")
                      game_types.Continue(player, universe, None)
                    }
                  }
                }
                False -> {
                  io.println("\nYour fuel tanks are already full!")
                  game_types.Continue(player, universe, None)
                }
              }
            }
            Error(reason) -> {
              io.println("\n" <> reason)
              game_types.Continue(player, universe, None)
            }
          }
        }
        False -> {
          io.println("\nNo starport available at this location.")
          game_types.Continue(player, universe, None)
        }
      }
    }
    Error(_) -> {
      io.println("\nNo planet at current location.")
      game_types.Continue(player, universe, None)
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

// Handle the player's turn in the game
pub fn player_turn(
  universe: universe.Universe,
  player: player.Player,
  npc_ships: option.Option(List(ship.Ship)),
) -> game_types.GameState {
  let player.Player(name, ship, _, credits, cargo) = player
  let #(x, y) = ship.location
  let current_speed = ship.speed
  let max_speed = ship.max_speed
  let fuel = ship.fuel_units

  // Check if player is at a starport
  let current_planet_result =
    list.find(universe.planets, fn(p) { p.position.x == x && p.position.y == y })

  // Show status
  io.println(
    name
    <> ", your location is "
    <> int.to_string(x)
    <> ":"
    <> int.to_string(y)
    <> ".",
  )

  // Show docked status if at a starport
  case current_planet_result {
    Ok(planet) -> {
      case planet.has_starport {
        True -> io.println("Docked at starport.")
        False -> Nil
      }
    }
    Error(_) -> Nil
  }

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
            trade_goods.Protein(name: n, price: _, quantity: _) -> n
            trade_goods.Hydro(name: n, price: _, quantity: _) -> n
            trade_goods.Fuel(name: n, price: _, quantity: _) -> n
            trade_goods.SpareParts(name: n, price: _, quantity: _) -> n
            trade_goods.Mineral(name: n, price: _, quantity: _) -> n
            trade_goods.Habitat(name: n, price: _, quantity: _) -> n
            trade_goods.Weapons(name: n, price: _, quantity: _) -> n
            trade_goods.Shields(name: n, price: _, quantity: _) -> n
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
  io.println("  S - Show system information")

  // Show system info and trade/refuel options if at a planet
  case current_planet_result {
    Ok(planet) -> {
      case planet.has_starport {
        True -> {
          io.println("  B - Trade at " <> planet.name <> "'s starport")
          io.println("  R - Refuel ship")
        }
        False -> io.println("  (No starport in this system)")
      }
    }
    Error(_) -> io.println("  (No planet at current location)")
  }

  io.println("  Q - Quit")
  io.print("> ")

  // Get command and convert to uppercase for case-insensitive matching
  let command = string.uppercase(string.trim(utils.get_line("")))

  // Handle empty input first
  case command == "" {
    True -> game_types.Continue(player, universe, npc_ships)
    False -> {
      // Handle commands
      case command {
        // FTL Travel
        "F" -> handle_ftl_travel(player, universe, current_planet_result)

        // Show ship info
        "I" -> {
          let ship_info = ship.to_string(player.ship)
          io.println("\nShip Status:")
          io.println(ship_info)
          io.println("\nPress Enter to continue...")
          let _ = utils.get_line("")
          game_types.Continue(player, universe, npc_ships)
        }

        // Show location map
        "L" -> {
          case npc_ships {
            option.Some(ships) -> {
              coordinate_map.show_minimap(player, universe, ships, False)
              io.println("\nPress Enter to continue...")
              let _ = utils.get_line("")
              game_types.Continue(player, universe, npc_ships)
            }
            option.None -> {
              coordinate_map.show_minimap(player, universe, [], False)
              io.println("\nPress Enter to continue...")
              let _ = utils.get_line("")
              game_types.Continue(player, universe, npc_ships)
            }
          }
        }

        // Trade at starport
        "B" -> handle_starport_trade(player, universe, current_planet_result)

        // Refuel ship
        "R" -> handle_refuel(player, universe, current_planet_result)

        // Quit command
        "Q" -> game_types.Quit

        // Movement command section
        "M" ->
          handle_movement_menu(
            player,
            universe,
            current_planet_result,
            npc_ships,
          )

        // Show system information
        "S" -> show_system_information(player, universe, current_planet_result)

        // Thruster speed settings (dynamic T#)
        _ -> handle_thruster_speed(command, player, universe)
      }
    }
  }
}

fn handle_ftl_travel(
  player: player.Player,
  universe: universe.Universe,
  current_planet_result: Result(universe.Planet, Nil),
) -> game_types.GameState {
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
          game_types.Continue(player, universe, None)
        }
        _ -> show_ftl_destinations(player, universe, destinations)
      }
    }
    Error(_) -> {
      io.println(
        "\nYou must be at or near a planet with an FTL lane to use FTL travel.",
      )
      game_types.Continue(player, universe, None)
    }
  }
}

fn show_ftl_destinations(
  player: player.Player,
  universe: universe.Universe,
  destinations: List(universe.Planet),
) -> game_types.GameState {
  // Print available destinations
  let #(prev_x, prev_y) = player.ship.previous_location
  io.println("\nAvailable FTL destinations:")
  let _ =
    list.index_fold(destinations, 1, fn(i, dest, _) {
      let is_previous = dest.position.x == prev_x && dest.position.y == prev_y

      io.println(
        string.concat([
          int.to_string(i),
          ". ",
          case is_previous {
            True -> "[PREV] "
            False -> ""
          },
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
  io.print("\nEnter destination number (or press Enter to cancel): ")
  let input = utils.get_trimmed_line("")

  case input {
    "" -> {
      io.println("FTL travel cancelled.")
      game_types.Continue(player, universe, None)
    }
    _ -> {
      case int.parse(input) {
        Ok(choice) -> {
          // Find the selected destination by dropping the first (choice-1) elements
          let remaining = list.drop(destinations, choice - 1)
          case list.first(remaining) {
            Ok(dest) -> {
              // Only consume FTL fuel (250 units)
              case player.consume_ftl_fuel(player) {
                Ok(player_with_less_fuel) -> {
                  io.println("\nInitiating FTL jump to " <> dest.name <> "...")
                  io.println("Fuel consumed: 250 units")

                  // Now move the player without consuming additional fuel
                  let updated_ship =
                    ship.move_ship(
                      player_with_less_fuel.ship,
                      // Use the ship with updated fuel
                      dest.position.x,
                      dest.position.y,
                      universe.universe_width,
                    )
                  let updated_player =
                    player.Player(..player_with_less_fuel, ship: updated_ship)

                  io.println("Arrived at " <> dest.name <> "!")
                  game_types.Continue(updated_player, universe, None)
                }
                Error(e) -> {
                  io.println("FTL jump failed: " <> e)
                  game_types.Continue(player, universe, None)
                }
              }
            }
            Error(_) -> {
              io.println("Invalid selection. FTL travel cancelled.")
              game_types.Continue(player, universe, None)
            }
          }
        }
        Error(_) -> {
          io.println("Invalid input. Please enter a number.")
          game_types.Continue(player, universe, None)
        }
      }
    }
  }
}

fn handle_starport_trade(
  player: player.Player,
  universe: universe.Universe,
  current_planet_result: Result(universe.Planet, Nil),
) -> game_types.GameState {
  case current_planet_result {
    Ok(planet) -> {
      case planet.has_starport {
        True -> {
          // Show trade menu
          io.println("\nDocking at " <> planet.name <> "'s starport...")
          case trade.show_trade_menu(player, planet) {
            Ok(updated_player) -> {
              io.println("\nLeaving starport...")
              game_types.Continue(updated_player, universe, None)
            }
            Error(e) -> {
              io.println("Error in trade: " <> e)
              game_types.Continue(player, universe, None)
            }
          }
        }
        False -> {
          io.println("No starport at " <> planet.name <> "!")
          game_types.Continue(player, universe, None)
        }
      }
    }
    Error(_) -> {
      io.println("No planet at current location!")
      game_types.Continue(player, universe, None)
    }
  }
}

fn handle_movement_menu(
  player: player.Player,
  universe: universe.Universe,
  current_planet_result: Result(universe.Planet, Nil),
  npc_ships: Option(List(ship.Ship)),
) -> game_types.GameState {
  // Show minimap with NPC info
  case npc_ships {
    option.Some(ships) ->
      coordinate_map.show_minimap(player, universe, ships, True)
    option.None -> coordinate_map.show_minimap(player, universe, [], True)
  }

  // Show menu options
  io.println("\n  (C)oordinates - Enter specific coordinates to move to")
  io.println("  (F)TL - Show FTL travel options")
  io.println(
    "  (T)# - Set speed to # (1-" <> int.to_string(player.ship.max_speed) <> ")",
  )
  io.println("  (H)elp - Show help for movement commands")
  io.println("  (Q)uit - Return to main menu")
  io.print("\n> ")

  // Get user input
  let input = string.trim(utils.get_line(""))

  // Handle menu selection
  case string.uppercase(input) {
    // Coordinates input
    "C" -> handle_coordinates_input(player, universe, npc_ships)

    // FTL travel
    "F" -> handle_ftl_travel(player, universe, current_planet_result)

    // Help
    "H" -> {
      // Show help
      io.println("\n=== Movement Help ===")
      io.println("C - Enter specific coordinates to move to")
      io.println("F - Show FTL travel options")
      io.println(
        "T# - Set speed to # (1-" <> int.to_string(player.ship.max_speed) <> ")",
      )
      io.println("  Example: 'T3' sets speed to 3")
      io.println("Q - Return to main menu")
      io.println("\nPress Enter to continue...")
      let _ = utils.get_line("")
      game_types.Continue(player, universe, None)
    }

    // Handle Q to quit
    "Q" -> game_types.Continue(player, universe, None)

    // Handle empty input
    "" -> game_types.Continue(player, universe, None)

    // Handle T# command (speed change)
    _ -> handle_thruster_speed(input, player, universe)
  }
}

fn handle_coordinates_input(
  player: player.Player,
  universe: universe.Universe,
  npc_ships: Option(List(ship.Ship)),
) -> game_types.GameState {
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

              // Calculate wrapped distances (accounting for 10x10 universe)
              let wrap_distance = fn(a: Int, b: Int) -> Int {
                let universe_size = 10
                // Ensure coordinates are positive and within universe bounds
                let wrap_coord = fn(coord: Int) -> Int {
                  let mod = coord % universe_size
                  case mod < 0 {
                    True -> mod + universe_size
                    False -> mod
                  }
                }

                let a_wrapped = wrap_coord(a)
                let b_wrapped = wrap_coord(b)
                let diff = int.absolute_value(a_wrapped - b_wrapped)
                // The minimum of direct distance and wrapped distance
                int.min(diff, universe_size - diff)
              }

              let dx = wrap_distance(x, current_x)
              let dy = wrap_distance(y, current_y)
              // Using Manhattan distance (sum of x and y differences)
              let distance = dx + dy

              case distance <= player.ship.speed && distance > 0 {
                True ->
                  case player.move_ship(player, x, y) {
                    Ok(updated_player) -> {
                      io.println(
                        "\nMoved to "
                        <> int.to_string(x)
                        <> ":"
                        <> int.to_string(y),
                      )
                      game_types.Continue(updated_player, universe, npc_ships)
                    }
                    Error(e) -> {
                      io.println("\nError: " <> e)
                      game_types.Continue(player, universe, None)
                    }
                  }
                False -> {
                  case distance == 0 {
                    True -> {
                      io.println("Error: You're already at that location!")
                      game_types.Continue(player, universe, None)
                    }
                    False -> {
                      io.println(
                        "Error: Cannot move that far! Maximum distance is "
                        <> int.to_string(player.ship.speed),
                      )
                      io.println(
                        "You tried to move "
                        <> int.to_string(distance)
                        <> " units",
                      )
                      game_types.Continue(player, universe, None)
                    }
                  }
                }
              }
            }
            Error(_) -> {
              io.println("\nError: Invalid Y coordinate")
              game_types.Continue(player, universe, None)
            }
          }
        }
        Error(_) -> {
          io.println("\nError: Invalid X coordinate")
          game_types.Continue(player, universe, None)
        }
      }
    }
    // Handle cases with wrong number of coordinates
    [] -> {
      io.println("\nError: Please enter coordinates in the format X:Y")
      game_types.Continue(player, universe, None)
    }
    [_] -> {
      io.println(
        "\nError: Please enter both X and Y coordinates separated by a colon (X:Y)",
      )
      game_types.Continue(player, universe, None)
    }
    _ -> {
      io.println("\nError: Too many coordinates. Please enter exactly X:Y")
      game_types.Continue(player, universe, None)
    }
  }
}

fn show_system_information(
  player: player.Player,
  universe: universe.Universe,
  current_planet_result: Result(universe.Planet, Nil),
) -> game_types.GameState {
  case current_planet_result {
    Ok(planet) -> {
      io.println("\n=== " <> planet.name <> " ===")
      io.println(
        "Population: " <> int.to_string(planet.population) <> " million",
      )
      io.println("Water: " <> int.to_string(planet.water_percentage) <> "%")
      io.println("Oxygen: " <> int.to_string(planet.oxygen_percentage) <> "%")
      io.println("Gravity: " <> float.to_string(planet.gravity) <> "G")
      io.println("Industry: " <> universe.industry_to_string(planet.industry))
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
                trade_goods.Protein(name: n, price: _, quantity: _) -> n
                trade_goods.Hydro(name: n, price: _, quantity: _) -> n
                trade_goods.Fuel(name: n, price: _, quantity: _) -> n
                trade_goods.SpareParts(name: n, price: _, quantity: _) -> n
                trade_goods.Mineral(name: n, price: _, quantity: _) -> n
                trade_goods.Habitat(name: n, price: _, quantity: _) -> n
                trade_goods.Weapons(name: n, price: _, quantity: _) -> n
                trade_goods.Shields(name: n, price: _, quantity: _) -> n
              }
              let price = case good {
                trade_goods.Protein(name: _, price: p, quantity: _) -> p
                trade_goods.Hydro(name: _, price: p, quantity: _) -> p
                trade_goods.Fuel(name: _, price: p, quantity: _) -> p
                trade_goods.SpareParts(name: _, price: p, quantity: _) -> p
                trade_goods.Mineral(name: _, price: p, quantity: _) -> p
                trade_goods.Habitat(name: _, price: p, quantity: _) -> p
                trade_goods.Weapons(name: _, price: p, quantity: _) -> p
                trade_goods.Shields(name: _, price: p, quantity: _) -> p
              }
              let quantity = case good {
                trade_goods.Protein(name: _, price: _, quantity: q) -> q
                trade_goods.Hydro(name: _, price: _, quantity: q) -> q
                trade_goods.Fuel(name: _, price: _, quantity: q) -> q
                trade_goods.SpareParts(name: _, price: _, quantity: q) -> q
                trade_goods.Mineral(name: _, price: _, quantity: q) -> q
                trade_goods.Habitat(name: _, price: _, quantity: q) -> q
                trade_goods.Weapons(name: _, price: _, quantity: q) -> q
                trade_goods.Shields(name: _, price: _, quantity: q) -> q
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
        [] -> io.println("\nYour cargo is empty.")
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
      game_types.Continue(player, universe, None)
    }
    Error(_) -> {
      io.println("No planet at current location!")
      game_types.Continue(player, universe, None)
    }
  }
}

fn handle_thruster_speed(
  command: String,
  player: player.Player,
  universe: universe.Universe,
) -> game_types.GameState {
  // Check if the command starts with "T"
  case string.slice(command, 0, 1) {
    "T" | "t" -> {
      let speed_str = string.slice(command, 1, string.length(command))
      case int.parse(speed_str) {
        Ok(speed) -> {
          case speed >= 1 && speed <= player.ship.max_speed {
            True -> {
              let updated_ship = ship.set_speed(player.ship, speed)
              let updated_player = player.Player(..player, ship: updated_ship)
              io.println("\nSpeed set to " <> int.to_string(speed))
              game_types.Continue(updated_player, universe, None)
            }
            False -> {
              io.println(
                "\nInvalid speed. Must be between 1 and "
                <> int.to_string(player.ship.max_speed),
              )
              game_types.Continue(player, universe, None)
            }
          }
        }
        Error(_) -> {
          io.println("\nInvalid speed command. Use T# where # is a number.")
          game_types.Continue(player, universe, None)
        }
      }
    }
    _ -> {
      io.println("Unknown command: " <> command)
      game_types.Continue(player, universe, None)
    }
  }
}
