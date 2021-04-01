# What does this do?

This simulates Conway's Game of Life in the terminal using ASCII chars. It's bare bones and makes no effort to optimize the calculation, emphasizing clarity over all. Each state is printed line-by-line. The output is limited by a time function which prevents the screen from flickering.

You may need to increase the size of the window, or change the height and width of the graph, to get a nice result.

# How do I run the program?

If you want to compile `game_of_life` yourself, you need to have `zig` installed:

```
$ brew install zig
```

Then to build, open the terminal and type

```
$ zig run game_of_life.zig
```

Each time the program starts with a new random seed, so you'll get a new graph every time. 

# What I learned 

* how to work with and call initialized structs
* ANSI escape codes

# What next?

* automatic terminal sizing
* using a graphics library to make more uniform squares
* pause, save, rewind?
* custom initial states?

# Have suggestions?

Let me know!