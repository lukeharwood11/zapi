const std = @import("std");
const http = @import("./http.zig");

pub const ResponseConfig = struct {
    status: http.Status = http.Status.ok,
};

pub const Response = struct {
    stream: std.net.Stream,
    allocator: std.mem.Allocator,
    response_sent: bool = false, // private state variable

    pub fn send(self: *Response, content: anytype, config: ResponseConfig) void {
        // const response_prefix = "HTTP/1.1 200 OK";
        var response = std.ArrayList(u8).init(self.allocator);
        defer response.deinit();
        const writer = response.writer();
        writer.writeAll("HTTP/1.1 ") catch return;
        var status_buf: [3]u8 = undefined;
        const status_string = std.fmt.bufPrint(&status_buf, "{d}", .{@intFromEnum(config.status)}) catch "500";
        writer.writeAll(status_string) catch return;
        writer.writeAll("\r\n\r\n") catch return;
        std.json.stringify(content, .{}, writer) catch return;
        self.stream.writeAll(response.items) catch return;
        self.response_sent = true;
    }

    pub fn sendStatus(self: *Response, status: http.Status) !void {
        _ = self;
        _ = status;
    }
};
