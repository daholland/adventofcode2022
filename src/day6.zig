const std = @import("std");

pub fn addToQueue(queue: []u8, value: u8) void {
    var i: usize = 0;
    while (i < queue.len - 1) : (i += 1) {
        queue[i] = queue[i+1];
    }
    queue[queue.len-1] = value;
}

pub fn isUniqueChars(queue: []u8) bool {
    for (queue) |c| {
        if (std.mem.count(u8, queue, &[_]u8{c}) > 1) {
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day6.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var lineiter = std.mem.split(u8, file, "\n");
    var line = lineiter.next().?;

    var queue = [_]u8{0,0,0,0};
    var charsProcessed: usize = 0;
    for (line) |c| {
        addToQueue(&queue, c);
        charsProcessed += 1;
        if (charsProcessed >= 4 and isUniqueChars(&queue)) {
            break;
        }
    }
    try std.io.getStdOut().writer().print("Number of chars processed: {d} Current queue: {s}\n", .{charsProcessed, queue});
    var queue2 = [_]u8{0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    charsProcessed = 0;
    for (line) |c| {
        addToQueue(&queue2, c);
        charsProcessed += 1;
        if (charsProcessed >= 14 and isUniqueChars(&queue2)) {
            break;
        }
    }
    try std.io.getStdOut().writer().print("Number of chars processed: {d} Current queue: {s}\n", .{charsProcessed, queue2});


}
