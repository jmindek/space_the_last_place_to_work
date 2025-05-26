import gleam/int
import gleam/io
import gleam/list
import gleam/string
import player
import ship
import title_screen
import trade_goods
import universe

// Game state type to represent the game's state
pub type GameState {
  Continue(player: player.Player, universe: universe.Universe)
  Quit
}

// I was returning a Result<String, String> but it was not working. I just need a string.
@external(erlang, "io", "get_line")
pub fn get_line(prompt: String) -> String

fn with_quit_prompt(
  prompt: String,
  on_continue: fn() -> Result(GameState, String),
) -> Result(GameState, String) {
  let input = string.trim(get_line(prompt))
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
  let ship = ship.new_ship(ship.Shuttle, #(0, 0))
  case player.new("Player", ship.class) {
    Ok(player) -> {
      io.println("Player created\n")
      Ok(Continue(player, universe))
    }
    Error(e) -> {
      Error("Failed to create player: " <> e)
    }
  }
}

fn game_loop(player: player.Player, universe: universe.Universe) -> Nil {
  case player_turn(universe, player) {
    Continue(updated_player, updated_universe) -> {
      // Continue with NPC and environment turns
      let next_player = npc_turn(updated_universe, updated_player)
      let #(next_player, updated_universe) = environment_turn(updated_universe, next_player)
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
      let next_player = npc_turn(updated_universe, updated_player)
      let #(next_player, updated_universe) = environment_turn(updated_universe, next_player)
      Continue(next_player, updated_universe)
    }
    Quit -> Quit
  }
}

fn player_turn(universe: universe.Universe, player: player.Player) -> GameState {
  let player.Player(name, ship, _) = player
  let #(x, y) = ship.location
  let current_speed = ship.speed
  let max_speed = ship.max_speed

  // Show status
  io.println(
    name
    <> " your location is "
    <> int.to_string(x)
    <> ":"
    <> int.to_string(y)
    <> ".",
  )
  io.println("You have " <> int.to_string(ship.fuel_units) <> " fuel.")
  io.println(
    "Current speed: "
    <> int.to_string(current_speed)
    <> "/"
    <> int.to_string(max_speed),
  )
  io.println("Commands:")
  io.println("  M - Move")
  io.println("  I - Show ship info")
  io.println("  T# - Set speed (1-" <> int.to_string(max_speed) <> ")")
  io.println("  L - Show location map")
  io.println("  Q - Quit")
  io.print("> ")

  // Get command and convert to uppercase for case-insensitive matching
  let command = string.uppercase(string.trim(get_line("")))

  // Handle empty input first
  case command == "" {
    True -> Continue(player, universe)
    False -> {
      // Handle commands
      case command {
        // Show ship info
        "I" -> {
          let ship_info = ship.to_string(player.ship)
          io.println("\nShip Status:")
          io.println(ship_info)
          io.println("\nPress Enter to continue...")
          let _ = get_line("")
          Continue(player, universe)
        }
        // Show location map
        "L" -> {
          show_location_map(ship.location, universe)
          io.println("\nPress Enter to continue...")
          let _ = get_line("")
          Continue(player, universe)
        }
        // Quit command
        "Q" -> Quit
        // Move command
        "M" -> {
          io.println("Enter target coordinates (X:Y):")
          io.print("> ")

          // Get the input and split by colon
          let input = string.trim(get_line(""))

          // Split input on colon
          case string.split(input, ":") {
            [x_str, y_str] -> {
              let x_parsed = int.parse(string.trim(x_str))
              let y_parsed = int.parse(string.trim(y_str))

              case x_parsed, y_parsed {
                Ok(x), Ok(y) -> {
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
                            "Moved to "
                            <> int.to_string(x)
                            <> ":"
                            <> int.to_string(y),
                          )
                          Continue(updated_player, universe)
                        }
                        Error(e) -> {
                          io.println("Error: " <> e)
                          Continue(player, universe)
                        }
                      }
                    False -> {
                      case distance == 0 {
                        True -> {
                          io.println("Error: You're already at that location!")
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
                _, _ -> {
                  io.println("Invalid coordinates")
                  Continue(player, universe)
                }
              }
            }
            _ -> {
              io.println("Invalid input format. Please use X:Y")
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

// Display a 5x10 map showing the player's location and nearby objects
fn show_location_map(
  player_pos: #(Int, Int),
  universe: universe.Universe,
) -> Nil {
  let #(player_x, player_y) = player_pos

  // Calculate the visible area (10x5 grid centered on player)
  let start_x = player_x - 4
  // Show 4 columns to the left
  let end_x = player_x + 5
  // and 5 columns to the right (10 total)
  let start_y = player_y - 2
  // Show 2 rows above
  let end_y = player_y + 2
  // and 2 rows below (5 total)

  // Print header
  io.println("\n      " <> string.repeat("-", 19))
  io.println("     |0 1 2 3 4 5 6 7 8 9|")
  io.println("     +------------------+")

  // Print each row
  list.each(list.range(start_y, end_y), fn(y) {
    // Print row number with padding for alignment
    let y_str = int.to_string(y)
    let padding = case string.length(y_str) {
      1 -> "  "
      // Two spaces for single-digit numbers
      2 -> " "
      // One space for two-digit numbers
      _ -> ""
      // No space for three-digit numbers
    }
    io.print(padding <> y_str <> " |")

    // Print each column in the row
    list.each(list.range(start_x, end_x), fn(x) {
      // Check if this is the player's position
      case x == player_x && y == player_y {
        True -> io.print("* ")
        False -> {
          // Check if there's a planet at this position
          let has_planet =
            list.any(universe.planets, fn(planet) {
              planet.position.x == x && planet.position.y == y
            })

          // Print the appropriate symbol
          case has_planet {
            True -> io.print("0 ")
            False -> io.print(". ")
          }
        }
      }
    })

    // End of row
    io.println("|")
  })

  // Print footer and legend
  io.println("     +------------------+")
  io.println("     * = Your ship")
  io.println("     0 = Planet")
  io.println("     . = Empty space")
}

pub fn npc_turn(
  _universe: universe.Universe,
  player: player.Player,
) -> player.Player {
  io.println("NPC's turn\n")
  // NPC turn logic will go here
  player
}

// Update the price of a single trade good with some random fluctuation
fn fluctuate_price(trade_good: trade_goods.TradeGoods) -> trade_goods.TradeGoods {
  let fluctuation = int.random(21) - 10
  // Random number between -10 and +10

  case trade_good {
    trade_goods.Protein(name, price, quantity) -> {
      let new_price = int.max(1, price + fluctuation)
      trade_goods.Protein(name, new_price, quantity)
    }
    trade_goods.Hydro(name, price, quantity) -> {
      let new_price = int.clamp(price + fluctuation, 10, 1000)
      trade_goods.Hydro(name, new_price, quantity)
    }
    trade_goods.Fuel(name, price, quantity) -> {
      let new_price = int.clamp(price + fluctuation, 50, 1000)
      trade_goods.Fuel(name, new_price, quantity)
    }
    trade_goods.SpareParts(name, price, quantity) -> {
      let new_price = int.clamp(price + fluctuation, 25, 1000)
      trade_goods.SpareParts(name, new_price, quantity)
    }
    trade_goods.Mineral(name, price, quantity) -> {
      let new_price = int.clamp(price + fluctuation, 100, 1000)
      trade_goods.Mineral(name, new_price, quantity)
    }
    trade_goods.Habitat(name, price, quantity) -> {
      let new_price = int.clamp(price + fluctuation, 500, 5000)
      trade_goods.Habitat(name, new_price, quantity)
    }
    trade_goods.Weapons(name, price, quantity) -> {
      let new_price = int.clamp(price + fluctuation, 1000, 10_000)
      trade_goods.Weapons(name, new_price, quantity)
    }
    trade_goods.Shields(name, price, quantity) -> {
      let new_price = int.clamp(price + fluctuation, 1000, 10_000)
      trade_goods.Shields(name, new_price, quantity)
    }
  }
}

// Update all trade goods on a planet with price fluctuations
fn update_planet_prices(planet: universe.Planet) -> universe.Planet {
  let updated_goods = list.map(planet.trade_goods, fluctuate_price)
  universe.Planet(
    position: planet.position,
    life_supporting: planet.life_supporting,
    population: planet.population,
    water_percentage: planet.water_percentage,
    oxygen_percentage: planet.oxygen_percentage,
    gravity: planet.gravity,
    industry: planet.industry,
    mapping_percentage: planet.mapping_percentage,
    name: planet.name,
    moons: planet.moons,
    has_starport: planet.has_starport,
    has_ftl_lane: planet.has_ftl_lane,
    trade_allowed: planet.trade_allowed,
    trade_goods: updated_goods,
  )
}

pub fn environment_turn(
  universe: universe.Universe,
  player: player.Player,
) -> #(player.Player, universe.Universe) {
  io.println("Environment's turn - updating trade good prices...")

  // Update prices on all planets
  let updated_planets = list.map(universe.planets, update_planet_prices)
  let updated_universe =
    universe.Universe(size: universe.size, planets: updated_planets)

  // Return both the player and the updated universe
  #(
    player.Player(
      name: player.name,
      ship: player.ship,
      homeworld: player.homeworld
    ),
    updated_universe
  )
}
