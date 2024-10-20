/// https://swagger.io/specification/
const default_openapi_version = "3.0.2";

const Contact = struct {
    name: []const u8,
    url: []const u8,
    email: []const u8,
};

const License = struct {
    name: []const u8,
    url: []const u8,
};

const Info = struct {
    title: []const u8,
    summary: []const u8,
    description: []const u8,
    termsOfService: []const u8, // link
    contact: Contact,
    license: License,
    version: []const u8, // "1.0.1"
};

const ExternalDocs = struct {
    description: []const u8,
    name: []const u8,
};

const Server = struct {
    url: []const u8,
};

const Tag = struct {
    name: []const u8,
    description: []const u8,
    externalDocs: ?ExternalDocs,
};

const Content = struct {
    name: []const u8,
    ref: []const u8, // #/components/schemas/Pet
};

const RequestBody = struct { description: []const u8, content: []Content, required: bool };

const Path = struct {
    path: []const u8,
    method: []const u8,
    summary: []const u8,
    description: []const u8,
    operationId: []const u8,
    requestBody: RequestBody,
};

const Properties = struct {
    type: []const u8, // "integer"
    format: []const u8, // "int32"
    example: ?[]const u8,
};

const Schema = struct { name: []const u8, properties: []Properties };

const SecuritySchemes = struct {};

const Component = struct {
    schemas: []Schema,
    requestBodies: []RequestBody = .{},
    securitySchemes: []SecuritySchemes = .{},
};

const Spec = struct { openapi: []const u8 = default_openapi_version, info: Info, externalDocs: ExternalDocs, servers: []Server, tags: []Tag, paths: []Path, components: []Component };

fn generateSwaggerSpec() void {}
