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
    var pts: u32 = 0;
    while(try nextLine(file.reader(), &buffer)) |input| {
      const opp = input[0];
      const you: u8 = switch(input[2]) {
        'X' => 'A', // Rock
        'Y' => 'B', // Paper
        'Z' => 'C', // Scissors
        else => 0
      };
      const shape_pts: u8 = switch(you) {
        'A' => 1,
        'B' => 2,
        'C' => 3,
        else => 0
      };
      var outcome_pts: u32 = 0;
      if (
        (opp == 'A' and you == 'B') or
        (opp == 'B' and you == 'C') or
        (opp == 'C' and you == 'A')
        ) {
        outcome_pts += 6;
      } else if (opp == you) {
        outcome_pts += 3;
      }
      pts += (shape_pts + outcome_pts);
    }
    std.debug.print("{d}\n", .{pts});
}