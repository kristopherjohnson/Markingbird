/*

Markdown.swift
Copyright (c) 2014 Kristopher Johnson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

/*

Markdown.swift is based on MarkdownSharp, whose licenses and history are
enumerated in the following sections.

*/

/*
* MarkdownSharp
* -------------
* a C# Markdown processor
*
* Markdown is a text-to-HTML conversion tool for web writers
* Copyright (c) 2004 John Gruber
* http://daringfireball.net/projects/markdown/
*
* Markdown.NET
* Copyright (c) 2004-2009 Milan Negovan
* http://www.aspnetresources.com
* http://aspnetresources.com/blog/markdown_announced.aspx
*
* MarkdownSharp
* Copyright (c) 2009-2011 Jeff Atwood
* http://stackoverflow.com
* http://www.codinghorror.com/blog/
* http://code.google.com/p/markdownsharp/
*
* History: Milan ported the Markdown processor to C#. He granted license to me so I can open source it
* and let the community contribute to and improve MarkdownSharp.
*
*/

/*

Copyright (c) 2009 - 2010 Jeff Atwood

http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Copyright (c) 2003-2004 John Gruber
<http://daringfireball.net/>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name "Markdown" nor the names of its contributors may
be used to endorse or promote products derived from this software
without specific prior written permission.

This software is provided by the copyright holders and contributors "as
is" and any express or implied warranties, including, but not limited
to, the implied warranties of merchantability and fitness for a
particular purpose are disclaimed. In no event shall the copyright owner
or contributors be liable for any direct, indirect, incidental, special,
exemplary, or consequential damages (including, but not limited to,
procurement of substitute goods or services; loss of use, data, or
profits; or business interruption) however caused and on any theory of
liability, whether in contract, strict liability, or tort (including
negligence or otherwise) arising in any way out of the use of this
software, even if advised of the possibility of such damage.
*/


import Foundation


public struct MarkdownOptions {
    /// when true, (most) bare plain URLs are auto-hyperlinked
    /// WARNING: this is a significant deviation from the markdown spec
    public var autoHyperlink: Bool = false

    /// when true, RETURN becomes a literal newline
    /// WARNING: this is a significant deviation from the markdown spec
    public var autoNewlines: Bool = false

    /// use ">" for HTML output, or " />" for XHTML output
    public var emptyElementSuffix: String = " />"

    /// when true, problematic URL characters like [, ], (, and so forth will be encoded
    /// WARNING: this is a significant deviation from the markdown spec
    public var encodeProblemUrlCharacters: Bool = false

    /// when false, email addresses will never be auto-linked
    /// WARNING: this is a significant deviation from the markdown spec
    public var linkEmails: Bool = true

    /// when true, bold and italic require non-word characters on either side
    /// WARNING: this is a significant deviation from the markdown spec
    public var strictBoldItalic: Bool = false

    public init() {}
}

/// Markdown is a text-to-HTML conversion tool for web writers.
///
/// Markdown allows you to write using an easy-to-read, easy-to-write plain text format,
/// then convert it to structurally valid XHTML (or HTML).
public struct Markdown {
    // The MarkdownRegex, MarkdownRegexOptions, and MarkdownRegexMatch types
    // provide interfaces similar to .NET's Regex, RegexOptions, and Match.
    fileprivate typealias Regex = MarkdownRegex
    fileprivate typealias RegexOptions = MarkdownRegexOptions
    fileprivate typealias Match = MarkdownRegexMatch
    fileprivate typealias MatchEvaluator = (Match) -> String

    /// MarkdownSharp version on which this implementation is based
    fileprivate let _version = "1.13"

    /// Create a new Markdown instance and set the options from the MarkdownOptions object.
    public init(options: MarkdownOptions? = nil) {
        if Markdown.staticsInitialized {
            if let options = options {
                _autoHyperlink = options.autoHyperlink
                _autoNewlines = options.autoNewlines
                _emptyElementSuffix = options.emptyElementSuffix
                _encodeProblemUrlCharacters = options.encodeProblemUrlCharacters
                _linkEmails = options.linkEmails
                _strictBoldItalic = options.strictBoldItalic
            }
        }
    }

    /// use ">" for HTML output, or " />" for XHTML output
    public var emptyElementSuffix: String {
        get        { return _emptyElementSuffix }
        set(value) { _emptyElementSuffix = value }
    }
    fileprivate var _emptyElementSuffix = " />"

    /// when false, email addresses will never be auto-linked
    /// WARNING: this is a significant deviation from the markdown spec
    public var linkEmails: Bool {
        get        { return _linkEmails }
        set(value) { _linkEmails = value }
    }
    fileprivate var _linkEmails = true

    /// when true, bold and italic require non-word characters on either side
    /// WARNING: this is a significant deviation from the markdown spec
    public var strictBoldItalic: Bool {
        get        { return _strictBoldItalic }
        set(value) { _strictBoldItalic = value }
    }
    fileprivate var _strictBoldItalic = false

    /// when true, RETURN becomes a literal newline
    /// WARNING: this is a significant deviation from the markdown spec
    public var autoNewLines: Bool {
        get        { return _autoNewlines }
        set(value) { _autoNewlines = value }
    }
    fileprivate var _autoNewlines = false

    /// when true, (most) bare plain URLs are auto-hyperlinked
    /// WARNING: this is a significant deviation from the markdown spec
    public var autoHyperlink: Bool {
        get        { return _autoHyperlink }
        set(value) { _autoHyperlink = value }
    }
    fileprivate var _autoHyperlink = false

    /// when true, problematic URL characters like [, ], (, and so forth will be encoded
    /// WARNING: this is a significant deviation from the markdown spec
    public var encodeProblemUrlCharacters: Bool {
        get        { return _encodeProblemUrlCharacters }
        set(value) { _encodeProblemUrlCharacters = value }
    }
    fileprivate var _encodeProblemUrlCharacters = false

    fileprivate enum TokenType {
        case text
        case tag
    }

    fileprivate struct Token {
        fileprivate init(type: TokenType, value: String) {
            self.type = type
            self.value = value
        }

        fileprivate var type: TokenType
        fileprivate var value: String
    }

    /// maximum nested depth of [] and () supported by the transform; implementation detail
    fileprivate static let _nestDepth = 6

    /// Tabs are automatically converted to spaces as part of the transform
    /// this constant determines how "wide" those tabs become in spaces
    fileprivate static let _tabWidth = 4

    fileprivate static let _markerUL = "[*+-]"
    fileprivate static let _markerOL = "\\d+[.]"

    fileprivate static var _escapeTable = Dictionary<String, String>()
    fileprivate static var _invertedEscapeTable = Dictionary<String, String>()
    fileprivate static var _backslashEscapeTable = Dictionary<String, String>()

    fileprivate var _urls = Dictionary<String, String>()
    fileprivate var _titles = Dictionary<String, String>()
    fileprivate var _htmlBlocks = Dictionary<String, String>()

    fileprivate var _listLevel: Int = 0
    fileprivate static let autoLinkPreventionMarker = "\u{1A}P" // temporarily replaces "://" where auto-linking shouldn't happen;

    /// Swift doesn't have static initializers, so our trick is to
    /// define this static property with an initializer, and use the
    /// property in init() to force initialization.
    fileprivate static let staticsInitialized: Bool = {
        // Table of hash values for escaped characters:
        _escapeTable = Dictionary<String, String>()
        _invertedEscapeTable = Dictionary<String, String>()
        // Table of hash value for backslash escaped characters:
        _backslashEscapeTable = Dictionary<String, String>()

        var backslashPattern = ""

        for c in "\\`*_{}[]()>#+-.!/".characters {
            let key = String(c)
            let hash = Markdown.getHashKey(key, isHtmlBlock: false)
            _escapeTable[key] = hash
            _invertedEscapeTable[hash] = key
            _backslashEscapeTable["\\" + key] = hash
            if !backslashPattern.isEmpty {
                backslashPattern += "|"
            }
            backslashPattern += Regex.escape("\\" + key)
        }

        _backslashEscapes = Regex(backslashPattern)

        return true
        }()

    /// current version of MarkdownSharp;
    /// see http://code.google.com/p/markdownsharp/ for the latest code or to contribute
    public var version: String {
        get { return _version }
    }

    /// Transforms the provided Markdown-formatted text to HTML;
    /// see http://en.wikipedia.org/wiki/Markdown
    ///
    /// - parameter text: Markdown-format text to be transformed to HTML
    ///
    /// - returns: HTML-format text
    public mutating func transform(_ text: String) -> String {
        // The order in which other subs are called here is
        // essential. Link and image substitutions need to happen before
        // EscapeSpecialChars(), so that any *'s or _'s in the a
        // and img tags get encoded.

        if text.isEmpty { return "" }

        setup()

        var text = normalize(text)

        text = hashHTMLBlocks(text)
        text = stripLinkDefinitions(text)
        text = runBlockGamut(text)
        text = unescape(text)

        cleanup()

        return text + "\n"
    }

