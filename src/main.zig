const std = @import("std");
const print = std.debug.print;
const Jason = @import("core/main.zig").Jason;

pub fn main() !void {
    const path = "./examples/4.json";
    const allocator = std.heap.page_allocator;

    const input = try std.fs.cwd().readFileAlloc(allocator, path, 1024);
    defer allocator.free(input); // Free memory after usage

    var jason = Jason.init(allocator, input);

    const queried = try jason.query("$[1]");
    //const queried = try jason.query("$.store.book[3].title");

    jason.printValue(queried);
}
