const std = @import("std");
const map = @import("map.zig");

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
    fn help() void {
        std.debug.print("Help menu\n", .{});
    }

    fn go(direction: []const u8) void {
        std.debug.print("You go {s}\n", .{direction});
    }

    fn examine(object: []const u8) void {
        std.debug.print("You examine {s}\n", .{object});
    }

    fn look() void {
        // This function depends on the location of the player.
        std.debug.print("You look around.\n", .{});
    }

    fn take(item: []const u8) void {
        // Need logic here to determine if the object can be taken.
        // Is the object actually an item?
        //if (!item.isItem()) {
        //    std.debug.print("This object cannot be taken.", .{});
        //}
        std.debug.print("You take {s}\n", .{item});
    }

    fn drop() void {
        std.debug.print("You drop it like it's hot\n", .{});
    }

    fn open() void {
        std.debug.print("You open it.\n", .{});
    }

    fn put(object: anytype) void {
        // TODO: Implement "put it in" vs "put it on"
        _ = object;

        std.debug.print("You put it somewhere.\n", .{});
    }

    fn push() void {
        std.debug.print("You push it.\n", .{});
    }

    fn pull() void {
        std.debug.print("You pull it.\n", .{});
    }

    fn turn() void {
        std.debug.print("You turn it.\n", .{});
    }

    fn feel() void {
        std.debug.print("You feel it.\n", .{});
    }

    fn eat() void {
        std.debug.print("You eat it.\n", .{});
    }

    fn unknown() void {
        std.debug.print("Unknown command. Try again.\n", .{});
    }
};

// Commands:
const commands = [_][]const u8{
    "help", "h",    "go",   "examine", "x",   "look", "l", "take", "drop", "open", "put",
    "push", "pull", "turn", "feel",    "eat",
};

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

    //var commands = std.StringHashMap(*const fn (anytype) void).init(std.heap.page_allocator);
    //try commands.put("help", Cmd.help);
    //try commands.put("h", Cmd.help);
    //try commands.put("examine", Cmd.examine);
    //try commands.put("x", Cmd.examine);
    //try commands.put("look", Cmd.look);
    //try commands.put("l", Cmd.look);
    //try commands.put("take", Cmd.take);
    //try commands.put("drop", Cmd.drop);
    //try commands.put("open", Cmd.open);
    //try commands.put("put", Cmd.put);
    //try commands.put("push", Cmd.push);
    //try commands.put("pull", Cmd.pull);
    //try commands.put("turn", Cmd.turn);
    //try commands.put("feel", Cmd.feel);
    //try commands.put("eat", Cmd.eat);
    //try commands.put("unknown", Cmd.unknown);
    //try commands.put("go", Cmd.go);

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

        // Collect the first word of the command,
        var it = std.mem.split(u8, input_line, " ");
        const first_word = it.next();
        const second_word = it.next();
        var match = false;
        // loop through all `commands`, and if it matches the first word supplied,
        for (commands) |command| {
            // if the first word matches this command being iterated...
            if (std.mem.eql(u8, first_word.?, command)) {
                match = true;
                if (std.mem.eql(u8, first_word.?, "help")) Cmd.help();
                if (std.mem.eql(u8, first_word.?, "h")) Cmd.help();
                // TODO: Error occurs when command function has 2 args, but 2nd command wasn't supplied in prompt.
                if (std.mem.eql(u8, first_word.?, "examine")) Cmd.examine(second_word.?);
                if (std.mem.eql(u8, first_word.?, "x")) Cmd.examine(second_word.?);
                if (std.mem.eql(u8, first_word.?, "look")) Cmd.look();
                if (std.mem.eql(u8, first_word.?, "l")) Cmd.look();
                if (std.mem.eql(u8, first_word.?, "take")) Cmd.take(second_word.?);
                if (std.mem.eql(u8, first_word.?, "drop")) Cmd.drop();
                if (std.mem.eql(u8, first_word.?, "open")) Cmd.open();
                if (std.mem.eql(u8, first_word.?, "put")) Cmd.put(second_word.?);
                if (std.mem.eql(u8, first_word.?, "push")) Cmd.push();
                if (std.mem.eql(u8, first_word.?, "pull")) Cmd.pull();
                if (std.mem.eql(u8, first_word.?, "turn")) Cmd.turn();
                if (std.mem.eql(u8, first_word.?, "feel")) Cmd.feel();
                if (std.mem.eql(u8, first_word.?, "eat")) Cmd.eat();
                if (std.mem.eql(u8, first_word.?, "go")) Cmd.go(second_word.?);
                break;
            }
        }
        if (!match) Cmd.unknown();
    }
}
