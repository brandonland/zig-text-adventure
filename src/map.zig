const std = @import("std");
const Item = @import("main.zig").Item;

const print = std.debug.print;

pub const Direction = enum { north, east, south, west, up, down };

pub const Door = struct {
    // TODO: Lockable doors are different depending on which side of the door you are on.
    // on one side, you don't need the key to lock it. On the other, you do.
    var autolocks: bool = false; // by default, doors don't auto-lock behind you.
    var lockable: bool = true;

    door_side: ?DoorSide, // must have a door_side set if door is lockable.
    key: usize = 0, // ID of the item that can open this door.
};

pub const Opening = struct {
    // declaration are here so that they can be changed programmatically if needed.
    var autolocks: bool = false;
    var lockable: bool = false;
};

pub const Ledge = struct {
    var autolocks: bool = false; // by default, requires an item to "get down" from ledge.
    var lockable: bool = true; //

    is_one_way_only: bool, // Some ledges can be jumped down but not climbed up.
};

pub const Tunnel = struct {
    const autolock: bool = false;
    var exists: bool = true; // possible not to exist until you dig with a shovel.
    var requires_key: bool = false;

    //fn init(self: *Self, exists: bool) Self {
    //
    //
    //}
};

pub const Bridge = struct {
    var stays_unlocked: bool = true; // by default, doors don't auto-lock behind you.
};

const PortType = enum {
    door,
    ledge,
    bridge,
    tunnel,
    opening,
};

// In case of being locked, DoorSide indicates which side of the door has the latch
// and which side requires the key. DoorSide should be optional because not every
// door is lockable.
pub const DoorSide = enum {
    inside,
    outside,
};

// Also used for state management.
pub const Port = struct {
    const Self = @This();

    //var locked: bool = false;

    id: u8,
    name: []const u8,
    port_sibling_id: u8,
    direction: Direction,
    port_type: PortType,
    description: []const u8,
    from_room_id: u8,
    to_room_id: u8,
    key: ?Item = null,
    lockable: bool = true,
    locked: bool = false,
    door_side: ?DoorSide = null,

    pub fn lock(self: *Self) void {
        self.locked = true;
        std.debug.print("You locked the <{s}>.\n", .{self.name});
    }
    pub fn unlock(self: *Self) void {
        self.locked = false;
    }
    pub fn examine(self: Self) void {
        if (self.lockable) {
            const locked_state = switch (self.locked) {
                true => "locked",
                false => "unlocked",
            };
            print("{s}\nIt is currently {s}\n", .{ self.description, locked_state });
        }
    }

    // Some ports will stay open once they were opened, e.g. shovel to dig.
    // Other ports will always require an item to be used on it, e.g. parachute.
    // Or perhaps some doors will auto-lock when they close behind you.
    //fn stays_unlocked(self: Self) bool {
    //    return self.port_type.stays_unlocked;
    //}

};

pub const Room = struct {
    id: u8,
    name: []const u8,
    description: []const u8,
    items: ?[*]Item, // optional pointer to an unknown number of Items
    north: ?usize,
    east: ?usize,
    south: ?usize,
    west: ?usize,
    up: ?usize,
    down: ?usize,
    ports: []const usize, // pointer to an unknown number of immutable usizes
    //ports: ?[]u8, // Optional because some rooms need a port created (dig hole)
    //ports: [*]Port,

    //pub fn getPortByDirection(d: Direction) *Port {
    //    _ = d;
    //if (@typeInfo(Direction).Enum.fields)

    // Check to see if corresponding Room.<direction> field has a value
    //inline for (@typeInfo(@This().Struct.fields)) |field| {
    //    if (std.mem.eql(u8, field, @typeInfo(d))) {

    //    }
    //}

    //const result = switch (d) {
    //    //Direction.north =>
    //};

    //if (result != null) {

    //}

    //   return &@This().ports[0];
    //}

};

