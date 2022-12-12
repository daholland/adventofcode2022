const std = @import("std");

const Node = struct {
    height: u8,
    x: usize,
    y: usize,
    neighbors: [4]?*Node,

    pub fn populateNeighbors(self: *Node, graph: []*Node) !void {

        if (self.y < 40) self.neighbors[0] = graph[(self.y + 1) * 162 + self.x];
        if (self.y > 0) self.neighbors[1] = graph[(self.y - 1) * 162 + self.x];
        if (self.x > 0) self.neighbors[2] = graph[(self.y) * 162 + (self.x - 1)];
        if (self.x < 161) self.neighbors[3] = graph[(self.y) * 162 + (self.x + 1)];

    }
};

pub fn cmpNode(context: *Node, a: *Node, b: *Node) std.math.Order {
    var ctxX = @intCast(i64, context.*.x);
    var ctxY = @intCast(i64, context.*.y);
    var manhattandista = std.math.absCast(ctxX - @intCast(i64, a.*.x)) + std.math.absCast( ctxY - @intCast(i64, a.*.y));
    var manhattandistb = std.math.absCast(ctxX - @intCast(i64, b.*.x)) + std.math.absCast( ctxY - @intCast(i64, b.*.y));

    if (b.*.height > a.*.height and manhattandistb <= manhattandista) {
        return std.math.Order.gt;
    } else if (b.*.height < a.*.height) {
        return std.math.Order.lt;
    }
    return std.math.Order.eq;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const w =  std.io.getStdOut().writer();


    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day12.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var graph : [41*162]*Node = undefined;
    var start : *Node = undefined;
    var end : *Node = undefined;

    var lineiter = std.mem.split(u8, file, "\n");
    var lineno  : usize = 0;
    while (lineiter.next()) |line| {
        for (line) |c, i| {
            if (c == '\n') continue;

            var x = i; var y = lineno;

            var n = allocator.create(Node) catch unreachable;
            // defer allocator.destroy(n);
            var height = c;
            if (height == 'S') {
                start = n;
                height = 'a';
            }

            if (height == 'E') {
                end = n;
                height = 'z';
            }

            n.* = Node {
              .height = height, .x = x, .y = y, .neighbors = [4]?*Node { null, null, null, null }
            };
            try w.print("Node @ ({d},{d}) created in idx: {d} with height: {c}\n", .{x, y, (y) * 162 + x, c});
            graph[(y) * 162 + x] = n;
        }
        lineno += 1;
    }

    for (graph) |n| try n.populateNeighbors(std.mem.span(&graph));

    var frontier = std.PriorityQueue(*Node, *Node, cmpNode).init(allocator, end);
    try frontier.add(start);

    var came_from = std.AutoHashMap(*Node, *Node).init(allocator);
    var cost_so_far = std.AutoHashMap(*Node, u64).init(allocator);
    try came_from.put(start, undefined);
    try cost_so_far.put(start, 0);

    while (frontier.count() > 0) {
        var curr = frontier.remove();

        if (curr == end) {
            try w.print("Reached end the first!\n", .{});
            var steps: usize = 0;
            var trail: [1000]usize = undefined;
            while (came_from.get(curr) != null) {
                try w.print("cost_so_far[curr]: {d}\n", .{cost_so_far.get(curr).?});
                trail[steps] = curr.*.y * 162 + curr.*.x;
                curr = came_from.get(curr).?;
                steps += 1;
            }
            try printGraph(std.mem.span(&graph), &came_from, frontier.items[0..], trail[0..steps]);

            try w.print("# of steps: {d}\n", .{steps});
            continue;
        }

        for (curr.neighbors) |next| {
            if (next == null) continue;

            var new_cost = cost_so_far.get(curr).?  + 1;
            if (!cost_so_far.contains(next.?) or new_cost < (cost_so_far.get(next.?) orelse 0)) {
                if (curr.height + 1 >= next.?.height) {
                    try cost_so_far.put(next.?, new_cost);
                    // var priority
                    try frontier.add(next.?);
                    try came_from.put(next.?, curr);
                }
            }
        }

        // if (curr.height >= 'x') {
        //     try printGraph(std.mem.span(&graph), &came_from, frontier.items[0..], null);
        //
        //     try w.print("Press enter to step ... ", .{});
        //     var buf: [5]u8 = undefined;
        //     _ = try std.io.getStdIn().reader().readUntilDelimiterOrEof(buf[0..], '\n');
        //
        // }

    }

    var steps: usize = 0;
    var trail: [1000]usize = undefined;
    var curr = end;
    while (came_from.get(curr) != null) {
        // try w.print("cost_so_far[curr]: {d}\n", .{cost_so_far.get(curr).?});
        trail[steps] = curr.*.y * 162 + curr.*.x;
        curr = came_from.get(curr).?;
        steps += 1;
    }
    try w.print("FULL RUN\n------------\n# of steps: {d}\n", .{steps});

    try printGraph(std.mem.span(&graph), &came_from, frontier.items[0..], trail[0..steps]);

    try w.print("# of steps: {d}\n", .{steps});
    try w.print("# of frontier: {d}\n", .{frontier.count()});
    var smallesttrailstepsforallruns: usize = 100000000;
    for (graph) |*n| {
        if (n.*.height != 'a') {
            continue;
        }
        start = n.*;
        var frontier2 = std.PriorityQueue(*Node, *Node, cmpNode).init(allocator, end);
        try frontier2.add(start);

        came_from.clearRetainingCapacity();
        cost_so_far.clearRetainingCapacity();
        try came_from.put(start, undefined);
        try cost_so_far.put(start, 0);

        while (frontier2.count() > 0) {
            curr = frontier2.remove();

            if (curr == end) {
                // try w.print("Reached end the first!\n", .{});
                steps = 0;
                trail = undefined;
                while (came_from.get(curr) != null) {
                    // try w.print("cost_so_far[curr]: {d}\n", .{cost_so_far.get(curr).?});
                    trail[steps] = curr.*.y * 162 + curr.*.x;
                    curr = came_from.get(curr).?;
                    steps += 1;
                }
                // try printGraph(std.mem.span(&graph), &came_from, frontier2.items[0..], trail[0..steps]);

                try w.print("# of steps: {d}\n", .{steps});
                if (steps < smallesttrailstepsforallruns) smallesttrailstepsforallruns = steps;
                continue;
            }

            for (curr.neighbors) |next| {
                if (next == null) continue;

                var new_cost = cost_so_far.get(curr).?  + 1;
                if (!cost_so_far.contains(next.?) or new_cost < (cost_so_far.get(next.?) orelse 0)) {
                    if (curr.height + 1 >= next.?.height) {
                        try cost_so_far.put(next.?, new_cost);
                        // var priority
                        try frontier2.add(next.?);
                        try came_from.put(next.?, curr);
                    }
                }
            }

            // if (curr.height >= 'x') {
            //     try printGraph(std.mem.span(&graph), &came_from, frontier.items[0..], null);
            //
            //     try w.print("Press enter to step ... ", .{});
            //     var buf: [5]u8 = undefined;
            //     _ = try std.io.getStdIn().reader().readUntilDelimiterOrEof(buf[0..], '\n');
            //
            // }

        }



        // try printGraph(std.mem.span(&graph), &came_from, frontier.items[0..], trail[0..steps]);
    }

    try w.print("All runs smallest steps (already - 1):  {d}", .{smallesttrailstepsforallruns - 1});

    try w.print("Node @ (0,0) neighbors:  ", .{});
    for (graph[0*162 + 0].neighbors) |n| {
        if (n != null) {
            try w.print("Node @ ({d},{d}) \t", .{n.?.x, n.?.y});
        }
    }
    try w.print("\nNode @ (0,161) neighbors:  ", .{});

    for (graph[0*162 + 161].neighbors) |n| {
        if (n != null) {
            try w.print("Node @ ({d},{d}) \t", .{n.?.x, n.?.y});
        }
    }
    try w.print("\nNode @ (40,0) neighbors:  ", .{});

    for (graph[40*162 + 0].neighbors) |n| {
        if (n != null) {
            try w.print("Node @ ({d},{d}) \t", .{n.?.x, n.?.y});
        }
    }
    try w.print("\nNode @ (40,161) neighbors:  ", .{});

    for (graph[40*162 + 161].neighbors) |n| {
        if (n != null) {
            try w.print("Node @ ({d},{d}) \t", .{n.?.x, n.?.y});
        }
    }



    try w.print("\n", .{ });


}

pub fn printGraph(graph: []*Node, came_from: *const std.AutoHashMap(*Node, *Node), frontier: []*Node, trail: ?[]usize) !void {
    const w =  std.io.getStdOut().writer();

    for (graph) |*n, i| {
        if (i % 162 == 0) try w.print("\n", .{});
        if (trail != null and std.mem.indexOf(usize, trail.?, &[_]usize { i }) != null) {
            try w.print("*", .{});
        } else if (came_from.contains(n.*)) {

            try w.print("#", .{});
        } else if (std.mem.indexOf(*Node, frontier[0..], &[_]*Node { n.* }) != null) {
            try w.print("@", .{});
        } else {
            try w.print("{c}", .{n.*.height});
        }
    }
    try w.print("\n", .{});
}