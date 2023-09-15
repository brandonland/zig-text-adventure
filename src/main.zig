const std = @import("std");

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

// Tuple
//const direction = .{
//    "north",
//    "east",
//    "south",
//    "west",
//    "up",
//    "down",
//};

const Room = struct {
    name: []const u8,
    description: []const u8,
    items: ?[]u16, // array of items in the room
    //exits: []u8,
    north: ?usize,
    east: ?usize,
    south: ?usize,
    west: ?usize,
    up: ?usize,
    down: ?usize,
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

const rooms = [_]Room{
    Room{ // 0
        .name = "start",
        .description = "This is your bedroom. You keep forgetting to clean it...",
        .items = null,
        .north = null,
        .south = 1,
        .east = null,
        .west = null,
        .up = null,
        .down = null,
    },
    Room{ // 1
        .name = "apartment_living_room",
        .description = "This is your apartment living room.",
        .items = null,
        .north = null,
        .east = 2,
        .south = 3,
        .west = null,
        .up = null,
        .down = null,
    },
    Room{ // 2
        .name = "bathroom",
        .description = "A cute little bathroom.",
        .items = null,
        .north = null,
        .east = null,
        .south = null,
        .west = 1, // connected to living room
        .up = null,
        .down = null,
    },
    Room{ // 3
        .name = "your_apartment_entrance",
        .description = "Just outside of your apartment building.",
        .items = null,
        .north = 1,
        .east = null,
        .south = 4,
        .west = null,
        .up = null,
        .down = null,
    },
    Room{ // 4
        .name = "the_end",
        .description = "You made it!",
        .items = null,
        .north = null,
        .east = null,
        .south = 1,
        .west = null,
        .up = null,
        .down = null,
    },
};

//fn getAction(room: *Room) ?*Room {
//    var action: []const u8 = undefined;
//    while (true) : (action = std.io.readLine(allocator).strip()) {
//        switch (action) {
//
//            else => std.debug.print("Invalid action. Try again.\n")
//        }
//    }
//    return null;
//}
//
//

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

    // const player = Player{ .name = "Hero", .description = "You are a mystery." };
    // _ = player;

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
    try stdout.print("{s}\n", .{rooms[p_state.room].description});

    //

    while (true) {
        // If you've reached the end, you won
        if (std.mem.eql(u8, rooms[p_state.room].name, "the_end")) {
            try stdout.print("{s}\n", .{rooms[p_state.room].description});
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

//test "simple test" {
//    var list = std.ArrayList(i32).init(std.testing.allocator);
//    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//    try list.append(42);
//    try std.testing.expectEqual(@as(i32, 42), list.pop());
//}