pub var ports = [_]Port{
    Port{ .id = 0, .name = "bedroom door", .port_sibling_id = 1, .port_type = PortType.door, .direction = Direction.south, .description = "There is a door to your south.", .from_room_id = 0, .to_room_id = 1, .lockable = true, .door_side = DoorSide.inside },
    Port{
        .id = 1,
        .name = "bedroom door",
        .port_sibling_id = 0,
        .port_type = PortType.door,
        .direction = Direction.north,
        .description = "There is a door to your north.",
        .from_room_id = 1,
        .to_room_id = 0,
        .lockable = true,
        .door_side = DoorSide.outside,
    },
    Port{
        .id = 2,
        .name = "bathroom door",
        .port_sibling_id = 3,
        .port_type = PortType.door,
        .direction = Direction.east,
        .description = "The bathroom door is to the east.",
        .from_room_id = 1,
        .to_room_id = 2,
        .lockable = true,
        .door_side = DoorSide.outside,
    },
    Port{
        .id = 3,
        .name = "bathroom door",
        .port_sibling_id = 2,
        .port_type = PortType.door,
        .direction = Direction.west,
        .description = "You can exit the bathroom to the west.",
        .from_room_id = 1,
        .to_room_id = 2,
        .lockable = true,
        .door_side = DoorSide.inside,
    },
    Port{
        .id = 4,
        .name = "front door",
        .port_sibling_id = 5,
        .port_type = PortType.door,
        .direction = Direction.south,
        .description = "The front door is to the south.",
        .from_room_id = 1,
        .to_room_id = 3,
        .lockable = true,
        .door_side = DoorSide.inside,
    },
    Port{
        .id = 5,
        .name = "front door",
        .port_sibling_id = 4,
        .port_type = PortType.door,
        .direction = Direction.north,
        .description = "This is the front door to your apartment.",
        .from_room_id = 3,
        .to_room_id = 1,
        .lockable = true,
        .door_side = DoorSide.outside,
    },
    Port{
        .id = 6,
        .name = "to the end",
        .port_sibling_id = 7,
        .port_type = PortType.opening,
        .direction = Direction.south,
        .description = "Continue this way to finish the game :)",
        .from_room_id = 3,
        .to_room_id = 4,
    },
    Port{
        .id = 7,
        .name = "to the apartment complex",
        .port_sibling_id = 6,
        .port_type = PortType.opening,
        .direction = Direction.north,
        .description = "This way leads to your apartment complex.",
        .from_room_id = 4,
        .to_room_id = 3,
    },
};

pub var rooms = [_]Room{
    Room{ // 0
        .id = 0,
        .name = "start",
        .description = "This is your bedroom. You keep forgetting to clean it...",
        .items = null,
        .north = null,
        .south = 1,
        .east = null,
        .west = null,
        .up = null,
        .down = null,
        .ports = &[_]usize{0},
    },
    Room{ // 1
        .id = 1,
        .name = "living room",
        .description = "This is your apartment living room.",
        .items = null,
        .north = 0,
        .east = 2,
        .south = 3,
        .west = null,
        .up = null,
        .down = null,
        .ports = &[_]usize{ 1, 2, 4 },
    },
    Room{ // 2
        .id = 2,
        .name = "bathroom",
        .description = "A cute little bathroom.",
        .items = null,
        .north = null,
        .east = null,
        .south = null,
        .west = 1, // connected to living room
        .up = null,
        .down = null,
        .ports = &[_]usize{3},
    },
    Room{ // 3
        .id = 3,
        .name = "your_apartment_entrance",
        .description = "Just outside of your apartment building.",
        .items = null,
        .north = 1,
        .east = null,
        .south = 4,
        .west = null,
        .up = null,
        .down = null,
        .ports = &[_]usize{ 5, 6 },
    },
    Room{ // 4
        .id = 4,
        .name = "the_end",
        .description = "You made it!",
        .items = null,
        .north = 3,
        .east = null,
        .south = null,
        .west = null,
        .up = null,
        .down = null,
        .ports = &[_]usize{7},
    },
};

pub fn getPortById(id: usize) *Port {
    return &ports[id];
}
