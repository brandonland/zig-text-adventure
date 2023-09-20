const std = @import("std");
const map = @import("map.zig");

const print = std.debug.print;
const eql = std.mem.eql;
const ascii = std.ascii;

const Player = struct {
    name: []const u8,
    description: []const u8,
};
const PlayerState = struct {
    hp: u32,
    room: *map.Room,
    status_effects: ?[]StatusEffect,
    inventory: ?[*]Item,
    item_wielded: ?*Item,
    gear_equipped: ?[*]Item,
    ripperdoc_mods: ?[]Item,
};

const StatusEffect = struct {
    id: []const u8, // identifier for retrieval
    name: []const u8, // printable name
};

pub const Item = struct {
    id: []const u8, // for retrieval
    name: []const u8, // Printable name
    description: []const u8,
    stackable: bool,
    type: enum {
        key_item,
        wieldable,
        wearable,
        consumable,
        currency,
    },
};

fn isItem() bool {
    // TODO: fix stub
    return true;
}

const Cmd = struct {
    //pub fn help(input: ?[]const u8) void {
    pub fn help(obj: CmdPayload) void {
        const help_target = obj.input.?;
        print("Help menu\n\n", .{});
        print("Help target is: {s}\n", .{help_target});
    }

    //pub fn go(input: ?[]const u8, p_state: PlayerState) void {
    pub fn go(obj: CmdPayload) void {
        var it = std.mem.splitAny(u8, obj.input.?, " ");
        const w2 = it.next();
        if (w2) |word| {
            if (eql(u8, word, "north")) @This().goNorthUpdater(obj);
            if (eql(u8, word, "n")) @This().goNorthUpdater(obj);
            if (eql(u8, word, "east")) @This().goEastUpdater(obj);
            if (eql(u8, word, "e")) @This().goEastUpdater(obj);
            if (eql(u8, word, "south")) @This().goSouthUpdater(obj);
            if (eql(u8, word, "s")) @This().goSouthUpdater(obj);
            if (eql(u8, word, "west")) @This().goWestUpdater(obj);
            if (eql(u8, word, "w")) @This().goWestUpdater(obj);
            if (eql(u8, word, "up")) @This().goUpUpdater(obj);
            if (eql(u8, word, "u")) @This().goUpUpdater(obj);
            if (eql(u8, word, "down")) @This().goDownUpdater(obj);
            if (eql(u8, word, "d")) @This().goDownUpdater(obj);
        }
        if (w2.?.len == 0) {
            print("Go where? (n|e|s|w) (north|east|south|west)\n", .{});
        }
    }

    // If "Updater" is in the name of the function, this indicates that player state
    // will change/update. This is required so that we know to pass struct literals
    // that contain the pointer to PlayerState.
    //pub fn goNorth(p_state: PlayerState) void {
    pub fn goNorthUpdater(obj: CmdPayload) void {
        if (obj.p_state) |state| {
            if (state.room.north != null) {
                print("You go north.\n", .{});
                state.*.room = &map.rooms[state.room.north.?];
                print("{s}\n", .{state.room.description});
            } else {
                print("There is no exit that way.\n", .{});
            }
        }
    }

    pub fn goEastUpdater(obj: CmdPayload) void {
        if (obj.p_state) |state| {
            if (state.room.east != null) {
                print("You go east.\n", .{});
                state.*.room = &map.rooms[state.room.east.?];
                print("{s}\n", .{state.room.description});
            } else {
                print("There is no exit that way.\n", .{});
            }
        }
    }

    pub fn goSouthUpdater(obj: CmdPayload) void {
        if (obj.p_state) |state| {
            if (state.room.south != null) {
                print("You go south.\n", .{});
                state.*.room = &map.rooms[state.room.south.?];
                print("{s}\n", .{state.room.description});
            } else {
                print("There is no exit that way.\n", .{});
            }
        }
    }

    pub fn goWestUpdater(obj: CmdPayload) void {
        if (obj.p_state) |state| {
            if (state.room.west != null) {
                print("You go west.\n", .{});
                state.*.room = &map.rooms[state.room.west.?];
                print("{s}\n", .{state.room.description});
            } else {
                print("There is no exit that way.\n", .{});
            }
        }
    }

    pub fn goUpUpdater(obj: CmdPayload) void {
        if (obj.p_state) |state| {
            if (state.room.up != null) {
                print("You go up.\n", .{});
                state.*.room = &map.rooms[state.room.up.?];
                print("{s}\n", .{state.room.description});
            } else {
                print("There is no exit that way.\n", .{});
            }
        }
    }

    pub fn goDownUpdater(obj: CmdPayload) void {
        if (obj.p_state) |state| {
            if (state.room.down != null) {
                print("You go down.\n", .{});
                state.*.room = &map.rooms[state.room.down.?];
                print("{s}\n", .{state.room.description});
            } else {
                print("There is no exit that way.\n", .{});
            }
        }
    }

    //pub fn examine(input: ?[]const u8) void {
    pub fn examine(obj: CmdPayload) void {
        print("You examine the object\n", .{});
        _ = obj.input.?;
    }

    //pub fn look(input: ?[]const u8) void {
    pub fn look(obj: CmdPayload) void {
        // TODO: This function depends on the location of the player.
        // Each room should have unique information based on what you see
        // when you "look"
        print("You look around.\n", .{});
        _ = obj.input.?;
    }

    //pub fn read(input: ?[]const u8) void {
    pub fn read(obj: CmdPayload) void {
        print("You read the thing.\n", .{});
        _ = obj.input.?;
    }

    //pub fn take(input: ?[]const u8) void {
    pub fn takeUpdater(obj: CmdPayload) void {
        // TODO: Need logic here to determine if the object can be taken.
        // Is the object actually an item?
        // Does your inventory have enough free slots?

        //if (!item.isItem()) {
        //    print("This object cannot be taken.", .{});
        //}
        print("You take the object\n", .{});
        _ = obj.input.?;
    }

    pub fn dropUpdater(obj: CmdPayload) void {
        print("You drop it like it's hot\n", .{});
        _ = obj.input.?;
        _ = obj.p_state.?;
    }

    pub fn open(obj: CmdPayload) void {
        print("You open it.\n", .{});
        _ = obj.input.?;
    }

    pub fn putUpdater(obj: CmdPayload) void {
        // TODO: Implement "put it in" vs "put it on"
        // In order to "put" something, you must have the thing in your hands.
        print("You put it somewhere.\n", .{});
        _ = obj.input.?;
        _ = obj.p_state.?;
    }

    pub fn push(obj: CmdPayload) void {
        print("You push it.\n", .{});
        _ = obj.input.?;
    }

    pub fn pull(obj: CmdPayload) void {
        print("You pull it.\n", .{});
        _ = obj.input.?;
    }

    pub fn turn(obj: CmdPayload) void {
        print("You turn it.\n", .{});
        _ = obj.input.?;
    }

    pub fn feelUpdater(obj: CmdPayload) void {
        print("You feel it.\n", .{});
        _ = obj.input.?;
    }

    pub fn eatUpdater(obj: CmdPayload) void {
        print("You eat it.\n", .{});
        _ = obj.input.?;
    }

    pub fn unknown(input: ?[]const u8) void {
        _ = input;
        print("Invalid command. Try again.\n", .{});
        print("(For help, type help or h)", .{});
    }
};

