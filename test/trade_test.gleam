import gleam/option
import player
import ship

// Test the greed tax functionality
pub fn greed_tax_test() -> Nil {
  // Create a test player with some credits
  let test_player =
    player.Player(
      name: "TestPlayer",
      ship: ship.Ship(
        location: #(0, 0),
        previous_location: #(0, 0),
        speed: 0,
        max_speed: 10,
        class: ship.Shuttle,
        crew_size: 4,
        fuel_units: 100,
        max_fuel_units: 100,
        shields: 0,
        max_shields: 0,
        weapons: 2,
        max_weapons: 2,
        cargo_holds: 0,
        max_cargo_holds: 10,
        passenger_holds: 0,
        max_passenger_holds: 0,
      ),
      homeworld: option.None,
      credits: 1000,
      cargo: [],
    )

  // TODO: Implement actual test once trade module is updated
  // For now, just verify the test player was created correctly
  assert test_player.credits == 1000
}
