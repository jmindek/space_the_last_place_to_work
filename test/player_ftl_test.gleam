import gleam/option
import gleeunit/should
import player
import ship

// Helper function to create a test player with a ship that has specific fuel values
fn create_test_player_with_fuel(current: Int, max_fuel: Int) -> player.Player {
  let test_ship =
    ship.Ship(
      location: #(0, 0),
      speed: 5,
      max_speed: 10,
      class: ship.Shuttle,
      crew_size: 1,
      fuel_units: current,
      max_fuel_units: max_fuel,
      shields: 5,
      max_shields: 10,
      weapons: 0,
      max_weapons: 0,
      cargo_holds: 0,
      max_cargo_holds: 0,
      passenger_holds: 0,
      max_passenger_holds: 0,
    )
  player.Player(
    name: "Test Player",
    ship: test_ship,
    homeworld: option.None,
    credits: 1000,
    cargo: [],
  )
}

pub fn consume_ftl_fuel_success_test() {
  // Test normal FTL fuel consumption
  let test_player = create_test_player_with_fuel(1000, 5000)

  case player.consume_ftl_fuel(test_player) {
    Ok(updated_player) -> {
      updated_player.ship.fuel_units
      |> should.equal(750)
      // 1000 - 250
      Nil
    }
    _ -> {
      should.fail()
      Nil
    }
  }
}

pub fn consume_ftl_fuel_insufficient_test() {
  // Test with not enough fuel for FTL
  let test_player = create_test_player_with_fuel(200, 5000)

  case player.consume_ftl_fuel(test_player) {
    Ok(_) -> {
      should.fail()
      Nil
    }
    Error(e) -> {
      case e {
        "Not enough fuel for FTL travel (requires 250 units)" -> Nil
        _ -> {
          should.fail()
          Nil
        }
      }
    }
  }
}

pub fn consume_ftl_fuel_exact_amount_test() {
  // Test with exactly enough fuel for FTL
  let test_player = create_test_player_with_fuel(250, 5000)

  case player.consume_ftl_fuel(test_player) {
    Ok(updated_player) -> {
      updated_player.ship.fuel_units
      |> should.equal(0)
      // 250 - 250
      Nil
    }
    _ -> {
      should.fail()
      Nil
    }
  }
}
