// This file represents the hard-coded map of the game. This should eventually not be
// represented in actual code; it should eventually be migrated to a database.
// Rooms, ports, item locations, etc. should be defined in this file.

const Item = @import("main.zig").Item;

const Direction = enum { north, east, south, west };

const Door = struct {
    var stays_unlocked: bool = true; // by default, doors don't auto-lock behind you.
};

const Opening = struct {
    // declaration are here so that they can be changed programmatically if needed.
    var stays_unlocked: bool = true;
};

const Ledge = struct {
    var stays_unlocked: bool = false; // by default, requires an item to "get down" from ledge.

    is_one_way_only: bool, // Some ledges can be jumped down but not climbed up.
};

const Hole = struct {
    var stays_unlocked: bool = true;
    var exists: bool = true;
};

const Bridge = struct {
    var stays_unlocked: bool = true; // by default, doors don't auto-lock behind you.
};

const PortType = union {
    door: Door,
    ledge: Ledge,
    bridge: Bridge,
    hole: Hole,
};

const Port = struct {
    const Self = @This();

    var is_locked: bool = false; // needs to be changeable on the fly

    direction: Direction,
    port_type: PortType,
    description: []const u8,
    requires_key: bool,
    rooms: *[2]Room, // A port always connects two rooms

    // The item required to open the port.
    // It's possible the port can be locked/closed without requiring an item, too,
    // e.g. for doors that require a password instead of an item.
    key: ?Item = null,

    // Some ports will stay open once they were opened, e.g. shovel to dig.
    // Other ports will always require an item to be used on it, e.g. parachute.
    // Or perhaps some doors will auto-lock when they close behind you.
    fn stays_unlocked(self: Self) bool {
        return self.port_type.stays_unlocked;
    }
};

pub const Room = struct {
    name: []const u8,
    description: []const u8,
    items: ?[*]Item,
    north: ?usize,
    east: ?usize,
    south: ?usize,
    west: ?usize,
    up: ?usize,
    down: ?usize,
    ports: ?[*]Port, // Optional because some rooms need a port created (dig hole)
};

// TODO: Room "ports" have two different states: open or closed.
// e.g. a locked door is a closed port until it is unlocked,
// and a blocked pathway is closed until it is somehow cleared.
// It may or may not be immediately obvious to the player that a direction
// has a port or not. e.g., "There is a pile of rubble to the east" doesn't
// necessarily mean you can dig through it. Or "There's a river below the bridge" doesn't
// mean you can jump down safely. You may need certain items to access closed ports,
// such as keys to unlock, shovels to dig, parachutes to land, or even ladders to climb.
pub var rooms = [_]Room{
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
        .ports = .{
            Port{
                .direction = Direction.south,
                .description = "There is a door to your south.",
                .remains_open = true,
            },
        },
    },
    Room{ // 1
        .name = "apartment_living_room",
        .description = "This is your apartment living room.",
        .items = null,
        .north = 0,
        .east = 2,
        .south = 3,
        .west = null,
        .up = null,
        .down = null,
        .ports = .{
            Port{
                .direction = Direction.east,
                .description = "There is a door to your east.",
                .key = null,
                .remains_open = true,
            },
        },
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
