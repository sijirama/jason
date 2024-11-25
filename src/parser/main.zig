const Token = @import("../tokenizer/main.zig").Token;
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

    // Placeholder parsing methods (you'll implement these)
    fn parseObject(self: *Parser) !JsonValue {
        // TODO: Implement object parsing
        return error.Unimplemented;
    }

    fn parseArray(self: *Parser) !JsonValue {
        // TODO: Implement array parsing
        return error.Unimplemented;
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
