const std = @import("std");

pub fn setRC(bitset: *std.DynamicBitSet, row: usize, col: usize) void {
    bitset.set(row*99 + col);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day8.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var lineiter = std.mem.split(u8, file, "\n");
    var forest: [99][99]u8 = undefined;
    var lineno: usize = 0;
    while (lineiter.next()) |line| {
        forest[lineno] = [_]u8{0} ** 99;
        for (line) |c, i| {
            forest[lineno][i] = c - 48;
        }
        lineno += 1;
    }
    var visibleSet: std.DynamicBitSet = try std.DynamicBitSet.initEmpty(allocator, 99*99);

    for (forest) |row| {
        for (row) |c| {
            try std.io.getStdOut().writer().print("{c}", .{c + 48});
        }
        // try std.io.getStdOut().writer().print("{s} ", .{row});
        try std.io.getStdOut().writer().print(" row[0]: {d}\n", .{row[0]});
    }

    try scanFromTop(&forest, &visibleSet);
    try scanFromBottom(&forest, &visibleSet);
    try scanFromLeft(&forest, &visibleSet);
    try scanFromRight(&forest, &visibleSet);

    _ = try scanDownFromTree(&forest, 3, 3);
    _ = try scanUpFromTree(&forest, 3, 3);
    _ = try scanLeftFromTree(&forest, 3, 3);
    _ = try scanRightFromTree(&forest, 3, 3);

    _ = try scanDownFromTree(&forest, 98, 98);
    _ = try scanUpFromTree(&forest, 0, 5);
    _ = try scanLeftFromTree(&forest, 96, 0);
    _ = try scanRightFromTree(&forest, 96, 98);

    // var x : usize = 0;
    // var y : usize = 0;
    var bestScenicScore : usize = 0;
    var best_x : usize = 0;
    var best_y : usize = 0;
    for (forest) |row,row_i| {
        for (row) |_, col_i| {
            var d = try scanDownFromTree(&forest, row_i, col_i);
            var u = try scanUpFromTree(&forest, row_i, col_i);
            var l = try scanLeftFromTree(&forest, row_i, col_i);
            var r = try scanRightFromTree(&forest, row_i, col_i);

            var score = d * u * l * r;

            if (row_i == 57 and col_i == 84) try std.io.getStdOut().writer().print("({d},{d}): {d} = {d} * {d} * {d} * {d} \n", .{row_i, col_i, score, d, u, l, r});

            if (score > bestScenicScore) {
                best_x = row_i;
                best_y = col_i;
                bestScenicScore = score;
            }
        }

    }

    try std.io.getStdOut().writer().print("Best Scenic score is {d} @ ({d}, {d})\n", .{bestScenicScore, best_x, best_y});

}

pub fn scanFromTop(forest: *[99][99]u8, visible: *std.DynamicBitSet) !void {
    var col: usize = 0;
    while (col < 99) : (col += 1) {
        var row : usize = 0;
        setRC(visible, row, col);
        var highestSeenTree = forest[row][col];

        while (row < 99) : (row += 1) {
            if (forest[row][col] > highestSeenTree) {
                setRC(visible, row, col);
                highestSeenTree = forest[row][col];
            }
        }
        try std.io.getStdOut().writer().print("TOP {d} visible count \n", .{visible.count()});
    }
}

pub fn scanFromBottom(forest: *[99][99]u8, visible: *std.DynamicBitSet) !void {
    var col: usize = 0;
    while (col < 99) : (col += 1) {
        var row : usize = 98;
        setRC(visible, row, col);
        var highestSeenTree = forest[row][col];

        while (row > 0) : (row -= 1) {
            if (forest[row][col] > highestSeenTree) {
                setRC(visible, row, col);
                highestSeenTree = forest[row][col];
            }
        }
        try std.io.getStdOut().writer().print("BOT {d} visible count \n", .{visible.count()});
    }
}

