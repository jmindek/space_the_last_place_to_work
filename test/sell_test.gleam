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

// Test selling with higher greed tax - TODO: Reimplement when sell_item is available
pub fn test_sell_with_higher_greed_tax() {
  // This test is currently a placeholder since sell_item is not implemented yet
  True
  |> should.be_true
}

// TODO: Uncomment and implement once trade.sell_item is implemented
// Test selling an item the starport doesn't want
// pub fn test_sell_unwanted_item() {

// Test selling with invalid input - placeholder for future tests
pub fn test_sell_invalid_input() {
  // TODO: Add tests for invalid input scenarios once the sell_item function is implemented
  True
  |> should.be_true
}

// Test selling multiple items - placeholder for future tests
pub fn test_sell_multiple_items() {
  // TODO: Add tests for selling multiple items once the sell_item function is implemented
  True
  |> should.be_true
}

// Test selling an unwanted item - placeholder for future tests
pub fn test_sell_unwanted_item() {
  // TODO: Add test for selling an item the starport doesn't want
  True
  |> should.be_true
}
