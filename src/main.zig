const std = @import("std");
const tkn = @import("tokenizer/main.zig");
const qrytkn = @import("query/tokenizer.zig");
const prser = @import("parser/main.zig");
const print = std.debug.print;
const jason = @import("core/main.zig");

pub fn main() !void {
    const path = "./examples/3.json";
    const allocator = std.heap.page_allocator;

    // Dynamically allocate memory and read the file
    const input = try std.fs.cwd().readFileAlloc(allocator, path, 1024);
    defer allocator.free(input); // Free memory after usage

    //INFO: TOKENIZER ------------

    const Tokenizer = tkn.Tokenizer;
    var tokenizer = Tokenizer{
        .input = input,
        .position = 0,
    };
    const tokens = try tokenizer.tokenize();
    defer {
        for (tokens) |token| {
            std.heap.page_allocator.free(token.value);
        }
        std.heap.page_allocator.free(tokens);
    }

    //INFO: PARSER ------------

    var parser = prser.Parser.init(tokens, allocator);
    defer parser.deinit();
    const parsed_value = try parser.parse();
    //prser.printJsonValue(parsed_value);

    //INFO: QUERY ------------

    var queryTokenizer = qrytkn.QueryTokenizer.init("$.store.book[3].title", allocator);
    defer queryTokenizer.deinit();

    try queryTokenizer.scanQueryTokens();

    const value = try queryTokenizer.executeQuery(parsed_value);
    prser.printJsonValue(value);
}
