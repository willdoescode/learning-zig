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
    const a = [3]u8{ 1, 2, 3 };
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
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    expect(total(slice) == 6);
}

test "slices 2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    expect(@TypeOf(slice) == *const [3]u8);
}

const Direction = enum { north, south, east, west };

const Value = enum(u2) { zero, one, two };

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
    var vec = Vec3{ .x = 0, .y = 4, .z = 7 };
    vec.yo();

    expect(vec.x == 4);
}

const Payload = union { int: i64, float: f64, bool: bool };

test "simple union" {
    var payload = Payload{ .int = 1234 };
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

test "int float things" {
    const a: i32 = 0;
    const b = @intToFloat(f32, a);
    const c = @floatToInt(i32, b);
    expect(c == a);
}

fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;
    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

test "while loop expression" {
    expect(rangeHasNumber(0, 10, 3));
}

test "null" {
    var x: ?usize = null;
    const data = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12 };
    for (data) |v, i| {
        if (v == 10) x = 1;
    }

    expect(x == null);
}

test "orelse" {
    var a: ?f32 = null;
    var b = a orelse 0;
    expect(b == 0);
    expect(@TypeOf(b) == f32);
}

test "orelse unreachable" {
    const a: ?f32 = 5;
    const b = a orelse unreachable;
    const c = a.?;
    expect(b == c);
    expect(@TypeOf(c) == f32);
}

test "opt capture" {
    const a: ?i32 = 5;

    if (a != null) {
        const value = a.?;
    }

    const b: ?i32 = 5;

    if (b) |value| {}
}

var numbers_left: u32 = 4;

fn eventuallyNull() ?u32 {
    if (numbers_left == 0) return null;
    numbers_left -= 1;
    return numbers_left;
}

test "while null" {
    var sum: u32 = 0;
    while (eventuallyNull()) |val| {
        sum += val;
    }

    expect(sum == 6);
}

test "cool types" {
    const a = 5;

    const b: if (a < 10) f32 else i32 = 5;
}

fn Matrix(
    comptime T: type,
    comptime width: comptime_int,
    comptime height: comptime_int,
) type {
    return [height][width]T;
}

test "returning a type" {
    expect(Matrix(f32, 4, 4) == [4][4]f32);
}

fn addSmallInts(comptime T: type, a: T, b: T) T {
    return switch (@typeInfo(T)) {
        .ComptimeInt => a + b,
        .Int => |info| if (info.bits <= 16) a + b else @compileError("ints too large"),
        else => @compileError("only ints accepted"),
    };
}

test "typeinfo switch" {
    const x = addSmallInts(u16, 20, 30);
    expect(@TypeOf(x) == u16);
    expect(x == 50);
}

// Can just construct new bigger int at comptime??!??!?!?!??!?!?
fn GetBiggerInt(comptime T: type) type {
    return @Type(.{
        .Int = .{
            .bits = @typeInfo(T).Int.bits + 1,
            .signedness = @typeInfo(T).Int.signedness,
        },
    });
}

test "@Type" {
    expect(GetBiggerInt(u8) == u9);
    expect(GetBiggerInt(i31) == i32);
}

fn Vec(
    comptime count: comptime_int,
    comptime T: type,
) type {
    return struct {
        data: [count]T,
        const Self = @This();

        fn abs(self: Self) Self {
            var tmp = Self{ .data = undefined };
            for (self.data) |v, i| {
                tmp.data[i] = if (v < 0)
                    -v
                else
                    v;
            }
            return tmp;
        }

        fn init(data: [count]T) Self {
            return Self{ .data = data };
        }
    };
}

const eql = std.mem.eql;

test "generic vector" {
    const x = Vec(3, f32).init([_]f32{ 10, -10, 5 });
    const y = x.abs();
    expect(eql(f32, &y.data, &[_]f32{ 10, 10, 5 }));
}

fn plusOne(x: anytype) @TypeOf(x) {
    return x + 1;
}

test "inferred function parameter" {
    expect(plusOne(@as(u32, 1)) == 2);
}

test "opt if" {
    var maybe: ?usize = 10;
    if (maybe) |n| {
        expect(@TypeOf(n) == usize);
        expect(n == 10);
    } else {
        unreachable;
    }
}

test "error union if" {
    var err_un: error{Err}!u32 = 5;
    if (err_un) |e| {
        expect(@TypeOf(e) == u32);
        expect(e == 5);
    } else |err| {
        unreachable;
    }
}

