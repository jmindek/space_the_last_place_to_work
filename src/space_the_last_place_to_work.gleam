import gleam/int
import gleam/io
import gleam/string
import player
import ship
import universe

// I was returning a Result<String, String> but it was not working. I just need a string.
@external(erlang, "io", "get_line")
pub fn get_line(prompt: String) -> String

@external(erlang, "init", "stop")
pub fn stop() -> a

fn with_quit_prompt(prompt: String, on_continue: fn() -> a) -> a {
  case string.trim(get_line(prompt)) {
    "q" -> {
      io.println("Quitting\n")
      stop()
    }
    _ -> on_continue()
  }
}

pub fn main() {
  io.println("Starting Space The Last Place To Work!\n")
  with_quit_prompt("Enter a key. Q to quit.\n", setup)
}

pub fn setup() {
  let universe = universe.create_universe(100, 10)
  let ship = ship.new_ship(ship.Shuttle, #(0, 0))
  case player.new("Player", ship.class) {
    Ok(player) -> {
      io.println("Player created\n")
      turn(universe, player)
    }
    Error(e) -> {
      io.println("Failed to create player: " <> e)
      stop()
    }
  }
}

pub fn turn(universe: universe.Universe, player: player.Player) {
  let updated_player = player_turn(universe, player)
  npc_turn(universe, updated_player)
  environment_turn(universe, updated_player)
  turn(universe, updated_player)
}

pub fn player_turn(
  universe: universe.Universe,
  player: player.Player,
) -> player.Player {
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
  io.println("  Q - Quit")
  io.print("> ")

  // Get command and convert to uppercase for case-insensitive matching
  let command = string.uppercase(string.trim(get_line("")))

  // Handle empty input first
  case command == "" {
    True -> player
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
          player
        }
        // Quit command
        "Q" -> {
          io.println("Quitting\n")
          stop()
        }
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
                          updated_player
                        }
                        Error(e) -> {
                          io.println("Error: " <> e)
                          player
                        }
                      }
                    False -> {
                      case distance == 0 {
                        True -> {
                          io.println("Error: You're already at that location!")
                          player
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
                          player
                        }
                      }
                    }
                  }
                }
                _, _ -> {
                  io.println("Invalid coordinates")
                  player
                }
              }
            }
            _ -> {
              io.println("Invalid input format. Please use X:Y")
              player
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
                  updated_player
                }
                Error(_) -> {
                  io.println(
                    "Invalid speed command. Use T# where # is a number.",
                  )
                  player
                }
              }
            }
            _ -> {
              io.println("Unknown command")
              player
            }
          }
        }
      }
    }
  }
}

pub fn npc_turn(_universe: universe.Universe, player: player.Player) {
  io.println("NPC's turn\n")
  player
  // Return the player unchanged
}

pub fn environment_turn(_universe: universe.Universe, player: player.Player) {
  // Environment turn logic will go here
  player
}
