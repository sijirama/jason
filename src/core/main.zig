const std = @import("std");
const prsr = @import("../parser/main.zig");
const tkn = @import("../tokenizer//main.zig");
const qry = @import("../query//tokenizer.zig");
pub const JsonValue = @import("../parser/main.zig").JsonValue;

pub const Jason = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Jason {
        return Jason{
            .allocator = allocator,
        };
    }
    pub fn parse(self: *Jason, json_string: []const u8) !JsonValue {

        // Tokenize
        var tokenizer = tkn.Tokenizer{
            .input = json_string,
            .position = 0,
        };

        const tokens = try tokenizer.tokenize();
        defer {
            for (tokens) |token| {
                self.allocator.free(token.value);
            }
            self.allocator.free(tokens);
        }

        // Parse
        var parser = prsr.Parser.init(tokens, self.allocator);
        defer parser.deinit();

        return parser.parse();
    }

    pub fn query(self: *Jason, json_value: JsonValue, query_string: []const u8) !JsonValue {
        var queryTokenizer = qry.QueryTokenizer.init(query_string, self.allocator);
        defer queryTokenizer.deinit();

        try queryTokenizer.scanQueryTokens();
        return queryTokenizer.executeQuery(json_value);
    }

    pub fn printValue(self: *Jason, value: JsonValue) void {
        _ = self;
        prsr.printJsonValue(value);
    }
};
