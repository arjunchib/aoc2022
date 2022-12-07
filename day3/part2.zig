const std = @import("std");
const test_allocator = std.testing.allocator;

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

test "read until next line" {
    const file = try std.fs.cwd().openFile(
        // "test.txt",
        "input.txt",
        .{},
    );
    defer file.close();

    var map1 = std.AutoHashMap(u32, void).init(test_allocator);
    var map2 = std.AutoHashMap(u32, void).init(test_allocator);
    defer map1.deinit();
    defer map2.deinit();

    std.debug.print("\n", .{});

    var buffer: [100]u8 = undefined;
    var index: usize = 0;
    var total: usize = 0;
    while (try nextLine(file.reader(), &buffer)) |input| : (index += 1) {
        for (input) |c| {
            if (index % 3 == 0) {
                try map1.put(c, {});
            } else if (index % 3 == 1) {
                try map2.put(c, {});
            } else if (map1.contains(c) and map2.contains(c)) {
                const pts = switch (c) {
                    97...122 => c - 96,
                    65...90 => c - 38,
                    else => 0,
                };
                total += pts;
                std.debug.print("{s} - {c} - {d}\n", .{ input, c, pts });
                map1.clearRetainingCapacity();
                map2.clearRetainingCapacity();
                break;
            }
        }
    }
    std.debug.print("Total: {d}\n", .{total});
}
