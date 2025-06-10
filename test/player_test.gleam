import gleam/list
import gleam/option
import gleam/string
import gleeunit/should
import player
import ship
import trade_goods
import universe

// Helper function to create a test player
fn create_test_player() -> Result(player.Player, String) {
  player.new("TestPlayer", ship.Shuttle)
}

// Helper function to create a test universe with some planets
fn create_test_universe() -> universe.Universe {
  let planets = [
    universe.Planet(
      position: universe.Position(1, 1),
      life_supporting: True,
      population: 1000,
      water_percentage: 70,
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
    ),
    universe.Planet(
      position: universe.Position(5, 5),
      life_supporting: False,
      population: 0,
      water_percentage: 0,
      oxygen_percentage: 0,
      gravity: 0.38,
      industry: universe.Mining,
      mapping_percentage: 100,
      name: "Mars",
      moons: 2,
      has_starport: False,
      has_ftl_lane: False,
      trade_allowed: False,
      trade_goods: [],
    ),
    universe.Planet(
      position: universe.Position(3, 3),
      life_supporting: True,
      population: 5000,
      water_percentage: 80,
      oxygen_percentage: 22,
      gravity: 0.9,
      industry: universe.Technology,
      mapping_percentage: 100,
      name: "New Terra",
      moons: 0,
      has_starport: True,
      has_ftl_lane: True,
      trade_allowed: True,
      trade_goods: [],
    ),
  ]
  universe.Universe(planets: planets)
}

pub fn new_player_test() {
  // Test valid name
  case create_test_player() {
    Ok(p) -> {
      p.name
      |> should.equal("TestPlayer")
      p.credits
      |> should.equal(1000)
    }
    Error(_) -> should.fail()
  }

  // Test invalid name (too long)
  case
    player.new(
      "ThisNameIsWayTooLongAndShouldNotBeAllowedInTheGameAtAllBecauseItExceedsTheMaximumLength",
      ship.Shuttle,
    )
  {
    Ok(_) -> should.fail()
    Error(e) ->
      string.contains(e, "must be 1-64 characters")
      |> should.be_true
  }
}

pub fn set_homeworld_test() -> Nil {
  let test_universe = create_test_universe()

  case create_test_player() {
    Ok(p) ->
      case
        list.find(test_universe.planets, fn(planet) { planet.name == "Earth" })
      {
        Ok(earth) ->
          case player.set_homeworld(p, earth) {
            Ok(updated) ->
              case updated.homeworld {
                option.Some(planet) -> {
                  planet.name
                  |> should.equal("Earth")
                  planet.has_starport
                  |> should.be_true
                }
                _ -> should.fail()
              }
            Error(_) -> should.fail()
          }
        Error(_) -> should.fail()
      }
    Error(_) -> should.fail()
  }
}

pub fn move_ship_test() -> Nil {
  case create_test_player() {
    Ok(p) -> {
      // Test moving within bounds
      case player.move_ship(p, 5, 5) {
        Ok(updated) ->
          case updated.ship.location {
            #(x, y) ->
              check_coordinates(
                x,
                y,
                universe.universe_width,
                universe.universe_height,
              )
          }
        Error(_) -> should.fail()
      }

      // Test wrapping around the universe
      case player.move_ship(p, -1, 11) {
        Ok(wrapped) ->
          case wrapped.ship.location {
            #(wx, wy) ->
              check_coordinates(
                wx,
                wy,
                universe.universe_width,
                universe.universe_height,
              )
          }
        Error(_) -> should.fail()
      }
    }
    Error(_) -> should.fail()
  }
}

fn check_coordinates(x: Int, y: Int, width: Int, height: Int) -> Nil {
  // Verify coordinates are within bounds using pattern matching
  case x >= 0 {
    True ->
      case x < width {
        True ->
          case y >= 0 {
            True ->
              case y < height {
                True -> Nil
                False -> should.fail()
              }
            False -> should.fail()
          }
        False -> should.fail()
      }
    False -> should.fail()
  }
}

pub fn cargo_display_test() -> Nil {
  // Create test cargo items
  let protein = trade_goods.Protein("Test Protein", 10, 5)
  let fuel = trade_goods.Fuel("Test Fuel", 20, 1)

  // Test with non-empty cargo
  let test_cargo = [
    #(protein, 3),
    // 3 units of protein
    #(fuel, 2),
    // 2 units of fuel
  ]

  // Calculate total cargo
  let total_cargo =
    test_cargo
    |> list.map(fn(pair: #(trade_goods.TradeGoods, Int)) { pair.1 })
    |> list.fold(0, fn(quantity, acc) { acc + quantity })

  // Verify the total is calculated correctly
  total_cargo
  |> should.equal(5)

  // Test with empty cargo
  let empty_cargo = []
  let empty_total =
    empty_cargo
    |> list.map(fn(pair: #(trade_goods.TradeGoods, Int)) { pair.1 })
    |> list.fold(0, fn(quantity, acc) { acc + quantity })

  empty_total
  |> should.equal(0)
}
