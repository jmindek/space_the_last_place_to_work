import gleam/io
import gleam/list
import player
import trade
import universe

// Update all trade goods on a planet with price fluctuations
fn update_planet_prices(planet: universe.Planet) -> universe.Planet {
  let updated_goods = list.map(planet.trade_goods, trade.fluctuate_price)
  universe.Planet(
    position: planet.position,
    life_supporting: planet.life_supporting,
    population: planet.population,
    water_percentage: planet.water_percentage,
    oxygen_percentage: planet.oxygen_percentage,
    gravity: planet.gravity,
    industry: planet.industry,
    mapping_percentage: planet.mapping_percentage,
    name: planet.name,
    moons: planet.moons,
    has_starport: planet.has_starport,
    has_ftl_lane: planet.has_ftl_lane,
    trade_allowed: planet.trade_allowed,
    trade_goods: updated_goods,
  )
}

pub fn environment_turn(
  universe: universe.Universe,
  player: player.Player,
) -> #(player.Player, universe.Universe) {
  io.println("Environment's turn - updating trade good prices...")

  // Update prices on all planets
  let updated_planets = list.map(universe.planets, update_planet_prices)
  let updated_universe =
    universe.Universe(size: universe.size, planets: updated_planets)

  // Return both the player and the updated universe
  #(
    player.Player(
      name: player.name,
      ship: player.ship,
      homeworld: player.homeworld,
      credits: player.credits,
      cargo: player.cargo,
    ),
    updated_universe,
  )
}