    /// Perform transformations that form block-level tags like paragraphs, headers, and list items.
    fileprivate mutating func runBlockGamut(_ text: String, unhash: Bool = true) -> String {
        var text = doHeaders(text)
        text = doHorizontalRules(text)
        text = doLists(text)
        text = doCodeBlocks(text)
        text = doBlockQuotes(text)

        // We already ran HashHTMLBlocks() before, in Markdown(), but that
        // was to escape raw HTML in the original Markdown source. This time,
        // we're escaping the markup we've just created, so that we don't wrap
        // <p> tags around block-level tags.
        text = hashHTMLBlocks(text)

        text = formParagraphs(text, unhash: unhash)

        return text
    }

    /// Perform transformations that occur *within* block-level tags like paragraphs, headers, and list items.
    fileprivate func runSpanGamut(_ text: String) -> String {
        var text = doCodeSpans(text)
        text = escapeSpecialCharsWithinTagAttributes(text)
        text = escapeBackslashes(text)

        // Images must come first, because ![foo][f] looks like an anchor.
        text = doImages(text)
        text = doAnchors(text)

        // Must come after DoAnchors(), because you can use < and >
        // delimiters in inline links like [this](<url>).
        text = doAutoLinks(text)

        text = text.replacingOccurrences(of: Markdown.autoLinkPreventionMarker,
            with: "://")

        text = encodeAmpsAndAngles(text)
        text = doItalicsAndBold(text)
        text = doHardBreaks(text)

        return text
    }

    fileprivate static let _newlinesLeadingTrailing = Regex("^\\n+|\\n+\\z")
    fileprivate static let _newlinesMultiple = Regex("\\n{2,}")
    fileprivate static let _leadingWhitespace = Regex("^\\p{Z}*")

    fileprivate static let _htmlBlockHash = Regex("\u{1A}H\\d+H")

    /// splits on two or more newlines, to form "paragraphs";
    /// each paragraph is then unhashed (if it is a hash and unhashing isn't turned off) or wrapped in HTML p tag
    fileprivate func formParagraphs(_ text: String, unhash: Bool = true) -> String
    {
        // split on two or more newlines
        var grafs = Markdown._newlinesMultiple.split(
            Markdown._newlinesLeadingTrailing.replace(text, ""))
        let grafsLength = grafs.count

        for i in 0..<grafsLength {
            if (grafs[i].hasPrefix("\u{1A}H")) {
                // unhashify HTML blocks
                if unhash {
                    var sanityCheck = 50 // just for safety, guard against an infinite loop
                    var keepGoing = true // as long as replacements where made, keep going
                    while keepGoing && sanityCheck > 0 {
                        keepGoing = false
                        let graf = grafs[i]
                        grafs[i] = Markdown._htmlBlockHash.replace(graf) { match in
                            if let replacementValue = self._htmlBlocks[match.value as String] {
                                keepGoing = true
                                return replacementValue
                            }
                            return graf
                        }
                        sanityCheck -= 1
                    }
                    /* if (keepGoing)
                    {
                    // Logging of an infinite loop goes here.
                    // If such a thing should happen, please open a new issue on http://code.google.com/p/markdownsharp/
                    // with the input that caused it.
                    }*/
                }
            }
            else
            {
                // do span level processing inside the block, then wrap result in <p> tags
                let paragraph = Markdown._leadingWhitespace.replace(runSpanGamut(grafs[i]), "<p>") + "</p>"
                grafs[i] = paragraph
            }
        }

        return grafs.joined(separator: "\n\n")
    }

    fileprivate mutating func setup() {
        // Clear the global hashes. If we don't clear these, you get conflicts
        // from other articles when generating a page which contains more than
        // one article (e.g. an index page that shows the N most recent
        // articles):
        _urls.removeAll(keepingCapacity: false)
        _titles.removeAll(keepingCapacity: false)
        _htmlBlocks.removeAll(keepingCapacity: false)
        _listLevel = 0
    }

    fileprivate mutating func cleanup() {
        setup()
    }

    fileprivate static var _nestedBracketsPattern = ""

    /// Reusable pattern to match balanced [brackets]. See Friedl's
    /// "Mastering Regular Expressions", 2nd Ed., pp. 328-331.
    fileprivate static func getNestedBracketsPattern() -> String {
        // in other words [this] and [this[also]] and [this[also[too]]]
        // up to _nestDepth
        if (_nestedBracketsPattern.isEmpty) {
            _nestedBracketsPattern = repeatString([
                "(?>             # Atomic matching",
                "[^\\[\\]]+      # Anything other than brackets",
                "|",
                "\\["
                ].joined(separator: "\n"), _nestDepth) +
                repeatString(" \\])*", _nestDepth)
        }
        return _nestedBracketsPattern
    }

    fileprivate static var _nestedParensPattern = ""

    /// Reusable pattern to match balanced (parens). See Friedl's
    /// "Mastering Regular Expressions", 2nd Ed., pp. 328-331.
    fileprivate static func getNestedParensPattern() -> String {
        // in other words (this) and (this(also)) and (this(also(too)))
        // up to _nestDepth
        if (_nestedParensPattern.isEmpty) {
            _nestedParensPattern = repeatString([
                "(?>            # Atomic matching",
                "[^()\\s]+      # Anything other than parens or whitespace",
                "|",
                "\\("
                ].joined(separator: "\n"), _nestDepth) +
                repeatString(" \\))*", _nestDepth)
        }
        return _nestedParensPattern
    }

    fileprivate static var _linkDef = Regex([
        "^\\p{Z}{0,\(Markdown._tabWidth - 1)}\\[([^\\[\\]]+)\\]:  # id = $1",
        "  \\p{Z}*",
        "  \\n?                   # maybe *one* newline",
        "  \\p{Z}*",
        "<?(\\S+?)>?              # url = $2",
        "  \\p{Z}*",
        "  \\n?                   # maybe one newline",
        "  \\p{Z}*",
        "(?:",
        "    (?<=\\s)             # lookbehind for whitespace",
        "    [\"(]",
        "    (.+?)                # title = $3",
        "    [\")]",
        "    \\p{Z}*",
        ")?                       # title is optional",
        "(?:\\n+|\\Z)"
        ].joined(separator: "\n"),
        options: RegexOptions.Multiline.union(RegexOptions.IgnorePatternWhitespace))

    /// Strips link definitions from text, stores the URLs and titles in hash references.
    ///
    /// ^[id]: url "optional title"
    fileprivate mutating func stripLinkDefinitions(_ text: String) -> String
    {
        return Markdown._linkDef.replace(text) { self.linkEvaluator($0) }
    }

    fileprivate mutating func linkEvaluator(_ match: Match) -> String
    {
        let linkID = match.valueOfGroupAtIndex(1) as String
        _urls[linkID] = encodeAmpsAndAngles(match.valueOfGroupAtIndex(2) as String)

        let group3Value = match.valueOfGroupAtIndex(3)
        if group3Value.length != 0 {
            _titles[linkID] = group3Value.replacingOccurrences(of: "\"",
                with: "&quot")
        }

        return ""
    }

    fileprivate static let _blocksHtml = Regex(Markdown.getBlockPattern(),
        options: RegexOptions.Multiline.union(RegexOptions.IgnorePatternWhitespace))

