const std = @import("std");
const tkn = @import("tokenizer/main.zig");

pub fn main() !void {
    const Tokenizer = tkn.Tokenizer;

    const input = "{:{}}";

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
    for (tokens) |token| {
        std.debug.print("Token Type: {}, Value: {s}\n", .{ token.type, token.value });
    }
}
