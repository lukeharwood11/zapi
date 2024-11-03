const std = @import("std");
const App = @import("./app.zig").App;
const Request = @import("./request.zig").Request;
const Response = @import("./response.zig").Response;

pub fn main() !void {
    // create allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // create app
    var app = App.init(allocator, .{ .title = "My Test App" });
    defer app.deinit();

    try app.mount(.POST, "/api/v1/hello", struct {
        /// All fields must be `pub` to be registered by the openapi engine
        pub const Body = struct {
            string: []const u8,
            integer: i32 = 1,
            float: f32 = 2,
        };
        pub fn sayHelloWorld(_: *Request, res: *Response) void {
            res.send(.{
                .hello = "world",
            }, .{});
        }
    });

    try app.run(.{});
    // end
}
