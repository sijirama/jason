const std = @import("std");

pub const TokenType = enum { LEFT_BRACE, RIGHT_BRACE, LEFT_BRACKET, RIGHT_BRACKET, COLON, STRING, NUMBER, BOOLEAN, NULL, COMMA, EOF };

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
                '[' => {
                    const value = try tokens.allocator.alloc(u8, 1);
                    value[0] = current;
                    try tokens.append(Token{ .type = TokenType.LEFT_BRACKET, .value = value });
                    self.position += 1;
                },

                ']' => {
                    const value = try tokens.allocator.alloc(u8, 1);
                    value[0] = current;
                    try tokens.append(Token{ .type = TokenType.RIGHT_BRACKET, .value = value });
                    self.position += 1;
                },

                ':' => {
                    const value = try tokens.allocator.alloc(u8, 1);
                    value[0] = current;
                    try tokens.append(Token{ .type = TokenType.COLON, .value = value });
                    self.position += 1;
                },

                ',' => {
                    const value = try tokens.allocator.alloc(u8, 1);
                    value[0] = current;
                    try tokens.append(Token{ .type = TokenType.COMMA, .value = value });
                    self.position += 1;
                },

                't' => { //INFO: wtf is even this colution bro, lmao
                    if (self.position + 3 < self.input.len and
                        self.input[self.position + 1] == 'r' and
                        self.input[self.position + 2] == 'u' and
                        self.input[self.position + 3] == 'e')
                    {
                        self.position += 4;
                        const value = try tokens.allocator.dupe(u8, "true");
                        try tokens.append(Token{ .type = TokenType.BOOLEAN, .value = value });
                    }
                },
                'f' => { //INFO: wtf is even this colution bro, lmao
                    if (self.position + 4 < self.input.len and
                        self.input[self.position + 1] == 'a' and
                        self.input[self.position + 2] == 'l' and
                        self.input[self.position + 3] == 's' and
                        self.input[self.position + 4] == 'e')
                    {
                        self.position += 5;
                        const value = try tokens.allocator.dupe(u8, "false");
                        try tokens.append(Token{ .type = TokenType.BOOLEAN, .value = value });
                    }
                },
                'n' => {
                    if (self.position + 3 < self.input.len and
                        self.input[self.position + 1] == 'u' and
                        self.input[self.position + 2] == 'l' and
                        self.input[self.position + 3] == 'l')
                    {
                        self.position += 4;
                        const value = try tokens.allocator.dupe(u8, "null");
                        try tokens.append(Token{ .type = TokenType.NULL, .value = value });
                    }
                },

                '"' => {
                    self.position += 1; // INFO: Move past opening quote
                    const allocator = std.heap.page_allocator;
                    var string = std.ArrayList(u8).init(allocator);
                    defer string.deinit();

                    while (self.position < self.input.len) {
                        const currentChar = self.input[self.position];

                        //INFO: check for opening quote
                        if (currentChar == '"') {
                            break;
                        }

                        // Handle escape sequences
                        if (currentChar == '\\') {
                            self.position += 1;
                            if (self.position >= self.input.len) {
                                // Error: Unexpected end of string
                                return error.InvalidString;
                            }
                            const escapedChar = self.input[self.position];
                            try string.append(escapedChar);
                        } else {
                            try string.append(currentChar);
                        }

                        self.position += 1;
                    }

                    if (self.position >= self.input.len) {
                        return error.UnterminatedString;
                    }

                    try tokens.append(Token{ .type = TokenType.STRING, .value = try string.toOwnedSlice() });

                    self.position += 1; // INFO: Move past closing quote
                },

                ' ', '\t', '\n', '\r' => {
                    // Skip whitespace
                    self.position += 1;
                },

                '-', '0'...'9' => {
                    const allocator = std.heap.page_allocator;
                    var number = std.ArrayList(u8).init(allocator);
                    defer number.deinit();

                    var hasDot = false; // To track if we've encountered a '.'
                    var hasExp = false; // To track if we've encountered 'e' or 'E'

                    while (self.position < self.input.len) {
                        const currentChar = self.input[self.position];

                        if (std.ascii.isDigit(currentChar) or currentChar == '-' or currentChar == '+' or currentChar == '.' or currentChar == 'e' or currentChar == 'E') {

                            //INFO: check for dot (.)
                            if (currentChar == '.') {
                                if (hasDot or hasExp) { //NOTE: we can't have 2 dots in the number wtf is 1.1.1
                                    break;
                                }
                                hasDot = true;
                            }

                            //INFO: Check for 'e/E' (scientific notation)
                            //NOTE: most of this code is from claude, i don't have much knowledge on scientific numbers (embarrassing i know)
                            if (currentChar == 'e' or currentChar == 'E') {
                                if (hasExp) break;
                                if (self.position + 1 >= self.input.len) break; // Ensure there are characters after 'e/E'
                                const nextChar = self.input[self.position + 1];
                                if (!(std.ascii.isDigit(nextChar) or nextChar == '+' or nextChar == '-')) break; // Ensure valid exponent format
                                hasExp = true;
                            }

                            try number.append(currentChar);
                            self.position += 1;
                        } else {
                            break;
                        }
                    }

                    if (number.items.len == 0) {
                        return error.InvalidNumber; // Handle case where no valid number was parsed
                    }

                    try tokens.append(Token{ .type = TokenType.NUMBER, .value = try number.toOwnedSlice() });
                },

                else => {},
            }
        }

        return tokens.toOwnedSlice();
    }
};
