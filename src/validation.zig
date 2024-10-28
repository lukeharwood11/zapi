const json = @import("std").json;
const Request = @import("./request.zig").Request;

pub fn parse(comptime T: type, request: Request) void {
    _ = T;
    _ = request;
}
