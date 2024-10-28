const std = @import("std");
const http = @import("./http.zig");

pub const ResponseParams = struct {
    status_code: u8,
};

pub const Response = struct {
    stream: std.net.Stream,

    pub fn sendJson(self: *Response, content: anytype) !void {
        try std.json.stringify(content, .{}, self.stream.writer());
    }

    pub fn sendStatus(self: *Response, status: http.Status) !void {
        _ = self;
        _ = status;
    }
};
