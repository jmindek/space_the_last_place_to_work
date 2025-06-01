import player
import universe

// Game state type to represent the game's state
pub type GameState {
  Continue(player: player.Player, universe: universe.Universe)
  Quit
}
