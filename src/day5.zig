const std = @import("std");

const Command = struct {
    amount: u8,
    source: u8,
    target: u8,

    pub fn runCommand(self: *Command, crateStacks: []std.ArrayList(u8)) !void {
        var cratesMoved: usize = 0;
        while (cratesMoved < self.amount) : (cratesMoved += 1) {
            var topCrate = crateStacks[self.source - 1].pop();
            try crateStacks[self.target - 1].append(topCrate);
        }
    }

    pub fn runCommand9001(self: *Command, crateStacks: []std.ArrayList(u8)) !void {
        var cratesMoved: usize = 0;

        while (cratesMoved < self.amount) : (cratesMoved += 1) {
            const stackHeight = crateStacks[self.source - 1].items.len;

            var idx = stackHeight - self.amount + cratesMoved;
            var bottomCrate = crateStacks[self.source - 1].items[idx];

            try crateStacks[self.target - 1].append(bottomCrate);
        }

        cratesMoved = 0;
        while (cratesMoved < self.amount) : (cratesMoved += 1) {
            _ = crateStacks[self.source - 1].pop();
        }
    }
};

pub fn addCrateLevel(crateStacks: []std.ArrayList(u8), line: []const u8) !void {
    var i: usize = 0;

    while (i < 9) : (i += 1) {
        var c = line[1 + (i * 4)];
        if (c != ' ') {
            try crateStacks[i].append(c);
        }
    }
}

pub fn parseCommand(line: []const u8, allocator: *const std.mem.Allocator) !Command {
    var tokens = std.ArrayList([]const u8).init(allocator.*);
    var splitLine = std.mem.split(u8, line, " ");

    while (splitLine.next()) |token| {
        try tokens.append(token);
    }

    return Command{ .amount = try std.fmt.parseUnsigned(u8, tokens.items[1], 10), .source = try std.fmt.parseUnsigned(u8, tokens.items[3], 10), .target = try std.fmt.parseUnsigned(u8, tokens.items[5], 10) };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day5.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var lineiter = std.mem.split(u8, file, "\n");
    var lines = std.ArrayList([]const u8).init(allocator);
    while (lineiter.next()) |line| {
        try lines.append(line);
    }
    var crateStacks: [9]std.ArrayList(u8) = .{ std.ArrayList(u8).init(allocator), std.ArrayList(u8).init(allocator), std.ArrayList(u8).init(allocator), std.ArrayList(u8).init(allocator), std.ArrayList(u8).init(allocator), std.ArrayList(u8).init(allocator), std.ArrayList(u8).init(allocator), std.ArrayList(u8).init(allocator), std.ArrayList(u8).init(allocator) };

    var i: isize = 7;
    while (i > -1) : (i -= 1) {
        try addCrateLevel(&crateStacks, lines.items[@intCast(usize, i)]);
    }

    for (crateStacks) |stack| {
        for (stack.items) |crate| {
            try std.io.getStdOut().writer().print("{c} ", .{crate});
        }
        try std.io.getStdOut().writer().print("\n", .{});
    }
    try std.io.getStdOut().writer().print("-------------\n", .{});

    for (lines.items[10..]) |cmd| {
        var command: Command = parseCommand(cmd, &allocator) catch unreachable;
        try command.runCommand(&crateStacks);
    }

    for (crateStacks) |stack| {
        for (stack.items) |crate| {
            try std.io.getStdOut().writer().print("{c} ", .{crate});
        }
        try std.io.getStdOut().writer().print("\n", .{});
    }
    try std.io.getStdOut().writer().print("-------------\n", .{});

    var j: usize = 0;
    while (j < 9) : (j += 1) {
        crateStacks[j].clearRetainingCapacity();
    }
    i = 7;
    while (i > -1) : (i -= 1) {
        try addCrateLevel(&crateStacks, lines.items[@intCast(usize, i)]);
    }

    for (crateStacks) |stack| {
        for (stack.items) |crate| {
            try std.io.getStdOut().writer().print("{c} ", .{crate});
        }
        try std.io.getStdOut().writer().print("\n", .{});
    }

     try std.io.getStdOut().writer().print("-------------\n", .{});

    for (lines.items[10..]) |cmd| {
        var command: Command = parseCommand(cmd, &allocator) catch unreachable;
        try command.runCommand9001(&crateStacks);
    }

    for (crateStacks) |stack| {
        for (stack.items) |crate| {
            try std.io.getStdOut().writer().print("{c} ", .{crate});
        }
        try std.io.getStdOut().writer().print("\n", .{});
    }
}
