import gleam/io
import gleam/string

// I was returning a Result<String, String> but it was not working. I just need a string.
@external(erlang, "io", "get_line")
pub fn get_line(prompt: String) -> String

pub fn main() {
  io.println("Starting Space The Last Place To Work!\n")
  let cap = get_line("Enter a key. Q to quit.\n")
  case string.trim(cap) {
    "q" -> io.println("Quiting\n")
    _ -> turn()
  }
}

pub fn turn() {
  io.println("Game continues\n")
  player()
  npc()
  environment()
  main()
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
