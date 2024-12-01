const std = @import("std");
const JsonValue = @import("../parser/main.zig").JsonValue;

// Object is a simple constant used throughout executeQuery for checking conditions
// Array is a simple constant used throughout executeQuery for checking conditions
const Object = "object";
const Array = "array";

// The available accessTypes
const ObjectAccess: u8 = 0;
const ArrayAccess: u8 = 1;

// QueryToken represents a single "step" in each query.
// Queries are parsed into a []queryTokens to be used for exploring the JSON.

pub const QueryToken = struct {
    accessType: u8, // ObjectAccess or ArrayAccess
    keyReq: []const u8, // a key like "name"
    indexReq: u32, // an index selection like 0, 1, 2
};

pub const QueryTokenizer = struct {
    input: []const u8,
    position: usize,
    tokens: std.ArrayList(QueryToken),
    allocator: std.mem.Allocator,

    pub fn executeQuery(self: *QueryTokenizer, jsonValue: JsonValue) !JsonValue {
        var currentValue = jsonValue; // Start at the root

        for (self.tokens.items) |token| {
            switch (currentValue) {
                .Object => |map| {
                    if (token.accessType != ObjectAccess) {
                        return error.InvalidAccessType;
                    }
                    currentValue = map.get(token.keyReq) orelse return error.KeyNotFound;
                },
                .Array => |arr| {
                    if (token.accessType != ArrayAccess) {
                        return error.InvalidAccessType;
                    }
                    if (token.indexReq >= arr.len) {
                        return error.IndexOutOfBounds;
                    }
                    currentValue = arr[token.indexReq];
                },
                else => return error.InvalidTraversalType,
            }
        }

        return currentValue;
    }

    pub fn init(input: []const u8, allocator: std.mem.Allocator) QueryTokenizer {
        return QueryTokenizer{
            .input = input,
            .position = 0,
            .tokens = std.ArrayList(QueryToken).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn scanQueryTokens(self: *QueryTokenizer) !void {
        if (self.input[0] != '$') {
            return error.InvalidQuerySyntax;
        }
        self.position = 1; // Skip '$'

        while (self.position < self.input.len) {
            const current = self.input[self.position];
            switch (current) {
                '.' => {
                    // Object key parsing
                    // Step into the key, ex: - If we were at the `.` in `.name` this bumps us to `n`.
                    self.position += 1;
                    var key = std.ArrayList(u8).init(self.allocator);
                    defer key.deinit();

                    // Collect key characters
                    while (self.position < self.input.len and
                        isValidKeyChar(self.input[self.position]))
                    {
                        try key.append(self.input[self.position]);
                        self.position += 1;
                    }

                    // Create object access token
                    const keySlice = try key.toOwnedSlice();
                    try self.tokens.append(QueryToken{
                        .accessType = ObjectAccess,
                        .keyReq = keySlice,
                        .indexReq = 0,
                    });
                },
                '[' => {
                    // Array index or key in bracket notation parsing
                    self.position += 1;

                    if (isNumeric(self.input[self.position])) {
                        // Parse numeric index
                        var indexStr = std.ArrayList(u8).init(self.allocator);
                        defer indexStr.deinit();

                        while (self.position < self.input.len and
                            isNumeric(self.input[self.position]))
                        {
                            try indexStr.append(self.input[self.position]);
                            self.position += 1;
                        }

                        // Convert to index
                        const index = try std.fmt.parseInt(u32, indexStr.items, 10);

                        // Expect closing bracket
                        if (self.input[self.position] != ']') {
                            return error.InvalidQuerySyntax;
                        }
                        self.position += 1;

                        try self.tokens.append(QueryToken{
                            .accessType = ArrayAccess,
                            .keyReq = &[_]u8{},
                            .indexReq = index,
                        });
                    } else if (self.input[self.position] == '\'' or self.input[self.position] == '"') {
                        // String key in bracket notation
                        const quote = self.input[self.position];
                        self.position += 1;

                        var key = std.ArrayList(u8).init(self.allocator);
                        defer key.deinit();

                        while (self.position < self.input.len and
                            self.input[self.position] != quote)
                        {
                            try key.append(self.input[self.position]);
                            self.position += 1;
                        }

                        // Expect closing quote and bracket
                        if (self.position >= self.input.len or
                            self.input[self.position] != quote or
                            self.input[self.position + 1] != ']')
                        {
                            return error.InvalidQuerySyntax;
                        }
                        self.position += 2;

                        const keySlice = try key.toOwnedSlice();
                        try self.tokens.append(QueryToken{
                            .accessType = ObjectAccess,
                            .keyReq = keySlice,
                            .indexReq = 0,
                        });
                    } else {
                        return error.InvalidQuerySyntax;
                    }
                },
                else => return error.InvalidQuerySyntax,
            }
        }
    }

    pub fn deinit(self: *QueryTokenizer) void {
        // Free each key in tokens
        for (self.tokens.items) |token| {
            self.allocator.free(token.keyReq);
        }
        self.tokens.deinit();
    }

    fn isValidKeyChar(char: u8) bool {
        return (char >= 'a' and char <= 'z') or
            (char >= 'A' and char <= 'Z') or
            (char >= '0' and char <= '9') or
            char == '_';
    }

    fn isNumeric(char: u8) bool {
        return char >= '0' and char <= '9';
    }
};
