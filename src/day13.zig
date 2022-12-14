const std = @import("std");

const ValueType = enum {
    int,
    list
};

const Value = union(ValueType) {
    int: usize,
    list: std.ArrayList(Value)
};


pub fn parseLine(allocator: std.mem.Allocator, line: []const u8) !Value {
    var retlist = std.ArrayList(Value).init(allocator);

    var listlevel: usize = 0;
    var workingdigit: usize = 420;

    for (line) |c, i| {
        _ = i;
        switch (c) {
            '0'...'9' => {
                if (workingdigit == 1) {
                    workingdigit = 10;
                } else {
                    workingdigit = c - 48;
                }
            },
            '[' => {
                try retlist.append(Value { .list = std.ArrayList(Value).init(allocator)});
                listlevel += 1;
            },
            ']' => {
                var l = retlist.pop();
                if (workingdigit != 420) {

                    try l.list.append(Value { .int = workingdigit});
                    workingdigit = 420;
                }
                listlevel -= 1;
                if (listlevel == 0) {
                    try retlist.append(l);
                    continue;
                }
                try retlist.items[listlevel - 1].list.append(l);

            },
            ',' => {

                if (workingdigit != 420) {

                    try retlist.items[listlevel - 1].list.append(Value { .int = workingdigit});
                    workingdigit = 420;
                }
            },
            '\n' => {break;},
            else => {}

        }
    }

    return retlist.items[0];
}

pub fn printValue(val: Value, first: bool) !void {
    const w = std.io.getStdOut().writer();
    if (first) try w.print("Value: ", .{});

    switch (val) {
        .int => {
            try w.print("{d}", .{val.int});
        },
        .list => {
            try w.print("[", .{});
            if (val == .int) return;
            for (val.list.items) |i, idx| {
                try printValue(i, false);
                if (idx != val.list.items.len - 1) try w.print(",", .{});
            }
            try w.print("]", .{});
        }
    }

    if (first) try w.print("\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const w =  std.io.getStdOut().writer();


    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day13.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var packetpairs = std.ArrayList([2]Value).init(allocator);
    var lineiter = std.mem.split(u8, file, "\n");
    while (lineiter.next()) |p1| {
        var pair: [2]Value = undefined;
        var p2 = lineiter.next().?;
        _ = lineiter.next();

        pair[0] = try parseLine(allocator, p1);
        pair[1] = try parseLine(allocator, p2);
        try packetpairs.append(pair);
    }

    var indexSum: usize = 0;
    for (packetpairs.items) |pair, i| {
        try printValue(pair[0], true);
        try printValue(pair[1], true);

        var inOrder = try checkOrder(allocator, pair[0], pair[1]);
        if (inOrder == 1) {
            indexSum += (i + 1);
        }
        try w.print("In order?: {d}\n", .{inOrder});
        try w.print("-----\n", .{});
    }
    try w.print("Index Sum: {d} len of pairs: {d}\n", .{indexSum, packetpairs.items.len});

    var allpackets: [151*2]Value = undefined;
    for (packetpairs.items) |packet, i| {
        allpackets[i*2] = packet[0];
        allpackets[i*2 + 1] = packet[1];
    }

    std.sort.sort(Value, allpackets[0..], {}, cmpValue);

    var indexProduct: usize = 1;
    var t = Value { .list = std.ArrayList(Value).init(allocator)};
    try t.list.append(Value { .list = std.ArrayList(Value).init(allocator)});
    try t.list.items[0].list.append(Value{ .int = 2});
    var t2 = Value { .list = std.ArrayList(Value).init(allocator)};
    try t2.list.append(Value { .list = std.ArrayList(Value).init(allocator)});
    try t2.list.items[0].list.append(Value{ .int = 6});

    try printValue(t, true);
    for (allpackets[0..]) |p, ix| {
        if (p == .list and p.list.items.len == 1) {
            var innerp = p.list.items[0];
            if (innerp == .list and innerp.list.items.len == 1) {
                var i = innerp.list.items[0];

                if (i == .int and (i.int == 2 or i.int == 6)) {
                    indexProduct *= ix + 1;
                }
            }
        }
    }
    try w.print("indexproduct: {d}\n", .{indexProduct});

}

pub fn cmpValue(context: void, lhs: Value, rhs: Value) bool {
    _ = context;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var check = checkOrder(allocator, lhs, rhs) catch 0;

    return check == 1;
}

pub fn checkOrder(allocator: std.mem.Allocator, left: Value, right: Value) !i8 {
    if (left == .int and right == .int) {
        if (left.int < right.int) {
            return 1;
        } else if (left.int > right.int) {
            return -1;
        } else { return 0; }
    }

    if (left == .list and right == .list) {
        var shorterlist: u8 = 'x';
        if (left.list.items.len < right.list.items.len) {
            shorterlist = 'L';
        } else if (left.list.items.len > right.list.items.len) {
            shorterlist = 'R';
        }
        var minlen = @min(left.list.items.len, right.list.items.len);
        var i : usize = 0;
        while (i < minlen) : (i += 1) {
            var idxCheck = try checkOrder(allocator,left.list.items[i], right.list.items[i]);
            if (idxCheck == 1) return 1;
            if (idxCheck == -1) return -1;
        }
        if (shorterlist == 'L') return 1;
        if (shorterlist == 'R') return -1;
    }

    if (left == .int and right == .list) {
        var newLeft = Value { .list = std.ArrayList(Value).init(allocator) };
        try newLeft.list.append(Value { .int = left.int });
        return checkOrder(allocator, newLeft, right);
    }

    if (left == .list and right == .int) {
        var newRight = Value { .list = std.ArrayList(Value).init(allocator) };
        try newRight.list.append(Value { .int = right.int });
        return checkOrder(allocator, left, newRight);
    }

    return 0;
}