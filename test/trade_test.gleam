import gleam/int
import gleam/io
import gleam/list
import trade_goods

// Helper function to print trade goods
fn print_trade_goods(goods: List(trade_goods.TradeGoods)) {
  list.each(goods, fn(good) {
    case good {
      trade_goods.Protein(name, price, quantity) ->
        io.println(
          "  "
          <> name
          <> ": "
          <> int.to_string(price)
          <> " credits ("
          <> int.to_string(quantity)
          <> " units)",
        )
      trade_goods.Hydro(name, price, quantity) ->
        io.println(
          "  "
          <> name
          <> ": "
          <> int.to_string(price)
          <> " credits ("
          <> int.to_string(quantity)
          <> " units)",
        )
      trade_goods.Fuel(name, price, quantity) ->
        io.println(
          "  "
          <> name
          <> ": "
          <> int.to_string(price)
          <> " credits ("
          <> int.to_string(quantity)
          <> " units)",
        )
      trade_goods.SpareParts(name, price, quantity) ->
        io.println(
          "  "
          <> name
          <> ": "
          <> int.to_string(price)
          <> " credits ("
          <> int.to_string(quantity)
          <> " units)",
        )
      trade_goods.Mineral(name, price, quantity) ->
        io.println(
          "  "
          <> name
          <> ": "
          <> int.to_string(price)
          <> " credits ("
          <> int.to_string(quantity)
          <> " units)",
        )
      trade_goods.Habitat(name, price, quantity) ->
        io.println(
          "  "
          <> name
          <> ": "
          <> int.to_string(price)
          <> " credits ("
          <> int.to_string(quantity)
          <> " units)",
        )
      trade_goods.Weapons(name, price, quantity) ->
        io.println(
          "  "
          <> name
          <> ": "
          <> int.to_string(price)
          <> " credits ("
          <> int.to_string(quantity)
          <> " units)",
        )
      trade_goods.Shields(name, price, quantity) ->
        io.println(
          "  "
          <> name
          <> ": "
          <> int.to_string(price)
          <> " credits ("
          <> int.to_string(quantity)
          <> " units)",
        )
    }
  })
}

// Function to update prices directly (for testing)
fn update_prices(
  goods: List(trade_goods.TradeGoods),
) -> List(trade_goods.TradeGoods) {
  list.map(goods, fn(good) {
    let fluctuation = int.random(21) - 10
    // Random number between -10 and +10

    case good {
      trade_goods.Protein(name, price, quantity) -> {
        let new_price = int.max(1, price + fluctuation)
        trade_goods.Protein(name, new_price, quantity)
      }
      trade_goods.Hydro(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 10, 1000)
        trade_goods.Hydro(name, new_price, quantity)
      }
      trade_goods.Fuel(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 50, 1000)
        trade_goods.Fuel(name, new_price, quantity)
      }
      trade_goods.SpareParts(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 25, 1000)
        trade_goods.SpareParts(name, new_price, quantity)
      }
      trade_goods.Mineral(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 100, 1000)
        trade_goods.Mineral(name, new_price, quantity)
      }
      trade_goods.Habitat(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 500, 5000)
        trade_goods.Habitat(name, new_price, quantity)
      }
      trade_goods.Weapons(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 1000, 10_000)
        trade_goods.Weapons(name, new_price, quantity)
      }
      trade_goods.Shields(name, price, quantity) -> {
        let new_price = int.clamp(price + fluctuation, 1000, 10_000)
        trade_goods.Shields(name, new_price, quantity)
      }
    }
  })
}

pub fn test_price_fluctuations() {
  // Generate test trade goods
  let test_goods = trade_goods.generate_trade_goods()

  // Print initial state
  io.println("=== Initial Trade Goods ===")
  print_trade_goods(test_goods)

  // Simulate 5 turns of price fluctuations
  let _ =
    list.range(1, 6)
    |> list.fold(test_goods, fn(goods, turn) {
      io.println("\n=== After Turn " <> int.to_string(turn) <> " ===")
      let updated_goods = update_prices(goods)
      print_trade_goods(updated_goods)
      updated_goods
    })

  io.println("\n=== Price Fluctuation Test Complete ===")
}

// Run the test
pub fn main() {
  test_price_fluctuations()
}
