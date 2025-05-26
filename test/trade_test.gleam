import gleam/io
import gleam/list
import gleam/option
import gleam/int
import gleam/float
import universe

// Helper function to print trade goods
fn print_trade_goods(goods: List(universe.TradeStuff)) {
  list.each(goods, fn(good) {
    case good {
      universe.Protein(name, price, quantity) -> 
        io.println("  " <> name <> ": " <> int.to_string(price) <> " credits (" <> int.to_string(quantity) <> " units)")
      universe.Hydro(name, price, quantity) -> 
        io.println("  " <> name <> ": " <> int.to_string(price) <> " credits (" <> int.to_string(quantity) <> " units)")
      universe.Fuel(name, price, quantity) -> 
        io.println("  " <> name <> ": " <> int.to_string(price) <> " credits (" <> int.to_string(quantity) <> " units)")
      universe.SpareParts(name, price, quantity) -> 
        io.println("  " <> name <> ": " <> int.to_string(price) <> " credits (" <> int.to_string(quantity) <> " units)")
      universe.Mineral(name, price, quantity) -> 
        io.println("  " <> name <> ": " <> int.to_string(price) <> " credits (" <> int.to_string(quantity) <> " units)")
      universe.Habitat(name, price, quantity) -> 
        io.println("  " <> name <> ": " <> int.to_string(price) <> " credits (" <> int.to_string(quantity) <> " units)")
      universe.Weapons(name, price, quantity) -> 
        io.println("  " <> name <> ": " <> int.to_string(price) <> " credits (" <> int.to_string(quantity) <> " units)")
      universe.Shields(name, price, quantity) -> 
        io.println("  " <> name <> ": " <> int.to_string(price) <> " credits (" <> int.to_string(quantity) <> " units)")
    }
  })
}

// Function to update prices directly (for testing)
fn update_prices(goods: List(universe.TradeStuff)) -> List(universe.TradeStuff) {
  list.map(goods, fn(good) {
    let fluctuation = int.random(21) - 10  // Random number between -10 and +10
    
    case good {
      universe.Protein(name, price, quantity) -> {
        let new_price = int.max(1, price + fluctuation)
        universe.Protein(name, new_price, quantity)
      }
      universe.Hydro(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 10, 1000)
        universe.Hydro(name, new_price, quantity)
      }
      universe.Fuel(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 50, 1000)
        universe.Fuel(name, new_price, quantity)
      }
      universe.SpareParts(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 25, 1000)
        universe.SpareParts(name, new_price, quantity)
      }
      universe.Mineral(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 100, 1000)
        universe.Mineral(name, new_price, quantity)
      }
      universe.Habitat(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 500, 5000)
        universe.Habitat(name, new_price, quantity)
      }
      universe.Weapons(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 1000, 10000)
        universe.Weapons(name, new_price, quantity)
      }
      universe.Shields(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 1000, 10000)
        universe.Shields(name, new_price, quantity)
      }
    }
  })
}

pub fn test_price_fluctuations() {
  // Generate a test planet
  let planet = universe.generate_planet(10)
  
  // Print initial state
  io.println("=== Initial Trade Goods ===")
  print_trade_goods(planet.trade_goods)
  
  // Simulate 5 turns of price fluctuations
  let _ = list.range(1, 6)
    |> list.fold(
      planet.trade_goods,
      fn(goods, turn) {
        io.println("\n=== After Turn " <> int.to_string(turn) <> " ===")
        let updated_goods = update_prices(goods)
        print_trade_goods(updated_goods)
        updated_goods
      }
    )
  
  io.println("\n=== Price Fluctuation Test Complete ===")
}

// Run the test
pub fn main() {
  test_price_fluctuations()
}
