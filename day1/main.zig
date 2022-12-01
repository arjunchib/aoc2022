const std = @import("std");

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
    var calories: u32 = 0;
    var max1: u32 = 0;
    var max2: u32 = 0;
    var max3: u32 = 0;
    while(true) {
        const input = (try nextLine(file.reader(), &buffer));
        if (input == null) {
            // Process final output
            // std.debug.print("{d}\n", .{calories});
            if (calories > max1) {
                max3 = max2;
                max2 = max1;
                max1 = calories;
            } else if (calories > max2) {
                max3 = max2;
                max2 = calories;
            } else if (calories > max3) {
                max3 = calories;
            }
            break;
        }
        const num = std.fmt.parseInt(u32, input.?, 10) catch {
            // Process each elf
            // std.debug.print("{d}\n", .{calories});
            if (calories > max1) {
                max3 = max2;
                max2 = max1;
                max1 = calories;
            } else if (calories > max2) {
                max3 = max2;
                max2 = calories;
            } else if (calories > max3) {
                max3 = calories;
            }
            calories = 0;
            continue;
        };
        calories += num;
    }
    std.debug.print("max1: {d}\n", .{max1});
    std.debug.print("max2: {d}\n", .{max2});
    std.debug.print("max3: {d}\n", .{max3});
    std.debug.print("sum: {d}\n", .{max1 + max2 + max3});
}