import gleam/int
import gleam/io
import gleam/list
import ship
import universe
import utils

/// Move an NPC ship randomly within the universe bounds
fn move_ship_randomly(ship: ship.Ship, universe: universe.Universe) -> ship.Ship {
  // Generate random direction (0-7, representing 8 cardinal/intercardinal directions)
  let direction = utils.random_range(0, 7)
  // Generate random distance (1-10)
  let distance = utils.random_range(1, 10)

  // Calculate new position based on direction
  let #(dx, dy) = case direction {
    0 -> #(0, -1)
    // N
    1 -> #(1, -1)
    // NE
    2 -> #(1, 0)
    // E
    3 -> #(1, 1)
    // SE
    4 -> #(0, 1)
    // S
    5 -> #(-1, 1)
    // SW
    6 -> #(-1, 0)
    // W
    _ -> #(-1, -1)
    // NW
  }

  // Calculate new position
  let new_x = ship.location.0 + dx * distance
  let new_y = ship.location.1 + dy * distance

  // Ensure position is within universe bounds
  let bounded_x = int.max(0, int.min(new_x, universe.size - 1))
  let bounded_y = int.max(0, int.min(new_y, universe.size - 1))

  // Update ship's location with proper coordinates and universe size
  ship.move_ship(ship, bounded_x, bounded_y, universe.size)
}

pub fn npc_turn(
  universe: universe.Universe,
  npc_ships: List(ship.Ship),
) -> List(ship.Ship) {
  io.println("NPC's turn\n")

  // Move each NPC ship randomly
  list.map(npc_ships, fn(ship) { move_ship_randomly(ship, universe) })
}
