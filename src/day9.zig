const std = @import("std");

const Point = struct {
    x: i32,
    y: i32,

    pub fn add(self: *Point, other: Point) Point {
        return Point { .x = self.x + other.x, .y = self.y + other.y};
    }

    pub fn sub(self: *Point, other: Point) Point {
        return Point { .x = self.x - other.x, .y = self.y - other.y};
    }

    pub fn eql(self: *Point, other: Point) bool {
        return self.x == other.x and self.y == other.y;
    }

    pub fn print(self: *Point) !void {
        try std.io.getStdOut().writer().print("( {d}, {d} )\n", .{self.x, self.y});
    }

    const DOWN = Point { .x = 0, .y = -1 };
    const UP = Point { .x = 0, .y = 1 };
    const LEFT = Point { .x = -1, .y = 0 };
    const RIGHT = Point { .x = 1, .y = 0 };
    const DOWNLEFT = Point { .x = -1, .y = -1 };
    const DOWNRIGHT = Point { .x = 1, .y = -1 };
    const UPLEFT = Point { .x = -1, .y = 1 };
    const UPRIGHT = Point { .x = 1, .y = 1 };
    const ZERO = Point { .x = 0, .y = 0 };

};

const allDirs : [8]Point = [8]Point{
                    Point.DOWN, Point.UP, Point.LEFT, Point.RIGHT,
                    Point.DOWNLEFT, Point.DOWNRIGHT, Point.UPLEFT, Point.UPRIGHT
                };

const Direction = enum(usize) {
    Down,
    Up,
    Left,
    Right,
    DownLeft,
    DownRight,
    UpLeft,
    UpRight
};

const Command = struct {
    dir: Direction,
    amount: i8
};

const Rope = struct {
    head: Point,
    tail: Point,
    tail_visited: std.AutoHashMap(Point, bool),

    pub fn diff(self: *Rope) Point {
        return self.head.sub(self.tail);
    }

    pub fn move(self: *Rope, dir: Direction) !void {
        switch (dir) {
            .Down => { self.head = self.head.add(Point.DOWN); },
            .Up => { self.head = self.head.add(Point.UP); },
            .Left => { self.head = self.head.add(Point.LEFT); },
            .Right => { self.head = self.head.add(Point.RIGHT); },
            .DownLeft => { self.head = self.head.add(Point.DOWNLEFT); },
            .DownRight => { self.head = self.head.add(Point.DOWNRIGHT); },
            .UpLeft => { self.head = self.head.add(Point.UPLEFT); },
            .UpRight => { self.head = self.head.add(Point.UPRIGHT); },
        }
        var delta = self.diff();
        if (try std.math.absInt(delta.x) > 1 or try std.math.absInt(delta.y) > 1) {
            try self.updateTail();
        }
        try std.io.getStdOut().writer().print("moved: \thd: \t({d}, {d}) \t| \ttl: \t({d}, {d})\t delta:\t ({d}.{d})\n", .{self.head.x, self.head.y, self.tail.x, self.tail.y, delta.x, delta.y});
    }

    pub fn updateTail(self: *Rope) !void {
        const delta = self.diff();

        if (delta.x == 0) {
            if (delta.y < 0) self.tail = self.tail.add(Point.DOWN);
            if (delta.y > 0) self.tail = self.tail.add(Point.UP);
        }
        if (delta.y == 0) {
            if (delta.x < 0) self.tail = self.tail.add(Point.LEFT);
            if (delta.x > 0) self.tail = self.tail.add(Point.RIGHT);
        }
        if (delta.y < 0) {
            if (delta.x < 0) self.tail = self.tail.add(Point.DOWNLEFT);
            if (delta.x > 0) self.tail = self.tail.add(Point.DOWNRIGHT);
        }
        if (delta.y > 0) {
            if (delta.x < 0) self.tail = self.tail.add(Point.UPLEFT);
            if (delta.x > 0) self.tail = self.tail.add(Point.UPRIGHT);
        }

        try self.tail_visited.put(self.tail, true);
    }

    pub fn countTailVisited(self: *Rope) usize {
       return self.tail_visited.count();
    }
};

