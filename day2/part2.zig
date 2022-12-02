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

const Shape = enum(u32) {
    rock = 1,
    paper = 2,
    scissors = 3,
};

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
      const you: u8 = input[2];
      const outcome_pts: u8 = switch(you) {
        'X' => 0, // Lose
        'Y' => 3, // Draw
        'Z' => 6, // Win
        else => 0
      };
      var shape_pts: u32 = 0;
      if (opp == 'A') { // Rock
        if (you == 'X') shape_pts += @enumToInt(Shape.scissors);
        if (you == 'Y') shape_pts += @enumToInt(Shape.rock);
        if (you == 'Z') shape_pts += @enumToInt(Shape.paper);
      } else if (opp == 'B') { // Paper
        if (you == 'X') shape_pts += @enumToInt(Shape.rock);
        if (you == 'Y') shape_pts += @enumToInt(Shape.paper);
        if (you == 'Z') shape_pts += @enumToInt(Shape.scissors);
      } else if (opp == 'C') { // Scissors
        if (you == 'X') shape_pts += @enumToInt(Shape.paper);
        if (you == 'Y') shape_pts += @enumToInt(Shape.scissors);
        if (you == 'Z') shape_pts += @enumToInt(Shape.rock);
      }
      pts += (shape_pts + outcome_pts);
    }
    std.debug.print("{d}\n", .{pts});
}