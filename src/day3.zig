const std = @import("std");

const alphabet = [_]u8{
                    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',};

pub fn getSharedItem(line: []const u8) !u8 {
    const compartmentOne = line[0..line.len/2];
    const compartmentTwo = line[line.len/2..line.len];
    var ret: u8 = undefined;
    for (alphabet) |c| {
        if (std.mem.indexOf(u8, compartmentOne, &[_]u8{c}) != null and std.mem.indexOf(u8, compartmentTwo, &[_]u8{c}) != null) {
            ret = c;
            break;
        }
    }

    return ret;
}

pub fn getBadgeItem(line1: []const u8, line2: []const u8, line3: []const u8) !u8 {
    var ret: u8 = 0;
    for (alphabet) |c| {
        if (std.mem.indexOf(u8, line1, &[_]u8{c}) != null
            and std.mem.indexOf(u8, line2, &[_]u8{c}) != null
            and std.mem.indexOf(u8, line3, &[_]u8{c}) != null) {
                ret = c;
                break;
            }
    }

    return ret;
}

pub fn day3() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day3.txt", @sizeOf(u8) * 50 * 3000);
    defer allocator.free(file);

    var priorities = std.AutoHashMap(u8,u8).init(allocator);

    for (alphabet) |c, i| {
        try priorities.put(c, @intCast(u8, i)+1);
    }

    try std.io.getStdOut().writer().print("priority for M: {?}\n", .{priorities.get('a')});

    var lineiter = std.mem.split(u8, file, "\n");
    var prioritysum: u32 = 0;
    while (lineiter.next()) |line| {
        var sharedItem = try getSharedItem(line);
        var toAdd = priorities.get(sharedItem).?;
        prioritysum += toAdd;
    }

    try std.io.getStdOut().writer().print("Priority Sum: {d}\n", .{prioritysum});

    lineiter = std.mem.split(u8, file, "\n");
    prioritysum = 0;
    while (lineiter.next()) |line1| {
            var line2 = lineiter.next().?;
            var line3 = lineiter.next().?;

            var sharedItem = try getBadgeItem(line1, line2, line3);
            var toAdd = priorities.get(sharedItem) orelse 0;
            prioritysum += toAdd;
        }
     try std.io.getStdOut().writer().print("Badge Sum: {d}\n", .{prioritysum});
}
