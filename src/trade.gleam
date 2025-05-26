import gleam/int
import gleam/io
import gleam/list
import player
import trade_goods
import universe
import utils

// Show the trade menu
pub fn show_trade_menu(
  player: player.Player,
  planet: universe.Planet,
) -> Result(player.Player, String) {
  io.println("\n=== Trading Post ===")
  io.println("Credits: " <> int.to_string(player.credits))

  // Show available goods with prices and quantities
  io.println("\nAvailable goods:")
  let _ =
    list.each(planet.trade_goods, fn(good: trade_goods.TradeGoods) {
      let name = case good {
        trade_goods.Protein(n, _, _) -> n
        trade_goods.Hydro(n, _, _) -> n
        trade_goods.Fuel(n, _, _) -> n
        trade_goods.SpareParts(n, _, _) -> n
        trade_goods.Mineral(n, _, _) -> n
        trade_goods.Habitat(n, _, _) -> n
        trade_goods.Weapons(n, _, _) -> n
        trade_goods.Shields(n, _, _) -> n
      }
      let price = case good {
        trade_goods.Protein(_, p, _) -> p
        trade_goods.Hydro(_, p, _) -> p
        trade_goods.Fuel(_, p, _) -> p
        trade_goods.SpareParts(_, p, _) -> p
        trade_goods.Mineral(_, p, _) -> p
        trade_goods.Habitat(_, p, _) -> p
        trade_goods.Weapons(_, p, _) -> p
        trade_goods.Shields(_, p, _) -> p
      }
      let quantity = case good {
        trade_goods.Protein(_, _, q) -> q
        trade_goods.Hydro(_, _, q) -> q
        trade_goods.Fuel(_, _, q) -> q
        trade_goods.SpareParts(_, _, q) -> q
        trade_goods.Mineral(_, _, q) -> q
        trade_goods.Habitat(_, _, q) -> q
        trade_goods.Weapons(_, _, q) -> q
        trade_goods.Shields(_, _, q) -> q
      }
      io.println(
        name
        <> " - "
        <> int.to_string(price)
        <> " credits ("
        <> int.to_string(quantity)
        <> " available)",
      )
    })

  // Show player's cargo
  io.println("\nYour cargo:")
  case player.cargo {
    [] -> io.println("  Empty")
    cargo -> {
      let _ =
        list.each(cargo, fn(pair: #(trade_goods.TradeGoods, Int)) {
          let name = case pair.0 {
            trade_goods.Protein(n, _, _) -> n
            trade_goods.Hydro(n, _, _) -> n
            trade_goods.Fuel(n, _, _) -> n
            trade_goods.SpareParts(n, _, _) -> n
            trade_goods.Mineral(n, _, _) -> n
            trade_goods.Habitat(n, _, _) -> n
            trade_goods.Weapons(n, _, _) -> n
            trade_goods.Shields(n, _, _) -> n
          }
          let qty = pair.1
          io.println("  - " <> name <> ": " <> int.to_string(qty) <> " units")
        })
    }
  }

  // Show menu options
  io.println("\nOptions:")
  io.println("1. Buy")
  io.println("2. Sell")
  io.println("3. Leave")

  io.print("\nSelect an option (1-3): ")
  let input = utils.get_trimmed_line("")

  case input {
    "1" -> {
      io.println("\nBuying items... (not implemented yet)")
      // TODO: Implement buying logic
      Ok(player)
    }
    "2" -> {
      io.println("\nSelling items... (not implemented yet)")
      // TODO: Implement selling logic
      Ok(player)
    }
    "3" -> {
      io.println("\nLeaving trading post...")
      Ok(player)
    }
    _ -> {
      io.println("\nInvalid choice")
      Ok(player)
    }
  }
}
