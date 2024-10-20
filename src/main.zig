const std = @import("std");
const net = std.net;
const http = std.http;

const RequestError = error{
    UnsupportedVersion,
    MalformattedRequest,
};

const host = "127.0.0.1";
const port = 8080;

const Request = struct {
    // version: http.Version,
    method: http.Method,
    path: []const u8,
    headers: std.StringHashMap([]const u8),

    fn init(allocator: std.mem.Allocator, request: []const u8) !Request {
        var it = std.mem.split(u8, request, " ");
        const method = it.next() orelse {
            return RequestError.MalformattedRequest;
        };
        const path = it.next() orelse {
            return RequestError.MalformattedRequest;
        };
        it.delimiter = "\r\n";
        const version = it.next().?;
        if (!std.mem.eql(u8, version, "HTTP/1.1")) {
            return RequestError.UnsupportedVersion;
        }
        // parse out the headers
        var hp = http.HeaderIterator.init(it.rest());
        var headers = std.StringHashMap([]const u8).init(allocator);
        while (hp.next()) |header| {
            try headers.put(header.name, header.value);
        }
        return .{
            .method = std.meta.intToEnum(http.Method, http.Method.parse(method)) catch {
                return RequestError.MalformattedRequest;
            },
            .path = path,
            .headers = headers,
        };
    }

    fn deinit(self: *Request) void {
        self.headers.deinit();
    }
};

pub fn main() !void {
    const addr = try net.Address.resolveIp(host, port);
    var server = try addr.listen(.{});
    defer server.deinit();

    std.log.info("Server listening on {s}:{d}", .{ host, port });

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    while (true) {
        const conn = try server.accept();
        const writer = conn.stream.writer();
        defer conn.stream.close();
        var buf: [4096]u8 = undefined;
        // read in request from the buffer
        _ = try conn.stream.read(&buf);
        var request = try Request.init(allocator, &buf);
        std.log.info("The 'Accept' header: '{s}'", .{request.headers.get("Accept").?});
        defer request.deinit();
        std.log.info("{s} - {s}", .{ @tagName(request.method), request.path });

        const response = "HTTP/1.1 200 OK\r\n\r\n";
        _ = try writer.writeAll(response);

        std.log.info("RESPONSE: {s}", .{response});
    }
}
