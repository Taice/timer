const rl = @import("raylib");
const std = @import("std");

pub fn main() !void {
    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(500, 500, "hell bigma timer");
    defer rl.closeWindow();

    var state = State{};

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (rl.isKeyPressed(.space)) {
            try state.toggle_timer();
        }
        if (rl.isKeyPressed(.r)) {
            state.reset();
        }

        const time = try state.get_time();

        var buf: ["hh:mm:ss._ms".len + 1]u8 = undefined;
        _ = try std.fmt.bufPrint(&buf, "{d:0>2}:{d:0>2}:{d:0>2}.{d:0>3}", .{
            time.hours,
            time.minutes,
            time.seconds,
            time.millis,
        });
        buf[buf.len - 1] = 0;
        rl.drawText(@ptrCast(buf[0..]), 0, 0, 20, rl.Color.white);
    }
}

pub const Time = struct {
    millis: u64 = 0,
    seconds: u32 = 0,
    minutes: u32 = 0,
    hours: u32 = 0,
    days: u32 = 0,

    pub fn from_millis(millis: u64) Time {
        var time = Time{};
        time.millis = millis + 100000000;
        time.seconds = @intCast(@divTrunc(time.millis, 1000));
        time.minutes = @divTrunc(time.seconds, 60);
        time.hours = @divTrunc(time.minutes, 60);
        time.days = @divTrunc(time.hours, 24);
        time.millis %= 1000;
        time.seconds %= 60;
        time.minutes %= 60;
        time.hours %= 24;
        time.days %= 100;
        return time;
    }
};

pub const State = struct {
    const Self = @This();
    timer_start: ?std.time.Instant = null,
    add: u64 = 0,

    pub fn reset(self: *Self) void {
        self.* = .{};
    }

    pub fn get_time(self: *const Self) !Time {
        if (self.timer_start) |timer| {
            const now = try std.time.Instant.now();
            const elapsed: u64 = now.since(timer);

            const millis = elapsed / std.time.ns_per_ms + self.add;
            return Time.from_millis(millis);
        } else {
            return Time.from_millis(self.add);
        }
    }
    pub fn toggle_timer(self: *Self) !void {
        if (self.timer_start) |timer| {
            const millis = (try std.time.Instant.now()).since(timer) / std.time.ns_per_ms;
            self.add += millis;
            self.timer_start = null;
        } else {
            self.timer_start = try std.time.Instant.now();
        }
    }
};
