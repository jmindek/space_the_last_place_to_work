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

// Display a map showing the player's location and nearby objects
pub fn show_location_map(
  player: player.Player,
  universe: universe.Universe,
) -> Nil {
  let #(player_x, player_y) = player.ship.location

  // Calculate the visible area (10x5 grid centered on player)
  let start_x = player_x - 4
  // Show 4 columns to the left
  let end_x = player_x + 5
  // and 5 columns to the right (10 total)
  let start_y = player_y - 2
  // Show 2 rows above
  let end_y = player_y + 2
  // and 2 rows below (5 total)
  // Print header
  io.println("\n      " <> string.repeat("-", 19))
  io.println("     |0 1 2 3 4 5 6 7 8 9|")
  io.println("     +------------------+")

  // Print each row
  list.each(list.range(start_y, end_y), fn(y) {
    // Print row number with padding for alignment
    let y_str = int.to_string(y)
    let padding = case string.length(y_str) {
      1 -> "  "
      // Two spaces for single-digit numbers
      2 -> " "
      // One space for two-digit numbers
      _ -> ""
      // No space for three-digit numbers
    }
    io.print(padding <> y_str <> " |")

    // Print each column in the row
    list.each(list.range(start_x, end_x), fn(x) {
      // Check if this is the player's position
      case x == player_x && y == player_y {
        True -> io.print("* ")
        False -> {
          // Check if there's a planet at this position
          let has_planet =
            list.any(universe.planets, fn(planet) {
              planet.position.x == x && planet.position.y == y
            })

          // Print the appropriate symbol
          case has_planet {
            True -> io.print("0 ")
            False -> io.print(". ")
          }
        }
      }
    })

    // End of row
    io.println("|")
  })

  // Print footer and legend
  io.println("     +------------------+")
  io.println("     * = Your ship")
  io.println("     0 = Planet")
  io.println("     . = Empty space")
}
