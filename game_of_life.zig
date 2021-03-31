const std = @import("std");
const c = @cImport({
    @cInclude("ncurses.h");
});

pub fn main() !void {

    _ = c.initscr();
    _ = c.raw();
    _ = c.printw("Hello");
    _ = c.move(12, 13); 
    _ = c.mvprintw(15,20, "Movement");
    _ = c.mvprintw(17, 25, "Another");
    _ = c.mvaddch(12,50, 99);

    _ = c.getch();
    _ = c.endwin();

    return;
}

fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();

        var width: u8 = undefined;
        var height: u8 = undefined;

    }
}

fn iterate(grid_in: Grid) Grid {
    // takes in a grid and returns a grid

    grid_out = Grid;


}