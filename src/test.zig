// Some testing grounds to help understand Ziggy things.
//

const std = @import("std");

const S = struct {
    const Self = @This();
    a: bool = true,

    fn toggle(self: *Self) void {
        self.a = !self.a;
    }
};

var s = S{};

var many = [_]S{
    S{ .a = false },
    S{ .a = true },
};

test "update a field by struct method" {
    var a = &s;
    try std.testing.expect(a.a == true);

    a.toggle();

    try std.testing.expect(a.a == false);
}

test "update by accessing array of structs first" {
    var x = &many[0];
    var y = &many[1];

    // Unepected error
    try std.testing.expect(x.a == false and y.a == true);

    x.toggle();
    y.toggle();

    try std.testing.expect(x.a == true and y.a == false);
}