    /// derived pretty much verbatim from PHP Markdown
    fileprivate static func getBlockPattern() -> String {

        // Hashify HTML blocks:
        // We only want to do this for block-level HTML tags, such as headers,
        // lists, and tables. That's because we still want to wrap <p>s around
        // "paragraphs" that are wrapped in non-block-level tags, such as anchors,
        // phrase emphasis, and spans. The list of tags we're looking for is
        // hard-coded:
        //
        // *  List "a" is made of tags which can be both inline or block-level.
        //    These will be treated block-level when the start tag is alone on
        //    its line, otherwise they're not matched here and will be taken as
        //    inline later.
        // *  List "b" is made of tags which are always block-level;
        //
        let blockTagsA = "ins|del"
        let blockTagsB = "p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|address|script|noscript|form|fieldset|iframe|math"

        // Regular expression for the content of a block tag.
        let attr = [
            "(?>                         # optional tag attributes",
            "  \\s                       # starts with whitespace",
            "  (?>",
            "    [^>\"/]+                # text outside quotes",
            "  |",
            "    /+(?!>)                 # slash not followed by >",
            "  |",
            "    \"[^\"]*\"              # text inside double quotes (tolerate >)",
            "  |",
            "    '[^']*'                 # text inside single quotes (tolerate >)",
            "  )*",
            ")?"
            ].joined(separator: "\n")

        let content = repeatString([
            "(?>",
            "  [^<]+                         # content without tag",
            "|",
            "  <\\2                          # nested opening tag",
            attr,
            "(?>",
            "    />",
            "|",
            "    >"].joined(separator: "\n"),
            _nestDepth) +   // end of opening tag
            ".*?" +             // last level nested tag content
            repeatString([
                "      </\\2\\s*>          # closing nested tag",
                "  )",
                "  |                             ",
                "  <(?!/\\2\\s*>           # other tags with a different name",
                "  )",
                ")*"].joined(separator: "\n"),
                _nestDepth)

        let content2 = content.replacingOccurrences(of: "\\2", with: "\\3")

        // First, look for nested blocks, e.g.:
        // 	<div>
        // 		<div>
        // 		tags for inner block must be indented.
        // 		</div>
        // 	</div>
        //
        // The outermost tags must start at the left margin for this to match, and
        // the inner nested divs must be indented.
        // We need to do this before the next, more liberal match, because the next
        // match will start at the first `<div>` and stop at the first `</div>`.
        var pattern = [
            "(?>",
            "      (?>",
            "        (?<=\\n)     # Starting at the beginning of a line",
            "        |           # or",
            "        \\A\\n?       # the beginning of the doc",
            "      )",
            "      (             # save in $1",
            "",
            "        # Match from `\\n<tag>` to `</tag>\\n`, handling nested tags ",
            "        # in between.",
            "          ",
            "            <($block_tags_b_re)   # start tag = $2",
            "            $attr>                # attributes followed by > and \\n",
            "            $content              # content, support nesting",
            "            </\\2>                 # the matching end tag",
            "            \\p{Z}*                  # trailing spaces",
            "            (?=\\n+|\\Z)            # followed by a newline or end of document",
            "",
            "      | # Special version for tags of group a.",
            "",
            "            <($block_tags_a_re)   # start tag = $3",
            "            $attr>\\p{Z}*\\n          # attributes followed by >",
            "            $content2             # content, support nesting",
            "            </\\3>                 # the matching end tag",
            "            \\p{Z}*                  # trailing spaces",
            "            (?=\\n+|\\Z)            # followed by a newline or end of document",
            "          ",
            "      | # Special case just for <hr />. It was easier to make a special ",
            "        # case than to make the other regex more complicated.",
            "      ",
            "            \\p{Z}{0,$less_than_tab}",
            "            <hr",
            "            $attr                 # attributes",
            "            /?>                   # the matching end tag",
            "            \\p{Z}*",
            "            (?=\\n{2,}|\\Z)         # followed by a blank line or end of document",
            "      ",
            "      | # Special case for standalone HTML comments:",
            "      ",
            "          (?<=\\n\\n|\\A)            # preceded by a blank line or start of document",
            "          \\p{Z}{0,$less_than_tab}",
            "          (?s:",
            "            <!--(?:|(?:[^>-]|-[^>])(?:[^-]|-[^-])*)-->",
            "          )",
            "          \\p{Z}*",
            "          (?=\\n{2,}|\\Z)            # followed by a blank line or end of document",
            "      ",
            "      | # PHP and ASP-style processor instructions (<? and <%)",
            "      ",
            "          \\p{Z}{0,$less_than_tab}",
            "          (?s:",
            "            <([?%])                # $4",
            "            .*?",
            "            \\4>",
            "          )",
            "          \\p{Z}*",
            "          (?=\\n{2,}|\\Z)            # followed by a blank line or end of document",
            "          ",
            "      )",
            ")"
            ].joined(separator: "\n")
        pattern = pattern.replacingOccurrences(of: "$less_than_tab",
            with: String(_tabWidth - 1))
        pattern = pattern.replacingOccurrences(of: "$block_tags_b_re",
            with: blockTagsB)
        pattern = pattern.replacingOccurrences(of: "$block_tags_a_re",
            with: blockTagsA)
        pattern = pattern.replacingOccurrences(of: "$attr",
            with: attr)
        pattern = pattern.replacingOccurrences(of: "$content2",
            with: content2)
        pattern = pattern.replacingOccurrences(of: "$content",
            with: content)

        return pattern
    }

    /// replaces any block-level HTML blocks with hash entries
    fileprivate mutating func hashHTMLBlocks(_ text: String) -> String {
        return Markdown._blocksHtml.replace(text) { self.htmlEvaluator($0) }
    }

    fileprivate mutating func htmlEvaluator(_ match: Match) -> String {
        let text: String = match.valueOfGroupAtIndex(1) as String 
        let key = Markdown.getHashKey(text, isHtmlBlock: true)
        _htmlBlocks[key] = text

        return "\n\n\(key)\n\n"
    }

    fileprivate static func getHashKey(_ s: String, isHtmlBlock: Bool) -> String {
        let delim = isHtmlBlock ? "H" : "E"
        return "\u{1A}" + delim + String(abs(s.hashValue)) + delim
    }

    // TODO: C# code uses RegexOptions.ExplicitCapture here. Need to figure out
    // how/whether to emulate that with NSRegularExpression.
    fileprivate static let _htmlTokens = Regex([
        "(<!--(?:|(?:[^>-]|-[^>])(?:[^-]|-[^-])*)-->)|   # match <!-- foo -->",
        "(<\\?.*?\\?>)|                                  # match <?foo?>"
        ].joined(separator: "\n") +
        Markdown.repeatString("(<[A-Za-z\\/!$](?:[^<>]|", _nestDepth) +
        Markdown.repeatString(")*>)", _nestDepth) + " # match <tag> and </tag>",
        options: RegexOptions.Multiline.union(RegexOptions.Singleline).union(RegexOptions.IgnorePatternWhitespace))

    /// returns an array of HTML tokens comprising the input string. Each token is
    /// either a tag (possibly with nested, tags contained therein, such
    /// as &lt;a href="&lt;MTFoo&gt;"&gt;, or a run of text between tags. Each element of the
    /// array is a two-element array; the first is either 'tag' or 'text'; the second is
    /// the actual value.
    fileprivate func tokenizeHTML(_ text: String) -> [Token] {
        var pos = 0
        var tagStart = 0
        var tokens = Array<Token>()

        let str = text as NSString

        // this regex is derived from the _tokenize() subroutine in Brad Choate's MTRegex plugin.
        // http://www.bradchoate.com/past/mtregex.php
        for match in Markdown._htmlTokens.matches(text) {
            tagStart = match.index

            if pos < tagStart {
                let range = NSMakeRange(pos, tagStart - pos)
                tokens.append(Token(type: .text, value: str.substring(with: range)))
            }
            tokens.append(Token(type: .tag, value: match.value as String))
            pos = tagStart + match.length
        }

        if pos < str.length {
            tokens.append(Token(type: .text, value: str.substring(with: NSMakeRange(pos, Int(str.length) - pos))))
        }

        return tokens
    }

    fileprivate static let _anchorRef = Regex([
        "(                               # wrap whole match in $1",
        "    \\[",
        "        (\(Markdown.getNestedBracketsPattern()))  # link text = $2",
        "    \\]",
        "",
        "    \\p{Z}?                        # one optional space",
        "    (?:\\n\\p{Z}*)?                # one optional newline followed by spaces",
        "",
        "    \\[",
        "        (.*?)                   # id = $3",
        "    \\]",
        ")"
        ].joined(separator: "\n"),
        options: RegexOptions.Singleline.union(RegexOptions.IgnorePatternWhitespace))

    fileprivate static let _anchorInline = Regex([
        "(                           # wrap whole match in $1",
        "    \\[",
        "        (\(Markdown.getNestedBracketsPattern()))   # link text = $2",
        "    \\]",
        "    \\(                     # literal paren",
        "        \\p{Z}*",
        "        (\(Markdown.getNestedParensPattern()))   # href = $3",
        "        \\p{Z}*",
        "        (                   # $4",
        "        (['\"])           # quote char = $5",
        "        (.*?)               # title = $6",
        "        \\5                 # matching quote",
        "        \\p{Z}*                # ignore any spaces between closing quote and )",
        "        )?                  # title is optional",
        "    \\)",
        ")"
        ].joined(separator: "\n"),
        options: RegexOptions.Singleline.union(RegexOptions.IgnorePatternWhitespace))

    fileprivate static let _anchorRefShortcut = Regex([
        "(                               # wrap whole match in $1",
        "  \\[",
        "     ([^\\[\\]]+)               # link text = $2; can't contain [ or ]",
        "  \\]",
        ")"
        ].joined(separator: "\n"),
        options: RegexOptions.Singleline.union(RegexOptions.IgnorePatternWhitespace))

    /// Turn Markdown link shortcuts into HTML anchor tags
    ///
    /// - [link text](url "title")
    /// - [link text][id]
    /// - [id]
    fileprivate func doAnchors(_ text: String) -> String {
        // First, handle reference-style links: [link text] [id]
        var text = Markdown._anchorRef.replace(text) { self.anchorRefEvaluator($0) }

        // Next, inline-style links: [link text](url "optional title") or [link text](url "optional title")
        text = Markdown._anchorInline.replace(text) { self.anchorInlineEvaluator($0) }

        //  Last, handle reference-style shortcuts: [link text]
        //  These must come last in case you've also got [link test][1]
        //  or [link test](/foo)
        text = Markdown._anchorRefShortcut.replace(text) { self.anchorRefShortcutEvaluator($0) }
        return text
    }

    fileprivate func saveFromAutoLinking(_ s: String) -> String {
        return s.replacingOccurrences(of: "://", with: Markdown.autoLinkPreventionMarker)
    }

