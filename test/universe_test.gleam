import gleam/list
import gleam/string
import gleeunit/should
import universe
import universe as universe_types

pub fn random_bool_test() {
  // Since random_bool is non-deterministic, we'll test it multiple times
  // to ensure it can produce both true and false values
  let results =
    list.range(0, 100)
    |> list.map(fn(_) { universe.random_bool() })

  // Check that we have at least one true and one false
  let has_true = list.any(results, fn(x) { x == True })
  let has_false = list.any(results, fn(x) { x == False })

  should.be_true(has_true)
  should.be_true(has_false)
}

pub fn generate_planet_test() {
  // When
  let planet = universe.generate_planet()

  // Then - verify the planet structure and constraints
  should.be_true(planet.position.x >= 0)
  should.be_true(planet.position.x < universe.universe_width)
  should.be_true(planet.position.y >= 0)
  should.be_true(planet.position.y < universe.universe_height)

  // Test population bounds
  should.be_true(planet.population >= 0)
  should.be_true(planet.population <= 2_147_483_647)

  // Test percentage bounds
  should.be_true(planet.water_percentage >= 0)
  should.be_true(planet.water_percentage <= 100)

  should.be_true(planet.oxygen_percentage >= 0)
  should.be_true(planet.oxygen_percentage <= 100)

  should.be_true(planet.mapping_percentage >= 0)
  should.be_true(planet.mapping_percentage <= 100)

  // Test gravity is between 0.0 and 1.0
  should.be_true(planet.gravity >=. 0.0)
  should.be_true(planet.gravity <=. 1.0)

  // Test moons count
  should.be_true(planet.moons >= 0)
  should.be_true(planet.moons <= 8)
  // 0 to 8 inclusive is 9 possible values

  // Test name format (starts with a letter, contains numbers and dashes)
  should.be_true(string.length(planet.name) > 0)

  // Test industry type is valid
  let valid_industries = [
    universe_types.Agra,
    universe_types.Mining,
    universe_types.Terraforming,
    universe_types.Technology,
    universe_types.Cloning,
    universe_types.Shipyard,
    universe_types.Classified,
    universe_types.Undefined,
  ]
  should.be_true(list.any(valid_industries, fn(i) { i == planet.industry }))
}
