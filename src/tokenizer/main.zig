const std = @import("std");

pub const TokenType = enum { LEFT_BRACE, RIGHT_BRACE, COLON, STRING, NUMBER, EOF };

pub const Token = struct {
    type: TokenType,
    value: []const u8, // The actual representation
};

pub const Tokenizer = struct {
    input: []const u8,
    position: u32,

    fn next(self: *Tokenizer) ?Token {
        if (self.position >= self.input.len) {
            return null;
        }
        return self.input[self.position];
    }

    pub fn tokenize(self: *Tokenizer) ![]Token {
        var tokens = std.ArrayList(Token).init(std.heap.page_allocator);

        while (self.position < self.input.len) {
            const current = self.input[self.position];

            switch (current) {
                '{' => {
                    const value = try tokens.allocator.alloc(u8, 1);
                    value[0] = current;
                    try tokens.append(Token{ .type = TokenType.LEFT_BRACE, .value = value });
                    self.position += 1;
                },
                '}' => {
                    const value = try tokens.allocator.alloc(u8, 1);
                    value[0] = current;
                    try tokens.append(Token{ .type = TokenType.RIGHT_BRACE, .value = value });
                    self.position += 1;
                },
                ':' => {
                    const value = try tokens.allocator.alloc(u8, 1);
                    value[0] = current;
                    try tokens.append(Token{ .type = TokenType.COLON, .value = value });
                    self.position += 1;
                },
                '"' => {},
                ' ', '\t', '\n', '\r' => {
                    // Skip whitespace
                    self.position += 1;
                },
                else => {},
            }
        }
        return tokens.toOwnedSlice();
    }
};
