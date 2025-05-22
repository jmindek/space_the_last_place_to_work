import gleam/io
import gleam/string
import universe

// I was returning a Result<String, String> but it was not working. I just need a string.
@external(erlang, "io", "get_line")
pub fn get_line(prompt: String) -> String

@external(erlang, "init", "stop")
pub fn stop() -> a

fn with_quit_prompt(prompt: String, on_continue: fn() -> a) -> a {
  case string.trim(get_line(prompt)) {
    "q" -> {
      io.println("Quitting\n")
      // Use exit_with to properly type the exit with a value
      // This will never actually return, satisfying the type system
      // The Never type is used to indicate this branch never returns
      stop()
    }
    _ -> on_continue()
  }
}

pub fn main() {
  io.println("Starting Space The Last Place To Work!\n")
  with_quit_prompt("Enter a key. Q to quit.\n", setup)
}

pub fn setup() {
  let universe = universe.create_universe(100, 10)
  io.println("Universe created\n")
  turn(universe)
}

pub fn turn(universe: universe) {
  player()
  npc()
  environment()
  with_quit_prompt("Enter a key. Q to quit.\n", fn() { turn(universe) })
}

pub fn player() {
  io.println("Player's turn\n")
}

pub fn npc() {
  io.println("NPC's turn\n")
}

pub fn environment() {
  io.println("Environment's turn\n")
}
