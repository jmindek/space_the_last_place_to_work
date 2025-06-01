import environment_turn
import game_types
import gleam/io
import gleam/list
import gleam/option
import npc_turn
import player
import player_turn
import ship
import title_screen
import universe
import utils

pub fn main() -> Result(Nil, String) {
  // Display the colored title screen
  title_screen.display_title_screen_clean()

  // Show prompt and wait for user input
  case
    utils.with_quit_prompt(
      "\n                    Enter any key to play. Q to quit. > ",
      fn() -> Result(Nil, String) {
        // Clear the screen after user input
        io.print("\u{001b}[2J\u{001b}[H")
        // Continue with the game
        Ok(Nil)
      },
    )
  {
    Ok(Nil) -> {
      // User continued, initialize the game
      let universe = universe.create_universe(100, 20)

      // Create a player with a default ship class
      case player.new("Player_1", ship.Freighter) {
        Ok(p) -> {
          // Find a suitable starting planet with a starport
          let starting_planet =
            list.find(universe.planets, fn(planet) { planet.has_starport })

          case starting_planet {
            Ok(planet) -> {
              // Position the player at the starting planet
              let updated_ship =
                ship.move_ship(
                  p.ship,
                  planet.position.x,
                  planet.position.y,
                  universe.size,
                )
              let player =
                player.Player(
                  name: p.name,
                  ship: updated_ship,
                  homeworld: option.Some(planet),
                  credits: p.credits,
                  cargo: p.cargo,
                )

              // Start the game loop
              game_loop(universe, player)
              Ok(Nil)
            }
            Error(_) -> Error("No starting planet with starport found")
          }
        }
        Error(e) -> Error("Failed to create player: " <> e)
      }
    }
    Error(e) -> Error(e)
  }
}

fn game_loop(universe: universe.Universe, player: player.Player) -> Nil {
  case turn(universe, player) {
    game_types.Continue(updated_player, updated_universe) ->
      game_loop(updated_universe, updated_player)
    game_types.Quit -> io.println("\nThanks for playing!")
  }
}

// Handle a single turn of the game
fn turn(
  universe: universe.Universe,
  player: player.Player,
) -> game_types.GameState {
  case player_turn.player_turn(universe, player) {
    game_types.Continue(updated_player, updated_universe) -> {
      let next_player = npc_turn.npc_turn(updated_universe, updated_player)
      let #(next_player, updated_universe) =
        environment_turn.environment_turn(updated_universe, next_player)
      game_types.Continue(next_player, updated_universe)
    }
    game_types.Quit -> game_types.Quit
  }
}
