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
