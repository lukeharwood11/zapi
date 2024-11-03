const std = @import("std");
const App = @import("./app.zig").App;
const Request = @import("./request.zig").Request;
const Response = @import("./response.zig").Response;
const Method = @import("./http.zig").Method;
const openapi = @import("./openapi.zig");

const HandlerFn = *const fn (*Request, *Response) void;

const RouteHandlerMetadata = struct {
    name: []const u8,
    schema: ?openapi.Schema = null,
    tags: ?[][]const u8 = null,
    responseType: ?[]const u8 = null,
};

const RouteHandler = struct {
    func: HandlerFn,
    metadata: RouteHandlerMetadata,
    path: []const u8,
    method: Method,
};

const RouteHandlers = std.ArrayList(RouteHandler);

pub const Router = struct {
    path: []const u8 = "",
    handlers: RouteHandlers,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Router {
        return .{
            .handlers = RouteHandlers.init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Router) void {
        for (self.handlers.items) |handler| {
            self.allocator.free(handler.metadata.name);
        }
        self.handlers.deinit();
    }

    pub fn handle(self: *Router, request: *Request, response: *Response) !void {
        // TODO: make this more efficient
        for (self.handlers.items) |handler| {
            if (std.mem.eql(u8, handler.path, request.path) and handler.method == request.method) {
                handler.func(request, response);
                break;
            }
        } else {
            // 404
        }
    }

    /// Add a whole router to be handled by this router as a child router.
    pub fn mountRouter(self: *Router) void {
        _ = self;
    }

    /// Add a single route to be handled by the router
    pub fn mount(self: *Router, comptime method: Method, comptime path: []const u8, comptime Handler: type) !void {
        comptime var func_count = 0;
        comptime var func: HandlerFn = undefined;
        var metadata: RouteHandlerMetadata = .{
            .name = undefined,
            .tags = null, // Fix this for null
        };
        inline for (@typeInfo(Handler).Struct.decls) |decl| {
            if (std.meta.hasMethod(Handler, decl.name)) {
                // handle methods
                func_count += 1;
                func = @field(Handler, decl.name);
                metadata.name = decl.name;
            } else if (std.mem.eql(u8, decl.name, "Body")) {
                // metadata.bodyType = @field(Handler, decl.name);
                const T = @field(Handler, "Body");
                metadata.schema = openapi.Schema.parse(T);
            } else if (std.mem.eql(u8, decl.name, "Tags")) {
                // metadata.tags = @field(Handler, decl.name);
            }
        }

        if (func_count > 1) {
            @compileError("Found more than one pub method inside handler.");
        } else if (func_count == 0) {
            @compileError("Couldn't find a request handler method (note that the handler method must have the `pub` specifier).");
        }

        // format the name to be the summary
        var buf = std.ArrayList(u8).init(self.allocator);
        for (0..metadata.name.len) |i| {
            if (i == 0) {
                try buf.append(std.ascii.toUpper(metadata.name[i]));
            } else if (std.ascii.isLower(metadata.name[i - 1]) and std.ascii.isUpper(metadata.name[i])) {
                try buf.appendSlice(&.{ ' ', metadata.name[i] });
            } else {
                try buf.append(metadata.name[i]);
            }
        }
        metadata.name = try buf.toOwnedSlice();

        // at this point, func is initialized
        try self.handlers.append(.{
            .path = path,
            .func = func,
            .metadata = metadata,
            .method = method,
        });
    }
};
