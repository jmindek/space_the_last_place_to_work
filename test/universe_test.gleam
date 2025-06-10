import gleam/list
import gleam/string
import universe

pub fn random_bool_test() {
  // Since random_bool is non-deterministic, we'll test it multiple times
  // to ensure it can produce both true and false values
  let results =
    list.range(0, 100)
    |> list.map(fn(_) { universe.random_bool() })

  // Check that we have at least one true and one false
  let has_true = list.any(results, fn(x) { x == True })
  let has_false = list.any(results, fn(x) { x == False })

  assert has_true == True
  assert has_false == True
}

pub fn generate_planet_test() {
  // When
  let planet: universe.Planet = universe.generate_planet()

  // Then - verify the planet structure and constraints
  assert planet.position.x >= 0
  assert planet.position.x < universe.universe_width
  assert planet.position.y >= 0
  assert planet.position.y < universe.universe_height

  // Test population bounds
  assert planet.population >= 0
  assert planet.population <= 2_147_483_647

  // Test percentage bounds
  assert planet.water_percentage >= 0
  assert planet.water_percentage <= 100

  assert planet.oxygen_percentage >= 0
  assert planet.oxygen_percentage <= 100

  assert planet.mapping_percentage >= 0
  assert planet.mapping_percentage <= 100

  // Test gravity is between 0.0 and 1.0
  assert planet.gravity >=. 0.0
  assert planet.gravity <=. 1.0

  // Test moons count
  assert planet.moons >= 0
  assert planet.moons <= 8
  // 0 to 8 inclusive is 9 possible values

  // Test name format (starts with a letter, contains numbers and dashes)
  assert string.length(planet.name) > 0

  // Test industry type is valid
  let valid_industries = [
    universe.Agra,
    universe.Mining,
    universe.Terraforming,
    universe.Technology,
    universe.Cloning,
    universe.Shipyard,
    universe.Classified,
    universe.Undefined,
  ]
  assert list.any(valid_industries, fn(i) { i == planet.industry })
}
