const std = @import("std");

const Sand = struct {
    pos: Point,
    stopped: bool,
    abyssal: bool,

    pub fn step(self: *Sand, grid: *[170][1000]u8) void {
        var d = self.pos.add(Point.DOWN);
        var dl = self.pos.add(Point.DOWNLEFT);
        var dr = self.pos.add(Point.DOWNRIGHT);
        var oldpos = self.pos;

        if (d.y > 167) {
            self.abyssal = true;
            // self.stopped = true;
            return;
        }

        if (grid.*[@intCast(usize,d.y)][@intCast(usize, d.x)] == '.') {
            self.pos = d;
        } else if (grid.*[@intCast(usize, dl.y)][@intCast(usize, dl.x)] == '.') {
            self.pos = dl;
        } else if (grid.*[@intCast(usize,dr.y)][@intCast(usize,dr.x)] == '.') {
            self.pos = dr;
        }

        if (self.pos.eql(oldpos)) {
            self.stopped = true;
            grid.*[@intCast(usize,self.pos.y)][@intCast(usize,self.pos.x)] = 'o';
        }

    }

    pub fn step2(self: *Sand, grid: *[170][1000]u8) void {
        var d = self.pos.add(Point.DOWN);
        var dl = self.pos.add(Point.DOWNLEFT);
        var dr = self.pos.add(Point.DOWNRIGHT);
        var oldpos = self.pos;

        if (d.y > 167) {
            self.stopped = true;
            grid.*[@intCast(usize,self.pos.y)][@intCast(usize,self.pos.x)] = 'o';
            return;
        }

        if (grid.*[@intCast(usize,d.y)][@intCast(usize, d.x)] == '.') {
            self.pos = d;
        } else if (grid.*[@intCast(usize, dl.y)][@intCast(usize, dl.x)] == '.') {
            self.pos = dl;
        } else if (grid.*[@intCast(usize,dr.y)][@intCast(usize,dr.x)] == '.') {
            self.pos = dr;
        }

        if (self.pos.eql(oldpos)) {
            self.stopped = true;
            grid.*[@intCast(usize,self.pos.y)][@intCast(usize,self.pos.x)] = 'o';
        }

    }
};

