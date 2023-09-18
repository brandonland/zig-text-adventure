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

fn isItem() bool {
    // TODO: fix stub
    return true;
}

const Cmd = struct {
    fn help(other_words: ?[]const u8) void {
        print("Help menu\n", .{});
        _ = other_words;
    }

    fn go(other_words: ?[]const u8) void {
        var it = std.mem.splitAny(u8, other_words.?, " ");
        const w2 = it.next();
        if (w2) |word| {
            if (eql(u8, word, "north")) @This().goNorth(w2);
            if (eql(u8, word, "n")) @This().goNorth(w2);
            if (eql(u8, word, "east")) @This().goEast(w2);
            if (eql(u8, word, "e")) @This().goEast(w2);
            if (eql(u8, word, "south")) @This().goSouth(w2);
            if (eql(u8, word, "s")) @This().goSouth(w2);
            if (eql(u8, word, "west")) @This().goWest(w2);
            if (eql(u8, word, "w")) @This().goWest(w2);
            if (eql(u8, word, "up")) @This().goUp(w2);
            if (eql(u8, word, "u")) @This().goUp(w2);
            if (eql(u8, word, "down")) @This().goDown(w2);
            if (eql(u8, word, "d")) @This().goDown(w2);
        }

        if (w2.?.len == 0) {
            print("Go where? (n|e|s|w) (north|east|south|west)\n", .{});
        }
    }

    fn goNorth(other_words: ?[]const u8) void {
        _ = other_words;
        print("You go north.\n", .{});
    }

    fn goEast(other_words: ?[]const u8) void {
        _ = other_words;
        print("You go east.\n", .{});
    }

    fn goSouth(other_words: ?[]const u8) void {
        _ = other_words;
        print("You go south.\n", .{});
    }

    fn goWest(other_words: ?[]const u8) void {
        _ = other_words;
        print("You go west.\n", .{});
    }

    fn goUp(other_words: ?[]const u8) void {
        _ = other_words;
        print("You go up.\n", .{});
    }

    fn goDown(other_words: ?[]const u8) void {
        _ = other_words;
        print("You go down.\n", .{});
    }

    fn examine(other_words: ?[]const u8) void {
        print("You examine the object\n", .{});
        _ = other_words;
    }

    fn look(other_words: ?[]const u8) void {
        // This function depends on the location of the player.
        print("You look around.\n", .{});
        _ = other_words;
    }

    fn read(other_words: ?[]const u8) void {
        print("You read the thing.\n", .{});
        _ = other_words;
    }

    fn take(other_words: ?[]const u8) void {
        // Need logic here to determine if the object can be taken.
        // Is the object actually an item?
        //if (!item.isItem()) {
        //    print("This object cannot be taken.", .{});
        //}
        print("You take the object\n", .{});
        _ = other_words;
    }

    fn drop(other_words: ?[]const u8) void {
        print("You drop it like it's hot\n", .{});
        _ = other_words;
    }

    fn open(other_words: ?[]const u8) void {
        print("You open it.\n", .{});
        _ = other_words;
    }

    fn put(other_words: ?[]const u8) void {
        // TODO: Implement "put it in" vs "put it on"
        print("You put it somewhere.\n", .{});
        _ = other_words;
    }

    fn push(other_words: ?[]const u8) void {
        print("You push it.\n", .{});
        _ = other_words;
    }

    fn pull(other_words: ?[]const u8) void {
        print("You pull it.\n", .{});
        _ = other_words;
    }

    fn turn(other_words: ?[]const u8) void {
        print("You turn it.\n", .{});
        _ = other_words;
    }

    fn feel(other_words: ?[]const u8) void {
        print("You feel it.\n", .{});
        _ = other_words;
    }

    fn eat(other_words: ?[]const u8) void {
        print("You eat it.\n", .{});
        _ = other_words;
    }

    fn unknown(other_words: ?[]const u8) void {
        print("Invalid command. Try again.\n", .{});
        _ = other_words;
    }
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
        .wielding = null,
        .gear = null,
    };

    // The reason for this is so that we can have shortcut commands,
    // e.g. typing "h" will call the "help" command.
    var cmds = std.StringHashMap(*const fn (?[]const u8) void).init(std.heap.page_allocator);
    try cmds.put("help", Cmd.help);
    try cmds.put("h", Cmd.help);
    try cmds.put("examine", Cmd.examine);
    try cmds.put("x", Cmd.examine);
    try cmds.put("look", Cmd.look);
    try cmds.put("l", Cmd.look);
    try cmds.put("take", Cmd.take);
    try cmds.put("drop", Cmd.drop);
    try cmds.put("open", Cmd.open);
    try cmds.put("put", Cmd.put);
    try cmds.put("push", Cmd.push);
    try cmds.put("pull", Cmd.pull);
    try cmds.put("turn", Cmd.turn);
    try cmds.put("feel", Cmd.feel);
    try cmds.put("eat", Cmd.eat);
    try cmds.put("go", Cmd.go);
    try cmds.put("north", Cmd.goNorth);
    try cmds.put("n", Cmd.goNorth);
    try cmds.put("east", Cmd.goEast);
    try cmds.put("e", Cmd.goEast);
    try cmds.put("west", Cmd.goWest);
    try cmds.put("w", Cmd.goWest);
    try cmds.put("south", Cmd.goSouth);
    try cmds.put("s", Cmd.goSouth);
    try cmds.put("up", Cmd.goUp);
    try cmds.put("u", Cmd.goUp);
    try cmds.put("down", Cmd.goDown);
    try cmds.put("d", Cmd.goDown);

    defer cmds.deinit();

    // TODO: might need a separate hashmap for functions with different signatures.
    // The reason being: some functions need to update player state, so a *PlayerState
    // type needs to be passed to certain functions, but not for other functions.
    // Possibility: call it state_changing_cmds or something.
    var state_changing_cmds = std.StringHashMap(*const fn (?[]const u8, *PlayerState) void).init(std.heap.page_allocator);
    _ = state_changing_cmds;

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

        if (cmds.getKey(first_word.?) == null) {
            Cmd.unknown(first_word.?);
            continue;
        }

        var it_len: usize = 0;
        while (it.next() != null) {
            it_len += 1;
        }

        // At this point, we know the command/word given is not unknown.
        // We just need to unwrap the optional and call the command function,
        // passing in the rest of the command.
        //
        //if (first_word) |word| {
        //    const cmd = cmds.get(word);
        //    cmd.?(it.rest());
        //}

        // This does the same thing.
        const cmd = cmds.get(first_word.?);
        //print("DBG: rest is: {s}\n", .{rest});
        cmd.?(rest);
    }
}
