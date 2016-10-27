import Markingbird
import XCTest

class SimpleTests: XCTestCase {
    
    fileprivate var m: Markdown!
    
    override func setUp() {
        // Create a new instance for each test
        m = Markdown()
    }
    
    func testBold()
    {
        let input = "This is **bold**. This is also __bold__."
        let expected = "<p>This is <strong>bold</strong>. This is also <strong>bold</strong>.</p>\n"
        
        let actual = m.transform(input)
        XCTAssertEqual(expected, actual)
    }
    
    func testItalic()
    {
        let input = "This is *italic*. This is also _italic_."
        let expected = "<p>This is <em>italic</em>. This is also <em>italic</em>.</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testLink()
    {
        let input = "This is [a link][1].\n\n  [1]: http://www.example.com"
        let expected = "<p>This is <a href=\"http://www.example.com\">a link</a>.</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testLinkBracket()
    {
        let input = "Have you visited <http://www.example.com> before?"
        let expected = "<p>Have you visited <a href=\"http://www.example.com\">http://www.example.com</a> before?</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testLinkBare_withoutAutoHyperLink()
    {
        let input = "Have you visited http://www.example.com before?"
        let expected = "<p>Have you visited http://www.example.com before?</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    /*
    func testLinkBare_withAutoHyperLink()
    {
        //TODO: implement some way of setting AutoHyperLink programmatically
        //to run this test now, just change the _autoHyperlink constant in Markdown.cs
        let input = "Have you visited http://www.example.com before?"
        let expected = "<p>Have you visited <a href=\"http://www.example.com\">http://www.example.com</a> before?</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }*/
    
    func testLinkAlt()
    {
        let input = "Have you visited [example](http://www.example.com) before?"
        let expected = "<p>Have you visited <a href=\"http://www.example.com\">example</a> before?</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testImage()
    {
        let input = "An image goes here: ![alt text][1]\n\n  [1]: http://www.google.com/intl/en_ALL/images/logo.gif"
        let expected = "<p>An image goes here: <img src=\"http://www.google.com/intl/en_ALL/images/logo.gif\" alt=\"alt text\" /></p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testBlockquote()
    {
        let input = "Here is a quote\n\n> Sample blockquote\n"
        let expected = "<p>Here is a quote</p>\n\n<blockquote>\n  <p>Sample blockquote</p>\n</blockquote>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }

    #if true // This test leads to "fatal error: unexpectedly found nil while unwrapping an Optional value
    func testNumberList()
    {
        let input = "A numbered list:\n\n1. a\n2. b\n3. c\n";
        let expected = "<p>A numbered list:</p>\n\n<ol>\n<li>a</li>\n<li>b</li>\n<li>c</li>\n</ol>\n";
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    #endif
    
    func testBulletList()
    {
        let input = "A bulleted list:\n\n- a\n- b\n- c\n"
        let expected = "<p>A bulleted list:</p>\n\n<ul>\n<li>a</li>\n<li>b</li>\n<li>c</li>\n</ul>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testHeader1()
    {
        let input = "#Header 1\nHeader 1\n========"
        let expected = "<h1>Header 1</h1>\n\n<h1>Header 1</h1>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testHeader2()
    {
        let input = "##Header 2\nHeader 2\n--------"
        let expected = "<h2>Header 2</h2>\n\n<h2>Header 2</h2>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testCodeBlock()
    {
        let input = "code sample:\n\n    <head>\n    <title>page title</title>\n    </head>\n"
        let expected = "<p>code sample:</p>\n\n<pre><code>&lt;head&gt;\n&lt;title&gt;page title&lt;/title&gt;\n&lt;/head&gt;\n</code></pre>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testCodeSpan()
    {
        let input = "HTML contains the `<blink>` tag"
        let expected = "<p>HTML contains the <code>&lt;blink&gt;</code> tag</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testHtmlPassthrough()
    {
        let input = "<div>\nHello World!\n</div>\n"
        let expected = "<div>\nHello World!\n</div>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testEscaping()
    {
        let input = "\\`foo\\`";
        let expected = "<p>`foo`</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testHorizontalRule()
    {
        let input = "* * *\n\n***\n\n*****\n\n- - -\n\n---------------------------------------\n\n"
        let expected = "<hr />\n\n<hr />\n\n<hr />\n\n<hr />\n\n<hr />\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testNormalizeCR()
    {
        let input = "# Header\r\rBody"
        let expected = "<h1>Header</h1>\n\n<p>Body</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testNormalizeCRLF()
    {
        let input = "# Header\r\n\r\nBody"
        let expected = "<h1>Header</h1>\n\n<p>Body</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testNormalizeLF()
    {
        let input = "# Header\n\nBody"
        let expected = "<h1>Header</h1>\n\n<p>Body</p>\n"
        
        let actual = m.transform(input)
        
        XCTAssertEqual(expected, actual)
    }
}
