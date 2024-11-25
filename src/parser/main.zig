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

pub const Parser = struct {
    tokens: []Token,
    current: usize = 0,

    pub fn parse(self: *Parser) !void {
        self.parse();
    }

    pub fn parseValue(self: *Parser) !void {
        if (self.current >= self.tokens.len) {
            return error.UnexpectedEndOfTokens;
        }
        const current_token = self.tokens[self.current];
        return switch (current_token.type) {
            .LEFT_BRACE => self.parseObject(),
            .LEFT_BRACKET => self.parseArray(),
            .STRING => self.parseString(),
            .NUMBER => self.parseNumber(),
            .BOOLEAN => self.parseBoolean(),
            .NULL => self.parseNull(),
            else => error.UnexpectedToken,
        };
    }

    fn parseObject(self: *Parser) !JsonValue {
        const current_token = self.tokens[self.current];

        if (current_token.type != TokenType.LEFT_BRACE) {
            return error.ExpectedObjectStart;
        }

        // Move past the left brace
        self.current += 1;

        const gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        defer _ = gpa.deinit();

        var map = std.StringHashMap(JsonValue).init(allocator);

        while (current_token.type != .RIGHT_BRACE) {
            if (self.tokens[self.current].type != .STRING) {
                return error.ExpectedStringKey;
            }
            // Store the key (need to duplicate the string)
            const key = try allocator.dupe(u8, self.tokens[self.current].value);
            self.current += 1;

            // Expect a colon
            if (self.tokens[self.current].type != .COLON) {
                return error.ExpectedColon;
            }
            self.current += 1;

            // Recursively parse the value
            const value = try self.parseValue();

            // Insert into the hash map
            try map.put(key, value);

            // Optional comma handling
            if (self.tokens[self.current].type == .COMMA) {
                self.current += 1;
            }
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

        const gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        defer _ = gpa.deinit();

        var array = std.ArrayList(JsonValue).init(allocator);

        while (current_token.type != .RIGHT_BRACKET) {
            // Parse the value (which could be anything)
            const value = try self.parseValue();

            // Append to the array
            try array.append(value);

            // Handle optional comma between elements
            if (self.tokens[self.current].type == .COMMA) {
                self.current += 1;
            }
        }

        self.current += 1;
        return JsonValue{ .Array = array.toOwnedSlice() };
    }

    fn parseString(self: *Parser) !JsonValue {
        // TODO: Implement string parsing
        return error.Unimplemented;
    }

    fn parseNumber(self: *Parser) !JsonValue {
        // TODO: Implement number parsing
        return error.Unimplemented;
    }

    fn parseBoolean(self: *Parser) !JsonValue {
        // TODO: Implement boolean parsing
        return error.Unimplemented;
    }

    fn parseNull(self: *Parser) !JsonValue {
        // TODO: Implement null parsing
        return error.Unimplemented;
    }
};
