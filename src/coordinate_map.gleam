import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import player
import ship
import universe

// Display a minimap showing the player's current location and nearby points of interest
// If show_npc_info is True, will display NPC ship locations
pub fn show_minimap(
  player: player.Player,
  universe: universe.Universe,
  npc_ships: List(ship.Ship),
  show_npc_info: Bool,
) {
  // Print NPC ship locations if enabled
  case show_npc_info {
    True -> {
      io.println(
        "\n=== NPC Ships ("
        <> int.to_string(list.length(npc_ships))
        <> " total) ===",
      )
      list.each(npc_ships, fn(ship) {
        let #(x, y) = ship.location
        io.println("  NPC at " <> int.to_string(x) <> ":" <> int.to_string(y))
      })
    }
    False -> Nil
  }
  let #(x, y) = player.ship.location

  // Display player's current position
  io.println(
    "\n=== Minimap (You are at "
    <> int.to_string(x)
    <> ":"
    <> int.to_string(y)
    <> ") ===",
  )

  // Helper function to wrap coordinates within universe bounds (0-49)
  let wrap = fn(coord: Int) -> Int {
    let mod = coord % 50
    case mod < 0 {
      True -> mod + 50
      False -> mod
    }
  }

  // Calculate starting coordinates for a 10x10 grid centered on player
  // 5 in each direction (including center) to make 10x10 grid
  let start_x = wrap(x - 5)
  let start_y = wrap(y - 5)
  io.println(
    "  (.) Empty space  (P) Planet  (S) Starport  (Y) You  (>) NPC Ship",
  )

  // Function to get display range with wrapping for a fixed size
  let display_range = fn(start, count: Int) -> List(Int) {
    list.map(list.range(0, count - 1), fn(i) { wrap(start + i) })
  }

  // Print top border
  io.print("   +")
  list.each(list.repeat(item: "---", times: 10), fn(s) { io.print(s) })
  io.println("+")

  // For each row (0-9)
  list.each(list.range(0, 9), fn(y_offset) {
    // Calculate actual y-coordinate for this row (with wrapping)
    let actual_y = wrap(start_y + y_offset)

    // Format y-coordinate with padding
    let y_str = case int.to_string(actual_y) {
      "0" -> " 0"
      s ->
        case string.length(s) {
          1 -> " " <> s
          _ -> s
        }
    }

    // Print y-coordinate and left border
    io.print(" ")
    io.print(y_str)
    io.print("|")

    // For each column (0-9)
    list.each(list.range(0, 9), fn(x_offset) {
      // Calculate actual x-coordinate for this column (with wrapping)
      let actual_x = wrap(start_x + x_offset)

      // Check if this is the player's location (center of the grid)
      let is_player_here = actual_x == x && actual_y == y

      // Check for homeworld (player's starting planet)
      let is_homeworld = case player.homeworld {
        option.Some(planet) ->
          planet.position.x == actual_x && planet.position.y == actual_y
        option.None -> False
      }

      // Check for other planets and starports
      let has_planet =
        list.any(universe.planets, fn(planet) {
          planet.position.x == actual_x && planet.position.y == actual_y
        })
        && !is_homeworld

      let has_starport =
        list.any(universe.planets, fn(planet) {
          planet.position.x == actual_x
          && planet.position.y == actual_y
          && planet.has_starport
        })

      // Check for NPC ships at this location
      let has_npc_ship =
        list.any(npc_ships, fn(npc_ship) {
          let #(nx, ny) = npc_ship.location
          nx == actual_x && ny == actual_y
        })

      // Determine what to print based on what's at this location
      // Priority: Player > Homeworld > Starport > Planet > NPC > Empty
      let symbol = case
        is_player_here,
        is_homeworld,
        has_starport,
        has_planet,
        has_npc_ship
      {
        True, _, _, _, _ -> " Y "
        _, True, _, _, _ -> " H "
        _, _, True, _, _ -> " S "
        _, _, _, True, _ -> " P "
        _, _, _, _, True -> " > "
        _, _, _, _, _ -> " . "
      }

      io.print(symbol)
    })

    // Print right border
    io.println(" |")
  })

  // Print x-axis numbers at the bottom
  io.print("    ")
  list.each(list.range(0, 9), fn(x_offset) {
    let x = wrap(start_x + x_offset)
    let num = int.to_string(x)
    io.print(case string.length(num) {
      1 -> "  " <> num
      2 -> " " <> num
      _ -> num
    })
    io.print(" ")
  })
  io.println("")

  io.println("")

  // Print x-axis labels
  io.print("    ")
  list.each(display_range(start_x, 10), fn(map_x) {
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
