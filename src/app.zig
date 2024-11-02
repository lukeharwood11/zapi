const std = @import("std");
const Request = @import("./request.zig").Request;
const Response = @import("./response.zig").Response;
const Method = @import("./http.zig").Method;
const Router = @import("./route.zig").Router;
const net = std.net;
const http = std.http;
const fs = std.fs;

const default_host: []const u8 = "127.0.0.1";
const default_port: u16 = 8080;

const AppConfig = struct {
    name: []const u8 = "Zippy App",
};

const RunConfig = struct {
    host: []const u8 = default_host,
    port: u16 = default_port,
};

pub const ServerError = error{ PortAlreadyInUse, Unknown };

pub const App = struct {
    allocator: std.mem.Allocator,
    config: AppConfig,
    root_router: Router,

    pub fn init(allocator: std.mem.Allocator, config: AppConfig) App {
        return .{
            .allocator = allocator,
            .config = config,
            .root_router = Router.init(allocator),
        };
    }

    pub fn deinit(self: *App) void {
        self.root_router.deinit();
    }

    /// Add middleware to be used by the application
    /// Middleware is 'used'
    pub fn use(self: *App) void {
        _ = self;
    }

    pub fn run(self: *App, config: RunConfig) !void {
        // config vars
        const host = config.host;
        const port = config.port;

        // resolve the address and create server
        const addr = try net.Address.resolveIp(host, port);
        var server = try addr.listen(.{});
        defer server.deinit();
        // TODO: make logging configurable
        std.log.info("Server listening on {s}:{d}", .{ host, port });

        while (true) {
            // accept a new connection
            const conn = try server.accept();
            // const time_start = std.time.milliTimestamp();
            defer conn.stream.close();
            // assume the buffer won't exceed 4096 (fix this later)
            var buf: [4096]u8 = undefined;
            // read request into the buffer
            const len = try conn.stream.read(&buf);
            // parse request
            var request = try Request.init(self.allocator, buf[0..len]);
            defer request.deinit();
            var response = Response{ .stream = conn.stream, .allocator = self.allocator };
            try self.root_router.handle(&request, &response);
        }
    }

    pub fn mount(self: *App, comptime method: Method, comptime path: []const u8, comptime Handler: type) !void {
        try self.root_router.mount(method, path, Handler);
    }
};
