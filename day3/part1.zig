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

    var map = std.AutoHashMap(u32, void).init(
        test_allocator,
    );
    defer map.deinit();

    std.debug.print("\n", .{});

    var buffer: [100]u8 = undefined;
    var total: usize = 0;
    while(try nextLine(file.reader(), &buffer)) |input| {
        const half = input.len / 2;
        for (input) |c, i| {
            if (i < half) {
                try map.put(c, {});
            } else if (map.contains(c)) {
                const pts = 
                    if (c >= 97 and c <= 122) c - 96
                    else if (c >= 65 and c <= 90) c - 38
                    else 0;
                std.debug.print("{c} - {d} ", .{c, pts});
                total += pts;
                break;
            }
        }
        map.clearRetainingCapacity();
        std.debug.print("{s}/{d}\n", .{input, half});
    }
    std.debug.print("Total: {d}\n", .{total});
}