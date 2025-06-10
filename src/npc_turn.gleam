import gleam/io
import gleam/list
import ship
import universe
import utils

/// Move an NPC ship randomly within the universe bounds
fn move_ship_randomly(ship: ship.Ship) -> ship.Ship {
  // Generate random direction (0-7, representing 8 cardinal/intercardinal directions)
  let direction = utils.random_range(0, 7)

  // Calculate new position based on direction and distance
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

  // Generate random distance (1-10)
  let distance = utils.random_range(1, 10)

  // Calculate new position
  let new_x = ship.location.0 + dx * distance
  let new_y = ship.location.1 + dy * distance

  // Use modulo to wrap around universe bounds
  let wrap = fn(coord: Int, size: Int) -> Int {
    let mod = coord % size
    case mod < 0 {
      True -> mod + size
      False -> mod
    }
  }

  let wrapped_x = wrap(new_x, universe.universe_width)
  let wrapped_y = wrap(new_y, universe.universe_height)

  // Update ship's location with wrapped coordinates
  // Using universe_width for both dimensions since move_ship expects a single size parameter
  ship.move_ship(ship, wrapped_x, wrapped_y, universe.universe_width)
}

pub fn npc_turn(npc_ships: List(ship.Ship)) -> List(ship.Ship) {
  io.println("NPC's turn\n")

  // Move each NPC ship randomly
  list.map(npc_ships, fn(ship) { move_ship_randomly(ship) })
}
