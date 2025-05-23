import gleam/io
import gleam/list
import gleam/option
import gleam/string
import gleeunit/should
import player
import ship
import universe

// Helper function to create a test universe with some planets
fn create_test_universe() -> universe.Universe {
  let planets = [
    universe.Planet(
      position: universe.Position(1, 1),
      life_supporting: True,
      population: 1000,
      water_percentage: 70,
      oxygen_percentage: 21,
      gravity: 1.0,
      industry: universe.Agra,
      mapping_percentage: 100,
      name: "Earth",
      moons: 1,
      has_starport: True,
      has_ftl_lane: True,
    ),
    universe.Planet(
      position: universe.Position(5, 5),
      life_supporting: False,
      population: 0,
      water_percentage: 0,
      oxygen_percentage: 0,
      gravity: 0.38,
      industry: universe.Mining,
      mapping_percentage: 100,
      name: "Mars",
      moons: 2,
      has_starport: False,
      has_ftl_lane: False,
    ),
    universe.Planet(
      position: universe.Position(3, 3),
      life_supporting: True,
      population: 5000,
      water_percentage: 80,
      oxygen_percentage: 22,
      gravity: 0.9,
      industry: universe.Technology,
      mapping_percentage: 100,
      name: "New Terra",
      moons: 3,
      has_starport: True,
      has_ftl_lane: True,
    ),
  ]
  universe.Universe(size: 10, planets: planets)
}

// Helper function to create a test player
pub fn create_test_player() -> Result(player.Player, String) {
  let test_universe = create_test_universe()
  case player.new("TestPlayer", ship.Shuttle) {
    Ok(p) -> {
      case
        list.find(test_universe.planets, fn(planet) { planet.name == "Earth" })
      {
        Ok(earth) -> {
          player.set_homeworld(p, earth)
        }
        Error(_) -> Error("Earth not found in test universe")
      }
    }
    Error(e) -> Error(e)
  }
}

pub fn new_player_test() {
  // Test valid name
  case player.new("ValidName", ship.Shuttle) {
    Ok(player1) -> {
      player1.name
      |> should.equal("ValidName")

      player1.homeworld
      |> should.equal(option.None)

      // Test invalid name (too long)
      let long_name =
        "ThisNameIsWayTooLongAndExceedsThe64CharacterLimitByQuiteABit1234567890"
      case player.new(long_name, ship.Shuttle) {
        Ok(_) -> {
          io.println("Should not create player with too long name")
          should.fail()
        }
        Error(_) -> Nil
      }

      // Test invalid characters
      case player.new("Invalid@Name", ship.Shuttle) {
        Ok(_) -> {
          io.println("Should not create player with invalid characters")
          should.fail()
        }
        Error(_) -> Nil
      }
    }
    Error(e) -> {
      io.println("Failed to create test player: " <> e)
      should.fail()
    }
  }
}

pub fn set_homeworld_test() {
  let test_universe = create_test_universe()

  // Find Earth in the test universe
  case list.find(test_universe.planets, fn(planet) { planet.name == "Earth" }) {
    Ok(earth) -> {
      // Create a test player
      case player.new("Test", ship.Shuttle) {
        Ok(p) -> {
          // Test setting homeworld to a planet with a starport
          case player.set_homeworld(p, earth) {
            Ok(player_with_homeworld) -> {
              // Verify homeworld was set correctly
              case player_with_homeworld.homeworld {
                option.Some(planet) -> {
                  planet.name
                  |> should.equal("Earth")

                  // Test setting homeworld to a planet without a starport
                  case
                    list.find(test_universe.planets, fn(planet) {
                      planet.name == "Mars"
                    })
                  {
                    Ok(mars) -> {
                      case player.set_homeworld(p, mars) {
                        Ok(_) ->
                          io.println(
                            "Error: Should not be able to set homeworld to Mars",
                          )
                        Error(_) -> Nil
                        // Expected error
                      }
                    }
                    Error(_) -> io.println("Mars not found in test universe")
                  }
                }
                option.None ->
                  io.println("Error: Homeworld should be set to Earth")
              }
            }
            Error(e) -> io.println("Failed to set homeworld: " <> e)
          }
        }
        Error(e) -> io.println("Failed to create test player: " <> e)
      }
    }
    Error(_) -> io.println("Earth not found in test universe")
  }
}

