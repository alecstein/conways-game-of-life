const std = @import("std");

// TODO Detect terminal window size
// TODO update on terminal window size change

pub fn main() !void {

    var grid = Grid(40, 140).init();

    while (true) {

        // main loop
        // sleep prevents terminal from flickering -- not strictly necessary

        std.time.sleep(40000000);

        grid.printToScr();
        grid.update();
    }

}

fn Grid(comptime height: usize, comptime width: usize) type {

    // Grid is the only object one needs to run the game,
    // containing all of the necessary functions (init, update, print)

    return struct {
        const Self = @This();
        height: usize,
        width: usize,
        grid: [height][width]u8,

        pub fn init() Self {

            // generate random numbers for the initial state

            var buf: [8]u8 = undefined;
            std.crypto.randomBytes(buf[0..]) catch unreachable;
            const seed = std.mem.readIntSliceLittle(u64, buf[0..8]);
            var rang = std.rand.DefaultPrng.init(seed);

            // initialize the grid

            var grid: [height][width]u8 = undefined;
            for (grid) |row, i| {
                for (row) |cell, j| {
                    const edge = (j == width - 1 or j == 0 or i == height - 1 or height == 0); // fix this
                    const r = rang.random.int(u8) % 20; // fix this
                    if (edge) {
                        grid[i][j] = 0;
                    } else if (r < 5) {
                        grid[i][j] = 1;
                    } else {
                        grid[i][j] = 0;
                    }
                }
            }

            return Self{
                .height = height,
                .width = width,
                .grid = grid,
            };
        }

        pub fn update(self: *Self) void {

            // applies Conway's rules

            var new_grid: [height][width]u8 = undefined; 
            for (new_grid) |row, i| {
                for (row) |cell, j| {
                    const edge = (j == width - 1 or j == 0 or i == height - 1 or i == 0); // fix this
                    if (edge) {
                        new_grid[i][j] = 0;
                        continue;
                    }
                    var alive_neighbors: u8 = 0;

                    // sum the cells around (and including) the cell in question
                    // instead of summing all 8 neighbors of a cell (laterals, verticals,
                    // and diagonals) it just sums a 3x3 block including the main cell.
                    // then we subtract off the value of that main cell in the next step.

                    const delt = [3]usize{ 0, 1, 2 };
                    for (delt) |x| {
                        for (delt) |y| {
                            alive_neighbors += self.grid[i + x - 1][j + y - 1];
                        }
                    }

                    // subtract the extra value in the center

                    alive_neighbors -= self.grid[i][j];

                    // Conway's rules
                    // note: this is not the optimal way of doing the calculation
                    
                    if (self.grid[i][j] == 1) {

                        // any live cell with fewer than two live neighbours dies, as if by underpopulation.

                        if (alive_neighbors < 2) {
                            new_grid[i][j] = 0;
                        } 
                        
                        // any live cell with two or three live neighbours lives on to the next generation.

                        else if (alive_neighbors == 2 or alive_neighbors == 3) {
                            new_grid[i][j] = 1;
                        } 

                        // any live cell with more than three live neighbours dies, as if by overpopulation.

                        else {
                            new_grid[i][j] = 0;
                        }
                    } 

                    else {

                        // any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

                        if (alive_neighbors == 3) {
                            new_grid[i][j] = 1;
                        } 
                        
                        else {
                            new_grid[i][j] = 0;
                        }
                    }

                    // from a reddit comment:

                    // any cell with three alive neighbors gets turned on
                    // otherwise if grid[i][j] == 1 and neighbors != 2, you turn it off.
                    // this code runs a little faster and is a little cleaner.

                    // if (alive_neighbors == 3) {
                    //     new_grid[i][j] = 1;
                    // }
                    // else if (self.grid[i][j] == 1 and alive_neighbors != 2) {
                    //     new_grid[i][j] = 0;
                    // }
                    // else {
                    //     new_grid[i][j] = self.grid[i][j];
                    // }

                }
            }
            self.grid = new_grid;
        }
        pub fn printToScr(self: Self) void {
            
            // clear the screen with an ANSI escpae code

            std.debug.print("\x1B[2J\x1B[H", .{});

            for (self.grid) |row| {
                std.debug.print("\n", .{});
                for (row) |cell| {
                    var v: []const u8 = undefined;
                    if (cell == 0) {
                        v = " ";
                    } else {
                        // v = " █"; // for those who want larger squares
                        v = "▮";
                    }
                    std.debug.print("{s}", .{v});
                }
            }
        }
    };
}