test "while optional" {
    var i: ?u32 = 10;
    while (i) |num| : (i.? -= 1) {
        expect(@TypeOf(num) == u32);
        if (num == 1) {
            i = null;
            break;
        }
    }
    expect(i == null);
}

var numbers_left2: u32 = undefined;

fn eventuallyErrorSequence() !u32 {
    return if (numbers_left2 == 0) error.ReachedZero else blk: {
        numbers_left2 -= 1;
        break :blk numbers_left2;
    };
}

test "while error union capture" {
    var sum: u32 = 0;
    numbers_left2 = 3;
    while (eventuallyErrorSequence()) |value| {
        sum += value;
    } else |err| {
        expect(err == error.ReachedZero);
    }
}

test "for capture" {
    const x = [_]i8{ 1, 5, 120, -5 };
    for (x) |v| expect(@TypeOf(v) == i8);
}

const Info = union(enum) {
    a: u32,
    b: []const u8,
    c,
    d: u32,
};

test "switch capture" {
    var b = Info{ .a = 10 };
    const x = switch (b) {
        .b => |str| blk: {
            expect(@TypeOf(str) == []const u8);
            break :blk 1;
        },
        .c => 2,

        .a, .d => |num| blk: {
            expect(@TypeOf(num) == u32);
            break :blk num * 2;
        },
    };

    expect(x == 20);
}

fn pointerList(x: *[3]u8) void {
    for (x) |*byte| byte.* += 1;
}

test "for with pointer" {
    var data = [_]u8{ 1, 2, 3 };
    pointerList(&data);
    expect(eql(u8, &data, &[_]u8{ 2, 3, 4 }));
}

// Inline for loops allow things that happen at compile time such as @sizeOf
test "inline for loop" {
    const types = [_]type{ i32, f32, u8, bool };
    var sum: usize = 0;
    inline for (types) |T| sum += @sizeOf(T);
    expect(sum == 10);
}

// Still dont quit understand opaque structs but whatever

// const Window = opaque {
//     fn show(self: *Window) void {
//         show_window(self);
//     }
// };

// extern fn show_window(*Window) callconv(.C) void;

// test "opaque" {
//     var main_window: *Window = undefined;
//     main_window.show();
// }

test "anon structs" {
    const Point = struct { x: i32, y: i32 };
    var pt: Point = .{
        .x = 13,
        .y = 67,
    };

    expect(pt.x == 13);
    expect(pt.y == 67);
}

test "full anon struct" {
    dump(.{
        .int = @as(u32, 1234),
        .float = @as(f64, 12.34),
        .b = true,
        .s = "hi",
    });
}

fn dump(args: anytype) void {
    expect(args.int == 1234);
    expect(args.float == 12.34);
    expect(args.b);
    expect(args.s[0] == 'h');
    expect(args.s[1] == 'i');
}

test "tuple" {
    const values = .{
        @as(u32, 1234),
        @as(f64, 12.34),
        true,
        "hi",
    } ++ .{false} ** 2;

    expect(values[0] == 1234);
    expect(values[4] == false);

    inline for (values) |v, i| {
        if (i != 2) continue;
        expect(v);
    }

    expect(values.len == 6);
    expect(values.@"3"[0] == 'h');
}

test "sentinel termination" {
    const terminated = [3:0]u8{3, 2, 1};
    expect(terminated.len == 3);
    expect(@bitCast([4]u8, terminated)[3] == 0);
}

// [N:0] N being the length of the string allows strings to coerse into different types
test "string literal" {
    expect(@TypeOf("hello") == *const [5:0]u8);
}


// [T:t] t being the child type value and T being the length of the string in this case being null terminated
test "null terminated c_string" {
    const c_string: [*:0]const u8 = "hello";
    var array: [5]u8 = undefined;

    var i: usize = 0;
    while (c_string[i] != 0) : (i += 1) {
        array[i] = c_string[i];
    }
}

test "coercion" {
    var a: [*:0]u8 = undefined;
    const b: [*]u8 = a;

    var c: [5:0]u8 = undefined;
    const d: [5]u8 = c;

    var e: [:10]f32 = undefined;
    const f = e;
}

test "terminated slicing"  {
    var x = [_:0]u8{255} ** 3;
    const y = x[0..3 :0];
}

const meta = std.meta;
const Vector = meta.Vector;

test "vector add" {
    const x: Vector(4, f32) = .{1, -10, 20, -1};
    const y: Vector(4, f32) = .{2, 10, 0, 1};
    const z = x + y;
    expect(meta.eql(z, Vector(4, f32){3, 0, 20, 0}));
}
