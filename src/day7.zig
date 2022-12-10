const std = @import("std");
const Directory = struct {
    name: []const u8,
    contents: std.ArrayList(File_t),
    parent: ?*Directory,

    pub fn init(self: *Directory, allocator: std.mem.Allocator) void {
        self.contents.init(allocator);
    }
    pub fn getContentsSize(self: *const Directory) u64 {
        var sumSize: u64 = 0;
        for (self.contents.items) |entry| {
            switch (entry) {
                .file => |*file| sumSize += file.size,
                .dir => |*dir| sumSize += dir.getContentsSize(),
            }
        }
        return sumSize;
    }
    // pub fn getContentsSizeLimit(self: *const Directory, limit: u64) u64 {
    //     var sumSize: u64 = 0;
    //     for (self.contents.items) |entry| {
    //         switch (entry) {
    //             .file => {
    //                 // if (file.size <= limit) {
    //                 //     sumSize += file.size;
    //
    //
    //             },
    //             .dir  => |*dir| {
    //                 const size = dir.getContentsSize();
    //                 if (size <= limit) {
    //                     sumSize += dir.getContentsSizeLimit(100000);
    //                 }
    //             }
    //         }
    //     }
    //     return sumSize;
    // }
    pub fn addItem(self: *Directory, item: File_t) !void {
        try self.contents.append(item);
    }
    pub fn findDir(self: *Directory, name: []const u8) *Directory {
        var ret: *Directory = self;
        for (self.contents.items) |*entry| {
            switch (entry.*) {
                .file => |*file| _ = file,
                .dir => |*dir| if (std.mem.eql(u8, dir.name, name)) {
                    ret = &(dir.*);
                },
            }
        }
        return ret;
    }
};
const File = struct { name: []const u8, size: u64 };
const File_t = union(enum) { file: File, dir: Directory };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day7.txt", @sizeOf(u8) * 50 * 3000 * 100);
    defer allocator.free(file);

    var lineiter = std.mem.split(u8, file, "\n");
    var fileSystem = File_t{ .dir = Directory{ .name = "/", .contents = std.ArrayList(File_t).init(allocator), .parent = null } };
    var currWorkingDirectory: *Directory = &fileSystem.dir;
    var allDirectories: std.ArrayList(*Directory) = std.ArrayList(*Directory).init(allocator);
    try std.io.getStdOut().writer().print("CWD: {s} Dir Size: {d}\n", .{ currWorkingDirectory.*.name, currWorkingDirectory.getContentsSize() });

    while (lineiter.next()) |line| {
        var splititer = std.mem.split(u8, line, " ");
        var curr = splititer.next();

        if (std.mem.eql(u8, curr.?, "$")) {
            curr = splititer.next();
            if (std.mem.eql(u8, curr.?, "cd")) {
                var targ = splititer.next();
                if (std.mem.eql(u8, targ.?, "..")) {
                    currWorkingDirectory = currWorkingDirectory.parent orelse &fileSystem.dir;
                }
                if (std.mem.eql(u8, targ.?, "/")) {
                    currWorkingDirectory = &fileSystem.dir;
                }
                if (!std.mem.eql(u8, targ.?, "/") or !std.mem.eql(u8, targ.?, "..")) {
                    var item = currWorkingDirectory.findDir(targ.?);

                    currWorkingDirectory = item;
                }
            }
        }

        if (std.mem.eql(u8, curr.?, "dir")) {
            curr = splititer.next();
            try currWorkingDirectory.addItem(File_t{ .dir = Directory{ .name = curr.?, .contents = std.ArrayList(File_t).init(allocator), .parent = currWorkingDirectory } });
            try allDirectories.append(currWorkingDirectory.findDir(curr.?));
        }

        if (curr.?[0] >= '0' and curr.?[0] <= '9') {
            var size = curr.?;
            var name = splititer.next();
            try currWorkingDirectory.addItem(File_t{ .file = File{ .name = name.?, .size = try std.fmt.parseUnsigned(u64, size, 10) } });
        }
    }
    try std.io.getStdOut().writer().print("CWD: {s} Dir Size: {d}\n", .{ currWorkingDirectory.*.name, currWorkingDirectory.getContentsSize() });
    currWorkingDirectory = &fileSystem.dir;
    try std.io.getStdOut().writer().print("CWD: {s} Dir Size: {d}\n", .{ currWorkingDirectory.*.name, currWorkingDirectory.getContentsSize() });
    try std.io.getStdOut().writer().print("CWD: {s} Dir Size: {d}\n", .{ currWorkingDirectory.*.name, currWorkingDirectory.getContentsSize() });

    try std.io.getStdOut().writer().print(" Size: {d}\n", .{currWorkingDirectory.getContentsSize()});
    var foo = try printTreeSize(&fileSystem, allocator);
    try std.io.getStdOut().writer().print(" Size: {d}\n", .{foo});

        var foo2 = try printTreeSize2(&fileSystem, allocator);
        try std.io.getStdOut().writer().print(" Smallest dir to delete size: {d}\n", .{foo2});
    // try std.io.getStdOut().writer().print("Root filesystem \n------------------\n", .{});
    //
    // for (fileSystem.dir.contents.items) |entry| {
    //     var name: []const u8 = "";
    //     switch (entry) {
    //         .file => |f| name = f.name,
    //         .dir => |dir| name = dir.name,
    //     }
    //     try std.io.getStdOut().writer().print("item name: {s}\n", .{name});
    //
    // }
    //
    // try std.io.getStdOut().writer().print("plws filesystem \n------------------\n", .{});
    //
    // for (fileSystem.dir.contents.items[0].dir.contents.items) |entry| {
    //     var name: []const u8 = "";
    //     switch (entry) {
    //         .file => |f| name = f.name,
    //         .dir => |dir| name = dir.name,
    //     }
    //     try std.io.getStdOut().writer().print("item name: {s}\n", .{name});
    //
    // }

    //try printTree(&fileSystem, 0);

    //try std.io.getStdOut().writer().print("LessThan10000 sum: {d}", .{try addAllLessThan100000(&fileSystem, allocator)});

}
pub fn printTree(root: *const File_t, indent: u32) !void {
    const w = std.io.getStdOut().writer();
    var i = indent;
    while (i > 0) : (i -= 1) {
        try w.print("\t", .{});
    }

    try w.print("{s}\n", .{root.dir.name});

    for (root.dir.contents.items) |item| {
        switch (item) {
            .file => |file| {
                i = indent;
                while (i > 0) : (i -= 1) {
                    try w.print(" \t", .{});
                }
                try w.print("\t-{s} {d}\n", .{ file.name, file.size });
            },
            .dir => {
                try printTree(&item, indent + 1);
            },
        }
    }
    try w.print("\n", .{});
}

