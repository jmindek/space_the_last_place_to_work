import game_types
import gleam/option
import npc
import player
import ship
import universe

pub fn setup() -> Result(game_types.GameState, String) {
  let universe =
    universe.create_universe(universe.universe_width, universe.universe_height)

  // Find the first planet to use as homeworld
  let homeworld = case universe.planets {
    [first_planet, ..] -> first_planet
    _ ->
      // Create a default homeworld if no planets exist
      universe.Planet(
        position: universe.Position(
          x: universe.universe_width / 2,
          y: universe.universe_height / 2,
        ),
        life_supporting: True,
        population: 1000,
        water_percentage: 80,
        oxygen_percentage: 21,
        gravity: 1.0,
        industry: universe.Agra,
        mapping_percentage: 100,
        name: "Earth",
        moons: 1,
        has_starport: True,
        has_ftl_lane: True,
        trade_allowed: True,
        trade_goods: [],
      )
  }

  // Create player's ship
  // Ensure homeworld position is wrapped within universe bounds
  let wrap_coord = fn(coord: Int, size: Int) -> Int {
    let mod = coord % size
    case mod < 0 {
      True -> mod + size
      False -> mod
    }
  }

  let home_x = wrap_coord(homeworld.position.x, universe.universe_width)
  let home_y = wrap_coord(homeworld.position.y, universe.universe_height)

  let player_ship =
    ship.Ship(
      location: #(home_x, home_y),
      previous_location: #(home_x, home_y),
      // Initialize with same as current location
      speed: 0,
      max_speed: 10,
      class: ship.Freighter,
      crew_size: 4,
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

  // Create player
  let player =
    player.Player(
      name: "Player",
      ship: player_ship,
      homeworld: option.Some(homeworld),
      credits: 1000,
      cargo: [],
    )

  let npc_ships =
    npc.generate_npc_ships(
      100,
      universe.universe_width,
      universe.universe_height,
    )

  Ok(game_types.Continue(player, universe, option.Some(npc_ships)))
}
