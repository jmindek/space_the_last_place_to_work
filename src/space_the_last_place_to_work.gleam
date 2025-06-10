import environment_turn
import game_types
import gleam/io
import gleam/list
import gleam/option
import npc
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
      let universe = universe.create_universe(20)

      // Create a player with a default ship class
      case player.new("Player_1", ship.Freighter) {
        Ok(p) -> {
          // Find a suitable starting planet with a starport
          let starting_planet =
            list.find(universe.planets, fn(planet) { planet.has_starport })

          case starting_planet {
            Ok(planet) -> {
              // Create a new ship at the planet's location
              let player_ship =
                ship.new_ship(p.ship.class, #(
                  planet.position.x,
                  planet.position.y,
                ))

              let player =
                player.Player(
                  name: p.name,
                  ship: player_ship,
                  homeworld: option.Some(planet),
                  credits: p.credits,
                  cargo: p.cargo,
                )

              let npc_ships =
                npc.generate_npc_ships(
                  50,
                  universe.universe_width,
                  universe.universe_height,
                )

              // Start the game loop
              game_loop(universe, player, npc_ships)
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

fn game_loop(
  universe: universe.Universe,
  player: player.Player,
  npc_ships: List(ship.Ship),
) -> Nil {
  case turn(universe, player, npc_ships) {
    game_types.Continue(
      updated_player,
      updated_universe,
      maybe_updated_npc_ships,
    ) -> {
      case maybe_updated_npc_ships {
        option.Some(updated_npc_ships) ->
          game_loop(updated_universe, updated_player, updated_npc_ships)
        option.None -> game_loop(updated_universe, updated_player, [])
      }
    }
    game_types.Quit -> io.println("\nThanks for playing!")
  }
}

// Handle a single turn of the game
fn turn(
  universe: universe.Universe,
  player: player.Player,
  npc_ships: List(ship.Ship),
) -> game_types.GameState {
  // Process player turn with current NPC ships
  case player_turn.player_turn(universe, player, option.Some(npc_ships)) {
    game_types.Continue(
      updated_player,
      updated_universe,
      _,
      // We'll ignore the NPC ships from player_turn since we'll use our own
    ) -> {
      // Process NPC turn with the current NPC ships
      let moved_npc_ships = npc_turn.npc_turn(npc_ships)

      // Process environment turn
      let #(next_player, final_universe) =
        environment_turn.environment_turn(updated_universe, updated_player)

      // Always pass along the moved NPC ships
      game_types.Continue(
        next_player,
        final_universe,
        option.Some(moved_npc_ships),
      )
    }
    game_types.Quit -> game_types.Quit
  }
}
