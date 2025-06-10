import gleam/list
import ship
import utils

/// Generate a list of NPC ships with random positions
pub fn generate_npc_ships(
  count: Int,
  universe_width: Int,
  universe_height: Int,
) -> List(ship.Ship) {
  list.repeat(0, count)
  |> list.map(fn(_) {
    // Generate random position
    let x = utils.random_range(0, universe_width - 1)
    let y = utils.random_range(0, universe_height - 1)

    // Generate random speed
    let speed = utils.random_range(1, 10)

    // Create ship
    ship.Ship(
      location: #(x, y),
      previous_location: #(x, y),
      speed: 0,
      // Start stationary
      max_speed: speed,
      class: ship.Freighter,
      crew_size: 1,
      // Minimal crew
      fuel_units: 100,
      max_fuel_units: 100,
      shields: 0,
      max_shields: 0,
      weapons: 0,
      max_weapons: 5,
      cargo_holds: 0,
      max_cargo_holds: 10,
      passenger_holds: 0,
      max_passenger_holds: 5,
    )
  })
}
