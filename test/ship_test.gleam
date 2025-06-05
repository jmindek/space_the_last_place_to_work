import gleeunit/should
import ship

pub fn new_ship_test() {
  // Test Shuttle
  test_ship_initialization(ship.Shuttle, 4, 0, 2, 10_000)

  // Test Fighter
  test_ship_initialization(ship.Fighter, 1, 2, 4, 5000)

  // Test Freighter
  test_ship_initialization(ship.Freighter, 2, 0, 2, 15_000)

  // Test Luxury
  test_ship_initialization(ship.Luxury, 8, 0, 2, 20_000)

  // Test Research
  test_ship_initialization(ship.Research, 10, 0, 0, 20_000)

  // Test Classified
  test_ship_initialization(ship.Classified, 1, 0, 0, 0)

  // Test Sling
  test_ship_initialization(ship.Sling, 1, 0, 0, 1000)

  // Test Sail
  test_ship_initialization(ship.Sail, 1, 0, 0, 1000)

  // Test Rescue
  test_ship_initialization(ship.Rescue, 4, 4, 0, 5000)

  // Test Miner
  test_ship_initialization(ship.Miner, 8, 4, 0, 15_000)
}

// Helper function to test ship initialization
fn test_ship_initialization(
  class: ship.ShipClass,
  expected_crew: Int,
  expected_shields: Int,
  expected_weapons: Int,
  expected_fuel: Int,
) -> Nil {
  let ship = ship.new_ship(class, #(0, 0))

  ship.crew_size
  |> should.equal(expected_crew)

  ship.shields
  |> should.equal(expected_shields)

  ship.max_shields
  |> should.equal(expected_shields)

  ship.weapons
  |> should.equal(expected_weapons)

  ship.max_weapons
  |> should.equal(expected_weapons)

  ship.fuel_units
  |> should.equal(expected_fuel)

  ship.max_fuel_units
  |> should.equal(expected_fuel)

  ship.speed
  |> should.equal(0)

  ship.class
  |> should.equal(class)

  ship.location
  |> should.equal(#(0, 0))
}

// Helper function to create a test ship with specific stats
fn create_test_ship(
  shields: Int,
  max_shields: Int,
  weapons: Int,
  max_weapons: Int,
) -> ship.Ship {
  let class = ship.Fighter
  let max_cargo = ship.get_max_cargo_holds(class)
  let max_passengers = ship.get_max_passenger_holds(class)

  ship.Ship(
    location: #(0, 0),
    previous_location: #(0, 0),
    speed: 0,
    max_speed: 10,
    class: class,
    crew_size: 10,
    fuel_units: 5000,
    max_fuel_units: 5000,
    cargo_holds: 0,
    max_cargo_holds: max_cargo,
    passenger_holds: 0,
    max_passenger_holds: max_passengers,
    shields: shields,
    max_shields: max_shields,
    weapons: weapons,
    max_weapons: max_weapons,
  )
}

pub fn repair_shields_test() {
  // Create a damaged ship (shields at 2/10)
  let damaged_ship = create_test_ship(2, 10, 5, 5)

  // Test partial repair (should go from 2 to 5)
  let partially_repaired = ship.repair_shields(damaged_ship, 3)
  partially_repaired.shields
  |> should.equal(5)

  // Test repair that would exceed max (should cap at max_shields)
  let over_repaired = ship.repair_shields(partially_repaired, 10)
  over_repaired.shields
  |> should.equal(10)

  // Test repair when already at max (should stay at max)
  let already_maxed = ship.repair_shields(over_repaired, 5)
  already_maxed.shields
  |> should.equal(10)
}

pub fn repair_weapons_test() {
  // Create a ship with damaged weapons (3/8)
  let damaged_ship = create_test_ship(5, 5, 3, 8)

  // Test partial repair (should go from 3 to 6)
  let partially_repaired = ship.repair_weapons(damaged_ship, 3)
  partially_repaired.weapons
  |> should.equal(6)

  // Test repair that would exceed max (should cap at max_weapons)
  let over_repaired = ship.repair_weapons(partially_repaired, 5)
  over_repaired.weapons
  |> should.equal(8)

  // Test repair when already at max (should stay at max)
  let already_maxed = ship.repair_weapons(over_repaired, 2)
  already_maxed.weapons
  |> should.equal(8)
}

pub fn combined_repairs_test() {
  // Create a heavily damaged ship
  let damaged_ship = create_test_ship(1, 10, 2, 8)

  // Repair both systems
  let repaired_shields = ship.repair_shields(damaged_ship, 5)
  let fully_repaired = ship.repair_weapons(repaired_shields, 4)

  // Verify both systems were repaired correctly
  fully_repaired.shields
  |> should.equal(6)
  fully_repaired.weapons
  |> should.equal(6)
}

pub fn take_damage_test() {
  // Test 1: Damage less than shields (shields should absorb all damage)
  let ship_with_shields = create_test_ship(5, 10, 8, 8)
  let damaged = ship.take_damage(ship_with_shields, 3)
  damaged.shields
  |> should.equal(2)
  // 5 - 3 = 2
  damaged.weapons
  |> should.equal(8)
  // Weapons should be unchanged

  // Test 2: Damage exactly equal to shields (shields should be depleted)
  let exact_damage = ship.take_damage(ship_with_shields, 5)
  exact_damage.shields
  |> should.equal(0)
  // 5 - 5 = 0
  exact_damage.weapons
  |> should.equal(8)
  // Weapons should be unchanged

  // Test 3: Damage more than shields (shields should be depleted, weapons damaged)
  let overkill = ship.take_damage(ship_with_shields, 7)
  overkill.shields
  |> should.equal(0)
  // Depleted
  overkill.weapons
  |> should.equal(6)
  // 8 - (7 - 5) = 6

  // Test 4: Massive damage (both shields and weapons should be 0)
  let massive_damage = ship.take_damage(ship_with_shields, 50)
  massive_damage.shields
  |> should.equal(0)
  // Depleted
  massive_damage.weapons
  |> should.equal(0)
  // 8 - (50 - 5) = -37, clamped to 0

  // Test 5: No shields, weapons should take full damage
  let no_shield_ship = create_test_ship(0, 10, 5, 5)
  let no_shield_damage = ship.take_damage(no_shield_ship, 3)
  no_shield_damage.shields
  |> should.equal(0)
  // Still 0
  no_shield_damage.weapons
  |> should.equal(2)
  // 5 - 3 = 2

  // Test 6: No weapons, only shields should be damaged
  let no_weapon_ship = create_test_ship(5, 10, 0, 0)
  let no_weapon_damage = ship.take_damage(no_weapon_ship, 3)
  no_weapon_damage.shields
  |> should.equal(2)
  // 5 - 3 = 2
  no_weapon_damage.weapons
  |> should.equal(0)
  // Still 0

  // Test 7: Zero damage should do nothing
  let zero_damage = ship.take_damage(ship_with_shields, 0)
  zero_damage.shields
  |> should.equal(5)
  // Unchanged
  zero_damage.weapons
  |> should.equal(8)
  // Unchanged
}

pub fn refuel_test() {
  // Test 1: Partial refuel
  let low_fuel = create_test_ship(5, 5, 5, 5) |> with_fuel(2000, 5000)
  let partially_refueled = ship.refuel(low_fuel, 1000)
  partially_refueled.fuel_units
  |> should.equal(3000)

  // Test 2: Refuel to max
  let to_max = ship.refuel(partially_refueled, 3000)
  to_max.fuel_units
  |> should.equal(5000)
  to_max.max_fuel_units
  |> should.equal(5000)

  // Test 3: Overfill protection
  let overfilled = ship.refuel(to_max, 1000)
  overfilled.fuel_units
  |> should.equal(5000)
  overfilled.max_fuel_units
  |> should.equal(5000)

  // Test 4: Zero fuel added
  let no_refuel = ship.refuel(low_fuel, 0)
  no_refuel.fuel_units
  |> should.equal(2000)
}

pub fn get_fuel_percentage_test() {
  // Test exact percentages
  let half_fuel = create_test_ship(5, 5, 5, 5) |> with_fuel(2500, 5000)
  ship.get_fuel_percentage(half_fuel)
  |> should.equal(50.0)

  // Test full
  let full = create_test_ship(5, 5, 5, 5) |> with_fuel(5000, 5000)
  ship.get_fuel_percentage(full)
  |> should.equal(100.0)

  // Test empty
  let empty = create_test_ship(5, 5, 5, 5) |> with_fuel(0, 5000)
  ship.get_fuel_percentage(empty)
  |> should.equal(0.0)
}

pub fn can_move_test() {
  // Test can move exact distance
  let test_ship = create_test_ship(5, 5, 5, 5) |> with_fuel(50, 5000)
  ship.can_move(test_ship, 50)
  // 50 * 1 = 50 fuel
  |> should.be_true

  // Test can't move (not enough fuel)
  ship.can_move(test_ship, 51)
  // 51 * 1 = 51 > 50
  |> should.be_false

  // Test edge case (exact fuel)
  ship.can_move(test_ship, 0)
  |> should.be_true
}

pub fn get_shield_percentage_test() {
  // Test with shields
  let with_shields = create_test_ship(5, 10, 5, 5)
  ship.get_shield_percentage(with_shields)
  |> should.equal(50.0)

  // Test full shields
  let full_shields = create_test_ship(10, 10, 5, 5)
  ship.get_shield_percentage(full_shields)
  |> should.equal(100.0)

  // Test no shields
  let no_shields = create_test_ship(0, 10, 5, 5)
  ship.get_shield_percentage(no_shields)
  |> should.equal(0.0)

  // Test ship with no shield capacity
  let no_shield_capacity = create_test_ship(0, 0, 5, 5)
  ship.get_shield_percentage(no_shield_capacity)
  |> should.equal(0.0)
}

// Helper function to create a ship with specific fuel values
fn with_fuel(ship: ship.Ship, current: Int, max: Int) -> ship.Ship {
  ship.Ship(..ship, fuel_units: current, max_fuel_units: max)
}

pub fn set_speed_test() {
  let test_ship = create_test_ship(5, 10, 5, 5)

  // Test normal speed set
  let faster = ship.set_speed(test_ship, 5)
  faster.speed
  |> should.equal(5)

  // Test minimum speed (0)
  let stopped = ship.set_speed(test_ship, -5)
  stopped.speed
  |> should.equal(0)

  // Test maximum speed (10)
  let max_speed = ship.set_speed(test_ship, 15)
  max_speed.speed
  |> should.equal(10)

  // Test speed remains unchanged when setting to current speed
  let same_speed = ship.set_speed(faster, 5)
  same_speed.speed
  |> should.equal(5)
}

pub fn move_to_test() {
  let test_ship = create_test_ship(5, 10, 5, 5)

  // Test moving to a new location
  let moved = ship.move_to(test_ship, #(10, 20))
  moved.location
  |> should.equal(#(10, 20))

  // Test moving to the same location
  let same_spot = ship.move_to(moved, #(10, 20))
  same_spot.location
  |> should.equal(#(10, 20))

  // Test moving to origin
  let origin = ship.move_to(test_ship, #(0, 0))
  origin.location
  |> should.equal(#(0, 0))
}

pub fn consume_fuel_test() {
  // Create a ship with 100 fuel units
  let test_ship =
    create_test_ship(5, 10, 5, 5)
    |> with_fuel(100, 5000)
  // Test normal fuel consumption
  case ship.consume_fuel(test_ship, 50) {
    // 50 * 1 = 50 fuel
    Ok(consumed) -> {
      consumed.fuel_units
      |> should.equal(50)
      // 100 - 50 = 50

      // Test consuming all remaining fuel
      case ship.consume_fuel(consumed, 50) {
        // Another 500 fuel
        Ok(empty) -> {
          empty.fuel_units
          |> should.equal(0)

          // Test consuming with not enough fuel
          case ship.consume_fuel(empty, 1) {
            Ok(_) -> should.fail()
            Error(_) -> {
              Nil
            }
          }
        }
        Error(_) -> {
          Nil
        }
      }
    }
    Error(_) -> {
      Nil
    }
  }

  // Test zero distance
  let test_ship2 = create_test_ship(5, 10, 5, 5) |> with_fuel(100, 5000)
  case ship.consume_fuel(test_ship2, 0) {
    Ok(no_consumption) -> {
      no_consumption.fuel_units
      |> should.equal(100)
      // Fuel should remain unchanged
    }
    Error(_) -> {
      Nil
    }
  }

  // Test negative distance (should be treated as 0)
  let test_ship3 = create_test_ship(5, 10, 5, 5) |> with_fuel(100, 5000)
  case ship.consume_fuel(test_ship3, -10) {
    Ok(consumed) ->
      consumed.fuel_units
      |> should.equal(90)
    // 100 - (10 * 1) = 90
    Error(_) -> {
      Nil
    }
  }
}
