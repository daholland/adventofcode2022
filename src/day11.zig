const std = @import("std");

const Test = struct {
    divisor: usize,
    true_targ: usize,
    false_targ: usize
};

const Monkey = struct {
    items: std.ArrayList(usize),
    operation: *const fn(a: usize, b: usize) usize,
    operation_amt: usize,
    throwtest: Test,
    items_seen: usize,

    pub fn step(self: *Monkey, group: []Monkey) !void {
        const M = 2 * 3 * 5 * 7 * 11 * 13 * 17 * 19 ;
        while (self.items.items.len > 0) {
            var helditem = self.items.pop();
            self.items_seen += 1;

            var newworry = self.operation(helditem, self.operation_amt);
            // try std.io.getStdOut().writer().print("{d} OP {d} == {d}\n", .{helditem, self.operation_amt, newworry});

            newworry = @mod(newworry, M);


            if (newworry % self.throwtest.divisor == 0) {
                //throw
                // try std.io.getStdOut().writer().print("T branch - throwing {d} @ monkey {d}\nT branch {d}\n", .{newworry, self.throwtest.true_targ, self.items.items});

                try group[self.throwtest.true_targ].items.insert(0, newworry);
            } else {
                // try std.io.getStdOut().writer().print("F branch - throwing {d} @ monkey {d}\nT branch {d}\n", .{newworry, self.throwtest.false_targ, self.items.items});
                try group[self.throwtest.false_targ].items.insert(0, newworry);
            }
        }

    }
};

pub fn op_Mul(a: usize, b: usize) usize {
    return a * b;
}

pub fn op_Add(a: usize, b: usize) usize {
    return a + b;
}

