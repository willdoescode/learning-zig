const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() !void {
    {
        var x: usize = 0;
        while (x < 10) : (x += 1) {
            print("{}\n", .{x});
        }
    }
    print("Hello world", .{});
}

fn failingFuncition() error{Oops}!void {
    return error.Oops;
}

fn failFn() error{Oops}!i32 {
    try failingFuncition();
    return 12;
}

var problems: u32 = 98;

fn failFnCounter() error{Oops}!void {
    errdefer problems += 1;
    try failingFuncition();
}

test "returning an error" {
    failingFuncition() catch |err| {
        expect(err == error.Oops);
        return;
    };
}

test "try" {
    var x = failFn() catch |err| {
        expect(err == error.Oops);
        return;
    };

    expect(x == 12);
}

test "errdefer" {
    failFnCounter() catch |err| {
        expect(err == error.Oops);
        expect(problems == 99);
        return;
    };
}

fn createFile() !void {
    return error.AccessDenied;
}

test "infered error return" {
    const x: error{AccessDenied}!void = createFile();
}

test "switch" {
    var x: i8 = 10;
    x = switch (x) {
        -1...1 => -x,
        10, 100 => @divExact(x, 10),
        else => x,
    };
    expect(x == 1);
}

test "out of bounds" {
    @setRuntimeSafety(false);
    const a = [3]u8{1, 2, 3};
    var index: u8 = 5;
    const b = a[index];
}

fn increment(num: *u8) void {
    num.* += 1;
}

test "pointers" {
    var x: u8 = 1;
    increment(&x);
    expect(x == 2);
}

test "pointer" {
    var x: u16 = 1;
    var y: *u8 = @intToPtr(*u8, x);
}

test "usize" {
    expect(@sizeOf(usize) == @sizeOf(*u8));
    expect(@sizeOf(isize) == @sizeOf(*u8));
}

fn total(values: []const u8) usize {
    var count: usize = 0;
    for (values) |v| count += v;
    return count;
}

test "slices" {
    const array = [_]u8{1, 2, 3, 4, 5};
    const slice = array[0..3];
    expect(total(slice) == 6);
}

test "slices 2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    expect(@TypeOf(slice) == *const [3]u8);
}

const Direction = enum {
    north,
    south,
    east,
    west
};

const Value = enum(u2) { 
   zero,
   one,
   two 
};

test "enum ordinal value" {
    expect(@enumToInt(Value.zero) == 0);
    expect(@enumToInt(Value.one) == 1);
    expect(@enumToInt(Value.two) == 2);
}

const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,
    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};

test "enum method" {
    expect(Suit.spades.isClubs() == Suit.isClubs(.spades));
}

const Mode = enum {
    var count: u32 = 0;
    on,
    off,
};

test "hmm" {
    // This is very weird
    Mode.count += 1;
    expect(Mode.count == 1);
}

const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn yo(self: *Vec3) void {
        self.x = 4;
    }
};

test "struct things" {
    var vec = Vec3 {
        .x = 0,
        .y = 4,
        .z = 7
    };
    vec.yo();

    expect(vec.x == 4);
}

const Payload = union {
    int: i64,
    float: f64,
    bool: bool
};

test "simple union" {
    var payload = Payload { .int = 1234 };
}

const Tag = enum { a, b, c };

const Tagged = union(Tag) { a: u8, b: f32, c: bool };

test "switch on tagged union" {
    var value = Tagged{ .b = 1.5 };
    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* *= 2,
        .c => |*b| b.* = !b.*,
    }
    expect(value.b == 3);
}

test "controled int overflow" {
    var x: u8 = 255;
    x +%= 1;
    expect(x == 0);
}