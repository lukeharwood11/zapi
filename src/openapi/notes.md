# API notes


```zig
const zippy = @import("zippy");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocator = gpa.allocator();

var app = ZippyApp.init(allocator);

var v1 = ZippyApp.router("/api/v1");

// v1 routing
v2.mount(route)

// app routing
app.mount(v1)


const GetUsers = struct {

}

v1.mount("/path/:url/route", .GET, struct {
    const RequestBody = struct {
        age: i32
    };

    body: RequestBody,
    response: ResponseType,

    fn handler(req: zippy.Request, res: zippy.Response) {
        const body: Body = req.parse(Body);
        // some business logic
        res.json(.{ .status=200, .body= .{"hello" = "world"} });
    }
});

const RequestBody = struct {};

fn Body(comptime K: type) struct {
    return struct {
        
        fn create() {

        };
    };
};

v1.mount("/my/path/:id", .GET, struct {
    // user defined
    const RequestBody = Body(struct {
        age: i32
    });
    // - - - - - - 
    body: RequestBody,
    fn handler(req: zippy.Request, res: zippy.Response) {}
});

// assume we're looping over all of our routes
inline switch(@fields(route.body)) {
    GetUser.Body => {
        // this is the http request
        
        //loop over fields in GetUser.Body
        newRequest: GetUser.Body = .{...}
        request.body.field
    }
}

v1.mount(GetUsers);

// --

fn zippyHandler(comptime K: type) !void {
    if (K.handler.args.len == ...) {
        @field(MyType, "handler")(request, params);
    } else if ()
}



fn getHandler(route: []const u8) {
    // build this at comptime somehow
    inline switch(route) {
        case GetUser.path => GetUser.handler
        ....
    }
}

// now we're in zippy code
request: HttpRequest = undefined; // we would have this defined probably...
.{.body = body, .params = params}
if(request.body != null && request.params != null) {
    getHandler(path)(request.body, request.params)
} else if (request.body != null) {

}
// handle the other cases (body, no params | params, no body)

// -- - - - -
if (args.len) {
    @field(MyType, "handler")(request, params);
}
```
