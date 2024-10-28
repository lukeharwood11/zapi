const std = @import("std");
const App = @import("./app.zig").App;
const Request = @import("./request.zig").Request;
const Response = @import("./response.zig").Response;
const Method = @import("./http.zig").Method;

const HandlerFn = *const fn (Request, Response) void;

const RouteHandler = struct {
    func: HandlerFn,
    path: []const u8,
    method: Method,
};

const RouteHandlers = std.ArrayList(RouteHandler);

pub const Router = struct {
    path: []const u8 = "",
    handlers: RouteHandlers,

    pub fn init(allocator: std.mem.Allocator) Router {
        return .{
            .handlers = RouteHandlers.init(allocator),
        };
    }

    pub fn deinit(self: *Router) void {
        self.handlers.deinit();
    }

    pub fn handle(self: *Router, request: *Request, response: *Response) !void {
        _ = self;
        _ = request;
        _ = response;

        // TODO: make this generic
        // const response_prefix = "HTTP/1.1 200 OK";
        // file
        // const file = try fs.cwd().openFile("index.html", .{ .mode = .read_only });
        // const file = try fs.cwd().openFile("./src/openapi.html", .{ .mode = .read_only });

        // defer file.close();
        // file reader
        // TODO: move this into a static file handler
        // var reader = file.reader();
        // const val = try reader.readAllAlloc(self.allocator, 8180);
        // defer self.allocator.free(val);
        // const r = try std.mem.concat(self.allocator, u8, &.{ (response_prefix ++ "\r\n\r\n")[0..], val });
        // defer self.allocator.free(r);
        // _ = try writer.writeAll(r);
        // // end handlers
        // const time_end = std.time.milliTimestamp();
        // std.log.info("{s} {d:.2}ms - {s} - {s}", .{ @tagName(request.method), time_end - time_start, request.path, response_prefix });
    }

    /// Add a whole router to be handled by this router as a child router.
    pub fn mountRouter(self: *Router) void {
        _ = self;
    }

    /// Add a single route to be handled by the router
    pub fn mount(self: *Router, comptime method: Method, comptime path: []const u8, comptime Handler: type) !void {
        comptime var json: []const u8 = "";

        if (@hasField(Handler, "body")) {
            inline for (std.meta.fields(Handler)) |field| {
                json = json ++ field.name ++ ": " ++ @typeName(field.type) ++ ", ";
            }
        } else {
            @compileError("No body!");
        }
        comptime var func_count = 0;
        comptime var func: HandlerFn = undefined;
        inline for (@typeInfo(Handler).Struct.decls) |decl| {
            if (std.meta.hasMethod(Handler, decl.name)) {
                func_count += 1;
                func = @field(Handler, decl.name);
            }
        }

        if (func_count > 1) {
            @compileError("Found more than one pub method inside handler.");
        } else if (func_count == 0) {
            @compileError("Couldn't find a request handler method (note that the handler method must have the `pub` specifier).");
        }
        // at this point, func is initialized
        try self.handlers.append(.{
            .path = path,
            .func = func,
            .method = method,
        });
    }
};
