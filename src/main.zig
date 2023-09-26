const std = @import("std");
const map = @import("map.zig");

const print = std.debug.print;
const eql = std.mem.eql;
const containsAtLeast = std.mem.containsAtLeast;
const ascii = std.ascii;

const Player = struct {
    name: []const u8,
    description: []const u8,
};

const PlayerState = struct {
    hp: u32,
    room: *map.Room,
    status_effects: ?[]StatusEffect,
    inventory: ?[]const Item,
    item_wielded: ?Item,
    gear_equipped: ?[]Item,
    ripperdoc_mods: ?[]Item,
    carrying_capacity: f16,
};

const StatusEffect = struct {
    id: []const u8, // identifier for retrieval
    name: []const u8, // printable name
};

const Cmd = struct {
    //pub fn help(input: ?[]const u8) void {
    pub fn help(obj: CmdPayload) void {
        const help_target = obj.input;
        _ = help_target;
        print("\nHelp menu - Coming soon\n\n", .{});
    }

    //pub fn go(input: ?[]const u8, player: PlayerState) void {
    pub fn go(obj: CmdPayload) void {
        const it = &obj.input;
        if (it.*.peek() == null) {
            print("Go where? (n|e|s|w) (north|east|south|west)\n", .{});
        }

        const word1 = it.*.peek().?;

        if (eql(u8, word1, "north")) @This().goNorthUpdater(obj);
        if (eql(u8, word1, "n")) @This().goNorthUpdater(obj);
        if (eql(u8, word1, "east")) @This().goEastUpdater(obj);
        if (eql(u8, word1, "e")) @This().goEastUpdater(obj);
        if (eql(u8, word1, "south")) @This().goSouthUpdater(obj);
        if (eql(u8, word1, "s")) @This().goSouthUpdater(obj);
        if (eql(u8, word1, "west")) @This().goWestUpdater(obj);
        if (eql(u8, word1, "w")) @This().goWestUpdater(obj);
        if (eql(u8, word1, "up")) @This().goUpUpdater(obj);
        if (eql(u8, word1, "u")) @This().goUpUpdater(obj);
        if (eql(u8, word1, "down")) @This().goDownUpdater(obj);
        if (eql(u8, word1, "d")) @This().goDownUpdater(obj);
    }

    // TODO: Make this more DRY. A single go() function should be able to loop over
    // each direction.

    // If "Updater" is in the name of the function, this indicates that player state
    // will change/update. This is required so that we know to pass struct literals
    // that contain the pointer to PlayerState.
    //pub fn goNorth(player: PlayerState) void {
    pub fn goNorthUpdater(obj: CmdPayload) void {
        if (obj.player) |state| {
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
        if (obj.player) |state| {
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
        if (obj.player) |state| {
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
        if (obj.player) |state| {
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
        if (obj.player) |state| {
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
        if (obj.player) |state| {
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
        _ = obj.input;
    }

    //pub fn look(input: ?[]const u8) void {
    pub fn look(obj: CmdPayload) void {
        // TODO: This function depends on the location of the player.
        // Each room should have unique information based on what you see
        // when you "look"
        print("You look around.\n", .{});
        _ = obj.input;
    }

    // From the PlayerState object, fetch the room, and from that, the port.
    // then update the port's locked state.
    // If you say "lock door", this should succeed if there is only 1 door in the room.
    // If there are multiple doors, you will need to specify which door by "east door" or "front door", etc.
    //
    // TODO: There is a bug: when you say "lock door" in the living room, it locks the bedroom door.
    // This is a bug -- there are three doors in this room that can be locked.
    // it looks like it chose the door with the lowest ID number. This is because the loop breaks
    // when it finds the first door.
    pub fn lock(obj: CmdPayload) void {
        //var requires_key: bool = true;
        var doors_count: u4 = 0;
        _ = doors_count;

        var target_door: *map.Port = undefined;
        var input = &obj.input;

        print("Input buffer is: {s}\n", .{input.*.buffer});

        var ports = obj.player.?.*.room.ports;

        // Check for lockable doors in room. If there are none, then bail.
        var room_has_lockable_door = false;
        for (ports) |port_id| {
            var port = &map.ports[port_id];
            if (port.lockable) {
                room_has_lockable_door = true;
                break;
            }
        }
        if (!room_has_lockable_door) print("This room has no lockable doors!", .{});

        if (input.*.buffer.len == 0 and ports.len == 1 and map.ports[0].lockable) {
            //print(
            //    \\ DBG: There is one lockable door in this room. You haven't specified
            //    \\ which door to lock, but I assume you mean the only door here.
            //    \\
            //, .{});

            target_door = &map.ports[0];
        } else if (input.*.buffer.len > 0 and ports.len == 1 and map.ports[0].lockable) {
            //print(
            //    \\ DBG: You provided some info on which lockable door to lock, and
            //    \\ there is a single door in this room.
            //    \\
            //, .{});

            const port_type = @tagName(map.ports[0].port_type);
            // Loop over each word provided
            // (e.g. "lock the damn door" will have 4 items to iterate over.)
            while (input.*.peek() != null) {
                if (containsAtLeast(u8, input.*.peek().?, 1, port_type)) {
                    target_door = &map.ports[0];
                    input.*.reset();
                    break;
                }
                _ = input.*.next();
            }
        } else if (ports.len > 1) {
            const TargetPoints = struct {
                north: u8 = 0,
                east: u8 = 0,
                south: u8 = 0,
                west: u8 = 0,
                up: u8 = 0,
                down: u8 = 0,
            };
            var target_points = TargetPoints{};

            // Loop through the ports of the current room
            for (ports) |port_id| {
                var port: *map.Port = &map.ports[port_id];
                const port_type = @tagName(port.port_type);
                const direction_points = switch (port.direction) {
                    map.Direction.north => &target_points.north,
                    map.Direction.east => &target_points.east,
                    map.Direction.south => &target_points.south,
                    map.Direction.west => &target_points.west,
                    map.Direction.up => &target_points.up,
                    map.Direction.down => &target_points.down,
                };

                // Loop through each word
                while (input.*.peek() != null) {
                    // If this word matches the port *type*, add a point.
                    const word = input.*.peek().?;
                    const direction = @tagName(port.direction);
                    if (containsAtLeast(u8, word, 1, port_type)) {
                        print("Adding a point to the {s} door.\n", .{direction});
                        direction_points.* += 1;
                    }
                    // Add more points when each input word matches part of the port *name*.
                    if (containsAtLeast(u8, port.name, 1, word)) {
                        print("Adding another point to the {s} door because it matches the port name.\n", .{direction});
                        direction_points.* += 1;
                    }
                    _ = input.*.next();
                }
                input.*.reset();
            }

            // Determine which direction has the most "points". It must have more than any other
            // in order to know this is the target door.
            //print("target_points directions: {any}\n", .{@field(target_points, "north")});

            // This is very hardcoded. May need to revisit all of this.
            var best_target: ?[]const u8 = null;
            _ = best_target;
            const port_points = [6]u8{
                target_points.north,
                target_points.east,
                target_points.south,
                target_points.west,
                target_points.up,
                target_points.down,
            };
            //print("\n target_points.down is: {any}\n", .{target_points.down});
            const max = std.sort.max(u8, &port_points, {}, std.sort.asc(u8));
            //print("max is {any}\n", .{max});
            if (max == 0) {
                print("Apparently, max is 0.\n", .{});
                print("Sorry, but I don't know what you're trying to lock.\n", .{});
                print("The names of the doors in the current room are:\n", .{});
                for (ports) |id| {
                    print("{s}\n", .{map.ports[id].name});
                }
                return;
            }
            var max_count: u4 = 0;
            var unique = true;

            //print("\ntarget_points: {any}\n", .{target_points});

            for (port_points, 0..) |p, i| {
                _ = i;
                if (p == max) {
                    max_count += 1;
                    continue;
                }
            }

            //print("max_count is {any}\n\n", .{max_count});

            if (max_count > 1) unique = false;

            if (!unique) {
                print("Sorry, but I don't know what you're trying to lock.\n", .{});
                print("The names of the doors in the current room are:\n\n", .{});
                for (ports) |id| {
                    print("{s}\n", .{map.ports[id].name});
                }
                return;
            }

            // From here, we know which one is the target door now because we have
            // a best candidate based on what the user said using a point system.
            // In other words, only one door has the "max" number of points (max number is unique).

            // Loop through port_points, and if it is equal to max, this is the one.
            var max_elem: usize = 0;
            for (port_points, 0..) |p, i| {
                if (p == max) {
                    max_elem = i;
                    break;
                }
            }

            const target_direction = switch (max_elem) {
                0 => "north",
                1 => "east",
                2 => "south",
                3 => "west",
                4 => "up",
                5 => "down",
                else => unreachable,
            };

            // Get target door by direction
            target_door = for (ports) |id| {
                const port_direction = @tagName(map.ports[id].direction);
                if (eql(u8, port_direction, target_direction)) {
                    break &map.ports[id];
                }
            } else undefined;
        }

        //print("Target door: {any}\n", .{target_door.*});
        if (target_door != undefined) {
            // for debugging purposes
            var locked_state = switch (target_door.locked) {
                true => "locked",
                false => "unlocked",
            };
            print("The <{s}> is now <{s}>.\n", .{ target_door.name, locked_state });

            print("Locking door...\n", .{});
            target_door.lock();

            // for debugging purposes
            locked_state = switch (target_door.locked) {
                true => "locked",
                false => "unlocked",
            };
            print("The <{s}> is now <{s}>.\n", .{ target_door.name, locked_state });
        } else {
            print("Something really horribly weird just happened.\n", .{});
        }
    }

    // This should work for doors, safes, anything that can be locked in the first place.
    // Doors can only be unlocked from the side with the latch if you don't have a key or lockpick.
    // if you *do* have the key or lockpick, you can unlock from either side.
    pub fn unlock(obj: CmdPayload) void {
        _ = obj;
    }

    //pub fn read(input: ?[]const u8) void {
    pub fn read(obj: CmdPayload) void {
        print("You read the thing.\n", .{});
        _ = obj.input;
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
        _ = obj.input;
    }

    pub fn dropUpdater(obj: CmdPayload) void {
        print("You drop it like it's hot\n", .{});
        _ = obj.input;
        _ = obj.player.?;
    }

    pub fn open(obj: CmdPayload) void {
        print("You open it.\n", .{});
        _ = obj.input;
    }

    pub fn putUpdater(obj: CmdPayload) void {
        // TODO: Implement "put it in" vs "put it on"
        // In order to "put" something, you must have the thing in your hands.
        print("You put it somewhere.\n", .{});
        _ = obj.input;
        _ = obj.player.?;
    }

    pub fn push(obj: CmdPayload) void {
        print("You push it.\n", .{});
        _ = obj.input;
    }

    pub fn pull(obj: CmdPayload) void {
        print("You pull it.\n", .{});
        _ = obj.input;
    }

    pub fn turn(obj: CmdPayload) void {
        print("You turn it.\n", .{});
        _ = obj.input;
    }

    pub fn feelUpdater(obj: CmdPayload) void {
        print("You feel it.\n", .{});
        _ = obj.input;
    }

    pub fn eatUpdater(obj: CmdPayload) void {
        print("You eat it.\n", .{});
        _ = obj.input;
    }

    pub fn unknown(input: ?[]const u8) void {
        _ = input;
        print("Invalid command. Try again.\n", .{});
        print("(For help, type help or h)\n", .{});
    }
};

const CmdPayload = struct {
    //input: ?[][]const u8 = null,
    input: *std.mem.TokenIterator(u8, .any),
    player: ?*PlayerState = null,
};

const ItemType = enum {
    basic,
    wieldable,
    wearable,
    consumable,
    currency,
};

pub const Item = struct {
    id: u16, // for retrieval
    name: []const u8, // Printable name
    description: []const u8,
    stackable: bool,
    type: ItemType,
    degradable: bool = false,
    weight: f16, // in lbs
    is_key: bool = false,
};

pub const ItemsList = std.MultiArrayList(Item);

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Initialize Item list
    //var items_gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //const items_allocator = items_gpa.allocator();
    //var items_list = ItemsList{};
    //defer _ = items_gpa.deinit();

    // Append the items
    // TODO: move this to its own file to list out and append every item.
    //try items_list.append(items_allocator, .{
    //    .id = 0,
    //    .name = "simple key",
    //    .description = "It's a key. It must fit a lock somewhere.",
    //    .stackable = false,
    //    .is_key = true,
    //    .type = ItemType.basic,
    //    .weight = 0.1,
    //});
    //try items_list.append(items_allocator, .{
    //    .id = 1,
    //    .name = "lockpick",
    //    .description = "A lockpick. One of your favorite tools.",
    //    .stackable = true,
    //    .degradable = true,
    //    .is_key = true, // Opens various things but degrades over time
    //    .type = ItemType.basic,
    //    .weight = 0.1,
    //});
    //try items_list.append(items_allocator, .{
    //    .id = 2,
    //    .name = "baseball bat",
    //    .description = "A sturdy baseball bat that was handed down to you from your grandfather.",
    //    .stackable = false,
    //    .is_key = true, // Can be used to break windows.
    //    .type = ItemType.wieldable,
    //    .weight = 2.5,
    //});

    // Initialize player state
    var player: PlayerState = PlayerState{
        .hp = 100,
        .room = &map.rooms[0],
        .status_effects = null,
        //.inventory = &[_]Item{
        //    items_list.get(0), //key
        //    items_list.get(2), //baseball bat
        //},
        .inventory = &[_]Item{},
        .item_wielded = null,
        .gear_equipped = null,
        .ripperdoc_mods = null,
        .carrying_capacity = 60.0,
    };

    //print("Printing inventory: \n\n", .{});
    //for (player.inventory.?) |item| {
    //    print("Item: {s}\n\n", .{item.name});
    //}

    // The reason for this is so that we can have shortcut commands,
    // e.g. typing "h" will call the "help" command. Also, it's for cleanliness.
    // There may be a more efficient way of doing this.
    var cmds = std.StringHashMap(*const fn (CmdPayload) void).init(std.heap.page_allocator);
    try cmds.put("help", Cmd.help);
    try cmds.put("h", Cmd.help);
    try cmds.put("examine", Cmd.examine);
    try cmds.put("x", Cmd.examine);
    try cmds.put("look", Cmd.look);
    try cmds.put("l", Cmd.look);
    try cmds.put("lock", Cmd.lock);
    try cmds.put("unlock", Cmd.unlock);
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
    try stdout.print("{s}\n", .{player.room.description});

    while (true) {

        // If you've reached the end, you won
        if (eql(u8, player.room.name, "the_end")) {
            try stdout.print("{s}\n", .{player.room.description});
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

        // turn `rest` into a tokenized array of arrays
        var rest_tokenized = std.mem.tokenizeAny(u8, rest, " ,.!?;");
        //_ = rest_tokenized;
        var rest_array = [_][]const u8{};
        //var i: usize = 0;
        //while (rest_tokenized.peek().? != null) : (i += 1) {
        //    rest_array[i] = rest_tokenized.next();
        //}
        print("The rest array is: {any}\n", .{rest_array});
        //if (rest.len != 0) {
        //    break;
        //}

        // TODO: strip out articles (a, the, this, that) from the input before sending
        // it to the command function.
        var cmd_payload = CmdPayload{
            //.input = &rest_array,
            .input = &rest_tokenized,
        };

        // Find out if the first_word needs to call a function that requires updates PlayerState.
        // If so, add player state to the payload.
        // This doesn't work.
        //if (std.mem.endsWith(u8, cmds.get(first_word.?), "Updater")) {
        //    cmd_payload.player = &player;
        //}

        // TODO: This works, but how do we *only* send this in the payload when it's necessary?
        cmd_payload.player = &player;

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
