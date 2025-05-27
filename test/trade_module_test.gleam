import gleam/io
import gleam/list
import gleam/option
import gleam/result

import player
import ship
import trade
import trade_goods
import universe

// Helper function to create a test planet with trade goods
fn create_test_planet(goods: List(trade_goods.TradeGoods)) -> universe.Planet {
  universe.Planet(
    position: universe.Position(0, 0),
    life_supporting: True,
    population: 1000,
    water_percentage: 70,
    oxygen_percentage: 21,
    gravity: 1.0,
    industry: universe.Agra,
    mapping_percentage: 100,
    name: "Test Planet",
    moons: 1,
    has_starport: True,
    has_ftl_lane: True,
    trade_allowed: True,
    trade_goods: goods,
  )
}

// Helper function to create a test player
fn create_test_player(
  credits: Int,
  cargo: List(#(trade_goods.TradeGoods, Int)),
) -> player.Player {
  let ship =
    ship.Ship(
      location: #(0, 0),
      speed: 1,
      max_speed: 10,
      class: ship.Freighter,
      crew_size: 4,
      fuel_units: 100,
      max_fuel_units: 100,
      shields: 0,
      max_shields: 100,
      weapons: 0,
      max_weapons: 4,
      cargo_holds: list.length(cargo),
      max_cargo_holds: 10,
      passenger_holds: 0,
      max_passenger_holds: 0,
    )

  player.Player(
    name: "Test Player",
    ship: ship,
    homeworld: option.None,
    credits: credits,
    cargo: cargo,
  )
}

// Test that trading menu shows available goods and handles basic navigation
pub fn test_show_trade_menu() -> Result(Nil, String) {
  // Create test trade goods
  let test_goods = [
    trade_goods.Protein("Test Protein", 100, 50),
    trade_goods.Fuel("Test Fuel", 50, 200),
  ]

  // Create test planet and player
  let planet = create_test_planet(test_goods)
  let test_player = create_test_player(1000, [])

  // Call the function with parameters in correct order (player, planet)
  case trade.show_trade_menu(test_player, planet) {
    Ok(updated_player) -> {
      // Verify the player object is returned unchanged (since no buying/selling is implemented yet)
      case updated_player.credits == test_player.credits {
        True -> Ok(Nil)
        False ->
          Error("Player credits should not change in current implementation")
      }
    }
    Error(e) -> Error("show_trade_menu failed: " <> e)
  }
}

// Test that the trade menu shows the correct credits
pub fn test_show_credits() -> Result(Nil, String) {
  let test_goods = []
  let planet = create_test_planet(test_goods)

  // Test with different credit amounts
  let test_cases = [1000, 500, 0, 9999]

  let results =
    list.map(test_cases, fn(credits) {
      let test_player = create_test_player(credits, [])
      trade.show_trade_menu(test_player, planet)
    })

  // Check if any test failed
  case list.find(results, result.is_error) {
    Ok(Error(e)) -> Error("Test failed with error: " <> e)
    _ -> Ok(Nil)
  }
}

// Test with different cargo loads
pub fn test_with_cargo() -> Result(Nil, String) {
  let test_goods = [trade_goods.Protein("Test Protein", 100, 50)]
  let planet = create_test_planet(test_goods)

  // Test with different cargo loads
  let test_cases = [
    [],
    // Empty cargo
    [#(trade_goods.Protein("Test Protein", 0, 0), 5)],
    // 5 units of protein
    [
      #(trade_goods.Protein("Test Protein", 0, 0), 5),
      #(trade_goods.Fuel("Test Fuel", 0, 0), 10),
    ],
    // Multiple items
  ]

  let results =
    list.map(test_cases, fn(cargo) {
      let test_player = create_test_player(1000, cargo)
      trade.show_trade_menu(test_player, planet)
    })

  // Check if any test failed
  case list.find(results, result.is_error) {
    Ok(Error(e)) -> Error("Test failed with error: " <> e)
    _ -> Ok(Nil)
  }
}

// Test successful purchase
fn test_successful_purchase() -> Result(Nil, String) {
  // Create a test good with price 10 and quantity 5
  let test_good = trade_goods.Protein("Test Protein", 10, 5)
  let planet = create_test_planet([test_good])
  let player = create_test_player(100, [])
  // 100 credits, empty cargo

  // Attempt to buy 2 units (cost: 20 credits)
  case trade.process_purchase(player, planet, test_good, 2) {
    Ok(updated_player) -> {
      // Check credits were deducted (100 - 20 = 80)
      case updated_player.credits == 80 {
        True -> {
          // Check cargo was updated
          case updated_player.cargo {
            [#(trade_goods.Protein("Test Protein", _, _), 2)] -> {
              // Check ship's cargo_holds was updated
              case updated_player.ship.cargo_holds == 2 {
                True -> Ok(Nil)
                False -> Error("Cargo holds not updated correctly")
              }
            }
            _ -> Error("Cargo not updated correctly")
          }
        }
        False -> Error("Credits not deducted correctly")
      }
    }
    Error(e) -> Error("Purchase failed: " <> e)
  }
}

// Test purchase with insufficient credits
fn test_insufficient_credits() -> Result(Nil, String) {
  let test_good = trade_goods.Protein("Expensive", 100, 5)
  let planet = create_test_planet([test_good])
  let player = create_test_player(50, [])
  // Only 50 credits

  // Attempt to buy 1 unit (cost: 100 credits)
  case trade.process_purchase(player, planet, test_good, 1) {
    Ok(_) -> Error("Purchase should have failed due to insufficient credits")
    Error(_) -> Ok(Nil)
  }
}

// Test purchase with insufficient cargo space
fn test_insufficient_cargo_space() -> Result(Nil, String) {
  let test_good = trade_goods.Protein("Bulky", 10, 10)
  let planet = create_test_planet([test_good])

  // Create a ship with max_cargo_holds = 1
  let test_ship =
    ship.Ship(
      location: #(0, 0),
      speed: 1,
      max_speed: 10,
      class: ship.Freighter,
      crew_size: 4,
      fuel_units: 100,
      max_fuel_units: 100,
      shields: 0,
      max_shields: 100,
      weapons: 0,
      max_weapons: 4,
      cargo_holds: 1,
      // Already has 1 unit in cargo
      max_cargo_holds: 1,
      // Can only hold 1 unit total
      passenger_holds: 0,
      max_passenger_holds: 0,
    )

  // Create player with the test ship and 1 unit in cargo
  let player =
    player.Player(
      name: "Test Player",
      ship: test_ship,
      homeworld: option.None,
      credits: 1000,
      cargo: [#(test_good, 1)],
    )

  // Attempt to buy 1 more unit (would exceed cargo capacity)
  case trade.process_purchase(player, planet, test_good, 1) {
    Ok(_) ->
      Error("Purchase should have failed due to insufficient cargo space")
    Error(_) -> Ok(Nil)
  }
}

// Test purchase with insufficient stock
fn test_insufficient_stock() -> Result(Nil, String) {
  let test_good = trade_goods.Protein("Rare", 10, 1)
  // Only 1 in stock
  let planet = create_test_planet([test_good])
  let player = create_test_player(100, [])
  // 100 credits, empty cargo

  // Attempt to buy 2 units
  case trade.process_purchase(player, planet, test_good, 2) {
    Ok(_) -> Error("Purchase should have failed due to insufficient stock")
    Error(_) -> Ok(Nil)
  }
}

// Run all tests
pub fn main() {
  io.println("Running trade module tests...\n")

  let tests = [
    #("test_show_trade_menu", test_show_trade_menu()),
    #("test_show_credits", test_show_credits()),
    #("test_with_cargo", test_with_cargo()),
    #("test_successful_purchase", test_successful_purchase()),
    #("test_insufficient_credits", test_insufficient_credits()),
    #("test_insufficient_cargo_space", test_insufficient_cargo_space()),
    #("test_insufficient_stock", test_insufficient_stock()),
  ]

  let results =
    list.map(tests, fn(t) {
      case t {
        #(name, result) -> {
          case result {
            Ok(_) -> #(name, "PASSED")
            Error(e) -> #(name, "FAILED: " <> e)
          }
        }
      }
    })

  io.println("\nTest Results:")
  list.each(results, fn(t) {
    case t {
      #(name, status) -> io.println(name <> ": " <> status)
    }
  })
}
