const std = @import("std");

pub fn main() !void {

    var grid = Grid(40, 140).init();
    grid.printToScr();

    while (true) {
        std.time.sleep(30000000);
        grid.update();
        grid.printToScr();
    }
}

fn Grid(comptime height: usize, comptime width: usize) type {
    return struct {
        const Self = @This();
        height: usize,
        width: usize,
        grid: [height][width]u8,

        pub fn init() Self {
            var rang = std.rand.DefaultPrng.init(0);
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
            var new_grid: [height][width]u8 = undefined;
            for (new_grid) |row, i| {
                for (row) |cell, j| {
                    const edge = (j == width - 1 or j == 0 or i == height - 1 or i == 0); // fix this
                    if (edge) {
                        new_grid[i][j] = 0;
                        continue;
                    }
                    var alive_neighbors: u8 = 0;
                    const delt = [3]usize{ 0, 1, 2 };
                    for (delt) |x| {
                        for (delt) |y| {
                            alive_neighbors += self.grid[i + x - 1][j + y - 1];
                        }
                    }
                    alive_neighbors -= self.grid[i][j];

                    if (self.grid[i][j] == 1) {
                        if (alive_neighbors < 2) {
                            new_grid[i][j] = 0;
                        }else if (alive_neighbors == 2 or alive_neighbors == 3) {
                            new_grid[i][j] = 1;
                        } else {
                            new_grid[i][j] = 0;
                        }
                    } else {
                        if (alive_neighbors == 3) {
                            new_grid[i][j] = 1;
                        } else {
                            new_grid[i][j] = 0;
                        }
                    }
                }
            }

            self.grid = new_grid;
            
        }
        pub fn printToScr(self: Self) void {
            std.debug.print("\x1B[2J\x1B[H", .{});
            for (self.grid) |row| {
                std.debug.print("\n", .{});
                for (row) |cell| {
                    var v: []const u8 = undefined;
                    if (cell == 0) {
                        v = " ";
                    } else {
                        v = "▮";
                    }
                    std.debug.print("{s}", .{v});
                }
            }
        }
    };
}
