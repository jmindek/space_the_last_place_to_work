import gleam/option.{type Option}
import player
import ship
import universe

// Game state type to represent the game's state
pub type GameState {
  Continue(
    player: player.Player,
    universe: universe.Universe,
    npc_ships: Option(List(ship.Ship)),
  )
  Quit
}
