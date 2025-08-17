const rl = @import("raylib");
const std = @import("std");

pub fn main() !void {
    rl.initWindow(500, 500, "hell bigma timer");
    defer rl.closeWindow();

    var state = State{};

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (rl.isKeyPressed(.space)) {}
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
        time.millis = millis;
        time.seconds = @divTrunc(millis, 1000);
        time.minutes = @divTrunc(time.seconds, 60);
        time.hours = @divTrunc(time.minutes, 60);
        time.days = @divTrunc(time.hours, 24);
        return time;
    }
};

pub const State = struct {
    const Self = @This();
    timer_start: ?std.time.Instant = null,
    add: u64 = 0,

    pub fn get_millis(self: *const Self) !Time {
        if (self.timer_start) |timer| {
            const now = try std.time.Instant.now();
            const elapsed: u64 = now.since(timer);

            const millis = elapsed / std.time.ns_per_ms + self.add;
            return Time.from_millis(millis);
        } else {}
    }
    pub fn pause_timer(self: *const Self) void {
        if (self.timer_start) |timer| {
            const millis = std.time.Instant.now().since(timer) / std.time.ns_per_ms;
            self.add += millis;
            self.timer_start = null;
        } else {}
    }
};
