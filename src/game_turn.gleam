import environment_turn
import game_types
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import player
import ship
import universe
import utils

pub fn turn(
  universe: universe.Universe,
  player: player.Player,
  npc_ships: List(ship.Ship),
) -> game_types.GameState {
  case player_turn(universe, player, npc_ships) {
    game_types.Continue(updated_player, updated_universe, updated_npc_ships) -> {
      let #(next_player, updated_universe) =
        npc_turn(updated_universe, updated_player)
      let #(next_player, updated_universe) =
        environment_turn.environment_turn(updated_universe, next_player)
      game_types.Continue(next_player, updated_universe, updated_npc_ships)
    }
    game_types.Quit -> game_types.Quit
  }
}

fn player_turn(
  universe: universe.Universe,
  player: player.Player,
  npc_ships: List(ship.Ship),
) -> game_types.GameState {
  let player.Player(name, player_ship, _, credits, cargo) = player
  let #(x, y) = player_ship.location
  let speed = player_ship.speed
  let max_speed = player_ship.max_speed
  let fuel_units = player_ship.fuel_units
  let max_fuel_units = player_ship.max_fuel_units
  let max_cargo_holds = player_ship.max_cargo_holds

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
    "Fuel: "
    <> int.to_string(fuel_units)
    <> "/"
    <> int.to_string(max_fuel_units),
  )
  let total_cargo =
    cargo
    |> list.map(fn(pair) { pair.1 })
    |> list.fold(0, fn(quantity, acc) { acc + quantity })
  io.println(
    "Cargo: "
    <> int.to_string(total_cargo)
    <> "/"
    <> int.to_string(max_cargo_holds),
  )
  io.println(
    "Current speed: " <> int.to_string(speed) <> "/" <> int.to_string(max_speed),
  )
  io.println("\nWhat would you like to do? (H for help)")
  let command = utils.get_trimmed_line("> ")

  // Handle empty input
  case command == "" {
    True -> game_types.Continue(player, universe, option.Some(npc_ships))
    False -> handle_command(command, player, universe, option.Some(npc_ships))
  }
}

fn handle_command(
  command: String,
  player: player.Player,
  universe: universe.Universe,
  npc_ships: option.Option(List(ship.Ship)),
) -> game_types.GameState {
  // Handle commands
  case command {
    // Help
    "H" -> {
      io.println("\nAvailable commands:")
      io.println("H - Show this help")
      io.println("F - Travel via FTL to another planet")
      io.println("Q - Quit to main menu")
      io.println("\nPress Enter to continue...")
      let _ = utils.get_trimmed_line("")
      game_types.Continue(player, universe, npc_ships)
    }
    // FTL Travel
    "F" -> handle_ftl_travel(player, universe, npc_ships)
    // Quit
    "Q" -> game_types.Quit
    // Add other command handlers here...
    _ -> {
      io.println("Unknown command. Type 'H' for help.")
      game_types.Continue(player, universe, npc_ships)
    }
  }
}

fn handle_ftl_travel(
  player: player.Player,
  universe: universe.Universe,
  npc_ships: option.Option(List(ship.Ship)),
) -> game_types.GameState {
  case get_current_planet(player, universe) {
    Ok(_planet) -> {
      let destinations = find_ftl_destinations(player, universe)
      case destinations {
        [] -> {
          io.println("\nNo valid FTL destinations from this location.")
          game_types.Continue(player, universe, npc_ships)
        }
        _ -> {
          io.println("\nAvailable FTL Destinations:")
          // Display each destination with its index
          let display_destinations = fn(dests: List(universe.Planet)) -> Nil {
            let display = fn(planet: universe.Planet, index: Int) -> Nil {
              let universe.Position(px, py) = planet.position
              io.println(string.append(
                int.to_string(index + 1),
                ". "
                  <> planet.name
                  <> " ("
                  <> int.to_string(px)
                  <> ":"
                  <> int.to_string(py)
                  <> ")",
              ))
            }
            list.index_fold(dests, 0, fn(index, planet, _) {
              display(planet, index)
              index + 1
            })
            Nil
          }
          display_destinations(destinations)
          io.println("\nEnter destination number or 'C' to cancel:")
          let input = utils.get_trimmed_line("> ")

          case input {
            "C" -> {
              io.println("FTL travel cancelled.")
              game_types.Continue(player, universe, npc_ships)
            }
            _ ->
              handle_ftl_destination_selection(
                input,
                destinations,
                player,
                universe,
                npc_ships,
              )
          }
        }
      }
    }
    Error(_) -> {
      io.println(
        "\nYou must be at or near a planet with an FTL lane to use FTL travel.",
      )
      game_types.Continue(player, universe, npc_ships)
    }
  }
}

fn handle_ftl_destination_selection(
  input: String,
  destinations: List(universe.Planet),
  player: player.Player,
  universe: universe.Universe,
  npc_ships: option.Option(List(ship.Ship)),
) -> game_types.GameState {
  case int.parse(input) {
    Ok(index) -> {
      // Find destination by index
      case list.at(destinations, index - 1) {
        Ok(destination) -> {
          case ftl_travel(player, destination) {
            Ok(updated_player) -> {
              io.println("Arrived at " <> destination.name <> "!")
              game_types.Continue(updated_player, universe, npc_ships)
            }
            Error(e) -> {
              io.println("FTL travel failed: " <> e)
              game_types.Continue(player, universe, npc_ships)
            }
          }
        }
        Error(_) -> {
          io.println("Invalid selection. FTL travel cancelled.")
          game_types.Continue(player, universe, npc_ships)
        }
      }
    }
    Error(_) -> {
      io.println("Invalid input. Please enter a number.")
      game_types.Continue(player, universe, npc_ships)
    }
  }
}

fn npc_turn(
  universe: universe.Universe,
  player: player.Player,
) -> #(player.Player, universe.Universe) {
  // TODO: Implement NPC turn logic
  #(player, universe)
}

// Environment turn logic is now in the environment_turn module

// Get the current planet the player is at
fn get_current_planet(
  player: player.Player,
  universe: universe.Universe,
) -> Result(universe.Planet, String) {
  let player.Player(_, player_ship, _, _, _) = player
  // player_ship is used in the following line to get the location
  let #(x, y) = player_ship.location
  let _ = player_ship
  // Mark as intentionally unused

  case
    list.find(universe.planets, fn(planet) {
      let universe.Position(px, py) = planet.position
      px == x && py == y
    })
  {
    Ok(planet) -> Ok(planet)
    _ -> Error("You are not at a planet")
  }
}

// Find all planets with FTL lanes that the player can travel to
fn find_ftl_destinations(
  player: player.Player,
  universe: universe.Universe,
) -> List(universe.Planet) {
  // For now, return all planets except the current one
  // In a real implementation, this would check for FTL lanes
  case get_current_planet(player, universe) {
    Ok(current_planet) -> {
      list.filter(universe.planets, fn(planet) {
        planet != current_planet && planet.has_ftl_lane
      })
    }
    Error(_) -> []
  }
}

// Handle FTL travel between planets
fn ftl_travel(
  player: player.Player,
  destination: universe.Planet,
) -> Result(player.Player, String) {
  let player.Player(name, player_ship, homeworld, credits, cargo) = player
  let universe.Position(px, py) = destination.position

  // Move the ship to the destination
  let updated_ship = ship.move_ship(player_ship, px, py, 100)
  // Assuming universe size 100

  // Create a new player with the updated ship
  let updated_player =
    player.Player(
      name: name,
      ship: updated_ship,
      homeworld: homeworld,
      credits: credits,
      cargo: cargo,
    )

  Ok(updated_player)
}