pub fn scanFromLeft(forest: *[99][99]u8, visible: *std.DynamicBitSet) !void {
    var row : usize = 0;
    while (row < 99) : (row += 1) {
        var col: usize = 0;
        setRC(visible, row, col);
        var highestSeenTree = forest[row][col];

        while (col < 99) : (col += 1) {
            if (forest[row][col] > highestSeenTree) {
                setRC(visible, row, col);
                highestSeenTree = forest[row][col];
            }
        }
        try std.io.getStdOut().writer().print("LEFT {d} visible count \n", .{visible.count()});
    }
}

pub fn scanFromRight(forest: *[99][99]u8, visible: *std.DynamicBitSet) !void {
    var row : usize = 0;
    while (row < 99) : (row += 1) {
        var col: usize = 98;
        setRC(visible, row, col);
        var highestSeenTree = forest[row][col];

        while (col > 0) : (col -= 1) {
            if (forest[row][col] > highestSeenTree) {
                setRC(visible, row, col);
                highestSeenTree = forest[row][col];
            }
        }
        try std.io.getStdOut().writer().print("RIGHT {d} visible count \n", .{visible.count()});

    }
}

pub fn scanDownFromTree(forest: *[99][99]u8, row_in: usize, col_in: usize) !usize {
    var col: usize = col_in;

    var row : usize = row_in;
    var highestSeenTree = forest[row][col];
    var seenTrees : usize = 0;

    while (row < 99) : (row += 1) {
            if (row == row_in and col == col_in) {
                continue;
            }
            if (forest[row][col] >= highestSeenTree) {
                seenTrees += 1;
                break;
            }
            seenTrees += 1;
    }
    // try std.io.getStdOut().writer().print("# Trees looking DOWN from ({d} , {d}): {d}\n", .{row_in, col_in, seenTrees});
    return seenTrees;
}

pub fn scanUpFromTree(forest: *[99][99]u8, row_in: usize, col_in: usize) !usize {
    var col: usize = col_in;

       var row : usize = row_in;
       var highestSeenTree = forest[row][col];
       var seenTrees : usize = 0;

       while (row > -1) : (row -= 1) {
              if (row_in == 0) {
                  break;
              }
               if (row == row_in and col == col_in) {
                   continue;
               }
               if (row == 0) {
                    seenTrees += 1;
                    break;
               }
               if (forest[row][col] >= highestSeenTree) {
                   seenTrees += 1;
                   break;
               }
               seenTrees += 1;
       }
      // try std.io.getStdOut().writer().print("# Trees looking UP from ({d} , {d}): {d}\n", .{row_in, col_in, seenTrees});
       return seenTrees;
}

pub fn scanLeftFromTree(forest: *[99][99]u8, row_in: usize, col_in: usize) !usize {
    var col: usize = col_in;
    var row : usize = row_in;
    var highestSeenTree = forest[row][col];
    var seenTrees : usize = 0;

    while (col > -1) : (col -= 1) {
            if (col_in == 0) {
                break;
            }
           if (row == row_in and col == col_in) {
               continue;
           }
           if (col == 0) {
                seenTrees += 1;
                break;
           }
           if (forest[row][col] >= highestSeenTree) {
               seenTrees += 1;
               break;
           }
           seenTrees += 1;
    }
   // try std.io.getStdOut().writer().print("# Trees looking LEFT from ({d} , {d}): {d}\n", .{row_in, col_in, seenTrees});
    return seenTrees;
}

pub fn scanRightFromTree(forest: *[99][99]u8, row_in: usize, col_in: usize) !usize {
    var col: usize = col_in;

    var row : usize = row_in;
    var highestSeenTree = forest[row][col];
    var seenTrees : usize = 0;

    while (col < 99) : (col += 1) {
      if (row == row_in and col == col_in) {
          continue;
      }
      if (forest[row][col] >= highestSeenTree) {
          seenTrees += 1;
          break;
      }
      seenTrees += 1;
    }
   // try std.io.getStdOut().writer().print("# Trees looking RIGHT from ({d} , {d}): {d}\n", .{row_in, col_in, seenTrees});
    return seenTrees;
}