# Markingbird: A Markdown Processor in Swift

This library provides a [Markdown](http://daringfireball.net/projects/markdown/) processor written in [Swift](https://developer.apple.com/swift/) for OS X and iOS. It is a translation/port of the [MarkdownSharp](https://code.google.com/p/markdownsharp/) processor used by [Stack Overflow](http://blog.stackoverflow.com/2009/12/introducing-markdownsharp/).

The port currently passes all of the test cases in MarkdownSharp's `SimpleTests` test suite. However, it has not been extensively tested or used in production applications. If you find issues, please submit bug reports and fixes.

## How To Use It

The Xcode project packages the library as a Cocoa framework. However, as all the code is in the file `Markingbird/Markdown.swift`, the easiest way to use it is to simply copy that file into your own projects.

Typically, an app obtains some Markdown-formatted text somehow (read from a file, entered by a user, etc.), creates a `Markdown` object, and then calls its `transform(String) -> String` method to generate HTML.

    // If using Markingbird framework, import the module.
    // (If Markdown.swift is in your target, this is unneeded.)
    import Markingbird

	let inputText: String = getMarkdownFormatTextSomehow()

    // Note: must use `var` rather than `let` because the
    // Markdown struct mutates itself during processing
    var markdown = Markdown()
    let outputHtml: String = markdown.transform(inputText)

    // Use MarkdownOptions to enable non-default features
    var options = MarkdownOptions()
    options.autoHyperlink = true
    options.autoNewlines = true
    options.emptyElementSuffix = ">"
    options.encodeProblemUrlCharacters = true
    options.linkEmails = false
    options.strictBoldItalic = true
    var fancyMarkdown = Markdown(options)
	let fancyOutput = fancyMarkdown.transform(inputText)

A single `Markdown` instance can be used multiple times. However, it is not safe to use the `Markdown` class or its instances simultaneously from multiple threads, due to unsynchronized use of shared static data.

## To-Do

- Implement the `encodeProblemUrlCharacters` extension
- Port all of the unit tests from MarkdownSharp and ensure they  pass. (As of now, only the `SimpleTests` suite has been ported.)
- Eliminate all uses of `!` to force-unwrap Optionals (use safer `if let`, `??` or pattern-matching instead)
- Re-examine the ways that characters and substrings are processed (the current implementation is a mish-mash of `String` and `NSString` bridging)
- Create sample apps for OS X and iOS.

## Implementation Notes

For the most part, the code is a straightforward line-by-line translation of the C# code into Swift. Nothing has been done to make the code more "Swift-like" (whatever that means) or to improve the design. The C# code is itself a translation of Perl and PHP code, and the result is a bit of a mess. It is not a good example of Swift code, nor a good example of how to process Markdown. (It's really not a good example of anything.)

Aside from changes necessary for compatibility with Swift syntax and semantics, these are the only stylistic changes made during the translation:

- Lowercase identifiers for properties and methods
- Indentation and brace style matching Xcode's defaults and examples in _The Swift Programming Language_ guide
- Keyword arguments
- Use of `let` instead of `var` where possible
- Minimal use of Optional types (only used where the C# code explicitly uses or checks for `null`)
- Use of Swift string interpolation where the C# code uses `String.Format()`

When the Swift language and its standard library stabilize, it might make sense to reimplement this library to take advantage of advanced Swift features, but for now a simple translation of a mature implementation in a similar programming language is desirable as it is unlikely to break as Swift evolves.

A `Markdown` processor is implemented as a `struct`. It might be preferable to implement it as a `class`, because it mutates itself during processing. However, the C# implementation uses a lot of class-level data members, and Swift does not yet support `class` variables in classes. Swift does support `static` members in `structs`, so it made sense to use them. Whenever Swift does support class variables, the `struct` vs. `class` decision should be revisited.

To ease translation from C# to Swift, the private types `MarkdownRegex`, `MarkdownRegexOptions`, and `MarkdownRegexMatch` wrap Cocoa's `NSRegularExpression` class with interfaces similar to those of .NET's `Regex`, `RegexOptions`, and `Match` types.

The implementation uses many complex regular expressions. The C# version declares these using _verbatim string literals_ that span multiple lines and eliminate the need to escape special characters. Unfortunately, Swift does not allow string literals to span multiple lines, and requires escaping of all special characters. To translate the multi-line regular expression strings to Swift in a faithful and readable way, the `String.join` method is used to concatenate an array of lines copied from the original C# source. For example:

	// Original C# source
    string attr = @"
    (?>				    # optional tag attributes
      \s			    # starts with whitespace
      (?>
        [^>""/]+	    # text outside quotes
      |
        /+(?!>)		    # slash not followed by >
      |
        ""[^""]*""		# text inside double quotes (tolerate >)
      |
        '[^']*'	        # text inside single quotes (tolerate >)
      )*
    )?
	";

	// Translated to Swift
    let attr = "\n".join([
        "(?>            # optional tag attributes",
        "  \\s          # starts with whitespace",
        "  (?>",
        "    [^>\"/]+   # text outside quotes",
        "  |",
        "    /+(?!>)    # slash not followed by >",
        "  |",
        "    \"[^\"]*\" # text inside double quotes (tolerate >)",
        "  |",
        "    '[^']*'    # text inside single quotes (tolerate >)",
        "  )*",
        ")?"
        ])

The following transformations were made to the C# verbatim string literals to make them legal Swift literals and to conform to `NSRegularExpression`'s regular expression syntax:

- Convert each `\` to `\\`
- Convert each `""` to `\"`
- Convert each `[ ]` (a set containing a single space) to `\\p{Z}`
- In expressions that used `String.Format`, convert each `{{` to `{` and each `}}` to `}`


