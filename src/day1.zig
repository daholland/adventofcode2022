const std = @import("std");

const Elf = struct {
    rations: std.ArrayList(u32),

    pub fn getTotalWeight(self: *const Elf) u32 {
        var sum: u32 = 0;
        for (self.rations.items) |weight| {
            sum += weight;
        }
        return sum;
    }

    pub fn addRations(self: *Elf, weight: u32) !void {
        try self.rations.append(weight);
    }
};

pub fn cmpElfTotalWeight(context: void, a: Elf, b: Elf) bool {
    if (a.getTotalWeight() < b.getTotalWeight()) {
        return true;
    } else {
        return false;
    }
    _ = context;
}

pub fn dayone() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day1.txt", @sizeOf(u8) * 30 * 3000);
    defer allocator.free(file);

    var elfList = std.ArrayList(Elf).init(allocator);
    defer elfList.deinit();
    //var buffer: [@sizeOf(u32)*30]u8 = undefined;
    var lineiter = std.mem.split(u8, file, "\n");
    var newElf = Elf{ .rations = std.ArrayList(u32).init(allocator)};

    while (lineiter.next()) |line| {
        if (line.len > 1) {
            var rationweight = try std.fmt.parseUnsigned(u32, line, 10);
            try newElf.addRations(rationweight);
        } else {
            if (newElf.rations.items.len > 0) {
                try elfList.append(newElf);
                newElf = Elf{ .rations = std.ArrayList(u32).init(allocator)};
            }
        }
    }
    for (elfList.items) |e| {
        defer e.rations.deinit();
    }


    var biggestweight: u32 = 0;
    for (elfList.items) |e, i| {
        var weight = e.getTotalWeight();
        try std.io.getStdOut().writer().print("Elf {d} weight: {d}\n", .{i, weight});
        if (weight > biggestweight) {
            biggestweight = weight;
        }
    }
    try std.io.getStdOut().writer().print("Biggest Elf weight: {d}\n", .{biggestweight});

    var elfListSLice = elfList.toOwnedSlice();
    std.sort.sort(Elf, elfListSLice, {}, cmpElfTotalWeight);
    var elfListSliceLen = elfListSLice.len;
    var totaltop3weight = elfListSLice[elfListSliceLen-1].getTotalWeight() + elfListSLice[elfListSliceLen-2].getTotalWeight() + elfListSLice[elfListSliceLen-3].getTotalWeight();
    try std.io.getStdOut().writer().print("{}", .{totaltop3weight});



}
