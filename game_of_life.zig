const std = @import("std");

// TODO Detect terminal window size
// TODO update on terminal window size change

pub fn main() !void {

    var grid = Grid(40, 140).init();

    while (true) {

        // const termios = std.c.termios;
        // const original = os.tcgetattr(0);

        //
        std.time.sleep(40000000);

        grid.printToScr();
        grid.update();
    }

    try os.tcsetattr(0, std.os.TCSA.FLUSH, original);
}

fn Grid(comptime height: usize, comptime width: usize) type {

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

            var new_grid: [height][width]u8 = undefined; // why does this work?
            for (new_grid) |row, i| {
                for (row) |cell, j| {
                    const edge = (j == width - 1 or j == 0 or i == height - 1 or i == 0); // fix this
                    if (edge) {
                        new_grid[i][j] = 0;
                        continue;
                    }
                    var alive_neighbors: u8 = 0;

                    // sum the squares around the cell
                    const delt = [3]usize{ 0, 1, 2 };
                    for (delt) |x| {
                        for (delt) |y| {
                            alive_neighbors += self.grid[i + x - 1][j + y - 1];
                        }
                    }
                    // subtract the center (we added it in the for loop)
                    alive_neighbors -= self.grid[i][j];

                    // conway's rules
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
                        // v = " █";
                        v = "▮";
                    }
                    std.debug.print("{s}", .{v});
                }
            }
        }
    };
}
