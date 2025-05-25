import gleam/io
import gleam_community/ansi

pub fn display_title_screen() {
  let title_screen =
    "\u{001b}[2J\u{001b}[H"
    // Clear screen and move cursor to top
    <> "\n\n"
    <> "    "
    <> ansi.yellow("*")
    <> "                                           "
    <> ansi.white(".")
    <> "                   "
    <> ansi.magenta("*")
    <> "\n"
    <> ansi.cyan(".")
    <> "                      "
    <> ansi.yellow(".")
    <> "                                           "
    <> ansi.white("*")
    <> "\n"
    <> "            "
    <> ansi.magenta("*")
    <> "                                                             "
    <> ansi.cyan("*")
    <> "\n"
    <> "                "
    <> ansi.blue("████████ ██████   ██████   ██████  ███████")
    <> "\n"
    <> ansi.white(".")
    <> "               "
    <> ansi.blue("██       ██   ██ ██   ██ ██       ██     ")
    <> "      "
    <> ansi.yellow("*")
    <> "\n"
    <> "                "
    <> ansi.blue("███████  ██████  ██████  ██       █████  ")
    <> "\n"
    <> "     "
    <> ansi.cyan("*")
    <> "           "
    <> ansi.blue("     ██ ██      ██   ██ ██       ██     ")
    <> "\n"
    <> "                "
    <> ansi.blue("███████  ██      ██   ██  ██████  ███████")
    <> "         "
    <> ansi.magenta(".")
    <> "\n"
    <> "                 "
    <> ansi.black("██████  █      █   █   █████  ██████")
    <> "\n"
    <> "  "
    <> ansi.yellow(".")
    <> "                                                               "
    <> ansi.white("*")
    <> "\n"
    <> "                         "
    <> ansi.cyan("The Last Place To Work")
    <> "\n"
    <> "           "
    <> ansi.magenta("*")
    <> "                                     "
    <> ansi.cyan(".")
    <> "              "
    <> ansi.yellow("*")

  io.print(title_screen)
}

// Alternative version using the raw ANSI escape codes directly
pub fn display_title_screen_raw() {
  let title_screen =
    "\u{001b}[2J\u{001b}[H"
    // Clear screen and move cursor to top
    <> "\n\n"
    <> "    \u{001b}[33m*\u{001b}[0m                                           \u{001b}[37m.\u{001b}[0m                   \u{001b}[35m*\u{001b}[0m\n"
    <> "\u{001b}[36m.\u{001b}[0m                      \u{001b}[33m.\u{001b}[0m                                           \u{001b}[37m*\u{001b}[0m\n"
    <> "            \u{001b}[35m*\u{001b}[0m                                                             \u{001b}[36m*\u{001b}[0m\n"
    <> "                \u{001b}[1;34m████████ ██████   ██████   ██████  ███████\u{001b}[0m\n"
    <> "\u{001b}[37m.\u{001b}[0m               \u{001b}[1;34m██       ██   ██ ██   ██ ██       ██     \u{001b}[0m      \u{001b}[33m*\u{001b}[0m\n"
    <> "                \u{001b}[1;34m███████  ██████  ██████  ██       █████  \u{001b}[0m\n"
    <> "     \u{001b}[36m*\u{001b}[0m           \u{001b}[1;34m     ██ ██      ██   ██ ██       ██     \u{001b}[0m\n"
    <> "                \u{001b}[1;34m███████  ██      ██   ██  ██████  ███████\u{001b}[0m         \u{001b}[35m.\u{001b}[0m\n"
    <> "                 \u{001b}[30m██████  █      █   █   █████  ██████\u{001b}[0m\n"
    <> "  \u{001b}[33m.\u{001b}[0m                                                               \u{001b}[37m*\u{001b}[0m\n"
    <> "                         \u{001b}[1;96mThe Last Place To Work\u{001b}[0m\n"
    <> "           \u{001b}[35m*\u{001b}[0m                                     \u{001b}[36m.\u{001b}[0m              \u{001b}[33m*\u{001b}[0m"

  io.print(title_screen)
}

// Cleaner version with separate helper functions
pub fn display_title_screen_clean() {
  clear_screen()
  print_empty_lines(2)
  print_star_field_top()
  print_space_logo()
  print_star_field_bottom()
  print_subtitle()
  print_star_field_final()
}

fn clear_screen() {
  io.print("\u{001b}[2J\u{001b}[H")
}

fn print_empty_lines(count: Int) {
  case count {
    0 -> Nil
    n -> {
      io.print("\n")
      print_empty_lines(n - 1)
    }
  }
}

fn print_star_field_top() {
  io.print(
    "    "
    <> ansi.yellow("*")
    <> "                                           "
    <> ansi.white(".")
    <> "                   "
    <> ansi.magenta("*")
    <> "\n",
  )
  io.print(
    ansi.cyan(".")
    <> "                      "
    <> ansi.yellow(".")
    <> "                                           "
    <> ansi.white("*")
    <> "\n",
  )
  io.print(
    "            "
    <> ansi.magenta("*")
    <> "                                                             "
    <> ansi.cyan("*")
    <> "\n",
  )
}

fn print_space_logo() {
  let padding = "                "
  let shadow_padding = "                 "

  io.print(
    padding <> ansi.blue("████████ ██████   ██████   ██████  ███████") <> "\n",
  )
  io.print(
    ansi.white(".")
    <> "               "
    <> ansi.blue("██       ██   ██ ██   ██ ██       ██     ")
    <> "      "
    <> ansi.yellow("*")
    <> "\n",
  )
  io.print(
    padding <> ansi.blue("███████  ██████  ██████  ██       █████  ") <> "\n",
  )
  io.print(
    "     "
    <> ansi.cyan("*")
    <> "           "
    <> ansi.blue("     ██ ██      ██   ██ ██       ██     ")
    <> "\n",
  )
  io.print(
    padding
    <> ansi.blue("███████  ██      ██   ██  ██████  ███████")
    <> "         "
    <> ansi.magenta(".")
    <> "\n",
  )
  io.print(
    shadow_padding <> ansi.black("██████  █      █   █   █████  ██████") <> "\n",
  )
}

fn print_star_field_bottom() {
  io.print(
    "  "
    <> ansi.yellow(".")
    <> "                                                               "
    <> ansi.white("*")
    <> "\n",
  )
}

fn print_subtitle() {
  let subtitle_padding = "                         "
  io.print(subtitle_padding <> ansi.cyan("The Last Place To Work") <> "\n")
}

fn print_star_field_final() {
  io.print(
    "           "
    <> ansi.magenta("*")
    <> "                                     "
    <> ansi.cyan(".")
    <> "              "
    <> ansi.yellow("*"),
  )
}