pub fn RopeN(comptime Size: comptime_int) type {
    return struct {
        const Self = @This();
        knots: [Size]Point,
        tail_visited: std.AutoHashMap(Point, bool),

        pub fn diff(self: *Self, fst: usize, snd: usize) Point {
            return self.knots[fst].sub(self.knots[snd]);
        }

        pub fn move(self: *Self, dir: Direction) !void {
            switch (dir) {
                .Down => { self.knots[0] = self.knots[0].add(Point.DOWN); },
                .Up => { self.knots[0] = self.knots[0].add(Point.UP); },
                .Left => { self.knots[0] = self.knots[0].add(Point.LEFT); },
                .Right => { self.knots[0] = self.knots[0].add(Point.RIGHT); },
                .DownLeft => { self.knots[0] = self.knots[0].add(Point.DOWNLEFT); },
                .DownRight => { self.knots[0] = self.knots[0].add(Point.DOWNRIGHT); },
                .UpLeft => { self.knots[0] = self.knots[0].add(Point.UPLEFT); },
                .UpRight => { self.knots[0] = self.knots[0].add(Point.UPRIGHT); },
            }
            var idx: usize = 0;
            while (idx < Size - 1) : (idx += 1) {
                var delta = self.diff(idx, idx + 1);
                if (try std.math.absInt(delta.x) > 1 or try std.math.absInt(delta.y) > 1) {
                    try self.updateTail(idx+1);
                }
            }

            // try std.io.getStdOut().writer().print("moved: \thd: \t({d}, {d}) \t| \ttl: \t({d}, {d})\t delta:\t ({d}.{d})\n", .{self.head.x, self.head.y, self.tail.x, self.tail.y, delta.x, delta.y});
        }

        pub fn updateTail(self: *Self, idx: usize) !void {
            const delta = self.diff(idx-1, idx);

            if (delta.x == 0) {
                if (delta.y < 0) self.knots[idx] = self.knots[idx].add(Point.DOWN);
                if (delta.y > 0) self.knots[idx] = self.knots[idx].add(Point.UP);
            }
            if (delta.y == 0) {
                if (delta.x < 0) self.knots[idx] = self.knots[idx].add(Point.LEFT);
                if (delta.x > 0) self.knots[idx] = self.knots[idx].add(Point.RIGHT);
            }
            if (delta.y < 0) {
                if (delta.x < 0) self.knots[idx] = self.knots[idx].add(Point.DOWNLEFT);
                if (delta.x > 0) self.knots[idx] = self.knots[idx].add(Point.DOWNRIGHT);
            }
            if (delta.y > 0) {
                if (delta.x < 0) self.knots[idx] = self.knots[idx].add(Point.UPLEFT);
                if (delta.x > 0) self.knots[idx] = self.knots[idx].add(Point.UPRIGHT);
            }

            if (idx == Size - 1) {
                try self.tail_visited.put(self.knots[idx], true);
            }
        }

        pub fn countTailVisited(self: *Self) usize {
           return self.tail_visited.count();
        }
    };
}

