import gleam/int
import gleam/io
import gleam/list
import gleam/string
import player
import ship
import trade_goods
import universe
import utils

// Handle the offer response based on price ratio
fn handle_offer_response(
  price_ratio_percent: Int,
  price_per_unit: Int,
  quantity: Int,
  current_player: player.Player,
) -> player.Player {
  case price_ratio_percent {
    r if r <= 100 -> {
      io.println("No thank you.")
      current_player
    }
    r if r <= 200 -> {
      io.println(
        "No. We have anti-greed taxes here. Be careful or we will levy one upon you.",
      )
      current_player
    }
    _ -> {
      // Handle excessive offer (>200% of base price)
      // Apply greed tax (50% of asking price) using integer arithmetic
      let total = price_per_unit * quantity
      let tax = total / 2
      // Integer division is fine here as we want to round down
      let new_credits = current_player.credits - tax

      // Create and return the updated player with the greed tax applied
      let updated_player =
        player.Player(
          name: current_player.name,
          ship: current_player.ship,
          homeworld: current_player.homeworld,
          credits: new_credits,
          cargo: current_player.cargo,
        )

      io.println(
        "The starport has levied a greed tax of "
        <> int.to_string(tax)
        <> " credits for your outrageous prices!",
      )
      updated_player
    }
  }
}

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

  // Show player's cargo
  io.println("\nYour cargo:")
  case player.cargo {
    [] -> io.println("  Your cargo hold is empty.")
    _ -> {
      let _ =
        list.each(player.cargo, fn(pair: #(trade_goods.TradeGoods, Int)) {
          let #(item, qty) = pair
          let name = case item {
            trade_goods.Protein(n, _, _) -> n
            trade_goods.Hydro(n, _, _) -> n
            trade_goods.Fuel(n, _, _) -> n
            trade_goods.SpareParts(n, _, _) -> n
            trade_goods.Mineral(n, _, _) -> n
            trade_goods.Habitat(n, _, _) -> n
            trade_goods.Weapons(n, _, _) -> n
            trade_goods.Shields(n, _, _) -> n
          }
          io.println("  - " <> name <> ": " <> int.to_string(qty) <> " units")
        })
      io.println("")
    }
  }

  // Show available goods with prices and quantities
  io.println("\nStarport's goods:")
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
  io.println("0. Back")
  io.print("\nSelect an option: ")
  let choice = utils.get_trimmed_line("")

  case choice {
    "1" -> buy_goods(player, planet)
    "2" -> sell_cargo(player, planet)
    "0" -> Ok(player)
    _ -> {
      io.println("Invalid choice. Please try again.")
      Ok(player)
    }
  }
}

