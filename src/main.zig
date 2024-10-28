const std = @import("std");
const App = @import("./app.zig").App;
const Request = @import("./request.zig").Request;
const Response = @import("./response.zig").Response;

// fn processType(comptime K: type) []const u8 {
//     var string: []const u8 = "";
//     inline for (std.meta.fields(K)) |f| {
//         string = string ++ f.name ++ ":" ++ @typeName(f.type);
//         string = string ++ "\n";
//     }
//     return string;
// }

pub fn main() !void {
    // create allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // create app
    var app = App.init(allocator, .{ .name = "My Test App" });
    defer app.deinit();

    try app.mount(.POST, "/api/v1/hello", struct {
        const Body = struct {
            hello: i32,
            world: i32,
        };

        body: Body,
        pub fn handler(request: Request, response: Response) void {
            _ = request;
            _ = response;
        }
    });

    try app.run(.{});
    // end
}