pub fn printTreeSize(root: *const File_t, allocator: std.mem.Allocator) !u64 {
    var retSum: u64 = 0;
    var stack: std.ArrayList(*const File_t) = std.ArrayList(*const File_t).init(allocator);
    var discovered: std.AutoHashMap(*const Directory, bool) = std.AutoHashMap(*const Directory, bool).init(allocator);

    try stack.append(root);

    while (stack.items.len > 0) {
        var v = stack.pop();

        if (discovered.get(&v.dir) orelse false) {
            continue;
        }

        try discovered.put(&v.dir, true);
        var size = v.dir.getContentsSize();
        //try std.io.getStdOut().writer().print("{s} is being processed and has size: {d}\n", .{ v.dir.name, size });
        if (size <= 100000) {
            retSum += size;
        }

        for (v.dir.contents.items) |*it| {
            switch (it.*) {
                .file => {
                    //try std.io.getStdOut().writer().print("{s} is a file\n", .{it.file.name});
                },
                .dir => {
                    //try std.io.getStdOut().writer().print("{s} is a dir\n", .{it.dir.name});
                    if (!(discovered.get(&it.dir) orelse false)) {
                        try stack.append(it);
                    }
                },
            }
        }
        // try std.io.getStdOut().writer().print("END OF LOOP STACK\n--------\n", .{});
        //
        // for (stack.items) |it| {
        //     switch (it.*) {
        //                     .file => {
        //                         try std.io.getStdOut().writer().print("ERROR\n", .{});
        //                     },
        //                     .dir => {
        //                         try std.io.getStdOut().writer().print("{s}\n", .{it.dir.name});
        //
        //                     },
        //                 }
        // }
        //     try std.io.getStdOut().writer().print("--------\n", .{});
    }


    return retSum;
}

pub fn printTreeSize2(root: *const File_t, allocator: std.mem.Allocator) !u64 {
    var retSum: u64 = 70000000;
    var stack: std.ArrayList(*const File_t) = std.ArrayList(*const File_t).init(allocator);
    var discovered: std.AutoHashMap(*const Directory, bool) = std.AutoHashMap(*const Directory, bool).init(allocator);
    var unusedSpace = 70000000 - root.dir.getContentsSize();
    var spaceNeeded = 30000000 - unusedSpace;
    try std.io.getStdOut().writer().print(" spaceNeeded: {d} unusedSpace: {d}\n", .{ spaceNeeded , unusedSpace});

    try stack.append(root);

    while (stack.items.len > 0) {
        var v = stack.pop();

        if (discovered.get(&v.dir) orelse false) {
            continue;
        }

        try discovered.put(&v.dir, true);
        var size = v.dir.getContentsSize();
        if (size >= spaceNeeded) {
            if (size < retSum) {
                retSum = size;
            }
        }

        for (v.dir.contents.items) |*it| {
            switch (it.*) {
                .file => {
                    //try std.io.getStdOut().writer().print("{s} is a file\n", .{it.file.name});
                },
                .dir => {
                    //try std.io.getStdOut().writer().print("{s} is a dir\n", .{it.dir.name});
                    if (!(discovered.get(&it.dir) orelse false)) {
                        try stack.append(it);
                    }
                },
            }
        }

    }
    return retSum;
}

pub fn addAllLessThan100000(root: *const File_t, allocator: std.mem.Allocator) !u64 {
    var dirsToSum: std.ArrayList(*const Directory) = std.ArrayList(*const Directory).init(allocator);
    var retSum: u64 = 0;
    for (root.dir.contents.items) |filet| {
        switch (filet) {
            .dir => |*dir| {
                if (dir.getContentsSize() <= 100000) {
                    try dirsToSum.append(dir);
                }
                retSum += try addAllLessThan100000(&filet, allocator);
            },
            .file => {},
        }
    }

    while (dirsToSum.items.len > 0) {
        for (dirsToSum.items) |i| {
            try std.io.getStdOut().writer().print("toSum d name: {s} # of items: {d}\n", .{ i.name, i.contents.items.len });
        }
        var d = dirsToSum.pop();
        try std.io.getStdOut().writer().print("popped d name: {s} # of items: {d}\n", .{ d.name, d.contents.items.len });

        retSum += d.getContentsSize();
    }

    return retSum;
}