    fileprivate func anchorRefEvaluator(_ match: Match) -> String {
        let wholeMatch = match.valueOfGroupAtIndex(1)
        let linkText = saveFromAutoLinking(match.valueOfGroupAtIndex(2) as String)
        var linkID = match.valueOfGroupAtIndex(3).lowercased

        var result: String

        // for shortcut links like [this][].
        if linkID.isEmpty {
            linkID = linkText.lowercased()
        }

        if var url = _urls[linkID] {
            url = encodeProblemUrlChars(url)
            url = escapeBoldItalic(url)
            result = "<a href=\"\(url)\""

            if var title = _titles[linkID] {
                title = Markdown.attributeEncode(title)
                title = Markdown.attributeEncode(escapeBoldItalic(title))
                result += " title=\"\(title)\""
            }

            result += ">\(linkText)</a>"
        }
        else {
            result = wholeMatch as String
        }

        return result
    }

    fileprivate func anchorRefShortcutEvaluator(_ match: Match) -> String {
        let wholeMatch = match.valueOfGroupAtIndex(1)
        let linkText = saveFromAutoLinking(match.valueOfGroupAtIndex(2) as String)
        let linkID = Regex.replace(linkText.lowercased(),
            pattern: "\\p{Z}*\\n\\p{Z}*",
            replacement: " ")  // lower case and remove newlines / extra spaces

        var result: String

        if var url = _urls[linkID] {
            url = encodeProblemUrlChars(url)
            url = escapeBoldItalic(url)
            result = "<a href=\"\(url)\""

            if var title = _titles[linkID] {
                title = Markdown.attributeEncode(title)
                title = escapeBoldItalic(title)
                result += " title=\"\(title)\""
            }

            result += ">\(linkText)</a>"
        }
        else {
            result = wholeMatch as String
        }

        return result
    }

    fileprivate func anchorInlineEvaluator(_ match: Match) -> String {
        let linkText = saveFromAutoLinking(match.valueOfGroupAtIndex(2) as String)
        var url = match.valueOfGroupAtIndex(3)
        var title = match.valueOfGroupAtIndex(6)

        var result: String

        url = encodeProblemUrlChars(url as String) as NSString
        url = escapeBoldItalic(url as String) as NSString
        if url.hasPrefix("<") && url.hasSuffix(">") {
            url = url.substring(with: NSMakeRange(1, url.length - 2)) as NSString // remove <>'s surrounding URL, if present
        }

        result = "<a href=\"\(url)\""

        if title.length != 0 {
            title = Markdown.attributeEncode(title as String) as NSString
            title = escapeBoldItalic(title as String) as NSString
            result += " title=\"\(title)\""
        }

        result += ">\(linkText)</a>"
        return result
    }

    fileprivate static let _imagesRef = Regex([
        "(               # wrap whole match in $1",
        "!\\[",
        "    (.*?)       # alt text = $2",
        "\\]",
        "",
        "\\p{Z}?            # one optional space",
        "(?:\\n\\p{Z}*)?    # one optional newline followed by spaces",
        "",
        "\\[",
        "    (.*?)       # id = $3",
        "\\]",
        "",
        ")"
        ].joined(separator: "\n"),
        options: RegexOptions.IgnorePatternWhitespace.union(RegexOptions.Singleline))

    fileprivate static let _imagesInline = Regex([
        "(                     # wrap whole match in $1",
        "  !\\[",
        "      (.*?)           # alt text = $2",
        "  \\]",
        "  \\s?                # one optional whitespace character",
        "  \\(                 # literal paren",
        "      \\p{Z}*",
        "      (\(Markdown.getNestedParensPattern()))    # href = $3",
        "      \\p{Z}*",
        "      (               # $4",
        "      (['\"])       # quote char = $5",
        "      (.*?)           # title = $6",
        "      \\5             # matching quote",
        "      \\p{Z}*",
        "      )?              # title is optional",
        "  \\)",
        ")"
        ].joined(separator: "\n"),
        options: RegexOptions.IgnorePatternWhitespace.union(RegexOptions.Singleline))

    /// Turn Markdown image shortcuts into HTML img tags.
    ///
    /// - ![alt text][id]
    /// - ![alt text](url "optional title")
    fileprivate func doImages(_ text: String) -> String {
        // First, handle reference-style labeled images: ![alt text][id]
        var text = Markdown._imagesRef.replace(text) { self.imageReferenceEvaluator($0) }

        // Next, handle inline images:  ![alt text](url "optional title")
        // Don't forget: encode * and _
        text = Markdown._imagesInline.replace(text) { self.imageInlineEvaluator($0) }

        return text
    }

    // This prevents the creation of horribly broken HTML when some syntax ambiguities
    // collide. It likely still doesn't do what the user meant, but at least we're not
    // outputting garbage.
    fileprivate func escapeImageAltText(_ s: String) -> String {
        var s = escapeBoldItalic(s)
        s = Regex.replace(s, pattern: "[\\[\\]()]") { Markdown._escapeTable[$0.value as String]! }
        return s
    }

    fileprivate func imageReferenceEvaluator(_ match: Match) -> String {
        let wholeMatch = match.valueOfGroupAtIndex(1)
        let altText = match.valueOfGroupAtIndex(2)
        var linkID = match.valueOfGroupAtIndex(3).lowercased

        // for shortcut links like ![this][].
        if linkID.isEmpty {
            linkID = altText.lowercased
        }

        if let url = _urls[linkID] {
            var title: String? = nil

            if let t = _titles[linkID] {
                title = t
            }
            return imageTag(url, altText: altText as String, title: title)
        }
        else{
            // If there's no such link ID, leave intact:
            return wholeMatch as String
        }
    }

    fileprivate func imageInlineEvaluator(_ match: Match) -> String {
        let alt = match.valueOfGroupAtIndex(2)
        var url = match.valueOfGroupAtIndex(3)
        let title = match.valueOfGroupAtIndex(6)

        if url.hasPrefix("<") && url.hasSuffix(">") {
            url = url.substring(with: NSMakeRange(1, url.length - 2)) as NSString    // Remove <>'s surrounding URL, if present
        }
        return imageTag(url as String, altText: alt as String, title: title as String)
    }

    fileprivate func imageTag(_ url: String, altText: String, title: String?) -> String {
        let altText = escapeImageAltText(Markdown.attributeEncode(altText))
        var url = encodeProblemUrlChars(url)
        url = escapeBoldItalic(url)
        var result = "<img src=\"\(url)\" alt=\"\(altText)\""
        if var title = title {
            if !title.isEmpty {
                title = Markdown.attributeEncode(escapeBoldItalic(title))
                result += " title=\"\(title)\""
            }
        }
        result += _emptyElementSuffix
        return result
    }

    fileprivate static let _headerSetext = Regex([
        "^(.+?)",
        "\\p{Z}*",
        "\\n",
        "(=+|-+)     # $1 = string of ='s or -'s",
        "\\p{Z}*",
        "\\n+"
        ].joined(separator: "\n"),
        options: RegexOptions.Multiline.union(RegexOptions.IgnorePatternWhitespace))

    fileprivate static let _headerAtx = Regex([
        "^(\\#{1,6})  # $1 = string of #'s",
        "\\p{Z}*",
        "(.+?)        # $2 = Header text",
        "\\p{Z}*",
        "\\#*         # optional closing #'s (not counted)",
        "\\n+"
        ].joined(separator: "\n"),
        options: RegexOptions.Multiline.union(RegexOptions.IgnorePatternWhitespace))

    /// Turn Markdown headers into HTML header tags
    ///
    /// Header 1
    /// ========
    ///
    /// Header 2
    /// --------
    ///
    /// # Header 1
    ///
    /// ## Header 2
    ///
    /// ## Header 2 with closing hashes ##
    ///
    /// ...
    ///
    /// ###### Header 6
    fileprivate func doHeaders(_ text: String) -> String {
        var text = Markdown._headerSetext.replace(text) { self.setextHeaderEvaluator($0) }
        text = Markdown._headerAtx.replace(text) { self.atxHeaderEvaluator($0) }
        return text
    }

    fileprivate func setextHeaderEvaluator(_ match: Match) -> String {
        let header = match.valueOfGroupAtIndex(1)
        let level = match.valueOfGroupAtIndex(2).hasPrefix("=") ? 1 : 2
        return "<h\(level)>\(runSpanGamut(header as String))</h\(level)>\n\n"
    }

    fileprivate func atxHeaderEvaluator(_ match: Match) -> String {
        let header = match.valueOfGroupAtIndex(2)
        let level = match.valueOfGroupAtIndex(1).length
        return "<h\(level)>\(runSpanGamut(header as String))</h\(level)>\n\n"
    }

    fileprivate static let _horizontalRules = Regex([
        "^\\p{Z}{0,3}         # Leading space",
        "    ([-*_])       # $1: First marker",
        "    (?>           # Repeated marker group",
        "        \\p{Z}{0,2}  # Zero, one, or two spaces.",
        "        \\1       # Marker character",
        "    ){2,}         # Group repeated at least twice",
        "    \\p{Z}*          # Trailing spaces",
        "    $             # End of line."
        ].joined(separator: "\n"),
        options: RegexOptions.Multiline.union(RegexOptions.IgnorePatternWhitespace))

