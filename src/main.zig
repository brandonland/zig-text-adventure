const std = @import("std");
const map = @import("map");

const Player = struct {
    name: []const u8,
    description: []const u8,
};
const PlayerState = struct {
    hp: u32,
    room: u8,
    status_effects: ?[]StatusEffect,
    inventory: ?[]Item,
    wielding: ?*Item,
    gear: ?[]Item,
};

const StatusEffect = struct {
    key: []const u8, // identifier for retrieval
    name: []const u8, // printable name
};

const Item = struct {
    key: []const u8, // key name (for retrieval)
    name: []const u8, // Printable name
    description: []const u8,
    stackable: bool,
    type: enum {
        key_item,
        weapon,
        wearable,
        consumable,
        currency,
    },
};

// Commands:
//
fn cmdHelp() void {}

fn cmdExamine() void {}

fn cmdTake() void {}

fn cmdDrop() void {}

fn cmdOpen() void {}

fn cmdPutItIn() void {}

fn cmdPutItOn() void {}

fn cmdPush() void {}

fn cmdPull() void {}

fn cmdTurn() void {}

fn cmdFeel() void {}

fn cmdEat() void {}

fn cmdUnknown() void {}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Initialize player state
    var p_state: PlayerState = PlayerState{
        .hp = 100,
        .room = 0,
        .status_effects = null,
        .inventory = null,
        .wielding = null,
        .gear = null,
    };

    var commands = std.StringHashMap(void).init();
    _ = commands;

    // Print the current room's description
    try stdout.print("{s}\n", .{map.rooms[p_state.room].description});

    while (true) {
        // If you've reached the end, you won
        if (std.mem.eql(u8, map.rooms[p_state.room].name, "the_end")) {
            try stdout.print("{s}\n", .{map.rooms[p_state.room].description});
            break;
        }

        // Print the prompt
        try stdout.print("> ", .{});
        try bw.flush(); // don't forget to flush!

        // I don't know why it works yet, but it works.
        //
        const stdin_reader = std.io.getStdIn().reader();
        var stdin_buffered = std.io.bufferedReader(stdin_reader);
        const stdin_buffered_reader = stdin_buffered.reader();
        var input_line_buf: [4096]u8 = undefined;
        const input_line =
            try stdin_buffered_reader.readUntilDelimiterOrEof(&input_line_buf, '\n') orelse {
            return;
        };
        std.debug.print("input is {s}\n", .{input_line});
    }
}