const Point = struct {
    x: i32,
    y: i32,

    pub fn add(self: *Point, other: Point) Point {
        return Point{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn sub(self: *Point, other: Point) Point {
        return Point{ .x = self.x - other.x, .y = self.y - other.y };
    }

    pub fn eql(self: *Point, other: Point) bool {
        return self.x == other.x and self.y == other.y;
    }

    pub fn print(self: *Point) !void {
        try std.io.getStdOut().writer().print("( {d}, {d} )\n", .{ self.x, self.y });
    }

    const DOWN = Point{ .x = 0, .y = 1 };
    const UP = Point{ .x = 0, .y = -1 };
    const LEFT = Point{ .x = -1, .y = 0 };
    const RIGHT = Point{ .x = 1, .y = 0 };
    const DOWNLEFT = Point{ .x = -1, .y = 1 };
    const DOWNRIGHT = Point{ .x = 1, .y = 1 };
    const UPLEFT = Point{ .x = -1, .y = -1 };
    const UPRIGHT = Point{ .x = 1, .y = -1 };
    const ZERO = Point{ .x = 0, .y = 0 };
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const w = std.io.getStdOut().writer();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day14.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var lineiter = std.mem.split(u8, file, "\n");

    var smallestx: i32 = 10000;
    var smallesty: i32 = 10000;
    var biggestx: i32 = 0;
    var biggesty: i32 = 0;
    var grid: [170][1000]u8 = undefined;
    var xidx: usize = 0;
    var yidx: usize = 0;
    while (yidx < 170) : (yidx += 1) {
        while (xidx < 1000) : (xidx += 1) {
            grid[yidx][xidx] = '.';
        }
        xidx = 0;
    }

    try printGrid(grid[0..][0..]);
    while (lineiter.next()) |line| {
        var rockline = std.ArrayList(Point).init(allocator);
        var splititer = std.mem.split(u8, line, " -> ");
        while (splititer.next()) |pt| {
            var comma_idx = std.mem.indexOf(u8, pt, ",") orelse 0;
            var x = pt[0..comma_idx];
            var y = pt[comma_idx + 1 ..];
            // try w.print("x: {s} y: {s}", .{x, y});
            var p = Point{ .x = try std.fmt.parseUnsigned(i32, x, 10), .y = try std.fmt.parseUnsigned(i32, y, 10) };

            if (p.x < smallestx) smallestx = p.x;
            if (p.x > biggestx) biggestx = p.x;
            if (p.y < smallesty) smallesty = p.y;
            if (p.y > biggesty) biggesty = p.y;
            try rockline.append(p);
        }

        try drawRockline(grid[0..][0..], rockline);
    }
    try w.print("x range: {d} - {d}\ny range: {d} - {d}\n", .{ smallestx, biggestx, smallesty, biggesty });
    try printGrid(grid[0..][0..]);

    var sandGrains: usize = 0;
    var sandWentAbyssal = false;
    while (!sandWentAbyssal) {
        var s = Sand {
            .pos = Point { .x = 500, .y = 0 },
            .stopped = false, .abyssal = false
        };

        while (s.stopped == false) {
            if (s.abyssal) { sandWentAbyssal = true; break; }
            s.step(grid[0..][0..]);
            if (s.stopped) sandGrains += 1;
        }
    }
    try w.print("\n", .{});

    try printGrid(grid[0..][0..]);
    try w.print("# of sand grains: {d}", .{sandGrains});

    xidx = 0;
    yidx = 0;
    while (yidx < 170) : (yidx += 1) {
        while (xidx < 1000) : (xidx += 1) {
            grid[yidx][xidx] = '.';
        }
        xidx = 0;
    }
    lineiter = std.mem.split(u8, file, "\n");
    while (lineiter.next()) |line| {
        var rockline = std.ArrayList(Point).init(allocator);
        var splititer = std.mem.split(u8, line, " -> ");
        while (splititer.next()) |pt| {
            var comma_idx = std.mem.indexOf(u8, pt, ",") orelse 0;
            var x = pt[0..comma_idx];
            var y = pt[comma_idx + 1 ..];
            // try w.print("x: {s} y: {s}", .{x, y});
            var p = Point{ .x = try std.fmt.parseUnsigned(i32, x, 10), .y = try std.fmt.parseUnsigned(i32, y, 10) };

            if (p.x < smallestx) smallestx = p.x;
            if (p.x > biggestx) biggestx = p.x;
            if (p.y < smallesty) smallesty = p.y;
            if (p.y > biggesty) biggesty = p.y;
            try rockline.append(p);
        }

        try drawRockline(grid[0..][0..], rockline);
    }


    var sandReachedOrigin = false;
    sandGrains = 0;
    while (!sandReachedOrigin) {
        var s = Sand {
            .pos = Point { .x = 500, .y = 0 },
            .stopped = false, .abyssal = false
        };

        while (s.stopped == false) {
            s.step2(grid[0..][0..]);
            if (s.stopped) sandGrains += 1;
            if (s.pos.eql(Point {.x=500,.y=0})) { sandReachedOrigin = true; break; }
        }
    }
    try w.print("\n", .{});

    try printGrid(grid[0..][0..]);
    try w.print("# of sand grains: {d}", .{sandGrains});
}

pub fn printGrid(grid: *[170][1000]u8) !void {
    const w = std.io.getStdOut().writer();

    for (grid) |y| {
        for (y[395..530]) |x| {
            // if (xi == 500-395) {
            //     try w.print("@", .{});
            // } else {
                try w.print("{c}", .{x});
            // }
        }
        try w.print("\n", .{});
    }
}

pub fn drawRockline(grid: *[170][1000]u8, rockline: std.ArrayList(Point)) !void {
    var rlidx: usize = 0;
    while (rlidx < rockline.items.len - 1) : (rlidx += 1) {
        var curr = rockline.items[rlidx];
        var next = rockline.items[rlidx + 1];
        var diff = next.sub(curr);
        try std.io.getStdOut().writer().print("curr: ", .{});
        try curr.print();
        try std.io.getStdOut().writer().print("next: ", .{});
        try next.print();
        try std.io.getStdOut().writer().print("diff: ", .{});
        try diff.print();
        try std.io.getStdOut().writer().print("----\n", .{});
        grid.*[@intCast(usize, curr.y)][@intCast(usize, curr.x)] = '#';

        if (diff.y == 0) {
            if (diff.x < 0) {
                var cnt: isize = diff.x;
                while (cnt < 0) : (cnt += 1) {
                    grid.*[@intCast(usize, curr.y)][@intCast(usize, curr.x + cnt)] = '#';
                }
            }
            if (diff.x > 0) {
                var cnt: isize = diff.x;
                while (cnt > 0) : (cnt -= 1) {
                    grid.*[@intCast(usize, curr.y)][@intCast(usize, curr.x + cnt)] = '#';
                }
            }
        }
        if (diff.x == 0) {
            if (diff.y < 0) {
                var cnt: isize = diff.y;
                while (cnt < 0) : (cnt += 1) {
                    grid.*[@intCast(usize, curr.y + cnt)][@intCast(usize, curr.x)] = '#';
                }
            }
            if (diff.y > 0) {
                var cnt: isize = diff.y;
                while (cnt > 0) : (cnt -= 1) {
                    grid.*[@intCast(usize, curr.y + cnt)][@intCast(usize, curr.x)] = '#';
                }
            }
        }
    }
}