    /// Turn Markdown horizontal rules into HTML hr tags
    ///
    /// ***
    ///
    /// * * *
    ///
    /// ---
    ///
    /// - - -
    fileprivate func doHorizontalRules(_ text: String) -> String {
        return Markdown._horizontalRules.replace(text, "<hr" + _emptyElementSuffix + "\n")
    }

    fileprivate static let _listMarker = "(?:\(_markerUL)|\(_markerOL))"

    fileprivate static let _wholeList = [
        "(                               # $1 = whole list",
        "  (                             # $2",
        "    \\p{Z}{0,\(_tabWidth - 1)}",
        "    (\(_listMarker))            # $3 = first list item marker",
        "    \\p{Z}+",
        "  )",
        "  (?s:.+?)",
        "  (                             # $4",
        "      \\z",
        "    |",
        "      \\n{2,}",
        "      (?=\\S)",
        "      (?!                       # Negative lookahead for another list item marker",
        "        \\p{Z}*",
        "        \(_listMarker)\\p{Z}+",
        "      )",
        "  )",
        ")"
        ].joined(separator: "\n")

    fileprivate static let _listNested = Regex("^" + _wholeList,
        options: RegexOptions.Multiline.union(RegexOptions.IgnorePatternWhitespace))

    fileprivate static let _listTopLevel = Regex("(?:(?<=\\n\\n)|\\A\\n?)" + _wholeList,
        options: RegexOptions.Multiline.union(RegexOptions.IgnorePatternWhitespace))

    /// Turn Markdown lists into HTML ul and ol and li tags
    fileprivate mutating func doLists(_ text: String, isInsideParagraphlessListItem: Bool = false) -> String {
        // We use a different prefix before nested lists than top-level lists.
        // See extended comment in _ProcessListItems().
        var text = text
        if _listLevel > 0 {
            let evaluator = getListEvaluator(isInsideParagraphlessListItem)
            text = Markdown._listNested.replace(text) { evaluator($0) }
        }
        else {
            let evaluator = getListEvaluator(false)
            text = Markdown._listTopLevel.replace(text) { evaluator($0) }
        }
        return text
    }

    fileprivate mutating func getListEvaluator(_ isInsideParagraphlessListItem: Bool = false) -> MatchEvaluator {
        var selfCopy = self
        
        let matchEvaluator: MatchEvaluator = { match in
            let list = match.valueOfGroupAtIndex(1) as String
            let listType = Regex.isMatch(match.valueOfGroupAtIndex(3) as String, pattern: Markdown._markerUL) ? "ul" : "ol"
            var result: String
            
            result = selfCopy.processListItems(list,
                                               marker: listType == "ul" ? Markdown._markerUL : Markdown._markerOL,
                                               isInsideParagraphlessListItem: isInsideParagraphlessListItem)
            
            result = "<\(listType)>\n\(result)</\(listType)>\n"
            return result
        }
        
        self = selfCopy
        
        return matchEvaluator
    }

    /// Process the contents of a single ordered or unordered list, splitting it
    /// into individual list items.
    fileprivate mutating func processListItems(_ list: String, marker: String, isInsideParagraphlessListItem: Bool = false) -> String {
        // The listLevel global keeps track of when we're inside a list.
        // Each time we enter a list, we increment it; when we leave a list,
        // we decrement. If it's zero, we're not in a list anymore.

        // We do this because when we're not inside a list, we want to treat
        // something like this:

        //    I recommend upgrading to version
        //    8. Oops, now this line is treated
        //    as a sub-list.

        // As a single paragraph, despite the fact that the second line starts
        // with a digit-period-space sequence.

        // Whereas when we're inside a list (or sub-list), that line will be
        // treated as the start of a sub-list. What a kludge, huh? This is
        // an aspect of Markdown's syntax that's hard to parse perfectly
        // without resorting to mind-reading. Perhaps the solution is to
        // change the syntax rules such that sub-lists must start with a
        // starting cardinal number; e.g. "1." or "a.".

        _listLevel += 1

        // Trim trailing blank lines:
        var list = Regex.replace(list, pattern: "\\n{2,}\\z", replacement: "\n")

        let pattern = [
            "(^\\p{Z}*)                    # leading whitespace = $1",
            "(\(marker)) \\p{Z}+           # list marker = $2",
            "((?s:.+?)                  # list item text = $3",
            "(\\n+))",
            "(?= (\\z | \\1 (\(marker)) \\p{Z}+))"
            ].joined(separator: "\n")

        var lastItemHadADoubleNewline = false
        var selfCopy = self

        // has to be a closure, so subsequent invocations can share the bool
        let listItemEvaluator: MatchEvaluator = { match in
            var item = match.valueOfGroupAtIndex(3)

            let endsWithDoubleNewline = item.hasSuffix("\n\n")
            let containsDoubleNewline = endsWithDoubleNewline || Markdown.doesString(item, containSubstring: "\n\n")

            if containsDoubleNewline || lastItemHadADoubleNewline {
                // we could correct any bad indentation here..
                item = selfCopy.runBlockGamut(selfCopy.outdent(item as String) + "\n", unhash: false) as NSString
            }
            else {
                // recursion for sub-lists
                item = selfCopy.doLists(selfCopy.outdent(item as String), isInsideParagraphlessListItem: true) as NSString
                item = Markdown.trimEnd(item, "\n") as NSString
                if (!isInsideParagraphlessListItem) {
                    // only the outer-most item should run this, otherwise it's run multiple times for the inner ones
                    item = selfCopy.runSpanGamut(item as String) as NSString
                }
            }
            lastItemHadADoubleNewline = endsWithDoubleNewline
            return "<li>\(item)</li>\n"
        }
        
        self = selfCopy

        list = Regex.replace(list,
            pattern: pattern,
            evaluator: listItemEvaluator,
            options: RegexOptions.IgnorePatternWhitespace.union(RegexOptions.Multiline))

        _listLevel -= 1
        return list
    }

    fileprivate static let _codeBlock = Regex([
        "(?:\\n\\n|\\A\\n?)",
        "(                        # $1 = the code block -- one or more lines, starting with a space",
        "(?:",
        "    (?:\\p{Z}{\(_tabWidth)})       # Lines must start with a tab-width of spaces",
        "    .*\\n+",
        ")+",
        ")",
        "((?=^\\p{Z}{0,\(_tabWidth)}[^ \\t\\n])|\\Z) # Lookahead for non-space at line-start, or end of doc"
        ].joined(separator: "\n"),
        options: RegexOptions.Multiline.union(RegexOptions.IgnorePatternWhitespace))

    /// Turn Markdown 4-space indented code into HTML pre code blocks
    fileprivate func doCodeBlocks(_ text: String) -> String {
        let text = Markdown._codeBlock.replace(text) { self.codeBlockEvaluator($0) }
        return text
    }

    fileprivate func codeBlockEvaluator(_ match: Match) -> String {
        var codeBlock = match.valueOfGroupAtIndex(1)

        codeBlock = encodeCode(outdent(codeBlock as String)) as NSString
        codeBlock = Markdown._newlinesLeadingTrailing.replace(codeBlock as String, "") as NSString

        return "\n\n<pre><code>\(codeBlock)\n</code></pre>\n\n"
    }

    fileprivate static let _codeSpan = Regex([
        "(?<![\\\\`])   # Character before opening ` can't be a backslash or backtick",
        "(`+)           # $1 = Opening run of `",
        "(?!`)          # and no more backticks -- match the full run",
        "(.+?)          # $2 = The code block",
        "(?<!`)",
        "\\1",
        "(?!`)"
        ].joined(separator: "\n"),
        options: RegexOptions.IgnorePatternWhitespace.union(RegexOptions.Singleline))

    /// Turn Markdown `code spans` into HTML code tags
    fileprivate func doCodeSpans(_ text: String) -> String {
        //    * You can use multiple backticks as the delimiters if you want to
        //        include literal backticks in the code span. So, this input:
        //
        //        Just type ``foo `bar` baz`` at the prompt.
        //
        //        Will translate to:
        //
        //          <p>Just type <code>foo `bar` baz</code> at the prompt.</p>
        //
        //        There's no arbitrary limit to the number of backticks you
        //        can use as delimters. If you need three consecutive backticks
        //        in your code, use four for delimiters, etc.
        //
        //    * You can use spaces to get literal backticks at the edges:
        //
        //          ... type `` `bar` `` ...
        //
        //        Turns to:
        //
        //          ... type <code>`bar`</code> ...
        //

        return Markdown._codeSpan.replace(text) { self.codeSpanEvaluator($0) }
    }

