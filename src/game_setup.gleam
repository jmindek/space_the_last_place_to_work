import game_types
import gleam/option
import player
import ship
import universe

pub fn setup() -> Result(game_types.GameState, String) {
  let universe = universe.create_universe(100, 60)

  // Find the first planet to use as homeworld
  let homeworld = case universe.planets {
    [first_planet, ..] -> first_planet
    _ ->
      // Create a default homeworld if no planets exist
      universe.Planet(
        position: universe.Position(x: 50, y: 50),
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
  let player_ship =
    ship.Ship(
      location: #(homeworld.position.x, homeworld.position.y),
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

  Ok(game_types.Continue(player, universe))
}