// Handle the buy operation
fn buy_goods(
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
      // Get the selected good and its price
      let #(selected_good, price_per_unit) = case
        list.drop(planet.trade_goods, item_index - 1)
      {
        [good, ..] -> #(good, trade_goods.get_price(good))
        _ -> #(trade_goods.Protein("", 0, 0), 0)
        // Default values if item not found
      }

      // Calculate maximum quantity based on available quantity and player's credits
      let available_qty = trade_goods.get_quantity(selected_good)
      let max_affordable = player.credits / price_per_unit
      // Integer division is fine here
      let max_qty = int.min(available_qty, max_affordable)

      // Get quantity from user
      io.print("Enter quantity to buy (or press Enter for max): ")
      let qty_input = utils.get_trimmed_line("")
      let quantity = case qty_input {
        "" -> max_qty
        // Use max affordable quantity when Enter is pressed
        _ ->
          case int.parse(qty_input) {
            Ok(q) -> int.min(q, max_qty)
            // Don't allow more than max affordable
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
  _planet: universe.Planet,
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

// Sell cargo to the starport
pub fn sell_cargo(
  player: player.Player,
  planet: universe.Planet,
) -> Result(player.Player, String) {
  // Show player's cargo with indices
  case player.cargo {
    [] -> {
      io.println("You have no cargo to sell.")
      Ok(player)
    }
    _ -> {
      io.println("\nYour cargo:")
      let _ =
        list.index_fold(
          player.cargo,
          1,
          // Start index at 1 for display
          fn(index, item_with_qty, _) {
            case item_with_qty {
              #(item, qty) -> {
                let name = case item {
                  trade_goods.Protein(n, _, _) -> n
                  trade_goods.Hydro(n, _, _) -> n
                  trade_goods.Fuel(n, _, _) -> n
                  trade_goods.SpareParts(n, _, _) -> n
                  trade_goods.Mineral(n, _, _) -> n
                  trade_goods.Habitat(n, _, _) -> n
                  trade_goods.Weapons(n, _, _) -> n
                  trade_goods.Shields(n, _, _) -> n
                }
                io.println(
                  string.concat([
                    int.to_string(index),
                    ". ",
                    name,
                    " - ",
                    int.to_string(qty),
                    " units",
                  ]),
                )
                index + 1
                // Increment the index for the next item
              }
            }
          },
        )

      // Get item selection
      io.print("\nSelect an item to sell (1-")
      io.print(int.to_string(list.length(player.cargo)))
      io.print(") or 0 to cancel: ")
      let item_input = utils.get_trimmed_line("")

      case int.parse(item_input) {
        Ok(0) -> {
          io.println("Sale cancelled.")
          Ok(player)
        }
        Ok(item_index) -> {
          // Get the selected item using list.drop and pattern matching
          case list.drop(player.cargo, item_index - 1) {
            [pair, ..] -> {
              let #(item, available_qty) = pair

              // Get quantity to sell
              io.print("Enter quantity to sell (1-")
              io.print(int.to_string(available_qty))
              io.print(" or press Enter for all): ")
              let qty_input = utils.get_trimmed_line("")

              let quantity = case qty_input {
                "" -> available_qty
                _ ->
                  case int.parse(qty_input) {
                    Ok(q) -> int.min(q, available_qty)
                    _ -> available_qty
                  }
              }

              // Validate quantity
              case quantity <= 0 {
                True -> {
                  io.println("Quantity must be positive.")
                  Ok(player)
                }
                False -> {
                  // Get item name for lookup
                  let item_name = trade_goods.get_name(item)

                  // Find the current market price
                  let market_price = case
                    list.find(planet.trade_goods, fn(good) {
                      trade_goods.get_name(good) == item_name
                    })
                  {
                    Ok(found_good) -> trade_goods.get_price(found_good)
                    Error(_) -> trade_goods.get_price(item)
                    // Fallback to item's price if not found
                  }

                  io.print("Enter your asking price per unit (current: ")
                  io.print(int.to_string(market_price))
                  io.print("): ")
                  let price_input = utils.get_trimmed_line("")

                  case int.parse(price_input) {
                    Ok(price_per_unit) -> {
                      // Check if starport has this item
                      let starport_has_item =
                        list.any(planet.trade_goods, fn(g) {
                          case g, item {
                            trade_goods.Protein(n1, _, _),
                              trade_goods.Protein(n2, _, _)
                            -> n1 == n2
                            trade_goods.Hydro(n1, _, _),
                              trade_goods.Hydro(n2, _, _)
                            -> n1 == n2
                            trade_goods.Fuel(n1, _, _),
                              trade_goods.Fuel(n2, _, _)
                            -> n1 == n2
                            trade_goods.SpareParts(n1, _, _),
                              trade_goods.SpareParts(n2, _, _)
                            -> n1 == n2
                            trade_goods.Mineral(n1, _, _),
                              trade_goods.Mineral(n2, _, _)
                            -> n1 == n2
                            trade_goods.Habitat(n1, _, _),
                              trade_goods.Habitat(n2, _, _)
                            -> n1 == n2
                            trade_goods.Weapons(n1, _, _),
                              trade_goods.Weapons(n2, _, _)
                            -> n1 == n2
                            trade_goods.Shields(n1, _, _),
                              trade_goods.Shields(n2, _, _)
                            -> n1 == n2
                            _, _ -> False
                          }
                        })

                      // Get base price of the item
                      let base_price = case item {
                        trade_goods.Protein(_, p, _) -> p
                        trade_goods.Hydro(_, p, _) -> p
                        trade_goods.Fuel(_, p, _) -> p
                        trade_goods.SpareParts(_, p, _) -> p
                        trade_goods.Mineral(_, p, _) -> p
                        trade_goods.Habitat(_, p, _) -> p
                        trade_goods.Weapons(_, p, _) -> p
                        trade_goods.Shields(_, p, _) -> p
                      }

                      // Calculate price ratio as percentage using integer arithmetic
                      let price_ratio_percent =
                        price_per_unit * 100 / base_price

                      // Determine acceptance chance based on price ratio and starport inventory
                      let acceptance_chance = case starport_has_item {
                        True -> {
                          case price_ratio_percent {
                            r if r <= 100 -> 0
                            r if r <= 150 -> 35
                            r if r <= 200 -> 50
                            _ -> 25
                          }
                        }
                        False -> {
                          case price_ratio_percent {
                            r if r <= 100 -> 90
                            r if r <= 150 -> 75
                            r if r <= 200 -> 50
                            _ -> 25
                          }
                        }
                      }

                      // Generate random number between 1 and 100
                      let random_chance = utils.random_range(1, 100)
                      // Convert acceptance chance to integer percentage and compare with random chance
                      let accepted = acceptance_chance >= random_chance

                      // Process the sale
                      case accepted {
                        True -> {
                          // Check if price is too high (>200% of base price) and apply greed tax
                          case price_ratio_percent > 200 && starport_has_item {
                            True -> {
                              // Apply greed tax for excessive price
                              let taxed_player =
                                handle_offer_response(
                                  price_ratio_percent,
                                  price_per_unit,
                                  quantity,
                                  player,
                                )
                              Ok(taxed_player)
                            }
                            False -> {
                              // Standard successful transaction
                              let total_price = price_per_unit * quantity

                              // Update player's credits and cargo
                              let updated_cargo =
                                list.map(player.cargo, fn(p) {
                                  case p {
                                    #(i, q) if i == item -> #(i, q - quantity)
                                    x -> x
                                  }
                                })
                                |> list.filter(fn(x) { x.1 > 0 })

                              let updated_player =
                                player.Player(
                                  name: player.name,
                                  ship: player.ship,
                                  homeworld: player.homeworld,
                                  credits: player.credits + total_price,
                                  cargo: updated_cargo,
                                )

                              io.println(
                                "\nOffer accepted! You've earned "
                                <> int.to_string(total_price)
                                <> " credits.",
                              )
                              Ok(updated_player)
                            }
                          }
                        }
                        False -> {
                          // Starport rejects the offer
                          case starport_has_item {
                            True -> {
                              // Standard rejection for reasonable but not accepted offers
                              case price_ratio_percent > 200 {
                                True -> {
                                  io.println(
                                    "No. We have anti-greed taxes here. Be careful or we will levy one upon you.",
                                  )
                                }
                                False -> {
                                  io.println("No thank you.")
                                }
                              }
                              Ok(player)
                            }
                            False -> {
                              io.println("We're not interested in that price.")
                              Ok(player)
                            }
                          }
                        }
                      }
                    }
                    _ -> {
                      io.println("Invalid price. Please enter a number.")
                      Ok(player)
                    }
                  }
                }
              }
            }
            _ -> {
              io.println("Invalid item selection.")
              Ok(player)
            }
          }
        }
        _ -> {
          io.println("Invalid selection.")
          Ok(player)
        }
      }
    }
  }
}
