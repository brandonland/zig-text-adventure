const std = @import("std");
const map = @import("map.zig");

const print = std.debug.print;
const eql = std.mem.eql;

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
        print("You go somewhere.\n", .{});
        _ = other_words;
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

    fn unknown() void {
        print("Unknown command. Try again.\n", .{});
    }
};

// All commands:
const commands = [_][]const u8{
    "help", "h",    "go",   "examine", "x",   "look", "l", "take", "drop", "open", "put",
    "push", "pull", "turn", "feel",    "eat",
};

// These commands can be called with just 1 word
const one_word_commands = [_][]const u8{
    "help", "h", "look", "l", "feel",
};

// These commands are called with 2 or more words.
// Note: some of these can also be one-word commands.
const two_word_commands = [_][]const u8{ "go", "examine", "x", "" };

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

    // Print the current room's description
    try stdout.print("{s}\n", .{map.rooms[p_state.room].description});

    while (true) {
        // If you've reached the end, you won
        if (eql(u8, map.rooms[p_state.room].name, "the_end")) {
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

        var it = std.mem.splitAny(u8, input_line, " ");
        const first_word = it.next();
        const second_word = it.next();

        it.reset();

        var it_len: usize = 0;
        while (it.next() != null) {
            it_len += 1;
        }

        var match = false;

        // TODO: Nested if statements are ugly. This logic needs refactored and restructured.
        // Need to move logic to the command functions.
        //
        // Separate commands that require only 1 word and commands that require more.
        // Some commands fall under both categories (can have multiple or just 1 word)
        if (it_len == 1) {
            for (one_word_commands) |command| {
                if (eql(u8, first_word.?, command)) {
                    match = true;
                    if (eql(u8, first_word.?, "help")) Cmd.help(it.rest());
                    if (eql(u8, first_word.?, "h")) Cmd.help(it.rest());
                    if (eql(u8, first_word.?, "look")) Cmd.look(it.rest());
                    if (eql(u8, first_word.?, "l")) Cmd.look(it.rest());
                }
            }
        } else if (it_len == 2) {
            for (commands) |command| {
                if (eql(u8, first_word.?, command)) {
                    match = true;

                    // TODO: this is hardcoded
                    if (eql(u8, first_word.?, "examine")) {
                        if (it_len != 2) {
                            print("This command requires exactly two words. Try again.\n", .{});
                            print("(e.g: {s} door)\n", .{first_word.?});
                            break;
                        }
                        Cmd.examine(second_word.?);
                    }
                    if (eql(u8, first_word.?, "help")) Cmd.help(it.rest());
                    if (eql(u8, first_word.?, "h")) Cmd.help(it.rest());
                    if (eql(u8, first_word.?, "look")) Cmd.look(it.rest());
                    if (eql(u8, first_word.?, "l")) Cmd.look(it.rest());
                    if (eql(u8, first_word.?, "x")) Cmd.examine(it.rest());
                    if (eql(u8, first_word.?, "take")) Cmd.take(it.rest());
                    if (eql(u8, first_word.?, "drop")) Cmd.drop(it.rest());
                    if (eql(u8, first_word.?, "open")) Cmd.open(it.rest());
                    if (eql(u8, first_word.?, "put")) Cmd.put(it.rest());
                    if (eql(u8, first_word.?, "push")) Cmd.push(it.rest());
                    if (eql(u8, first_word.?, "pull")) Cmd.pull(it.rest());
                    if (eql(u8, first_word.?, "turn")) Cmd.turn(it.rest());
                    if (eql(u8, first_word.?, "feel")) Cmd.feel(it.rest());
                    if (eql(u8, first_word.?, "eat")) Cmd.eat(it.rest());
                    if (eql(u8, first_word.?, "go")) Cmd.go(it.rest());
                    break;
                }
            }
        }

        if (!match) Cmd.unknown(it.rest());
    }
}
