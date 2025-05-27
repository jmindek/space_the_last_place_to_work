import gleam/list
import gleam/option
import gleam/regex
import gleam/string
import ship
import trade_goods
import universe

// Player type that holds all player information
pub type Player {
  Player(
    name: String,
    ship: ship.Ship,
    homeworld: option.Option(universe.Planet),
    credits: Int,
    cargo: List(#(trade_goods.TradeGoods, Int)),
    // (TradeGood type, quantity)
  )
}

// Validate player name according to constraints
fn validate_name(name: String) -> Result(String, String) {
  let pattern = "^[a-zA-Z0-9_-]{1,64}$"
  case regex.from_string(pattern) {
    Ok(re) ->
      case regex.check(re, name) {
        True -> Ok(name)
        False ->
          Error(
            "Name must be 1-64 characters long and can only contain letters, hyphens, and underscores",
          )
      }
    Error(_) -> Error("Invalid regular expression")
  }
}

// Create a new player with a name and ship class
pub fn new(name: String, ship_class: ship.ShipClass) -> Result(Player, String) {
  case validate_name(name) {
    Ok(valid_name) -> {
      let player_ship = ship.new_ship(ship_class, #(0, 0))
      Ok(Player(
        name: valid_name,
        ship: player_ship,
        homeworld: option.None,
        credits: 1000,
        // Starting credits
        cargo: [],
        // Start with empty cargo
      ))
    }
    Error(e) -> Error(e)
  }
}

// Get a list of planets that have starports
pub fn get_planets_with_starports(
  universe: universe.Universe,
) -> List(universe.Planet) {
  list.filter(universe.planets, fn(planet: universe.Planet) {
    planet.has_starport
  })
}

// Set the player's homeworld
pub fn set_homeworld(
  player: Player,
  planet: universe.Planet,
) -> Result(Player, String) {
  case planet.has_starport {
    True -> {
      let updated_player =
        Player(
          ..player,
          homeworld: option.Some(planet),
          credits: 1000,
          // Ensure credits are set
          cargo: player.cargo,
          // Keep existing cargo
        )
      Ok(updated_player)
    }
    False -> Error("Selected planet does not have a starport")
  }
}

// Move the player's ship to new coordinates in a continuous universe
// If coordinates exceed bounds, they wrap around to the opposite side
pub fn move_ship(
  player: Player,
  x: Int,
  y: Int,
  universe: universe.Universe,
) -> Result(Player, String) {
  let updated_ship = ship.move_ship(player.ship, x, y, universe.size)
  Ok(Player(..player, ship: updated_ship))
}

// Update the player's ship speed
pub fn set_ship_speed(player: Player, speed: Int) -> Player {
  let updated_ship = ship.set_speed(player.ship, speed)
  Player(..player, ship: updated_ship)
}

// Format player information as a string
pub fn to_string(p: Player) -> String {
  let homeworld_str = case p.homeworld {
    option.Some(planet) -> "Homeworld: " <> planet.name
    option.None -> "No homeworld selected"
  }

  string.concat([
    "Player: " <> p.name <> "\n",
    "Ship: " <> ship.to_string(p.ship) <> "\n",
    homeworld_str <> "\n",
  ])
}
