const std = @import("std");

const InstructionTag = enum {
    noop,
    addx
};
const Instruction = union(InstructionTag) {
    noop: void,
    addx: isize
};

const CPU = struct {
    cycle: usize,
    x: isize,
    ip: usize,
    program: []Instruction,
    screen: []u8,
    execLeft: usize,
    crtIdx: usize,

    signalSum: isize,

    pub fn step(self: *CPU) !bool {
        self.cycle += 1;

        if (self.cycle == 20 or self.cycle == 60 or self.cycle == 100 or self.cycle == 140 or self.cycle == 180 or self.cycle == 220) {
            try std.io.getStdOut().writer().print("cycle: {d} x: {d} old signalSum: {d} added: {d} ", .{self.cycle, self.x, self.signalSum, self.x * @intCast(isize,self.cycle) });
            self.signalSum += self.x * @intCast(isize,self.cycle);
            try std.io.getStdOut().writer().print("new signalSum: {d}\n ", .{self.signalSum});
        }

        if (self.execLeft > 0) {
            self.execLeft -= 1;
        }

        if (self.ip >= self.program.len) {
            return false;
        }

        try self.drawToScreen();

        var currInst = self.program[self.ip];



        switch (currInst) {
            .noop => {
                if (self.execLeft == 0) {
                    self.execLeft = 1;
                }

                try std.io.getStdOut().writer().print("noop\n", .{});
                self.execLeft -= 1;
            },
            .addx => |n| {
                if (self.execLeft == 0) {
                    self.execLeft = 2;
                    try std.io.getStdOut().writer().print("addx {d}\n", .{n});
                    return true;
                }
                self.x += n;
                self.execLeft -= 1;
            }
        }


        self.ip += 1;


        return true;
    }

    pub fn drawToScreen(self: *CPU) !void {
        const w = std.io.getStdOut().writer();
        var row = self.crtIdx / 40;
        var offset = self.crtIdx % 40;

        if (self.x - 1 <= offset and offset <= self.x + 1) {
            self.screen[row*40 + offset] = '#';
        }

        self.crtIdx += 1;

        var screenIdx: usize = 0;
        while (screenIdx < self.screen.len) : (screenIdx += 1) {
            if (screenIdx % 40 == 0) {
                try w.print("\n", .{});
            }
            try w.print("{c}", .{self.screen[screenIdx]});
        }
        try w.print("\n", .{});
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const w =  std.io.getStdOut().writer();


    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day10.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var lineiter = std.mem.split(u8, file, "\n");

    var prog: [144]Instruction = undefined;
    var idx: usize = 0;
    while (lineiter.next()) |line| {
        var splititer = std.mem.split(u8, line, " ");
        var instName = splititer.next().?;


        if (std.mem.eql(u8,instName,"noop")) {
            prog[idx] = Instruction.noop;
            try w.print("Instruction: noop\n", .{});
        }
        if (std.mem.eql(u8,instName,"addx")) {
            var n = try std.fmt.parseInt(isize, splititer.next().?, 10);
            prog[idx] = Instruction { .addx = n };
            try w.print("Instruction: addx {d}\n", .{n});
        }
        idx += 1;
    }
    // for (prog) |i| {
    //     switch (i) {
    //         .noop => { try w.print("Instruction: noop\n", .{}); },
    //         .addx => |n| { try w.print("Instruction: addx {d}\n", .{n}); }
    //     }
    //
    // }
    var screen: [240]u8 = [_]u8{'.'} ** 240;
    var computer = CPU {
        .cycle = 0,
        .x = 1,
        .ip = 0,
        .crtIdx = 0,
        .program = std.mem.span(&prog),
        .screen = std.mem.span(&screen),
        .execLeft = 0,
        .signalSum = 0
    };


    while (try computer.step()) {
        try w.print("CPU cycle: {d} x: {d} keepgoing: true signalSum: {d} execLeft: {d} crtIdx: {d}\n", .{computer.cycle, computer.x, computer.signalSum, computer.execLeft, computer.crtIdx});

    }

    var screenIdx: usize = 0;
    while (screenIdx < screen.len) : (screenIdx += 1) {
        if (screenIdx % 40 == 0) {
            try w.print("\n", .{});
        }
        try w.print("{c}", .{screen[screenIdx]});
    }
    try w.print("\n", .{});

}