    fileprivate func codeSpanEvaluator(_ match: Match) -> String {
        var span = match.valueOfGroupAtIndex(2)
        span = Regex.replace(span as String, pattern: "^\\p{Z}*", replacement: "") as NSString // leading whitespace
        span = Regex.replace(span as String, pattern: "\\p{Z}*$", replacement: "") as NSString // trailing whitespace
        span = encodeCode(span as String) as NSString
        span = saveFromAutoLinking(span as String) as NSString // to prevent auto-linking. Not necessary in code *blocks*, but in code spans.

        return "<code>\(span)</code>"
    }

    fileprivate static let _bold = Regex("(\\*\\*|__) (?=\\S) (.+?[*_]*) (?<=\\S) \\1",
        options: RegexOptions.IgnorePatternWhitespace.union(RegexOptions.Singleline))
    fileprivate static let _strictBold = Regex("(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)\\2(?=\\S)(.*?\\S)\\2\\2(?!\\2)(?=[\\W_]|$)",
        options: RegexOptions.Singleline)

    fileprivate static let _italic = Regex("(\\*|_) (?=\\S) (.+?) (?<=\\S) \\1",
        options: RegexOptions.IgnorePatternWhitespace.union(RegexOptions.Singleline))
    fileprivate static let _strictItalic = Regex("(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)(?=\\S)((?:(?!\\2).)*?\\S)\\2(?!\\2)(?=[\\W_]|$)",
        options: RegexOptions.Singleline)

    /// Turn Markdown *italics* and **bold** into HTML strong and em tags
    fileprivate func doItalicsAndBold(_ text: String) -> String {
        // <strong> must go first, then <em>
        var text = text
        if (_strictBoldItalic) {
            text = Markdown._strictBold.replace(text, "$1<strong>$3</strong>")
            text = Markdown._strictItalic.replace(text, "$1<em>$3</em>")
        }
        else {
            text = Markdown._bold.replace(text, "<strong>$2</strong>")
            text = Markdown._italic.replace(text, "<em>$2</em>")
        }
        return text
    }

    /// Turn markdown line breaks (two space at end of line) into HTML break tags
    fileprivate func doHardBreaks(_ text: String) -> String {
        var text = text
        if (_autoNewlines) {
            text = Regex.replace(text, pattern: "\\n", replacement: "<br\(_emptyElementSuffix)\n")
        }
        else {
            text = Regex.replace(text, pattern: " {2,}\n", replacement: "<br\(_emptyElementSuffix)\n")
        }
        return text
    }

    fileprivate static let _blockquote = Regex([
        "(                           # Wrap whole match in $1",
        "    (",
        "    ^\\p{Z}*>\\p{Z}?              # '>' at the start of a line",
        "        .+\\n               # rest of the first line",
        "    (.+\\n)*                # subsequent consecutive lines",
        "    \\n*                    # blanks",
        "    )+",
        ")"
        ].joined(separator: "\n"),
        options: RegexOptions.IgnorePatternWhitespace.union(RegexOptions.Multiline))


    /// Turn Markdown > quoted blocks into HTML blockquote blocks
    fileprivate mutating func doBlockQuotes(_ text: String) -> String {
        return Markdown._blockquote.replace(text) { self.blockQuoteEvaluator($0) }
    }

    fileprivate mutating func blockQuoteEvaluator(_ match: Match) -> String {
        var bq = match.valueOfGroupAtIndex(1) as String

        bq = Regex.replace(bq,
            pattern: "^\\p{Z}*>\\p{Z}?",
            replacement: "",
            options: RegexOptions.Multiline)       // trim one level of quoting
        bq = Regex.replace(bq,
            pattern: "^\\p{Z}+$",
            replacement: "",
            options: RegexOptions.Multiline)       // trim whitespace-only lines
        bq = runBlockGamut(bq)                     // recurse

        bq = Regex.replace(bq,
            pattern: "^",
            replacement: "  ",
            options: RegexOptions.Multiline)

        // These leading spaces screw with <pre> content, so we need to fix that:
        bq = Regex.replace(bq,
            pattern: "(\\s*<pre>.+?</pre>)",
            evaluator: { self.blockQuoteEvaluator2($0) },
            options: RegexOptions.IgnorePatternWhitespace.union(RegexOptions.Singleline))

        bq = "<blockquote>\n\(bq)\n</blockquote>"
        let key = Markdown.getHashKey(bq, isHtmlBlock: true)
        _htmlBlocks[key] = bq

        return "\n\n\(key)\n\n"
    }

    fileprivate func blockQuoteEvaluator2(_ match: Match) -> String {
        return Regex.replace(match.valueOfGroupAtIndex(1) as String,
            pattern: "^  ",
            replacement: "",
            options: RegexOptions.Multiline)
    }

    fileprivate static let _charInsideUrl = "[-A-Z0-9+&@#/%?=~_|\\[\\]\\(\\)!:,\\.;\u{1a}]"
    fileprivate static let _charEndingUrl = "[-A-Z0-9+&@#/%=~_|\\[\\])]"

    fileprivate static let _autolinkBare = Regex("(<|=\")?\\b(https?|ftp)(://\(_charInsideUrl)*\(_charEndingUrl))(?=$|\\W)",
        options: RegexOptions.IgnoreCase)

    fileprivate static let _endCharRegex = Regex(_charEndingUrl,
        options: RegexOptions.IgnoreCase)

    fileprivate static func handleTrailingParens(_ match: Match) -> String {
        // The first group is essentially a negative lookbehind -- if there's a < or a =", we don't touch this.
        // We're not using a *real* lookbehind, because of links with in links, like <a href="http://web.archive.org/web/20121130000728/http://www.google.com/">
        // With a real lookbehind, the full link would never be matched, and thus the http://www.google.com *would* be matched.
        // With the simulated lookbehind, the full link *is* matched (just not handled, because of this early return), causing
        // the google link to not be matched again.
        if !Markdown.isNilOrEmpty(match.valueOfGroupAtIndex(1)) {
            return match.value as String
        }

        let proto = match.valueOfGroupAtIndex(2)
        var link: NSString = match.valueOfGroupAtIndex(3)
        if !link.hasSuffix(")") {
            return "<\(proto)\(link)>"
        }
        var level = 0
        for c in Regex.matches(link as String, pattern: "[()]") {
            if c.value == "(" {
                if (level <= 0) {
                    level = 1
                }
                else {
                    level += 1
                }
            }
            else {
                level -= 1
            }
        }
        var tail: NSString = ""
        if level < 0 {
            link = Regex.replace(link as String, pattern: "\\){1,\(-level)}$", evaluator: { m in
                tail = m.value
                return ""
            }) as NSString
        }
        if tail.length > 0 {
            let lastChar = link.substring(from: link.length - 1)
            if !_endCharRegex.isMatch(lastChar) {
                tail = "\(lastChar)\(tail)" as NSString
                link = link.substring(to: link.length - 1) as NSString
            }
        }
        return "<\(proto)\(link)>\(tail)"
    }

    /// Turn angle-delimited URLs into HTML anchor tags
    ///
    /// &lt;http://www.example.com&gt;
    fileprivate func doAutoLinks(_ text: String) -> String {

        var text = text
        if (_autoHyperlink) {
            // fixup arbitrary URLs by adding Markdown < > so they get linked as well
            // note that at this point, all other URL in the text are already hyperlinked as <a href=""></a>
            // *except* for the <http://www.foo.com> case
            text = Markdown._autolinkBare.replace(text) { Markdown.handleTrailingParens($0) }
        }

        // Hyperlinks: <http://foo.com>
        text = Regex.replace(text, pattern: "<((https?|ftp):[^'\">\\s]+)>", evaluator: { self.hyperlinkEvaluator($0) })
        if (_linkEmails) {
            // Email addresses: <address@domain.foo>
            let pattern = [
                "<",
                "(?:mailto:)?",
                "(",
                "  [-.\\w]+",
                "  \\@",
                "  [-a-z0-9]+(\\.[-a-z0-9]+)*\\.[a-z]+",
                ")",
                ">"
                ].joined(separator: "\n")
            text = Regex.replace(text,
                pattern: pattern,
                evaluator: { self.emailEvaluator($0) },
                options: RegexOptions.IgnoreCase.union(RegexOptions.IgnorePatternWhitespace))
        }

        return text
    }

    fileprivate func hyperlinkEvaluator(_ match: Match) -> String {
        let link = match.valueOfGroupAtIndex(1)
        return "<a href=\"\(escapeBoldItalic(encodeProblemUrlChars(link as String)))\">\(link)</a>"
    }

    fileprivate func emailEvaluator(_ match: Match) -> String {
        var email = unescape(match.valueOfGroupAtIndex(1) as String)

        //
        //    Input: an email address, e.g. "foo@example.com"
        //
        //    Output: the email address as a mailto link, with each character
        //            of the address encoded as either a decimal or hex entity, in
        //            the hopes of foiling most address harvesting spam bots. E.g.:
        //
        //      <a href="&#x6D;&#97;&#105;&#108;&#x74;&#111;:&#102;&#111;&#111;&#64;&#101;
        //        x&#x61;&#109;&#x70;&#108;&#x65;&#x2E;&#99;&#111;&#109;">&#102;&#111;&#111;
        //        &#64;&#101;x&#x61;&#109;&#x70;&#108;&#x65;&#x2E;&#99;&#111;&#109;</a>
        //
        //    Based by a filter by Matthew Wickline, posted to the BBEdit-Talk
        //    mailing list: <http://tinyurl.com/yu7ue>
        //
        email = "mailto:" + email

        // leave ':' alone (to spot mailto: later)
        email = encodeEmailAddress(email)

        email = "<a href=\"\(email)\">\(email)</a>"

        // strip the mailto: from the visible part
        email = Regex.replace(email, pattern: "\">.+?:", replacement: "\">")
        return email
    }

