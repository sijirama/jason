const std = @import("std");
const tkn = @import("tokenizer/main.zig");
const qrytkn = @import("query/tokenizer.zig");
const prser = @import("parser/main.zig");
const print = std.debug.print;

pub fn main() !void {

    //INFO: read from our examples
    // - for readFile you must pass in a fixed size of buffer, so you must before hand know the size of the file

    const path = "./examples/3.json";
    const allocator = std.heap.page_allocator;

    // Dynamically allocate memory and read the file
    const buffer = try std.fs.cwd().readFileAlloc(allocator, path, 1024);
    defer allocator.free(buffer); // Free memory after usage

    // Print the file content
    //std.debug.print("File Content:\n {s} \n\n", .{buffer});

    //INFO: tokenize
    const Tokenizer = tkn.Tokenizer;

    var tokenizer = Tokenizer{
        .input = buffer,
        .position = 0,
    };

    const tokens = try tokenizer.tokenize();
    //std.debug.print("Length of tokens: {d} \n\n", .{tokens.len});

    defer {
        for (tokens) |token| {
            std.heap.page_allocator.free(token.value);
        }
        std.heap.page_allocator.free(tokens);
    }

    // for (tokens) |token| {
    //     std.debug.print("Token Type: {}, Value: {s}\n", .{ token.type, token.value });
    // }

    var parser = prser.Parser.init(tokens, allocator);
    defer parser.deinit();

    const parsed_value = try parser.parse();
    //prser.printJsonValue(parsed_value);

    var queryTokenizer = qrytkn.QueryTokenizer.init("$.store.book[1].price", allocator);
    //var queryTokenizer = qrytkn.QueryTokenizer.init("$.store.book[50].title.program", allocator);
    defer queryTokenizer.deinit();

    try queryTokenizer.scanQueryTokens();

    // Now you can iterate through tokenizer.tokens.items
    // for (queryTokenizer.tokens.items) |token| {
    //     std.debug.print("Access Type: {}, Key: {s}, Index: {}\n", .{ token.accessType, token.keyReq, token.indexReq });
    // }

    const value = try queryTokenizer.executeQuery(parsed_value);
    prser.printJsonValue(value);
}
