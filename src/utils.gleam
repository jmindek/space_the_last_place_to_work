import gleam/string

// I was returning a Result<String, String> but it was not working. I just need a string.
@external(erlang, "io", "get_line")
pub fn get_line(prompt: String) -> String

pub fn get_trimmed_line(prompt: String) -> String {
  string.trim(get_line(prompt))
}
