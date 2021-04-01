// const c = @cImport({
//     @cInclude("ncurses.h");
// });

//const cstd = @cImport(@cInclude("stdlib.h"));
const std = @import("std");
const stdout = std.io.getStdOut().writer();
const print = stdout.print;
const writeAll = stdout.writeAll;

pub fn main() !void {

    // _ = c.initscr();
    // _ = c.refesh();

    // var xmax: usize = undefined;
    // var ymax: usize = undefined;


    // initialize the grid 

    var grid = initGrid();

    while (true) {
        std.time.sleep(50000000);
        try print("\x1B[2J\x1B[H", .{});
        try printGrid(grid);
        grid = updateGrid(grid);
    }
}

//const r = std.rand.Random;
var rng = std.rand.DefaultPrng.init(0);

fn initGrid() [40][100][]const u8 {
    var grid: [40][100][]const u8 = undefined;
    for (grid) |row, i| {
        for (row) |cell, j| {
            const edge = (j == 99 or j == 0 or i == 39 or i == 0);
            // const r = @rem(cstd.rand(), 10);
            const r = rng.random.int(u8) % 20;
            if (edge) { 
                grid[i][j] = " "; 
            }
            else if (r < 5) {
                grid[i][j] = "▮";
            }
            else {
                grid[i][j] = " ";
            }
        }
    }
    return grid;
}

fn printGrid(grid: [40][100][]const u8) !void {
    for (grid) |row| {
        try writeAll("\n");
        for (row) |cell| {
            try print("{s}", .{cell});
        }
    }
}

fn updateGrid(grid: [40][100][]const u8) [40][100][]const u8 {

    var new_grid = initGrid();

    for (grid) |row, i| {
        for (row) |cell, j| {

            const edge = (j == 99 or j == 0 or i == 39 or i == 0);
            if (edge) {
                continue;
            }

            var alive: bool = undefined;

            if (std.mem.eql(u8, cell, "▮")) {
                alive = true;
            }

            else {
                alive = false;
            }

            const delt = [3]u8{0,1,2};
            var alive_neighbors: u8 = 0;
            for (delt) |x, s| {
                for (delt) |y, t| {
                    if (x == 1 and y == 1) {
                        continue;
                    }
                    else {
                        if (std.mem.eql(u8, grid[i+x-1][j+y-1], "▮")) {
                            alive_neighbors += 1;
                        }
                    }
                }
            }

            // any live cell with fewer than two live neighbors dies
            // any live cell with two or three live neighbours lives on to the next generation
            // any live cell with more than three live neighbours dies, as if by overpopulation.
            if (alive) {
                if (alive_neighbors < 2) {
                    new_grid[i][j] = " ";
                }
                if (alive_neighbors == 2 or alive_neighbors == 3) {
                    new_grid[i][j] = "▮";
                }
                else {
                    new_grid[i][j] = " ";
                }
            }

            // any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

            else {
                if (alive_neighbors == 3) {
                    new_grid[i][j] = "▮";
                }
                else {
                    new_grid[i][j] = " ";
                }
                
            }
        }
    }
    return new_grid;
}