// This file represents the hard-coded map of the game. This should eventually not be
// represented in actual code; it should eventually be migrated to a database.
// Rooms, ports, item locations, etc. should be defined in this file.

const Item = @import("main.zig").Item;

const Direction = enum { north, east, south, west };

//pub const Door = struct {
//    // TODO: Lockable doors are different depending on which side of the door you are on.
//    // on one side, you don't need the key to lock it. On the other, you do.
//    var autolocks: bool = true; // by default, doors don't auto-lock behind you.
//    var lockable: bool = true;
//
//    is_lockable: bool = true,
//};
//
//pub const Opening = struct {
//    // declaration are here so that they can be changed programmatically if needed.
//    var autolocks: bool = false;
//    var lockable: bool = false;
//};
//
//pub const Ledge = struct {
//    var autolocks: bool = false; // by default, requires an item to "get down" from ledge.
//    var lockable: bool = true; //
//
//    is_one_way_only: bool, // Some ledges can be jumped down but not climbed up.
//};
//
//pub const Tunnel = struct {
//    const autolock: bool = false;
//    var exists: bool = true; // possible not to exist until you dig with a shovel.
//    var requires_key: bool = false;
//
//    //fn init(self: *Self, exists: bool) Self {
//    //
//    //
//    //}
//};
//
//pub const Bridge = struct {
//    var stays_unlocked: bool = true; // by default, doors don't auto-lock behind you.
//};

const PortType = enum {
    door,
    ledge,
    bridge,
    tunnel,
    opening,
};

const Port = struct {
    const Self = @This();
    var locked: bool = false;

    port_id: u8,
    port_sibling_id: u8,
    direction: Direction,
    port_type: PortType,
    description: []const u8,
    //connected_rooms: [2]usize,
    from_room_id: u8,
    to_room_id: u8,
    key: ?Item = null,

    // Some ports will stay open once they were opened, e.g. shovel to dig.
    // Other ports will always require an item to be used on it, e.g. parachute.
    // Or perhaps some doors will auto-lock when they close behind you.
    //fn stays_unlocked(self: Self) bool {
    //    return self.port_type.stays_unlocked;
    //}

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
    ports: ?[]usize, // Optional because some rooms need a port created (dig hole)

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

// Array of all ports
//pub var ports = [*]Port{
//    Port.init(){
//        .id = 0,
//        .port_type = PortType.door,
//        .description = .{"There is a flimsy-looking door."} ** 2,
//        .direction = .{ Direction.south, Direction.north }, // south from room 0, north from 1
//        .connected_rooms = .{ 0, 1 },
//    },
//    .{
//        .id = 1,
//        .port_type = PortType.door,
//        .description = .{ "There is a bathroom door.", "There is a door leading to the living room." },
//        .direction = .{ Direction.east, Direction.west }, // east from 1, west from 2
//        .connected_rooms = .{ 1, 2 },
//    },
//    .{
//        .id = 2,
//        .port_type = PortType.door,
//        .description = .{"There is the front door to your apartment."} ** 2,
//        .direction = .{ Direction.south, Direction.north },
//        .connected_rooms = .{ 1, 3 },
//    },
//    .{
//        .id = 3,
//        .port_type = PortType.door,
//        .description = .{"There is a door to your south."},
//        .directions = .{Direction.south}, // One way only
//        .connected_rooms = .{ 3, 4 }, // still "connected" to both rooms but only traversable in one direction.
//    },
//};

pub var ports: []Port = .{
    Port.init(false){
        .port_id = 0,
        .port_sibling_id = 1,
        .port_type = PortType.door,
        .direction = Direction.south,
        .description = "There is a door to your south.",
        .from_room_id = 0,
        .to_room_id = 1,
    },
    Port.init(false){
        .port_id = 1,
        .port_sibling_id = 0,
        .port_type = PortType.door,
        .direction = Direction.north,
        .description = "There is a door to your north.",
        .from_room_id = 1,
        .to_room_id = 0,
    },
};

// TODO
//fn getPortByRoomIdAndDirection(room_id: u8, d: Direction) *Port {
//    const room = &rooms[room_id].*;
//    return room.getPortByDirection(d);
//    // return &ports[id];
//}

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
        //.ports = .{
        //    .{
        //        .port_id = 0,
        //        .port_sibling = 1,
        //        .port_type = PortType.door,
        //        .direction = Direction.south,
        //        .description = "There is a door to your south.",
        //        .from_room_id = 0,
        //        .to_room_id = 1,
        //    },
        //    //.Port{
        //    //    .port_id = 0,
        //    //    .port_sibling_id = 1,
        //    //    .port_type = PortType.door,
        //    //    .direction = Direction.south,
        //    //    .description = "There is a door to your south.",
        //    //    .from_room_id = 0,
        //    //    .to_room_id = 1,
        //    //},
        //},
        .ports = .{0},
    },
    Room{ // 1
        .name = "apartment_living_room",
        .description = "This is your apartment living room.",
        .items = null,
        .north = 0,
        //.east = 2,
        .east = null,
        //.south = 3,
        .south = null,
        .west = null,
        .up = null,
        .down = null,
        //.ports = .{
        //.Port{
        //    .port_id = 1,
        //    .port_sibling_id = 0,
        //    .port_type = PortType.door,
        //    .direction = Direction.north,
        //    .description = "There is a door to your north.",
        //    .from_room_id = 1,
        //    .to_room_id = 0,
        //},
        //},
        .ports = .{1},
    },
    //Room{ // 2
    //    .name = "bathroom",
    //    .description = "A cute little bathroom.",
    //    .items = null,
    //    //.north = null,
    //    //.east = null,
    //    //.south = null,
    //    //.west = 1, // connected to living room
    //    //.up = null,
    //    //.down = null,
    //    .ports = .{
    //        .{},
    //    },
    //},
    //Room{ // 3
    //    .name = "your_apartment_entrance",
    //    .description = "Just outside of your apartment building.",
    //    .items = null,
    //    //.north = 1,
    //    //.east = null,
    //    //.south = 4,
    //    //.west = null,
    //    //.up = null,
    //    //.down = null,
    //    .ports = .{
    //        .{},
    //    },
    //},
    //Room{ // 4
    //    .name = "the_end",
    //    .description = "You made it!",
    //    .items = null,
    //    //.north = null,
    //    //.east = null,
    //    //.south = 1,
    //    //.west = null,
    //    //.up = null,
    //    //.down = null,
    //    .ports = .{
    //        .{},
    //    },
    //},
};

// Loop through rooms and add ports
//for (rooms) |*room| {
//    room.*.ports =
//

// TODO: Add ports to each room. hardcoded at first?
