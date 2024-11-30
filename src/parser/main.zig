const Token = @import("../tokenizer/main.zig").Token;
const TokenType = @import("../tokenizer/main.zig").TokenType;
const std = @import("std");

//INFO: from the json rfc https://www.ietf.org/rfc/rfc4627.txt
//JSON can represent four primitive types (strings, numbers, booleans,
//and null) and two structured types (objects and arrays).

pub const JsonValue = union(enum) {
    Object: std.StringHashMap(JsonValue),
    Array: []JsonValue,
    String: []const u8,
    Number: f64,
    Boolean: bool,
    Null: void,
};

const ParserError = error{
    UnexpectedTokensAfterParsing,
    UnexpectedEndOfTokens,
    UnexpectedToken,
    ExpectedObjectStart,
    ExpectedStringKey,
    ExpectedColon,
    OutOfMemory,
    ExpectedString,
    ExpectedNumber,
    InvalidNumberFormat,
    ExpectedBoolean,
    InvalidBooleanValue,
    ExpectedNull,
};

pub const Parser = struct {
    tokens: []Token,
    current: usize = 0,
    arena: std.heap.ArenaAllocator,
    allocator: std.mem.Allocator,

    pub fn init(tokens: []Token, parent_allocator: std.mem.Allocator) Parser {
        var arena = std.heap.ArenaAllocator.init(parent_allocator);
        return Parser{
            .tokens = tokens,
            .current = 0,
            .arena = arena,
            .allocator = arena.allocator(),
        };
    }

    pub fn parse(self: *Parser) !JsonValue {

        // Start by parsing the first value
        const value = try self.parseValue();

        // Debug print remaining tokens
        std.debug.print("Remaining tokens: {d}\n", .{self.tokens.len - self.current});
        std.debug.print("Parsed tokens: {d}\n", .{self.current});

        // Ensure no tokens are left after parsing
        if (self.current < self.tokens.len) {
            return ParserError.UnexpectedTokensAfterParsing;
        }

        return value;
    }

    pub fn parseValue(self: *Parser) ParserError!JsonValue {
        if (self.current >= self.tokens.len) {
            return ParserError.UnexpectedEndOfTokens;
        }
        const current_token = self.tokens[self.current];
        return switch (current_token.type) {
            .LEFT_BRACE => self.parseObject(),
            .LEFT_BRACKET => self.parseArray(),
            .STRING => self.parseString(),
            .NUMBER => self.parseNumber(),
            .BOOLEAN => self.parseBoolean(),
            .NULL => self.parseNull(),
            else => ParserError.UnexpectedToken,
        };
    }

    fn parseObject(self: *Parser) !JsonValue {
        const current_token = self.tokens[self.current];

        if (current_token.type != TokenType.LEFT_BRACE) {
            return ParserError.ExpectedObjectStart;
        }

        // Move past the left brace
        self.current += 1;

        var map = std.StringHashMap(JsonValue).init(self.allocator);

        // No defer here; memory is managed by the arena
        //defer map.deinit();

        while (self.current < self.tokens.len and self.tokens[self.current].type != .RIGHT_BRACE) {
            if (self.tokens[self.current].type != .STRING) {
                return ParserError.ExpectedStringKey;
            }

            // Store the key (need to duplicate the string)
            const key = try self.allocator.dupe(u8, self.tokens[self.current].value);
            self.current += 1;

            // Expect a colon
            if (self.tokens[self.current].type != .COLON) {
                self.allocator.free(key);
                return ParserError.ExpectedColon;
            }
            self.current += 1;

            // Recursively parse the value
            const value = try self.parseValue();

            // Insert into the hash map
            try map.put(key, value);

            // Optional comma handling
            if (self.current < self.tokens.len and self.tokens[self.current].type == .COMMA) {
                self.current += 1;
            }
        }

        // Verify end of object
        if (self.current >= self.tokens.len or self.tokens[self.current].type != .RIGHT_BRACE) {
            return ParserError.UnexpectedToken;
        }

        // Move past the right brace
        self.current += 1;

        // Return as a JsonValue Object
        return JsonValue{ .Object = map };
    }

    fn parseArray(self: *Parser) !JsonValue {
        //expect left bracket "["
        const current_token = self.tokens[self.current];
        if (current_token.type != .LEFT_BRACKET) {
            return error.ExpectedObjectStart;
        }

        //move past the left brace
        self.current += 1;

        var array = std.ArrayList(JsonValue).init(self.allocator);
        errdefer array.deinit();

        while (self.current < self.tokens.len and self.tokens[self.current].type != .RIGHT_BRACKET) {
            // Parse the value (which could be anything)
            const value = try self.parseValue();

            // Append to the array
            try array.append(value);

            // Handle optional comma between elements
            if (self.current < self.tokens.len and self.tokens[self.current].type == .COMMA) {
                self.current += 1;
            }
        }

        if (self.current >= self.tokens.len or self.tokens[self.current].type != .RIGHT_BRACKET) {
            return ParserError.UnexpectedToken;
        }

        self.current += 1;
        return JsonValue{ .Array = try array.toOwnedSlice() };
    }

    fn parseString(self: *Parser) !JsonValue {
        // Check if current token is actually a string
        if (self.tokens[self.current].type != .STRING) {
            return error.ExpectedString;
        }

        // Get the string value
        const string_value = self.tokens[self.current].value;

        // Move past the string token
        self.current += 1;

        // Return as JsonValue.String
        return JsonValue{ .String = string_value };
    }

    fn parseNumber(self: *Parser) !JsonValue {
        // Check if current token is actually a string
        if (self.tokens[self.current].type != .NUMBER) {
            return error.ExpectedNumber;
        }

        // Get the string value
        const value = self.tokens[self.current].value;

        // Parse the number
        const number_value = std.fmt.parseFloat(f64, value) catch |err| {
            std.debug.print("Number parsing error: {}\n", .{err});
            return error.InvalidNumberFormat;
        };

        // Move past the string token
        self.current += 1;

        // Return as JsonValue.String
        return JsonValue{ .Number = number_value };
    }

    fn parseBoolean(self: *Parser) !JsonValue {
        if (self.tokens[self.current].type != .BOOLEAN) {
            return error.ExpectedBoolean;
        }

        // Get the string value
        const value = self.tokens[self.current].value;

        // Determine boolean value
        const bool_value = if (std.mem.eql(u8, value, "true"))
            true
        else if (std.mem.eql(u8, value, "false"))
            false
        else
            return error.InvalidBooleanValue;

        // Move past the boolean token
        self.current += 1;

        // Return as JsonValue.Boolean
        return JsonValue{ .Boolean = bool_value };
    }

    fn parseNull(self: *Parser) !JsonValue {
        if (self.tokens[self.current].type != .NULL) {
            return error.ExpectedNull;
        }

        // Move past the null token
        self.current += 1;

        return JsonValue{ .Null = {} };
    }

    // When done, call arena.deinit() to free everything at once
    pub fn deinit(self: *Parser) void {
        self.arena.deinit();
    }
};

pub fn printJsonValue(value: JsonValue) void {
    switch (value) {
        .Object => |map| {
            std.debug.print("{{\n", .{});
            var it = map.iterator();
            while (it.next()) |entry| {
                // Safely print the key as a string
                std.debug.print("  \"{s}\": ", .{entry.key_ptr.*});

                // Safely print the value
                printJsonValue(entry.value_ptr.*);
            }
            std.debug.print("}}\n", .{});
        },
        .Array => |arr| {
            std.debug.print("[\n", .{});
            for (arr) |item| {
                printJsonValue(item);
            }
            std.debug.print("]\n", .{});
        },

        .String => |str| std.debug.print("\"{s}\"\n", .{str}),
        .Number => |num| std.debug.print("{d}\n", .{num}),
        .Boolean => |b| std.debug.print("{}\n", .{b}),
        .Null => std.debug.print("null\n", .{}),
    }
}
