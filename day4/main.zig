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

    std.debug.print("\n", .{});

    var buffer: [100]u8 = undefined;
    var fullyContainsTotal: usize = 0;
    var overlapTotal: usize = 0;
    while (try nextLine(file.reader(), &buffer)) |input| {
        if (fullyContains(input)) fullyContainsTotal += 1;
        if (overlap(input)) overlapTotal += 1;
    }
    std.debug.print("Fully contains: {d}\n", .{fullyContainsTotal});
    std.debug.print("Overlap: {d}\n", .{overlapTotal});
}

fn parseInput(input: []const u8) [4]usize {
    var bounds = [_]usize{ 0, 0, 0, 0 };
    var index: u8 = 0;
    for (input) |c| {
        if (c == ',' or c == '-') {
            index += 1;
            continue;
        }
        const num = c - 48;
        bounds[index] *= 10;
        bounds[index] += num;
    }
    return bounds;
}

fn fullyContains(input: []const u8) bool {
    const bounds = parseInput(input);
    // std.debug.print("{any} - {s}\n", .{ bounds, input });
    return (bounds[0] <= bounds[2] and bounds[1] >= bounds[3]) or
        (bounds[0] >= bounds[2] and bounds[1] <= bounds[3]);
}

fn overlap(input: []const u8) bool {
    const bounds = parseInput(input);
    // std.debug.print("{any} - {s}\n", .{ bounds, input });
    return (bounds[0] <= bounds[2] and bounds[1] >= bounds[2]) or
        (bounds[2] <= bounds[0] and bounds[3] >= bounds[0]);
}