pub fn op_Square(a: usize, b: usize) usize {
    _ = b;
    return a * a;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const w =  std.io.getStdOut().writer();


    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day11.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var lineiter = std.mem.split(u8, file, "\n");
    var monkeys: [8]Monkey = undefined;

    var monkeyIdx: usize = 0;
    while (lineiter.next()) |line| {
        _ = line;
        var line2 = lineiter.next().?;
        var items = std.ArrayList(usize).init(allocator);

        // try w.print("line2: {s}\n", .{line2[18..line2.len]});

        var tokeniter = std.mem.tokenize(u8, line2[18..line2.len], ", ");
        while (tokeniter.next()) |n| {
            try items.append(try std.fmt.parseUnsigned(u8, n, 10));
        }

        line2 = lineiter.next().?;
        // try w.print("line2: {s}\n", .{line2[23..]});

        var op = std.mem.trim(u8, line2[23..], "\n");
        var opiter = std.mem.split(u8, op, " ");
        var opfn = opiter.next().?;
        var opamt = opiter.next().?;

        var pFn: *const fn(a: usize, b: usize) usize = undefined;

        if (std.mem.eql(u8, opfn, "*")) pFn = &op_Mul;
        if (std.mem.eql(u8, opfn, "+")) pFn = &op_Add;

        var opamtn = std.fmt.parseUnsigned(u8, opamt, 10) catch 0;

        if (std.mem.eql(u8, opamt, "old")) pFn = &op_Square;

        line2 = lineiter.next().?;
        var divisor = try std.fmt.parseUnsigned(usize, std.mem.trim(u8, line2[21..], "\n"), 10);
        line2 = lineiter.next().?;
        // try w.print("line2: {s}\n", .{line2[29..]});

        var truetarg = try std.fmt.parseUnsigned(usize, line2[29..30], 10);
        line2 = lineiter.next().?;
        var falsetarg = try std.fmt.parseUnsigned(usize, line2[30..31], 10);

        _ = lineiter.next();
        std.mem.reverse(usize, items.items);
        var m = Monkey {
            .items = items,
            .operation = pFn,
            .operation_amt = opamtn,
            .items_seen = 0,
            .throwtest = Test {
                    .divisor = divisor,
                    .true_targ = truetarg,
                    .false_targ = falsetarg
            }
        };

        try w.print("parsed: Monkey #{d} item count: {d} op: {any} op_amt: {d} test: % {d} T:{d} F:{d} \n",
                        .{monkeyIdx, m.items.items, m.operation, m.operation_amt,
                        m.throwtest.divisor, m.throwtest.true_targ, m.throwtest.false_targ });

        monkeys[monkeyIdx] = m;
        monkeyIdx += 1;
    }


    monkeyIdx = 0;
    var round: usize = 0;
    var monkeybusiness = [8]usize {0,0,0,0,0,0,0,0};
    for (monkeys) |*m| { m.*.items_seen = 0;}

    while (round < 10000) {
        round += 1;
        try w.print("====   Round {d}   ====\n", .{round});
        while (monkeyIdx < monkeys.len) : (monkeyIdx += 1) {
            var m = &monkeys[monkeyIdx];
            // try w.print("****\nbefore turn: Monkey #{d} item count: {d} op: {any} op_amt: {d} test: % {d} T:{d} F:{d} \n",
            //                         .{monkeyIdx, m.items.items, m.operation, m.operation_amt,
            //                         m.throwtest.divisor, m.throwtest.true_targ, m.throwtest.false_targ });

            try m.step(std.mem.span(&monkeys));

            // try w.print("after turn: Monkey #{d} item count: {d} op: {any} op_amt: {d} test: % {d} T:{d} F:{d} \n****\n",
            //                         .{monkeyIdx, m.items.items, m.operation, m.operation_amt,
            //                         m.throwtest.divisor, m.throwtest.true_targ, m.throwtest.false_targ });
            monkeybusiness[monkeyIdx] = m.*.items_seen;
        }
        monkeyIdx = 0;
        // for (monkeys) |m, i| {
            // try w.print("after round: Monkey #{d} item count: {d} op: {any} op_amt: {d} test: % {d} T:{d} F:{d} \n****\n",
            //                                     .{i, m.items.items, m.operation, m.operation_amt,
            //                                     m.throwtest.divisor, m.throwtest.true_targ, m.throwtest.false_targ });
        // }
        monkeyIdx = 0;
        try w.print("==== End Round {d} ====\n", .{round});
    }

    try w.print("\nmonkeybusiness: {d}", .{monkeybusiness});
    std.sort.sort(usize, &monkeybusiness, {}, cmpMonkeyItemsSeen);
    try w.print("\nmonkeybusiness: {d} product .0 * .1: {d}\n", .{monkeybusiness, monkeybusiness[0] * monkeybusiness[1]});
    // monkeyIdx = 0;
    // round = 0;
    // monkeybusiness = [4]usize {0,0,0,0};//,0,0,0,0};
    //   for (monkeys) |*m| { m.*.items_seen = 0;}
    // while (round < 1) {
    //         round += 1;
    //         try w.print("====   Round {d}   ====\n", .{round});
    //         while (monkeyIdx < monkeys.len) : (monkeyIdx += 1) {
    //             var m = &monkeys[monkeyIdx];
    //             try w.print("****\nbefore turn: Monkey #{d} item count: {d} op: {any} op_amt: {d} test: % {d} T:{d} F:{d} \n",
    //                                     .{monkeyIdx, m.items.items, m.operation, m.operation_amt,
    //                                     m.throwtest.divisor, m.throwtest.true_targ, m.throwtest.false_targ });
    //
    //             try m.step(std.mem.span(&monkeys));
    //
    //             try w.print("after turn: Monkey #{d} item count: {d} op: {any} op_amt: {d} test: % {d} T:{d} F:{d} \n****\n",
    //                                     .{monkeyIdx, m.items.items, m.operation, m.operation_amt,
    //                                     m.throwtest.divisor, m.throwtest.true_targ, m.throwtest.false_targ });
    //             monkeybusiness[monkeyIdx] = m.*.items_seen;
    //         }
    //         monkeyIdx = 0;
    //         for (monkeys) |m, i| {
    //             try w.print("after round: Monkey #{d} item count: {d} op: {any} op_amt: {d} test: % {d} T:{d} F:{d} \n****\n",
    //                                                 .{i, m.items.items, m.operation, m.operation_amt,
    //                                                 m.throwtest.divisor, m.throwtest.true_targ, m.throwtest.false_targ });
    //         }
    //         monkeyIdx = 0;
    //         try w.print("==== End Round {d} ====\n", .{round});
    //     }

}

pub fn cmpMonkeyItemsSeen(context: void, a: usize, b: usize) bool {
    if (a > b) {
        return true;
    } else {
        return false;
    }
    _ = context;
}