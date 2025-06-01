import gleam/io
import player
import universe

pub fn npc_turn(
  _universe: universe.Universe,
  player: player.Player,
) -> player.Player {
  io.println("NPC's turn\n")
  // NPC turn logic will go here
  player
}
