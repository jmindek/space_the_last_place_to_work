import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import player
import ship
import trade_goods
import universe
import utils

// Helper function to add items to player's cargo
fn add_to_cargo(
  cargo: List(#(trade_goods.TradeGoods, Int)),
  item: trade_goods.TradeGoods,
  quantity: Int,
) -> List(#(trade_goods.TradeGoods, Int)) {
  // Check if item already exists in cargo
  case
    list.find(cargo, fn(p) {
      let #(existing_item, _) = p
      // Compare the type and name of the items
      case existing_item, item {
        trade_goods.Protein(n1, _, _), trade_goods.Protein(n2, _, _) -> n1 == n2
        trade_goods.Hydro(n1, _, _), trade_goods.Hydro(n2, _, _) -> n1 == n2
        trade_goods.Fuel(n1, _, _), trade_goods.Fuel(n2, _, _) -> n1 == n2
        trade_goods.SpareParts(n1, _, _), trade_goods.SpareParts(n2, _, _) ->
          n1 == n2
        trade_goods.Mineral(n1, _, _), trade_goods.Mineral(n2, _, _) -> n1 == n2
        trade_goods.Habitat(n1, _, _), trade_goods.Habitat(n2, _, _) -> n1 == n2
        trade_goods.Weapons(n1, _, _), trade_goods.Weapons(n2, _, _) -> n1 == n2
        trade_goods.Shields(n1, _, _), trade_goods.Shields(n2, _, _) -> n1 == n2
        _, _ -> False
      }
    })
  {
    Ok(pair) -> {
      // Item exists, update quantity
      let #(existing_item, existing_qty) = pair
      let updated_cargo = list.filter(cargo, fn(p) { p != pair })
      [#(existing_item, existing_qty + quantity), ..updated_cargo]
    }
    Error(_) -> {
      // Item doesn't exist, add new entry
      [#(item, quantity), ..cargo]
    }
  }
}

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
    "1" -> handle_buy(player, planet)
    "2" -> {
      io.println("\nSelling items... (not implemented yet)")
      // TODO: Implement selling logic
      Ok(player)
    }
    "3" -> {
      io.println("Leaving starport...")
      Ok(player)
    }
    _ -> {
      io.println("Invalid option. Please select 1-3.")
      Ok(player)
    }
  }
}

// Handle the buy operation
fn handle_buy(
  player: player.Player,
  planet: universe.Planet,
) -> Result(player.Player, String) {
  // Show available goods with indices
  io.println("\nAvailable goods:")
  let _ =
    planet.trade_goods
    |> list.fold(1, fn(index, good) {
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
        string.concat([
          int.to_string(index),
          ". ",
          name,
          " - ",
          int.to_string(price),
          " credits (",
          int.to_string(quantity),
          " available)",
        ]),
      )
      index + 1
    })

  // Get item selection
  io.print("\nSelect an item to buy (1-")
  io.print(int.to_string(list.length(planet.trade_goods)))
  io.print(") or 0 to cancel: ")
  let item_input = utils.get_trimmed_line("")

  case int.parse(item_input) {
    Ok(0) -> {
      io.println("Purchase cancelled.")
      Ok(player)
    }
    Ok(item_index) -> {
      // Get quantity
      io.print("Enter quantity to buy (or press Enter for 1): ")
      let qty_input = utils.get_trimmed_line("")
      let quantity = case qty_input {
        "" -> 1
        _ ->
          case int.parse(qty_input) {
            Ok(q) -> q
            _ -> 1
          }
      }

      // Validate quantity
      case quantity <= 0 {
        True -> {
          io.println("Quantity must be positive.")
          Ok(player)
        }
        False -> {
          // Find the selected item by dropping the first (item_index - 1) elements
          let maybe_good = case list.drop(planet.trade_goods, item_index - 1) {
            [good, ..] -> Ok(good)
            _ -> Error(Nil)
          }

          case maybe_good {
            Ok(good) -> process_purchase(player, planet, good, quantity)
            Error(_) -> {
              io.println("Invalid item selection.")
              Ok(player)
            }
          }
        }
      }
    }
    _ -> {
      io.println("Invalid selection.")
      Ok(player)
    }
  }
}

// Process a purchase transaction
pub fn process_purchase(
  player: player.Player,
  planet: universe.Planet,
  good: trade_goods.TradeGoods,
  quantity: Int,
) -> Result(player.Player, String) {
  let total_cost = trade_goods.get_price(good) * quantity
  let good_quantity = trade_goods.get_quantity(good)

  // Check if enough available
  case quantity > good_quantity {
    True -> {
      io.println(
        "Not enough in stock. Only "
        <> int.to_string(good_quantity)
        <> " available.",
      )
      Ok(player)
    }
    False -> {
      // Check if player has enough credits
      case player.credits < total_cost {
        True -> {
          io.println(
            "Not enough credits. You need "
            <> int.to_string(total_cost)
            <> " but only have "
            <> int.to_string(player.credits)
            <> ".",
          )
          Ok(player)
        }
        False -> {
          // Check cargo space
          let player_cargo_units =
            list.fold(player.cargo, 0, fn(acc, pair) { acc + pair.1 })
          let available_space = player.ship.max_cargo_holds - player_cargo_units

          case quantity > available_space {
            True -> {
              io.println(
                "Not enough cargo space. You can only fit "
                <> int.to_string(available_space)
                <> " more units.",
              )
              Ok(player)
            }
            False -> {
              // All checks passed, complete the purchase
              let new_credits = player.credits - total_cost
              let new_cargo = add_to_cargo(player.cargo, good, quantity)

              // Calculate new cargo units
              let player_cargo_units =
                list.fold(new_cargo, 0, fn(acc, pair) {
                  let #(_, qty) = pair
                  acc + qty
                })

              // Update player with new cargo and ship state
              let updated_ship =
                ship.Ship(
                  location: player.ship.location,
                  speed: player.ship.speed,
                  max_speed: player.ship.max_speed,
                  class: player.ship.class,
                  crew_size: player.ship.crew_size,
                  fuel_units: player.ship.fuel_units,
                  max_fuel_units: player.ship.max_fuel_units,
                  shields: player.ship.shields,
                  max_shields: player.ship.max_shields,
                  weapons: player.ship.weapons,
                  max_weapons: player.ship.max_weapons,
                  cargo_holds: player_cargo_units,
                  max_cargo_holds: player.ship.max_cargo_holds,
                  passenger_holds: player.ship.passenger_holds,
                  max_passenger_holds: player.ship.max_passenger_holds,
                )

              let updated_player =
                player.Player(
                  name: player.name,
                  ship: updated_ship,
                  homeworld: player.homeworld,
                  credits: new_credits,
                  cargo: new_cargo,
                )

              // Update planet's inventory (in a real implementation, you'd need to update the universe state)
              io.println(
                "Purchased "
                <> int.to_string(quantity)
                <> " units for "
                <> int.to_string(total_cost)
                <> " credits.",
              )
              io.println(
                "Remaining credits: " <> int.to_string(updated_player.credits),
              )

              Ok(updated_player)
            }
          }
        }
      }
    }
  }
}