const CmdPayload = struct {
    input: ?[]const u8 = null,
    p_state: ?*PlayerState = null,
};

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Initialize player state
    var p_state: PlayerState = PlayerState{
        .hp = 100,
        .room = &map.rooms[0],
        .status_effects = null,
        .inventory = null,
        .item_wielded = null,
        .gear_equipped = null,
        .ripperdoc_mods = null,
    };

    // The reason for this is so that we can have shortcut commands,
    // e.g. typing "h" will call the "help" command. Also, it's for cleanliness.
    var cmds = std.StringHashMap(*const fn (CmdPayload) void).init(std.heap.page_allocator);
    try cmds.put("help", Cmd.help);
    try cmds.put("h", Cmd.help);
    try cmds.put("examine", Cmd.examine);
    try cmds.put("x", Cmd.examine);
    try cmds.put("look", Cmd.look);
    try cmds.put("l", Cmd.look);
    try cmds.put("read", Cmd.read);
    try cmds.put("r", Cmd.read);
    try cmds.put("take", Cmd.takeUpdater);
    try cmds.put("drop", Cmd.dropUpdater);
    try cmds.put("open", Cmd.open);
    try cmds.put("put", Cmd.putUpdater);
    try cmds.put("push", Cmd.push);
    try cmds.put("pull", Cmd.pull);
    try cmds.put("turn", Cmd.turn);
    try cmds.put("feel", Cmd.feelUpdater);
    try cmds.put("eat", Cmd.eatUpdater);
    try cmds.put("go", Cmd.go);
    try cmds.put("north", Cmd.goNorthUpdater);
    try cmds.put("n", Cmd.goNorthUpdater);
    try cmds.put("east", Cmd.goEastUpdater);
    try cmds.put("e", Cmd.goEastUpdater);
    try cmds.put("west", Cmd.goWestUpdater);
    try cmds.put("w", Cmd.goWestUpdater);
    try cmds.put("south", Cmd.goSouthUpdater);
    try cmds.put("s", Cmd.goSouthUpdater);
    try cmds.put("up", Cmd.goUpUpdater);
    try cmds.put("u", Cmd.goUpUpdater);
    try cmds.put("down", Cmd.goDownUpdater);
    try cmds.put("d", Cmd.goDownUpdater);

    defer cmds.deinit();

    // TODO: might need a separate hashmap for functions with different signatures.
    // The reason being: some functions need to update player state, so a *PlayerState
    // type needs to be passed to certain functions, but not for other functions.

    // Print the current room's description
    try stdout.print("{s}\n", .{p_state.room.description});

    while (true) {

        // If you've reached the end, you won
        if (eql(u8, p_state.room.name, "the_end")) {
            try stdout.print("{s}\n", .{p_state.room.description});
            break;
        }

        // Print the prompt
        try stdout.print("> ", .{});
        try bw.flush();

        // Set up reader to read input
        const stdin_reader = std.io.getStdIn().reader();
        var stdin_buffered = std.io.bufferedReader(stdin_reader);
        const stdin_buffered_reader = stdin_buffered.reader();
        var input_line_buf: [4096]u8 = undefined;
        const input_line =
            try stdin_buffered_reader.readUntilDelimiterOrEof(&input_line_buf, '\n') orelse {
            return;
        };

        const allocator = std.heap.page_allocator;
        const input_lower = try ascii.allocLowerString(allocator, input_line);
        defer allocator.free(input_lower);

        var it = std.mem.splitAny(u8, input_lower, " ");
        const first_word = it.next();
        const rest = it.rest();
        it.reset();

        var cmd_payload = CmdPayload{ .input = rest };

        // Find out if the first_word needs to call a function that requires updates PlayerState.
        // If so, add player state to the payload.
        // This doesn't work.
        //if (std.mem.endsWith(u8, cmds.get(first_word.?), "Updater")) {
        //    cmd_payload.p_state = &p_state;
        //}

        // This works, but how do we *only* send this in the payload when it's necessary?
        cmd_payload.p_state = &p_state;

        //const this_entry = cmds.getEntry(first_word.?);
        //print("This entry: {any}\n", .{this_entry});

        if (cmds.getKey(first_word.?) == null) {
            Cmd.unknown(first_word.?);
            continue;
        }

        // Loop through the Cmd struct's method names
        //const MyStruct = @typeInfo(Cmd).Struct;
        //print("MyStruct layout: {any}\n\n", .{MyStruct.layout});

        //for (@typeInfo(Cmd).Struct.decls) |decl| {
        //    print("decl.name is {s}\n", .{decl.name});
        // decl is a string of the name of a method that's being looped over in the struct.
        // I want to be able to call the method/function by for example:
        // Pseudocode:
        // mystruct.callMethodByName(decl, .{arg1, arg2});
        //if (eql(u8, decl.name, "help") {
        //@call(.auto, Cmd.@"help", .{""});
        //@field(Cmd, decl.name)
        //}
        //}

        //var it_len: usize = 0;
        //while (it.next() != null) {
        //    it_len += 1;
        //}

        const cmd = cmds.get(first_word.?);
        cmd.?(cmd_payload);
    }
}