const Rope2 = struct {
    knots: [10]Point,
    tail_visited: std.AutoHashMap(Point, bool),

    pub fn diff(self: *Rope2, fst: usize, snd: usize) Point {
        return self.knots[fst].sub(self.knots[snd]);
    }

    pub fn move(self: *Rope2, dir: Direction) !void {
        switch (dir) {
            .Down => { self.knots[0] = self.knots[0].add(Point.DOWN); },
            .Up => { self.knots[0] = self.knots[0].add(Point.UP); },
            .Left => { self.knots[0] = self.knots[0].add(Point.LEFT); },
            .Right => { self.knots[0] = self.knots[0].add(Point.RIGHT); },
            .DownLeft => { self.knots[0] = self.knots[0].add(Point.DOWNLEFT); },
            .DownRight => { self.knots[0] = self.knots[0].add(Point.DOWNRIGHT); },
            .UpLeft => { self.knots[0] = self.knots[0].add(Point.UPLEFT); },
            .UpRight => { self.knots[0] = self.knots[0].add(Point.UPRIGHT); },
        }
        var idx: usize = 0;
        while (idx < 9) : (idx += 1) {
            var delta = self.diff(idx, idx + 1);
            if (try std.math.absInt(delta.x) > 1 or try std.math.absInt(delta.y) > 1) {
                try self.updateTail(idx+1);
            }
        }

        // try std.io.getStdOut().writer().print("moved: \thd: \t({d}, {d}) \t| \ttl: \t({d}, {d})\t delta:\t ({d}.{d})\n", .{self.head.x, self.head.y, self.tail.x, self.tail.y, delta.x, delta.y});
    }

    pub fn updateTail(self: *Rope2, idx: usize) !void {
        const delta = self.diff(idx-1, idx);

        if (delta.x == 0) {
            if (delta.y < 0) self.knots[idx] = self.knots[idx].add(Point.DOWN);
            if (delta.y > 0) self.knots[idx] = self.knots[idx].add(Point.UP);
        }
        if (delta.y == 0) {
            if (delta.x < 0) self.knots[idx] = self.knots[idx].add(Point.LEFT);
            if (delta.x > 0) self.knots[idx] = self.knots[idx].add(Point.RIGHT);
        }
        if (delta.y < 0) {
            if (delta.x < 0) self.knots[idx] = self.knots[idx].add(Point.DOWNLEFT);
            if (delta.x > 0) self.knots[idx] = self.knots[idx].add(Point.DOWNRIGHT);
        }
        if (delta.y > 0) {
            if (delta.x < 0) self.knots[idx] = self.knots[idx].add(Point.UPLEFT);
            if (delta.x > 0) self.knots[idx] = self.knots[idx].add(Point.UPRIGHT);
        }

        if (idx == 9) {
            try self.tail_visited.put(self.knots[idx], true);
        }
    }

    pub fn countTailVisited(self: *Rope2) usize {
       return self.tail_visited.count();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const w =  std.io.getStdOut().writer();


    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day9.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var commands: std.ArrayList(Command) = std.ArrayList(Command).init(allocator);

    var lineiter = std.mem.split(u8, file, "\n");

    while (lineiter.next()) |line| {
        var splititer = std.mem.split(u8, line, " ");
        var dir: []const u8 = splititer.next().?;
        var amount: i8 = try std.fmt.parseInt(i8, splititer.next().?, 10);

        var direction: Direction = undefined;

        switch (dir[0]) {
            'D' => { direction = Direction.Down; },
            'U' => { direction = Direction.Up; },
            'L' => { direction = Direction.Left; },
            'R' => { direction = Direction.Right; },
            else => {}
        }

        try commands.append(Command { .dir = direction, .amount = amount });
    }

    try w.print("@ of commands: {d} cmd 1998: {d} - {d}x \n", .{commands.items.len, @enumToInt(commands.items[1997].dir), commands.items[1997].amount});

    var rope = Rope { .head = Point.ZERO, .tail = Point.ZERO, .tail_visited = std.AutoHashMap(Point, bool).init(allocator)};
    try rope.updateTail();

    // try rope.move(Direction.Right);
    // try rope.move(Direction.Right);
    // try rope.move(Direction.Up);
    // try rope.move(Direction.Up);
    // try rope.move(Direction.Up);
    // try rope.move(Direction.Down);
    // try rope.move(Direction.Down);
    // try rope.move(Direction.Down);



    for (commands.items) |cmd| {
        var amount = cmd.amount;
        while (amount > 0) : (amount -= 1) {
            try rope.move(cmd.dir);
        }
    }
    // try rope.move(Direction.Right);
    // try rope.move(Direction.Up);
    // try rope.move(Direction.Left);
    // try rope.move(Direction.Left);
    // try rope.move(Direction.Down);
    // try rope.move(Direction.Down);
    // try rope.move(Direction.Right);
    // try rope.move(Direction.Right);
    // try rope.move(Direction.Up);
    // try rope.move(Direction.Left);

    // try rope.move(Direction.Right);
    // try rope.move(Direction.Right);
    // try rope.move(Direction.Down);
    // try rope.move(Direction.Down);



    // try rope.head.print();
    // try rope.tail.print();
    // try std.io.getStdOut().writer().print("---------\n", .{});

    var diff =  rope.diff();
    try std.io.getStdOut().writer().print("Diff: ({d}, {d})\n", .{diff.x, diff.y});

    try std.io.getStdOut().writer().print("------ tails_visited ------\n", .{});
    var riter = rope.tail_visited.keyIterator();
    while (riter.next()) |pt| {
        try std.io.getStdOut().writer().print("( {d}, {d} )\n", .{pt.x, pt.y});
    }

    try w.print("Size of tail_visited: {d}\n", .{rope.countTailVisited()});

    var rope2 = Rope2 { .knots = init: {
                                var init_val: [10]Point = undefined;
                                 for (init_val) |*pt| {
                                    pt.* = Point.ZERO;
                                 }
                                 break :init init_val; },
                        .tail_visited = std.AutoHashMap(Point, bool).init(allocator)};
    try rope2.updateTail(9);

    for (commands.items) |cmd| {
        var amount = cmd.amount;
        while (amount > 0) : (amount -= 1) {
            try rope2.move(cmd.dir);
        }
    }

    try w.print("Size of tail_visited on rope2: {d}\n", .{rope2.countTailVisited()});
    const noOfKnots = 10;
    var ropen = RopeN(noOfKnots) { .knots = init: {
                                    var init_val: [noOfKnots]Point = undefined;
                                     for (init_val) |*pt| {
                                        pt.* = Point.ZERO;
                                     }
                                     break :init init_val; },
                            .tail_visited = std.AutoHashMap(Point, bool).init(allocator)};
        try ropen.updateTail(noOfKnots-1);

        for (commands.items) |cmd| {
            var amount = cmd.amount;
            while (amount > 0) : (amount -= 1) {
                try ropen.move(cmd.dir);
            }
        }

        try w.print("Size of tail_visited on rope2: {d}\n", .{ropen.countTailVisited()});

}