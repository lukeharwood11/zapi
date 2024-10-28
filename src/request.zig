const std = @import("std");
const http = std.http;
const net = std.net;

const RequestError = error{
    UnsupportedHTTPVersion,
    MalformattedHTTPRequest,
};

pub const Request = struct {
    // version: http.Version,
    method: http.Method,
    path: []const u8,
    headers: std.StringHashMap([]const u8),
    body: ?[]const u8,

    pub fn init(allocator: std.mem.Allocator, request: []const u8) !Request {
        var it = std.mem.split(u8, request, " ");
        const method = it.next() orelse {
            return RequestError.MalformattedHTTPRequest;
        };
        const path = it.next() orelse {
            return RequestError.MalformattedHTTPRequest;
        };
        it.delimiter = "\r\n"; // start of version
        const version = it.next().?;
        if (!std.mem.eql(u8, version, "HTTP/1.1")) {
            return RequestError.UnsupportedHTTPVersion;
        }
        // parse out the headers
        var hp = http.HeaderIterator.init(it.rest());
        var headers = std.StringHashMap([]const u8).init(allocator);
        while (hp.next()) |header| {
            try headers.put(header.name, header.value);
        }
        it.delimiter = "\r\n\r\n"; // body
        _ = it.next(); // move on to the end of the headers
        var body: ?[]const u8 = null;
        if (it.next()) |data| {
            // ensure it isn't empty
            if (data.len > 0) {
                std.debug.print("{s}", .{data});
                body = data;
            }
        }
        return .{
            .method = std.meta.intToEnum(http.Method, http.Method.parse(method)) catch {
                return RequestError.MalformattedHTTPRequest;
            },
            .path = path,
            .headers = headers,
            .body = body,
        };
    }

    pub fn deinit(self: *Request) void {
        self.headers.deinit();
    }
};

test "request" {
    const allocator = std.testing.allocator;
    const test_request = "GET / HTTP/1.1\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8\r\nAccept-Encoding: gzip, deflate, br\r\nAccept-Language: en-US,en\r\nCache-Control: no-cache\r\nConnection: keep-alive\r\nCookie: _xsrf=2|15cc4973|28fad4828d5481671268275137b8d5ef|1726954072; username-localhost-8889=\"2|1:0|10:1726954159|23:username-localhost-8889|44:YjQ5NWUwNTk0YWYzNDdiYjg0YTUyMjBkZWUzN2QzOWI=|55dcaa14c31839827ce4aadfe1441416a20d4daaa5237352b9978066db7245a2\"; username-localhost-8888=\"2|1:0|10:1729383800|23:username-localhost-8888|44:MDk3ZDk0M2RkOWM4NGE5MGJiZjY2MTkzOWI5Yzc2ZmI=|afe15b44875b430af63e67ff9d5430c03a83d149cf7f090889dd9f8e307e43bb\"\r\nHost: localhost:8080\r\nPragma: no-cache\r\nSec-Fetch-Dest: document\r\nSec-Fetch-Mode: navigate\r\nSec-Fetch-Site: none\r\nSec-Fetch-User: ?1\r\nSec-GPC: 1\r\nUpgrade-Insecure-Requests: 1\r\nUser-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36\r\nsec-ch-ua: \"Chromium\";v=\"122\", \"Not(A:Brand\";v=\"24\", \"Brave\";v=\"122\"\r\nsec-ch-ua-mobile: ?0\r\nsec-ch-ua-platform: \"macOS\"\r\n\r\n";
    var request = try Request.init(allocator, test_request);
    defer request.deinit();
    try std.testing.expect(std.mem.eql(u8, "/", request.path));
}