    fileprivate static let _outDent = Regex("^\\p{Z}{1,\(_tabWidth)}",
        options: RegexOptions.Multiline)

    /// Remove one level of line-leading spaces
    fileprivate func outdent(_ block: String) -> String {
        return Markdown._outDent.replace(block, "")
    }

    /// encodes email address randomly
    /// roughly 10% raw, 45% hex, 45% dec
    /// note that @ is always encoded and : never is
    fileprivate func encodeEmailAddress(_ addr: String) -> String {
        var sb = ""
        let colon: UInt8 = 58 // ':'
        let at: UInt8 = 64    // '@'
        for c in addr.utf8 {
            let r = arc4random_uniform(99) + 1
            // TODO: verify that the following stuff works as expected in Swift
            if (r > 90 || c == colon) && c != at {
                sb += String(repeating: String(describing: UnicodeScalar(UInt32(c))), count: 1) // m
            } else if r < 45 {
                sb += NSString(format:"&#x%02x;", UInt(c)) as String                      // &#x6D
            } else {
                sb += "&#\(c);"                                                 // &#109
            }
        }
        return sb
    }

    fileprivate static let _codeEncoder = Regex("&|<|>|\\\\|\\*|_|\\{|\\}|\\[|\\]")

    /// Encode/escape certain Markdown characters inside code blocks and spans where they are literals
    fileprivate func encodeCode(_ code: String) -> String {
        return Markdown._codeEncoder.replace(code) { self.encodeCodeEvaluator($0) }
    }

    fileprivate func encodeCodeEvaluator(_ match: Match) -> String {
        switch (match.value) {
            // Encode all ampersands; HTML entities are not
            // entities within a Markdown code span.
        case "&":
            return "&amp;"
            // Do the angle bracket song and dance
        case "<":
            return "&lt;"
        case ">":
            return "&gt;"
            // escape characters that are magic in Markdown
        default:
            return Markdown._escapeTable[match.value as String]!
        }
    }

    // TODO: C# code uses RegexOptions.ExplicitCapture here. Need to figure out
    // how/whether to emulate that with NSRegularExpression.
    fileprivate static let _amps = Regex("&(?!((#[0-9]+)|(#[xX][a-fA-F0-9]+)|([a-zA-Z][a-zA-Z0-9]*));)")
    fileprivate static let _angles = Regex("<(?![A-Za-z/?\\$!])")

    /// Encode any ampersands (that aren't part of an HTML entity) and left or right angle brackets
    fileprivate func encodeAmpsAndAngles(_ s: String) -> String {
        var s = Markdown._amps.replace(s, "&amp;")
        s = Markdown._angles.replace(s, "&lt;")
        return s
    }

    fileprivate static var _backslashEscapes: Regex!

    /// Encodes any escaped characters such as \`, \*, \[ etc
    fileprivate func escapeBackslashes(_ s: String) -> String {
        return Markdown._backslashEscapes.replace(s) { self.escapeBackslashesEvaluator($0) }
    }
    fileprivate func escapeBackslashesEvaluator(_ match: Match) -> String {
        return Markdown._backslashEscapeTable[match.value as String]!
    }

    fileprivate static let _unescapes = Regex("\u{1A}E\\d+E")

    /// swap back in all the special characters we've hidden
    fileprivate func unescape(_ s: String) -> String {
        return Markdown._unescapes.replace(s) { self.unescapeEvaluator($0) }
    }
    fileprivate func unescapeEvaluator(_ match: Match) -> String {
        return Markdown._invertedEscapeTable[match.value as String]!
    }

    /// this is to emulate what's evailable in PHP
    fileprivate static func repeatString(_ text: String, _ count: Int) -> String {
        return Array(repeating: text, count: count).reduce("", +)
    }

    /// escapes Bold [ * ] and Italic [ _ ] characters
    fileprivate func escapeBoldItalic(_ s: String) -> String {
        var str = s as NSString
        if let escapeStars = Markdown._escapeTable["*"], let escapeUnderscore = Markdown._escapeTable["_"] {
            str = str.replacingOccurrences(of: "*", with: escapeStars) as NSString
            str = str.replacingOccurrences(of: "_", with: escapeUnderscore) as NSString
        }
        return str as String
    }

    fileprivate static let _problemUrlChars = CharacterSet(charactersIn: "\"'*()[]$:")

    /// hex-encodes some unusual "problem" chars in URLs to avoid URL detection problems
    fileprivate func encodeProblemUrlChars(_ url: String) -> String {
        if (!_encodeProblemUrlCharacters) { return url }

        var sb = ""
        var encode = false

        let str = url as NSString
        for i in 0..<str.length {
            let c = str.character(at: i)
            encode = Markdown._problemUrlChars.contains(UnicodeScalar(c)!)
            if (encode && c == U16_COLON && i < str.length - 1) {
                encode = !(str.character(at: i + 1) == U16_SLASH) &&
                    !(str.character(at: i + 1) >= U16_ZERO
                        && str.character(at: i + 1) <= U16_NINE)
            }

            if (encode) {
                sb += "%"
                sb += NSString(format:"%2x", UInt(c)) as String
            }
            else {
                sb += String(repeating: String(describing: UnicodeScalar(c)), count: 1)
            }
        }

        return sb
    }

    /// Within tags -- meaning between &lt; and &gt; -- encode [\ ` * _] so they
    /// don't conflict with their use in Markdown for code, italics and strong.
    /// We're replacing each such character with its corresponding hash
    /// value; this is likely overkill, but it should prevent us from colliding
    /// with the escape values by accident.
    fileprivate func escapeSpecialCharsWithinTagAttributes(_ text: String) -> String {
        let tokens = tokenizeHTML(text)

        // now, rebuild text from the tokens
        var sb = ""

        for token in tokens {
            var value = token.value

            if token.type == TokenType.tag {
                value = value.replacingOccurrences(of: "\\",
                    with: Markdown._escapeTable["\\"]!)

                if _autoHyperlink && value.hasPrefix("<!") { // escape slashes in comments to prevent autolinking there -- http://meta.stackoverflow.com/questions/95987/html-comment-containing-url-breaks-if-followed-by-another-html-comment
                    value = value.replacingOccurrences(of: "/",
                        with: Markdown._escapeTable["/"]!)
                }

                value = Regex.replace(value,
                    pattern: "(?<=.)</?code>(?=.)",
                    replacement: Markdown._escapeTable["`"]!)
                value = escapeBoldItalic(value)
            }

            sb += value
        }

        return sb
    }
    
    /// convert all tabs to _tabWidth spaces;
    /// standardizes line endings from DOS (CR LF) or Mac (CR) to UNIX (LF);
    /// makes sure text ends with a couple of newlines;
    /// removes any blank lines (only spaces) in the text
    fileprivate func normalize(_ text: String) -> String {
        var output = ""
        var line = ""
        var valid = false
        
        for i in text.characters.indices {
            let c = text[i]
            switch (c) {
            case "\n":
                if (valid) { output += line }
                output += "\n"
                line = ""
                valid = false
            case "\r":
                if (valid) { output += line }
                output += "\n"
                line = ""
                valid = false
            case "\r\n":
                if (valid) { output += line }
                output += "\n"
                line = ""
                valid = false
            case "\t":
                let width = Markdown._tabWidth - line.characters.count % Markdown._tabWidth
                for _ in 0..<width {
                    line += " "
                }
            default:
                if !valid && c != " " /* ' ' */ {
                    valid = true
                }
                line += String(repeating: String(c), count: 1)
                break
            }
        }
        
        if (valid) { output += line }
        output += "\n"
        
        // add two newlines to the end before return
        return output + "\n\n"
    }

