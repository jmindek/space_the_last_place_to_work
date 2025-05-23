import gleam/int

// Define the ship class type
pub type ShipClass {
  Shuttle
  Fighter
  Freighter
  Luxury
  Research
  Classified
  Sling
  Sail
  Rescue
  Miner
}

// Define the ship type
pub type Ship {
  Ship(
    location: #(Int, Int),
    speed: Int,
    class: ShipClass,
    crew_size: Int,
    fuel_units: Int,
    max_fuel_units: Int,
    shields: Int,
    max_shields: Int,
    weapons: Int,
    max_weapons: Int,
  )
}

// Get the crew size for a ship class
fn get_crew_size(class: ShipClass) -> Int {
  case class {
    Shuttle -> 4
    Fighter -> 1
    Freighter -> 2
    Luxury -> 8
    Research -> 10
    Classified -> 1
    Sling -> 1
    Sail -> 1
    Rescue -> 4
    Miner -> 8
  }
}

// Get the max shields for a ship class
fn get_max_shields(class: ShipClass) -> Int {
  case class {
    Shuttle -> 0
    Fighter -> 2
    Freighter -> 0
    Luxury -> 0
    Research -> 0
    Classified -> 0
    Sling -> 0
    Sail -> 0
    Rescue -> 4
    Miner -> 4
  }
}

// Get the max weapons for a ship class
fn get_max_weapons(class: ShipClass) -> Int {
  case class {
    Shuttle -> 2
    Fighter -> 4
    Freighter -> 2
    Luxury -> 2
    Research -> 0
    Classified -> 0
    // Unknown for classified ships
    Sling -> 0
    Sail -> 0
    Rescue -> 0
    Miner -> 0
  }
}

// Get the max fuel units for a ship class
fn get_max_fuel_units(class: ShipClass) -> Int {
  case class {
    Shuttle -> 10_000
    Fighter -> 5000
    Freighter -> 15_000
    Luxury -> 20_000
    Research -> 20_000
    Classified -> 0
    // Unknown for classified ships
    Sling -> 1000
    Sail -> 1000
    Rescue -> 5000
    Miner -> 15_000
  }
}

// Create a new ship with the given class and location
pub fn new_ship(class: ShipClass, location: #(Int, Int)) -> Ship {
  let crew_size = get_crew_size(class)
  let max_fuel = get_max_fuel_units(class)
  let max_shields = get_max_shields(class)
  let max_weapons = get_max_weapons(class)

  Ship(
    location: location,
    speed: 0,
    // Start at 0 speed
    class: class,
    crew_size: crew_size,
    fuel_units: max_fuel,
    // Start with full fuel
    max_fuel_units: max_fuel,
    shields: max_shields,
    // Start with full shields
    max_shields: max_shields,
    weapons: max_weapons,
    // Start with all weapons operational
    max_weapons: max_weapons,
  )
}

// Change the ship's speed (clamped between 0 and 10)
pub fn set_speed(ship: Ship, new_speed: Int) -> Ship {
  let clamped_speed = case new_speed {
    s if s < 0 -> 0
    s if s > 10 -> 10
    s -> s
  }

  let Ship(..) = ship
  Ship(..ship, speed: clamped_speed)
}

// Move the ship to a new location
pub fn move_to(ship: Ship, new_location: #(Int, Int)) -> Ship {
  let Ship(..) = ship
  Ship(..ship, location: new_location)
}

// Consume fuel based on distance traveled
pub fn consume_fuel(ship: Ship, distance: Int) -> Result(Ship, String) {
  let Ship(fuel_units: current_fuel, ..) = ship
  let absolute_distance = case distance < 0 {
    True -> -distance
    False -> distance
  }
  let fuel_cost = absolute_distance * 10
  // 10 fuel units per unit distance

  case current_fuel - fuel_cost {
    remaining if remaining >= 0 -> Ok(Ship(..ship, fuel_units: remaining))
    _ -> Error("Not enough fuel for this move")
  }
}

// Refuel the ship by a given amount (up to max capacity)
pub fn refuel(ship: Ship, amount: Int) -> Ship {
  let Ship(fuel_units: current, max_fuel_units: max, ..) = ship
  let new_amount = case current + amount {
    sum if sum > max -> max
    sum -> sum
  }

  Ship(..ship, fuel_units: new_amount)
}

// Get the ship's current fuel percentage
pub fn get_fuel_percentage(ship: Ship) -> Float {
  let Ship(fuel_units: current, max_fuel_units: max, ..) = ship
  int.to_float(current) /. int.to_float(max) *. 100.0
}

// Check if the ship can make a move of the given distance
pub fn can_move(ship: Ship, distance: Int) -> Bool {
  let Ship(fuel_units: current, ..) = ship
  current >= distance * 10
  // 10 fuel units per unit distance
}

// Get the ship's current shield percentage
pub fn get_shield_percentage(ship: Ship) -> Float {
  let Ship(shields: current, max_shields: max, ..) = ship
  case max > 0 {
    True -> int.to_float(current) /. int.to_float(max) *. 100.0
    False -> 0.0
  }
}

// Damage the ship's shields and potentially hull
pub fn take_damage(ship: Ship, amount: Int) -> Ship {
  let Ship(
    shields: current_shields,
    weapons: current_weapons,
    max_weapons: max_weapons,
    ..,
  ) = ship

  // First, damage shields
  let remaining_damage = case current_shields - amount {
    remaining if remaining >= 0 -> {
      // All damage absorbed by shields
      0
    }
    remaining -> {
      // Shields down, remaining damage goes through
      -remaining
    }
  }

  let new_shields = int.max(0, current_shields - amount)

  // If there's remaining damage after shields, damage weapons (if any)
  let new_weapons = case remaining_damage > 0 && max_weapons > 0 {
    True -> int.max(0, current_weapons - remaining_damage)
    False -> current_weapons
  }

  Ship(..ship, shields: new_shields, weapons: new_weapons)
}

// Repair ship's shields by a given amount (up to max)
pub fn repair_shields(ship: Ship, amount: Int) -> Ship {
  let Ship(shields: current, max_shields: max, ..) = ship
  let new_shields = int.min(max, current + amount)
  Ship(..ship, shields: new_shields)
}

// Repair ship's weapons by a given amount (up to max)
pub fn repair_weapons(ship: Ship, amount: Int) -> Ship {
  let Ship(weapons: current, max_weapons: max, ..) = ship
  let new_weapons = int.min(max, current + amount)
  Ship(..ship, weapons: new_weapons)
}
