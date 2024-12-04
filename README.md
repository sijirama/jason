# stupid simple json parser in zig

if this is the worst zig code you've ever seen please create pointers as issues, this is my frist zig project to know how the language works and i plan on mainstreaming it for a while, so please let me know where you thought the code was outrageous and what you think can be better.

## important reads i think
- https://www.ietf.org/rfc/rfc4627.txt
- https://news.ycombinator.com/item?id=38150833
- https://notes.eatonphil.com/writing-a-simple-json-parser.html

i want to try and implement this

```go
const testJSONObject = `{
    "item1": ["aryitem1", "aryitem2", {"some": {"thing": "coolObj"}}],
    "item2": "simplestringvalue"
}`

c, err := dora.NewFromString(testJSONObject)
if err != nil {
    fmt.Printf("\nError creating client: %v\n", err)
}

result, err := c.GetByPath("$.item1[2].some.thing")
if err != nil {
    fmt.Println(err)
}

```

inspired from here 
- https://medium.com/@bradford_hamilton/building-a-json-parser-and-query-tool-with-go-8790beee239a
- https://goessner.net/articles/JsonPath/

## a week later and yh i did it.

```zig
pub fn main() !void {
    const path = "./examples/3.json";
    const allocator = std.heap.page_allocator;

    const input = try std.fs.cwd().readFileAlloc(allocator, path, 1024);
    defer allocator.free(input); // Free memory after usage

    var jason = Jason.init(allocator, input);

    const queried = try jason.query("$.store.book[3].title");

    jason.printValue(queried);
}
```

the code became even more worse, sorry about that, i'm just learning zig, but good news is i like it and i'm gonna keep using it.