pub fn move_ship_test() {
  let test_universe = create_test_universe()
  case player.new("Test", ship.Shuttle) {
    Ok(player) -> {
      // Test normal movement
      case player.move_ship(player, 5, 5, test_universe) {
        Ok(moved1) -> {
          moved1.ship.location
          |> should.equal(#(5, 5))

          // Test wrapping around right edge
          case player.move_ship(player, 12, 5, test_universe) {
            Ok(moved2) -> {
              moved2.ship.location
              |> should.equal(#(2, 5))

              // Test wrapping around left edge
              case player.move_ship(player, -3, 5, test_universe) {
                Ok(moved3) -> {
                  moved3.ship.location
                  |> should.equal(#(7, 5))

                  // Test wrapping around top and bottom
                  case player.move_ship(player, 5, -3, test_universe) {
                    Ok(moved4) -> {
                      moved4.ship.location
                      |> should.equal(#(5, 7))

                      case player.move_ship(player, 5, 15, test_universe) {
                        Ok(moved5) -> {
                          moved5.ship.location
                          |> should.equal(#(5, 5))
                        }
                        Error(e) -> io.println("Failed to move ship: " <> e)
                      }
                    }
                    Error(e) -> io.println("Failed to move ship: " <> e)
                  }
                }
                Error(e) -> io.println("Failed to move ship: " <> e)
              }
            }
            Error(e) -> io.println("Failed to move ship: " <> e)
          }
        }
        Error(e) -> {
          io.println("Failed to move ship: " <> e)
          should.fail()
        }
      }
    }
    Error(e) -> {
      io.println("Failed to create test player: " <> e)
      should.fail()
    }
  }
}

pub fn get_planets_with_starports_test() {
  let test_universe = create_test_universe()
  let planets_with_starports = player.get_planets_with_starports(test_universe)
  let count = list.length(planets_with_starports)

  // Check that we have the correct number of planets with starports
  count
  |> should.equal(2)

  // Check that the correct planets are in the list
  let has_earth = list.any(planets_with_starports, fn(p) { p.name == "Earth" })
  has_earth
  |> should.be_true

  let has_new_terra =
    list.any(planets_with_starports, fn(p) { p.name == "New Terra" })
  has_new_terra
  |> should.be_true

  // Check that a planet without a starport is not in the list
  let has_mars = list.any(planets_with_starports, fn(p) { p.name == "Mars" })
  has_mars
  |> should.be_false
}

pub fn to_string_test() {
  let test_universe = create_test_universe()
  case list.find(test_universe.planets, fn(planet) { planet.name == "Earth" }) {
    Ok(earth) -> {
      case player.new("test", ship.Shuttle) {
        Ok(player1) -> {
          case player.set_homeworld(player1, earth) {
            Ok(player1_with_home) -> {
              let player1_str = player.to_string(player1_with_home)
              string.contains(string.lowercase(player1_str), "player: test\n")
              |> should.be_true

              // Check ship details are included
              string.contains(player1_str, "Ship: Class: Shuttle\n")
              |> should.be_true

              string.contains(
                string.lowercase(player1_str),
                "homeworld: earth\n",
              )
              |> should.be_true

              // Test without homeworld
              case player.new("test2", ship.Shuttle) {
                Ok(player2) -> {
                  let player2_str = player.to_string(player2)
                  string.contains(
                    string.lowercase(player2_str),
                    "player: test2\n",
                  )
                  |> should.be_true

                  string.contains(player2_str, "No homeworld selected\n")
                  |> should.be_true

                  // Verify ship details are still present
                  string.contains(player2_str, "Ship: Class: Shuttle\n")
                  |> should.be_true
                }
                Error(e) -> {
                  io.println("Failed to create test player 2: " <> e)
                  should.fail()
                }
              }
            }
            Error(e) -> {
              io.println("Failed to set homeworld: " <> e)
              should.fail()
            }
          }
        }
        Error(e) -> {
          io.println("Failed to create test player: " <> e)
          should.fail()
        }
      }
    }
    Error(_) -> {
      io.println("Earth not found in test universe")
      should.fail()
    }
  }
}
