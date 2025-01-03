# Stupid Simple JSON Parser in Zig

A lightweight JSON parser written in Zig that supports JSONPath queries. This is my first Zig project, created to learn the language and explore its capabilities.

## Features

- Parse JSON strings into a queryable structure
- Support for JSONPath syntax queries
- Handle nested objects and arrays
- Zero dependencies beyond Zig standard library

## Usage

```zig
const json_string =
    \\{ "store": { "book": [
    \\  { "title": "Book 1" },
    \\  { "title": "Book 2" },
    \\  { "title": "Book 3" },
    \\  { "title": "Book 4" }
    \\] } }
;
const allocator = std.heap.page_allocator;
var jason = Jason.init(allocator, json_string);
const queried = try jason.query("$.store.book[3].title");
jason.printValue(queried); // Outputs: "Book 4"
```

### JSONPath Query Support

The parser supports JSONPath queries similar to popular implementations. For example:

```zig
// Access nested objects
"$.store.book[2].title"

// Access array elements
"$.item1[0]"

// Access nested object properties
"$.item1[2].some.thing"
```

## Implementation Details

This parser is implemented with simplicity in mind while maintaining functionality. It follows the JSON specification as defined in [RFC 4627](https://www.ietf.org/rfc/rfc4627.txt).

### Inspiration

The project draws inspiration from several sources:
- [Building a JSON Parser and Query Tool with Go](https://medium.com/@bradford_hamilton/building-a-json-parser-and-query-tool-with-go-8790beee239a)
- [JSONPath Specification](https://goessner.net/articles/JsonPath/)
- [Writing a Simple JSON Parser](https://notes.eatonphil.com/writing-a-simple-json-parser.html)

## Project Status

This is an active learning project. The code is functional but may not follow Zig best practices in all areas as I'm still learning the language. Feedback and suggestions for improvement are welcome!

### Known Areas for Improvement

- Error handling could be more robust
- Memory management might need optimization
- Code structure could be more idiomatic Zig
- Test coverage could be expanded

## Contributing

Since this is a learning project, I welcome all forms of feedback:

1. Open issues for code improvements or suggestions
2. Share Zig best practices and idioms
3. Point out areas where the code could be more efficient
4. Suggest additional features or improvements

## Development Notes

As my first Zig project, this has been a valuable learning experience. I'm actively working on improving the code quality and learning better Zig patterns. Some key learnings so far:

- Working with Zig's memory allocator system
- Understanding Zig's error handling approach
- Managing complex data structures in Zig

## Resources

For those interested in similar projects or learning Zig:

- [RFC 4627 - JSON Specification](https://www.ietf.org/rfc/rfc4627.txt)
- [Zig Documentation](https://ziglang.org/documentation/master/)
- [Discussion on Simple Parsers](https://news.ycombinator.com/item?id=38150833)
