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

  // Helper function to wrap coordinates within universe bounds (0-9)
  let wrap = fn(coord: Int) -> Int {
    let mod = coord % 10
    case mod < 0 {
      True -> mod + 10
      False -> mod
    }
  }

  // Get player's wrapped coordinates
  let wrapped_x = wrap(x)
  let wrapped_y = wrap(y)

  // Display player's current position
  io.println(
    "\n=== Minimap (You are at "
    <> int.to_string(wrapped_x)
    <> ":"
    <> int.to_string(wrapped_y)
    <> ") ===",
  )
  io.println(
    "  (.) Empty space  (P) Planet  (S) Starport  (Y) You  (>) NPC Ship",
  )

  // Fixed 10x10 grid centered on player
  let grid_size = 10
  let half_size = 5
  // Half of grid size

  // Calculate starting coordinates (5 rows/cols behind player)
  let start_x = wrap(wrapped_x - half_size)
  let start_y = wrap(wrapped_y - half_size)

  // Calculate ending coordinates (4 rows/cols ahead of player, since start is inclusive)
  let end_x = wrap(start_x + grid_size - 1)
  let end_y = wrap(start_y + grid_size - 1)

  // Print top border
  io.print("   +")
  list.each(list.repeat(item: "---", times: grid_size), fn(s) { io.print(s) })
  io.println("+")

  // Print map rows
  let display_range = fn(start, end) -> List(Int) {
    case start <= end {
      True -> list.range(from: start, to: end)
      False ->
        list.append(
          list.range(from: start, to: 9),
          list.range(from: 0, to: end),
        )
    }
  }

  // Get y-coordinates to display (with wrapping)
  let y_coords = display_range(start_y, end_y)

  // For each row
  list.each(y_coords, fn(map_y) {
    // Print left border
    io.print("   |")

    // Get x-coordinates to display (with wrapping)
    let x_coords = display_range(start_x, end_x)

    // Print map cells
    list.each(x_coords, fn(map_x) {
      // Check if this is the player's location (using wrapped coordinates)
      let is_player_here = map_x == wrapped_x && map_y == wrapped_y

      // Check for homeworld (player's starting planet)
      let is_homeworld = case player.homeworld {
        option.Some(planet) ->
          planet.position.x == map_x && planet.position.y == map_y
        option.None -> False
      }

      // Check for other planets and starports
      let has_planet =
        list.any(universe.planets, fn(planet) {
          planet.position.x == map_x && planet.position.y == map_y
        })
        && !is_homeworld

      let has_starport =
        list.any(universe.planets, fn(planet) {
          planet.position.x == map_x
          && planet.position.y == map_y
          && planet.has_starport
        })

      // Check for NPC ships at this location
      let has_npc_ship =
        list.any(npc_ships, fn(npc_ship) {
          let #(nx, ny) = npc_ship.location
          nx == map_x && ny == map_y
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

    // Print right border and row number
    io.println(" | " <> int.to_string(map_y))
  })

  // Print bottom border
  io.print("   +")
  list.each(list.repeat(item: "---", times: grid_size), fn(s) { io.print(s) })
  io.println("+")
  io.println("")

  // Print x-axis labels
  io.print("    ")
  let x_coords = display_range(start_x, end_x)
  list.each(x_coords, fn(map_x) {
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
