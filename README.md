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

A Gleam project themed on the 80s BBS space resource text based adventure games. 

I 100% guarantee this will not be near as fun as those. 

## Development

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

### Development Commands

```sh
gleam format src test    # Format the code
gleam test   # Run the tests
gleam shell  # Start an Erlang shell with the project loaded
gleam build  # Compile the project
```
