import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import trade_goods

// The size of the universe grid
pub const universe_width = 50

pub const universe_height = 50

pub type IndustryType {
  Agra
  Mining
  Terraforming
  Technology
  Cloning
  Shipyard
  Classified
  Undefined
}

pub type Position {
  Position(x: Int, y: Int)
}

pub type Planet {
  Planet(
    position: Position,
    life_supporting: Bool,
    population: Int,
    water_percentage: Int,
    oxygen_percentage: Int,
    gravity: Float,
    industry: IndustryType,
    mapping_percentage: Int,
    name: String,
    moons: Int,
    has_starport: Bool,
    has_ftl_lane: Bool,
    trade_allowed: Bool,
    trade_goods: List(trade_goods.TradeGoods),
  )
}

pub fn industry_to_string(industry: IndustryType) -> String {
  case industry {
    Agra -> "Agriculture"
    Mining -> "Mining"
    Terraforming -> "Terraforming"
    Technology -> "Technology"
    Cloning -> "Cloning"
    Shipyard -> "Shipyard"
    Classified -> "Classified"
    Undefined -> "Undefined"
  }
}

pub type Universe {
  Universe(size: Int, planets: List(Planet))
}

fn random_industry() -> IndustryType {
  let industries = [
    Agra,
    Mining,
    Terraforming,
    Technology,
    Cloning,
    Shipyard,
    Classified,
    Undefined,
  ]
  // Get a random industry using list.drop and pattern matching
  let index =
    int.remainder(int.random(1000), 8)
    // 8 industry types
    |> result.unwrap(0)

  // Use list.drop to get a sublist starting at the random index
  // Then take the first element if it exists, otherwise default to Uncharted
  case list.drop(industries, index) {
    [industry, ..] -> industry
    _ -> Undefined
  }
}

fn generate_planet_name() -> String {
  let prefix = [
    "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta",
  ]
  let suffix = ["Prime", "Minor", "Major", "Secundus", "Tertius", "Rex", "Nova"]

  // Get a random prefix using list.drop and pattern matching
  let prefix_index =
    int.remainder(int.random(1000), list.length(prefix))
    |> result.unwrap(0)
  let prefix = case list.drop(prefix, prefix_index) {
    [p, ..] -> p
    _ -> "Alpha"
  }

  // Get a random suffix using list.drop and pattern matching
  let suffix_index =
    int.remainder(int.random(1000), list.length(suffix))
    |> result.unwrap(0)
  let suffix = case list.drop(suffix, suffix_index) {
    [s, ..] -> s
    _ -> "Prime"
  }
  let number = int.to_string(int.random(999))

  string.concat([prefix, "-", number, "-", suffix])
}

pub fn random_bool() -> Bool {
  // int.random(n) generates a number from 0 to n-1
  // So int.random(2) will return either 0 or 1
  int.random(2) == 1
}

pub fn generate_planet(size: Int) -> Planet {
  // Ensure coordinates are within universe bounds (0 to universe_width-1 and 0 to universe_height-1)
  let x = int.random(universe_width)
  let y = int.random(universe_height)

  Planet(
    position: Position(x: x, y: y),
    life_supporting: random_bool(),
    population: int.random(2_147_483_647),
    water_percentage: int.random(100),
    oxygen_percentage: int.random(100),
    gravity: float.divide(int.to_float(int.random(100)), 100.0)
      |> result.unwrap(1.0),
    industry: random_industry(),
    mapping_percentage: int.random(100),
    name: generate_planet_name(),
    moons: int.random(9),
    has_starport: random_bool(),
    has_ftl_lane: random_bool(),
    trade_allowed: random_bool(),
    trade_goods: trade_goods.generate_trade_goods(),
  )
}

fn is_position_taken(position: Position, planets: List(Planet)) -> Bool {
  list.any(planets, fn(planet) {
    case planet.position {
      Position(x: x, y: y) if x == position.x && y == position.y -> True
      _ -> False
    }
  })
}

fn generate_unique_planet(size: Int, existing_planets: List(Planet)) -> Planet {
  let planet = generate_planet(size)
  case is_position_taken(planet.position, existing_planets) {
    True -> generate_unique_planet(size, existing_planets)
    False -> planet
  }
}

fn generate_planets(count: Int, size: Int, acc: List(Planet)) -> List(Planet) {
  case count {
    0 -> acc
    _ -> {
      let planet = generate_unique_planet(size, acc)
      generate_planets(count - 1, size, [planet, ..acc])
    }
  }
}

pub fn create_universe(size: Int, num_planets: Int) -> Universe {
  Universe(size: size, planets: generate_planets(num_planets, size, []))
}
