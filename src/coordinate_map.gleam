import gleam/int
import gleam/io
import gleam/list
import gleam/string

import player
import universe

// Display a minimap showing the player's current location and nearby points of interest
pub fn show_minimap(player: player.Player, universe: universe.Universe) {
  let #(x, y) = player.ship.location
  let map_size = 10
  // 10x10 grid around the player

  io.println(
    "\n=== Minimap (You are at "
    <> int.to_string(x)
    <> ":"
    <> int.to_string(y)
    <> ") ===",
  )
  io.println("  (.) Empty space  (P) Planet  (S) Starport  (Y) You")

  // Calculate map bounds (ensure we have at least 1x1 map)
  let map_size_int = int.max(1, int.min(10, map_size))
  let half_size = map_size_int / 2
  let start_y = y - half_size
  let start_x = x - half_size
  let end_y = y + half_size
  let end_x = x + half_size

  // Print top border
  io.print("   +")
  list.each(list.repeat(item: "---", times: map_size_int), fn(s) { io.print(s) })
  io.println("+")

  // Print map rows
  list.range(from: start_y, to: end_y)
  |> list.each(fn(map_y) {
    // Print left border
    io.print("   |")

    // Print map cells
    list.range(from: start_x, to: end_x)
    |> list.each(fn(map_x) {
      // Check if this is the player's location
      case map_x == x && map_y == y {
        True -> io.print(" Y ")
        False -> {
          // Check for planets at this location
          let has_planet =
            list.any(universe.planets, fn(planet) {
              planet.position.x == map_x && planet.position.y == map_y
            })

          // Check for starports at this location
          let has_starport =
            list.any(universe.planets, fn(planet) {
              planet.position.x == map_x
              && planet.position.y == map_y
              && planet.has_starport
            })

          // Determine what to print based on what's at this location
          let symbol = case has_starport, has_planet {
            True, _ -> " S "
            False, True -> " P "
            False, False -> " . "
          }

          io.print(symbol)
        }
      }
    })

    // Print right border and row number
    io.println(" | " <> int.to_string(map_y))
  })

  // Print bottom border
  io.print("   +")
  list.each(list.repeat(item: "---", times: map_size_int), fn(s) { io.print(s) })
  io.print("+")
  io.println("")

  // Print x-axis labels
  io.print("    ")
  list.each(list.range(from: start_x, to: end_x), fn(map_x) {
    let label = int.to_string(map_x)
    let padding = 3 - string.length(label)
    let spaces = string.repeat(" ", times: padding)
    io.print(label <> spaces)
  })
  io.println("")
}
