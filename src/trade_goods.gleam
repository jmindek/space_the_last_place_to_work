import gleam/int

pub type TradeGoods {
  Protein(name: String, price: Int, quantity: Int)
  Hydro(name: String, price: Int, quantity: Int)
  Fuel(name: String, price: Int, quantity: Int)
  Mineral(name: String, price: Int, quantity: Int)
  Habitat(name: String, price: Int, quantity: Int)
  Weapons(name: String, price: Int, quantity: Int)
  Shields(name: String, price: Int, quantity: Int)
  SpareParts(name: String, price: Int, quantity: Int)
}

// Generate a random price within a range
fn random_price(min: Int, max: Int) -> Int {
  min + int.random(max - min + 1)
}

// Generate trade goods based on the specified quantities and prices
pub fn generate_trade_goods() -> List(TradeGoods) {
  [
    // Protein: 1-1,000,000 units, price 1-1000 (keeps original pricing as base)
    Protein("Protein", random_price(1, 1000), int.random(1_000_000)),
    // Hydro: 1-1,000,000 units, price 10-1000
    Hydro("Hydro", random_price(10, 1000), int.random(1_000_000)),
    // Fuel: 1-10,000 units, price 50-1000
    Fuel("Fuel", random_price(50, 1000), int.random(10_000)),
    // SpareParts: 1-500 units, price 25-1000
    SpareParts("Spare Parts", random_price(25, 1000), int.random(500)),
    // Mineral: 1-100,000 units, price 100-1000
    Mineral("Mineral", random_price(100, 1000), int.random(100_000)),
    // Habitat: 1-500 units, price 500-5000
    Habitat("Habitat", random_price(500, 5000), int.random(500)),
    // Weapons: 1-1,000 units, price 1000-10000
    Weapons("Weapons", random_price(1000, 10_000), int.random(1000)),
    // Shields: 1-500 units, price 1000-10000
    Shields("Shields", random_price(1000, 10_000), int.random(500)),
  ]
}

// Get the name of a trade good
pub fn get_name(good: TradeGoods) -> String {
  case good {
    Protein(name, _, _) -> name
    Hydro(name, _, _) -> name
    Fuel(name, _, _) -> name
    SpareParts(name, _, _) -> name
    Mineral(name, _, _) -> name
    Habitat(name, _, _) -> name
    Weapons(name, _, _) -> name
    Shields(name, _, _) -> name
  }
}

// Get the price of a trade good
pub fn get_price(good: TradeGoods) -> Int {
  case good {
    Protein(_, price, _) -> price
    Hydro(_, price, _) -> price
    Fuel(_, price, _) -> price
    SpareParts(_, price, _) -> price
    Mineral(_, price, _) -> price
    Habitat(_, price, _) -> price
    Weapons(_, price, _) -> price
    Shields(_, price, _) -> price
  }
}

// Get the quantity of a trade good
pub fn get_quantity(good: TradeGoods) -> Int {
  case good {
    Protein(_, _, qty) -> qty
    Hydro(_, _, qty) -> qty
    Fuel(_, _, qty) -> qty
    SpareParts(_, _, qty) -> qty
    Mineral(_, _, qty) -> qty
    Habitat(_, _, qty) -> qty
    Weapons(_, _, qty) -> qty
    Shields(_, _, qty) -> qty
  }
}
