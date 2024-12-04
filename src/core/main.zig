const std = @import("std");
const prsr = @import("../parser/main.zig");
const tkn = @import("../tokenizer//main.zig");
const qry = @import("../query//tokenizer.zig");
const JsonValue = @import("../parser/main.zig").JsonValue;

pub const Jason = struct {
    allocator: std.mem.Allocator,
    input: []const u8,

    pub fn init(allocator: std.mem.Allocator, input: []const u8) Jason {
        return Jason{
            .allocator = allocator,
            .input = input,
        };
    }

    pub fn parse(self: *Jason, json_string: []const u8) !JsonValue {
        var tokenizer = tkn.Tokenizer{
            .input = json_string,
            .position = 0,
        };

        const tokens = try tokenizer.tokenize();

        var parser = prsr.Parser.init(tokens, self.allocator);
        defer parser.deinit();
        const parsed_value = try parser.parse();

        //prsr.printJsonValue(parsed_value);

        return parsed_value;
    }

    pub fn query(self: *Jason, query_string: []const u8) !JsonValue {
        const json_value = try self.parse(self.input);

        var queryTokenizer = qry.QueryTokenizer.init(query_string, self.allocator);
        defer queryTokenizer.deinit();

        try queryTokenizer.scanQueryTokens();

        const queried_value = try queryTokenizer.executeQuery(json_value);
        //prsr.printJsonValue(queried_value);
        return queried_value;
    }

    pub fn printValue(self: *Jason, value: JsonValue) void {
        _ = self;
        prsr.printJsonValue(value);
    }
};