    fileprivate static func attributeEncode(_ s: String) -> String {
        return s.replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    fileprivate static func doesString(_ string: NSString, containSubstring substring: NSString) -> Bool {
        let range = string.range(of: substring as String)
        return !(NSNotFound == range.location)
    }

    fileprivate static func trimEnd(_ string: NSString, _ suffix: NSString) -> String {
        var s = string
        while s.hasSuffix(suffix as String) {
            s = s.substring(to: s.length - suffix.length) as NSString
        }
        return s as String
    }

    fileprivate static func isNilOrEmpty(_ s: String?) -> Bool {
        switch s {
        case .some(let nonNilString):
            return nonNilString.isEmpty
        default:
            return true
        }
    }

    fileprivate static func isNilOrEmpty(_ s: NSString?) -> Bool {
        switch s {
        case .some(let nonNilString):
            return nonNilString.length == 0
        default:
            return true
        }
    }

    /// Convert UnicodeScalar to a 16-bit unichar value
    fileprivate static func unicharForUnicodeScalar(_ unicodeScalar: UnicodeScalar) -> unichar {
        let u32 = UInt32(unicodeScalar)
        if u32 <= UInt32(UINT16_MAX) {
            return unichar(u32)
        }
        else {
            assert(false, "value must be representable in 16 bits")
            return 0
        }
    }

    // unichar constants
    // (Unfortunate that Swift doesn't provide easy single-character literals)
    fileprivate let U16_COLON   = Markdown.unicharForUnicodeScalar(":"  as UnicodeScalar)
    fileprivate let U16_SLASH   = Markdown.unicharForUnicodeScalar("/"  as UnicodeScalar)
    fileprivate let U16_ZERO    = Markdown.unicharForUnicodeScalar("0"  as UnicodeScalar)
    fileprivate let U16_NINE    = Markdown.unicharForUnicodeScalar("9"  as UnicodeScalar)
    fileprivate let U16_NEWLINE = Markdown.unicharForUnicodeScalar("\n" as UnicodeScalar)
    fileprivate let U16_RETURN  = Markdown.unicharForUnicodeScalar("\r" as UnicodeScalar)
    fileprivate let U16_TAB     = Markdown.unicharForUnicodeScalar("\t" as UnicodeScalar)
    fileprivate let U16_SPACE   = Markdown.unicharForUnicodeScalar(" "  as UnicodeScalar)
}

/// Private wrapper for NSRegularExpression that provides interface
/// similar to that of .NET's Regex class.
///
/// This is intended only for use by the Markdown parser. It is not
/// a general-purpose regex utility.
private struct MarkdownRegex {
    fileprivate let regularExpresson: NSRegularExpression!

    #if MARKINGBIRD_DEBUG
    // These are not used, but can be helpful when debugging
    private var initPattern: NSString
    private var initOptions: NSRegularExpression.Options
    #endif

    fileprivate init(_ pattern: String, options: NSRegularExpression.Options = NSRegularExpression.Options(rawValue: 0)) {
        #if MARKINGBIRD_DEBUG
            self.initPattern = pattern as NSString
            self.initOptions = options
        #endif

        var error: NSError?
        let re: NSRegularExpression?
        do {
            re = try NSRegularExpression(pattern: pattern,
                        options: options)
        } catch let error1 as NSError {
            error = error1
            re = nil
        }

        // If re is nil, it means NSRegularExpression didn't like
        // the pattern we gave it.  All regex patterns used by Markdown
        // should be valid, so this probably means that a pattern
        // valid for .NET Regex is not valid for NSRegularExpression.
        if re == nil {
            if let error = error {
                print("Regular expression error: \(error.userInfo)")
            }
            assert(re != nil)
        }

        self.regularExpresson = re
    }

    fileprivate func replace(_ input: String, _ replacement: String) -> String {
        let s = input as NSString
        let result = regularExpresson.stringByReplacingMatches(in: s as String,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, s.length),
            withTemplate: replacement)
        return result
    }

    fileprivate static func replace(_ input: String, pattern: String, replacement: String) -> String {
        let regex = MarkdownRegex(pattern)
        return regex.replace(input, replacement)
    }

    fileprivate func replace(_ input: String, evaluator: (MarkdownRegexMatch) -> String) -> String {
        // Get list of all replacements to be made
        var replacements = Array<(NSRange, String)>()
        let s = input as NSString
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = NSMakeRange(0, s.length)
        regularExpresson.enumerateMatches(in: s as String,
            options: options,
            range: range,
            using: { (result, flags, stop) -> Void in
                if result!.range.location == NSNotFound {
                    return
                }
                let match = MarkdownRegexMatch(textCheckingResult: result!, string: s)
                let range = result!.range
                let replacementText = evaluator(match)
                let replacement = (range, replacementText)
                replacements.append(replacement)
        })

        // Make the replacements from back to front
        var result = s
        for (range, replacementText) in Array(replacements.reversed()) {
            result = result.replacingCharacters(in: range, with: replacementText) as NSString
        }
        return result as String
    }

    fileprivate static func replace(_ input: String, pattern: String, evaluator: (MarkdownRegexMatch) -> String) -> String {
        let regex = MarkdownRegex(pattern)
        return regex.replace(input, evaluator: evaluator)
    }

    fileprivate static func replace(_ input: String, pattern: String, evaluator: (MarkdownRegexMatch) -> String, options: NSRegularExpression.Options) -> String {
        let regex = MarkdownRegex(pattern, options: options)
        return regex.replace(input, evaluator: evaluator)
    }

    fileprivate static func replace(_ input: String, pattern: String, replacement: String, options: NSRegularExpression.Options) -> String {
        let regex = MarkdownRegex(pattern, options: options)
        return regex.replace(input, replacement)
    }

    fileprivate func matches(_ input: String) -> [MarkdownRegexMatch] {
        var matchArray = Array<MarkdownRegexMatch>()

        let s = input as NSString
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = NSMakeRange(0, s.length)
        regularExpresson.enumerateMatches(in: s as String,
            options: options,
            range: range,
            using: { (result, flags, stop) -> Void in
                let match = MarkdownRegexMatch(textCheckingResult: result!, string: s)
                matchArray.append(match)
        })

        return matchArray
    }

    fileprivate static func matches(_ input: String, pattern: String) -> [MarkdownRegexMatch] {
        let regex = MarkdownRegex(input)
        return regex.matches(pattern)
    }

    fileprivate func isMatch(_ input: String) -> Bool {
        let s = input as NSString
        let firstMatchRange = regularExpresson.rangeOfFirstMatch(in: s as String,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, s.length))
        return !(NSNotFound == firstMatchRange.location)
    }

    fileprivate static func isMatch(_ input: String, pattern: String) -> Bool {
        let regex = MarkdownRegex(pattern)
        return regex.isMatch(input)
    }

    fileprivate func split(_ input: String) -> [String] {
        var stringArray: [String] = Array<String>()

        var nextStartIndex = 0

        let s = input as NSString
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = NSMakeRange(0, s.length)
        regularExpresson.enumerateMatches(in: input,
            options: options,
            range: range,
            using: { (result, flags, stop) -> Void in
                let range = result!.range
                if range.location > nextStartIndex {
                    let runRange = NSMakeRange(nextStartIndex, range.location - nextStartIndex)
                    let run = s.substring(with: runRange) as String
                    stringArray.append(run)
                    nextStartIndex = range.location + range.length
                }
        })

        if nextStartIndex < s.length {
            let lastRunRange = NSMakeRange(nextStartIndex, s.length - nextStartIndex)
            let lastRun = s.substring(with: lastRunRange) as String
            stringArray.append(lastRun)
        }

        return stringArray
    }

    fileprivate static func escape(_ input: String) -> String {
        return NSRegularExpression.escapedPattern(for: input)
    }
}

/// Provides interface similar to that of .NET's Match class for an NSTextCheckingResult
private struct MarkdownRegexMatch {
    let textCheckingResult: NSTextCheckingResult
    let string: NSString

    init(textCheckingResult: NSTextCheckingResult, string: NSString) {
        self.textCheckingResult = textCheckingResult
        self.string = string
    }

    var value: NSString {
        return string.substring(with: textCheckingResult.range) as NSString
    }

    var index: Int {
        return textCheckingResult.range.location
    }

    var length: Int {
        return textCheckingResult.range.length
    }

    func valueOfGroupAtIndex(_ idx: Int) -> NSString {
        if 0 <= idx && idx < textCheckingResult.numberOfRanges {
            let groupRange = textCheckingResult.rangeAt(idx)
            if (groupRange.location == NSNotFound) {
                return ""
            }
            assert(groupRange.location + groupRange.length <= string.length, "range must be contained within string")
            return string.substring(with: groupRange) as NSString
        }
        return ""
    }
}

/// Defines .NET-style synonyms for NSRegularExpressionOptions values
///
/// - Multiline
/// - IgnorePatternWhitespace
/// - Singleline
/// - IgnoreCase
/// - None
///
/// Note: NSRegularExpressionOptions does not provide equivalents to
/// these .NET RegexOptions values used in the original C# source:
///
/// - Compile
/// - ExplicitCapture
private struct MarkdownRegexOptions {
    /// Allow ^ and $ to match the start and end of lines.
    static let Multiline = NSRegularExpression.Options.anchorsMatchLines

    /// Ignore whitespace and #-prefixed comments in the pattern.
    static let IgnorePatternWhitespace = NSRegularExpression.Options.allowCommentsAndWhitespace

    /// Allow . to match any character, including line separators.
    static let Singleline = NSRegularExpression.Options.dotMatchesLineSeparators

    /// Match letters in the pattern independent of case.
    static let IgnoreCase = NSRegularExpression.Options.caseInsensitive

    /// Default options
    static let None = NSRegularExpression.Options(rawValue: 0)
}
