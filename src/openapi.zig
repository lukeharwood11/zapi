const std = @import("std");
/// https://swagger.io/specification/
pub const default_openapi_version = "3.0.2";
pub const default_title = "Zippy App";

pub const Contact = struct {
    name: []const u8,
    url: []const u8,
    email: []const u8,
};

pub const License = struct {
    name: []const u8,
    url: []const u8,
};

pub const Info = struct {
    title: []const u8 = default_title,
    summary: ?[]const u8 = null,
    description: ?[]const u8 = null,
    termsOfService: ?[]const u8 = null, // link
    contact: ?Contact = null,
    license: ?License = null,
    version: []const u8 = default_openapi_version, // "1.0.1"
};

pub const ExternalDocs = struct {
    description: []const u8,
    name: []const u8,
};

pub const Server = struct {
    url: []const u8,
};

pub const Tag = struct {
    name: []const u8,
    description: []const u8,
    externalDocs: ?ExternalDocs,
};

pub const Content = struct {
    name: []const u8,
    ref: []const u8, // #/components/schemas/Pet
};

pub const RequestBody = struct { description: []const u8, content: []Content, required: bool };

pub const Path = struct {
    path: []const u8,
    method: []const u8,
    summary: []const u8,
    description: []const u8,
    operationId: []const u8,
    requestBody: RequestBody,
};

pub const Properties = struct {
    type: []const u8, // "integer"
    format: []const u8, // "int32"
    example: ?[]const u8 = null, // Implement this later

    pub inline fn parse(field: std.builtin.Type.StructField) Properties {
        switch (@typeInfo(field.type)) {
            .Int => std.debug.print("Found int. {s}\n", .{field.name}),
            .Struct => std.debug.print("Found struct. {s}\n", .{field.name}),
            .Bool => std.debug.print("Found boolean: {s}\n", .{field.name}),
            else => |catchall| std.debug.print("Found unsupported type. {s}\n", .{@tagName(catchall)}),
        }
        return .{
            .type = "integer",
            .format = "int32",
        };
    }
};

pub const Schema = struct {
    name: []const u8,
    properties: []Properties,

    pub fn parse(comptime T: type) Schema {
        if (@typeInfo(T) != .Struct) {
            @compileError("Expected struct, found '" ++ @typeName(T) ++ "'");
        }
        const name = @typeName(T);
        var properties: [std.meta.fields(T).len]Properties = undefined;
        inline for (std.meta.fields(T), 0..) |field, i| {
            properties[i] = Properties.parse(field);
        }
        return .{
            .name = name,
            .properties = &properties,
        };
    }
};

pub const SecuritySchemes = struct {};

pub const Component = struct {
    schemas: []Schema,
    requestBodies: []RequestBody = .{},
    securitySchemes: []SecuritySchemes = .{},
};

pub const Spec = struct { openapi: []const u8 = default_openapi_version, info: Info, externalDocs: ExternalDocs, servers: []Server, tags: []Tag, paths: []Path, components: []Component };
