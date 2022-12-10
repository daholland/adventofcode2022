const std = @import("std");

const Elf = struct {
    startSection: u8,
    endSection: u8
};

pub fn rangeContainsOther(elf1: Elf, elf2: Elf) bool {
    if (elf1.startSection <= elf2.startSection and elf1.endSection >= elf2.endSection) {
        return true;
    }

    return false;
}

pub fn rangeOverlaps(elf1: Elf, elf2: Elf) bool {
    if (elf1.endSection >= elf2.startSection and elf1.startSection <= elf2.endSection) {
        return true;
    }

    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day4.txt", @sizeOf(u8) * 50 * 3000);
    defer allocator.free(file);

    var lineiter = std.mem.split(u8, file, "\n");
    var containingSum: u32 = 0;
    while (lineiter.next()) |line| {
        var elfiter = std.mem.split(u8, line, ",");
        var elfpair = std.ArrayList(Elf).init(allocator);
        while (elfiter.next()) |e| {
            var range = std.mem.split(u8, e, "-");
            var elf = Elf {.startSection = 0, .endSection = 0};

            var start = range.next().?;
            elf.startSection = try std.fmt.parseUnsigned(u8, start, 10);

            var end = range.next().?;
            elf.endSection = try std.fmt.parseUnsigned(u8, end, 10);

            try elfpair.append(elf);
        }

        if (rangeContainsOther(elfpair.items[0], elfpair.items[1]) or rangeContainsOther(elfpair.items[1], elfpair.items[0])) {
            containingSum += 1;
        }

    }
    try std.io.getStdOut().writer().print("Number of elves that contain another: {d}\n", .{containingSum});

    lineiter.reset();
    var overlapSum: u32 = 0;

    while (lineiter.next()) |line| {
        var elfiter = std.mem.split(u8, line, ",");
        var elfpair = std.ArrayList(Elf).init(allocator);
        while (elfiter.next()) |e| {
            var range = std.mem.split(u8, e, "-");
            var elf = Elf {.startSection = 0, .endSection = 0};

            var start = range.next().?;
            elf.startSection = try std.fmt.parseUnsigned(u8, start, 10);

            var end = range.next().?;
            elf.endSection = try std.fmt.parseUnsigned(u8, end, 10);

            try elfpair.append(elf);
        }

        if (rangeOverlaps(elfpair.items[0], elfpair.items[1]) or rangeOverlaps(elfpair.items[1], elfpair.items[0])) {
            overlapSum += 1;
        }

    }
    try std.io.getStdOut().writer().print("Number of elves that overlap another: {d}\n", .{overlapSum});
}
