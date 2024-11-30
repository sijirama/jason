const std = @import("std");
const tkn = @import("tokenizer/main.zig");
const prser = @import("parser/main.zig");
const print = std.debug.print;

pub fn main() !void {

    //INFO: read from our examples
    // - for readFile you must pass in a fixed size of buffer, so you must before hand know the size of the file

    const path = "./examples/2.json";
    const allocator = std.heap.page_allocator;

    // Dynamically allocate memory and read the file
    const buffer = try std.fs.cwd().readFileAlloc(allocator, path, 1024);
    defer allocator.free(buffer); // Free memory after usage

    // Print the file content
    std.debug.print("File Content:\n {s} \n\n", .{buffer});

    //INFO: tokenize
    const Tokenizer = tkn.Tokenizer;

    var tokenizer = Tokenizer{
        .input = buffer,
        .position = 0,
    };

    const tokens = try tokenizer.tokenize();
    std.debug.print("Length of tokens: {d} \n\n", .{tokens.len});

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
    const parsed_value = try parser.parse();
    defer parser.deinit();
    prser.printJsonValue(parsed_value);
}
