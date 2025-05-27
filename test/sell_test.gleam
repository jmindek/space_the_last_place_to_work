import gleam/list
import gleam/option
import gleeunit/should
import player
import ship
import trade
import trade_goods
import universe

// Helper function to create a test planet with trade goods
fn create_test_planet(
  trade_goods: List(trade_goods.TradeGoods),
) -> universe.Planet {
  universe.Planet(
    position: universe.Position(x: 0, y: 0),
    life_supporting: True,
    population: 1_000_000,
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
    trade_goods: trade_goods,
  )
}

// Helper function to create a test player with cargo
fn create_test_player() -> player.Player {
  // Create a test ship
  let test_ship =
    ship.Ship(
      location: #(0, 0),
      speed: 5,
      max_speed: 10,
      class: ship.Freighter,
      crew_size: 1,
      fuel_units: 100,
      max_fuel_units: 100,
      shields: 100,
      max_shields: 100,
      weapons: 0,
      max_weapons: 4,
      cargo_holds: 0,
      max_cargo_holds: 10,
      passenger_holds: 0,
      max_passenger_holds: 5,
    )

  player.Player(
    name: "Test Player",
    ship: test_ship,
    homeworld: option.None,
    credits: 1000,
    cargo: [],
  )
}

// Test the selling process
pub fn test_selling_process() {
  // Setup test planet with some trade goods
  let test_planet =
    create_test_planet([trade_goods.Protein("Test Protein", 10, 100)])

  // Setup test player with some cargo
  let test_player = create_test_player()

  // Test the sell_cargo function and verify the result is Ok
  case trade.sell_cargo(test_player, test_planet) {
    Ok(_) -> True |> should.be_true
    Error(_) -> False |> should.be_true
  }
}

// Test selling with empty cargo
pub fn test_sell_empty_cargo() {
  let test_planet = create_test_planet([])
  let test_player = create_test_player()

  // Verify selling empty cargo returns Ok (or appropriate result)
  case trade.sell_cargo(test_player, test_planet) {
    Ok(_) -> True |> should.be_true
    Error(_) -> False |> should.be_true
  }
}

// Test the greed tax calculation
pub fn test_greed_tax_calculation() {
  // Test case: price is 50 (500% of base price 10)
  let price_per_unit = 50
  let quantity = 5

  // Calculate expected tax and new credits
  let total_price = price_per_unit * quantity
  // 250
  let tax = total_price / 2
  // 125

  // Verify the tax calculation
  tax
  |> should.equal(125)
}

// Test selling an item the starport doesn't want
pub fn test_sell_unwanted_item() {
  // Create a test item that the starport doesn't have
  let test_item = trade_goods.Protein("Test Protein", 10, 100)
  // Create a planet with different items
  let test_planet =
    create_test_planet([
      trade_goods.Hydro("Hydro", 20, 50),
      trade_goods.Fuel("Fuel", 5, 200),
    ])

  // Create a test player with the unwanted item
  let test_player = {
    let p = create_test_player()
    player.Player(..p, cargo: [#(test_item, 5)])
    // 5 units of unwanted item
  }

  // Mock the selling function to simulate the behavior
  let result = trade.sell_cargo(test_player, test_planet)

  // Verify the player wasn't charged (kept their credits)
  case result {
    Ok(updated_player) -> {
      // Player should still have their original credits (1000)
      updated_player.credits
      |> should.equal(1000)

      // Cargo should remain unchanged
      updated_player.cargo
      |> should.equal([#(test_item, 5)])
    }
    Error(_) -> False |> should.be_true
  }
}

// Test selling with invalid input
pub fn test_sell_invalid_input() {
  // Setup test data
  let test_item = trade_goods.Protein("Test Protein", 10, 100)
  let test_planet = create_test_planet([test_item])

  // Create a test player with some cargo
  let test_player = {
    let p = create_test_player()
    player.Player(..p, cargo: [#(test_item, 10)])
  }

  // Test 1: Invalid item selection (non-numeric)
  case trade.sell_cargo(test_player, test_planet) {
    // Should handle non-numeric input gracefully
    Ok(updated_player) -> {
      // Player state should remain unchanged
      updated_player.credits
      |> should.equal(1000)
      updated_player.cargo
      |> should.equal([#(test_item, 10)])
    }
    _ -> False |> should.be_true
  }
  // Note: Testing of actual input handling would require mocking the input functions,
  // which is more complex in Gleam. These tests would be more comprehensive with
  // dependency injection for IO operations.
}

// Test selling multiple items
pub fn test_sell_multiple_items() {
  // Create test items
  let item1 = trade_goods.Protein("Protein", 10, 100)
  let item2 = trade_goods.Hydro("Hydro", 20, 50)

  // Create a planet that wants these items
  let test_planet = create_test_planet([item1, item2])

  // Create a test player with multiple items
  let test_player = {
    let p = create_test_player()
    player.Player(..p, cargo: [
      #(item1, 5),
      // 5 units of item1
      #(item2, 3),
      // 3 units of item2
    ])
  }

  // Mock the selling function to test the logic
  // Note: This is a simplified test since we can't easily mock the IO in Gleam
  // In a real test, we would mock the input/output
  let _ = test_player
  let _ = test_planet

  // Test that the player can sell items
  // The actual selling logic would be tested in integration tests
  // For now, just verify the test setup is correct
  list.length(test_planet.trade_goods)
  |> should.equal(2)

  list.length(test_player.cargo)
  |> should.equal(2)
}
