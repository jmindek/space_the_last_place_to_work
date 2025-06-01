import gleam/io
import gleam/string

// I was returning a Result<String, String> but it was not working. I just need a string.
@external(erlang, "io", "get_line")
pub fn get_line(prompt: String) -> String

@external(erlang, "init", "stop")
pub fn stop() -> a

/// Shows a prompt and handles quit functionality
/// Returns the result of the on_continue function if user doesn't quit
/// Returns Error if user chooses to quit
pub fn with_quit_prompt(
  prompt: String,
  on_continue: fn() -> Result(a, String),
) -> Result(a, String) {
  let input = get_trimmed_line(prompt)
  case input {
    "q" | "Q" -> {
      io.println("\nThanks for playing!")
      stop()
      // This line is theoretically unreachable due to stop()
      Error("Game stopped")
    }
    _ -> on_continue()
  }
}

pub fn get_trimmed_line(prompt: String) -> String {
  let input = get_line(prompt)
  case input {
    "" -> ""
    _ -> string.trim(input)
  }
}

// Generate a random integer between min and max (inclusive)
@external(erlang, "rand", "uniform")
pub fn random_uniform(max: Int) -> Int

pub fn random_range(min: Int, max: Int) -> Int {
  let range = max - min + 1
  min + random_uniform(range) % range
}
