const std = @import("std");

pub fn scoreRound(round: []const u8) u32 {
    var pointstoadd: u32 = 0;
    const opponent = round[0];
    const self = round[2];

    if (self == 'X') { //rock
        pointstoadd += 1;

        if (opponent == 'A') { //rock
            pointstoadd += 3;
        }
        if (opponent == 'B') { //paper
            //lose
        }
        if (opponent == 'C') { //scissors
            pointstoadd += 6;
        }
    }

    if (self == 'Y') { //paper
        pointstoadd += 2;

        if (opponent == 'A') { //rock
            pointstoadd += 6;
        }
        if (opponent == 'B') { //paper
            pointstoadd += 3;
        }
        if (opponent == 'C') { //scissors
            //win
        }
    }

    if (self == 'Z') { //scissors
        pointstoadd += 3;

        if (opponent == 'A') { //rock
            //draw
        }
        if (opponent == 'B') { //paper
            pointstoadd += 6;
        }
        if (opponent == 'C') { //scissors
            pointstoadd += 3;
        }
    }

    return pointstoadd;
}

pub fn scoreRound2(round: []const u8) u32 {
    var pointstoadd: u32 = 0;
    const opponent = round[0];
    const self = round[2];

    if (self == 'X') { //lose


        if (opponent == 'A') { //rock
            pointstoadd += 3; //play scissors
        }
        if (opponent == 'B') { //paper
            pointstoadd += 1;
        }
        if (opponent == 'C') { //scissors
            pointstoadd += 2;
        }
    }

    if (self == 'Y') { //draw
        pointstoadd += 3;

        if (opponent == 'A') { //rock
            pointstoadd += 1;
        }
        if (opponent == 'B') { //paper
            pointstoadd += 2;
        }
        if (opponent == 'C') { //scissors
            pointstoadd += 3;
        }
    }

    if (self == 'Z') { //win
        pointstoadd += 6;

        if (opponent == 'A') { //rock
            pointstoadd += 2;
        }
        if (opponent == 'B') { //paper
            pointstoadd += 3;
        }
        if (opponent == 'C') { //scissors
            pointstoadd += 1;
        }
    }

    return pointstoadd;
}

pub fn daytwo() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day2.txt", @sizeOf(u8) * 30 * 3000);
    defer allocator.free(file);


    var lineiter = std.mem.split(u8, file, "\n");
    var totalPoints: u32 = 0;

    while (lineiter.next()) |line| {
        totalPoints += scoreRound(line);
    }

    try std.io.getStdOut().writer().print("Total points: {d}", .{totalPoints});

    lineiter = std.mem.split(u8, file, "\n");
    totalPoints = 0;

    while (lineiter.next()) |line| {
        totalPoints += scoreRound2(line);
    }

    try std.io.getStdOut().writer().print("Total points: {d}", .{totalPoints});


}
