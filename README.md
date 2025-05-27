<pre style="background-color: black; color: white; padding: 20px; font-family: monospace;">
    <span style="color: #ffff00;">*</span>                                           <span style="color: #ffffff;">.</span>                   <span style="color: #ff00ff;">*</span>
<span style="color: #00ffff;">.</span>                      <span style="color: #ffff00;">.</span>                                           <span style="color: #ffffff;">*</span>
            <span style="color: #ff00ff;">*</span>                                                             <span style="color: #00ffff;">*</span>
                <span style="color: #0000ff; font-weight: bold;">████████ ██████   ██████   ██████  ███████</span>
<span style="color: #ffffff;">.</span>               <span style="color: #0000ff; font-weight: bold;">██       ██   ██ ██   ██ ██       ██     </span>      <span style="color: #ffff00;">*</span>
                <span style="color: #0000ff; font-weight: bold;">███████  ██████  ██████  ██       █████  </span>
     <span style="color: #00ffff;">*</span>           <span style="color: #0000ff; font-weight: bold;">     ██ ██      ██   ██ ██       ██     </span>
                <span style="color: #0000ff; font-weight: bold;">███████  ██      ██   ██  ██████  ███████</span>         <span style="color: #ff00ff;">.</span>
  <span style="color: #ffff00;">.</span>                                                               <span style="color: #ffffff;">*</span>

                         <span style="color: #00ffff; font-weight: bold;">The Last Place To Work</span>

           <span style="color: #ff00ff;">*</span>                                     <span style="color: #00ffff;">.</span>              <span style="color: #ffff00;">*</span>
</pre>

Space, it's the last place to work. Can you make a living? 
Maybe. 
More likely you'll burn out your remaining energy in the quest for riches and die drifting alone encouraging your crew not to eat each other (for decencies sake) in some uncharted part of space.

## Inspiration

My Gleam side-project is an homage to 80s BBS ANSI adventure games I used to play as a kid. The main source of inspiration is [Trade Wars 2002](https://en.wikipedia.org/wiki/Trade_Wars). But I also enjoyed and hope to pull from [Legend of the Red Dragon](https://en.wikipedia.org/wiki/Legend_of_the_Red_Dragon), Freshwater Fishing Simulator and others.

## Why Gleam?

I love new non-OO languages and right now I'm learning Gleam. To fast-track my learning, I figured I would build something fun.

Gleam is in no way the optimal language for this project as a single user game.
However if I scale it to a multi-player game, then it may be a good fit due to Erlang's ability to handle tons of concurrent users.

## Gameplay

In Space: The Last Place to Work, players can:

- **Navigate** between star systems and planets
- **Trade** goods between different planets for profit
- **Buy and sell** various trade goods with fluctuating prices


### Coming Soon

- **Battle** space pirates and other hostile forces
- **Dock** at space stations to repair and resupply
- **Manage** ship resources including fuel, shields, and cargo space

### Future

- **Complete** missions and contracts for credits
- **Hire** crew members with different skills
- **Encounter** random space events and make choices that affect the game
- **Mine** asteroids for valuable resources
- **Space** crew members (_how could this not be a feature???_)
- **Upgrade** their ship with better equipment and cargo holds


## Playing

### Prerequisites

1. **Install Gleam**
   - **macOS (using Homebrew)**:
     ```sh
     brew install gleam
     ```
     *Note: This will automatically install Erlang/OTP as a dependency*
   
   - **Windows**:
     1. First install Erlang/OTP 25+:
       - Using Chocolatey:
         ```powershell
         choco install erlang
         ```
       - Or download from [Erlang.org](https://www.erlang.org/downloads)
     
     2. Then install Gleam:
       - Using Scoop:
         ```powershell
         scoop install gleam
         ```
       - Or download from [Gleam's website](https://gleam.run/getting-started/installing/)

### Running the Game

1. **Clone the repository**
   ```sh
   git clone https://github.com/jmindek/space_the_last_place_to_work.git
   cd space_the_last_place_to_work
   ```

2. **Run the game**
   ```sh
   gleam run
   ```
