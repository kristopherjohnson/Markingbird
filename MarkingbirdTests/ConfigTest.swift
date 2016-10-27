import XCTest
import Markingbird

class ConfigTest: XCTestCase {

    func testOptions() {
        var options = MarkdownOptions()
        options.autoHyperlink = true
        options.autoNewlines = true
        options.emptyElementSuffix = ">"
        options.encodeProblemUrlCharacters = true
        options.linkEmails = false
        options.strictBoldItalic = true
        
        var markdown = Markdown(options: options)
        XCTAssertEqual(true, markdown.autoHyperlink)
        XCTAssertEqual(true, markdown.autoNewLines)
        XCTAssertEqual(">", markdown.emptyElementSuffix)
        XCTAssertEqual(true, markdown.encodeProblemUrlCharacters)
        XCTAssertEqual(false, markdown.linkEmails)
        XCTAssertEqual(true, markdown.strictBoldItalic)
    }

    func testNoOptions() {
        for markdown in [Markdown(), Markdown(options: nil)] {
            XCTAssertEqual(false, markdown.autoHyperlink)
            XCTAssertEqual(false, markdown.autoNewLines)
            XCTAssertEqual(" />", markdown.emptyElementSuffix)
            XCTAssertEqual(false, markdown.encodeProblemUrlCharacters)
            XCTAssertEqual(true, markdown.linkEmails)
            XCTAssertEqual(false, markdown.strictBoldItalic)
        }
    }
    
    func testAutoHyperlink() {
        var markdown = Markdown()
        XCTAssertFalse(markdown.autoHyperlink);
        XCTAssertEqual("<p>foo http://example.com bar</p>\n",
            markdown.transform("foo http://example.com bar"))
        
        markdown.autoHyperlink = true
        XCTAssertEqual("<p>foo <a href=\"http://example.com\">http://example.com</a> bar</p>\n",
            markdown.transform("foo http://example.com bar"))
    }
    
    func testAutoNewLines() {
        var markdown = Markdown()
        XCTAssertFalse(markdown.autoNewLines)
        XCTAssertEqual("<p>Line1\nLine2</p>\n",
            markdown.transform("Line1\nLine2"))
        
        markdown.autoNewLines = true
        XCTAssertEqual("<p>Line1<br />\nLine2</p>\n",
            markdown.transform("Line1\nLine2"))
    }
    
    func testEmptyElementSuffix() {
        var markdown = Markdown()
        XCTAssertEqual(" />", markdown.emptyElementSuffix)
        XCTAssertEqual("<hr />\n",
            markdown.transform("* * *"))
        
        markdown.emptyElementSuffix = ">"
        XCTAssertEqual("<hr>\n", markdown.transform("* * *"))
    }
    
    func testEncodeProblemUrlCharacters() {
        var markdown = Markdown()
        XCTAssertFalse(markdown.encodeProblemUrlCharacters)
        XCTAssertEqual("<p><a href=\"/'*_[]()/\">Foo</a></p>\n",
            markdown.transform("[Foo](/'*_[]()/)"))
        
        // Note: MarkdownSharp's test expects '_' to be
        // encoded, but that test has apparently not been
        // updated to match MarkdownSharp.cs change that
        // removed underscore from list of problem characters.
        markdown.encodeProblemUrlCharacters = true
        XCTAssertEqual("<p><a href=\"/%27%2a_%5b%5d%28%29/\">Foo</a></p>\n",
            markdown.transform("[Foo](/'*_[]()/)"))
    }
    
    func testLinkEmails() {
        var markdown = Markdown()
        XCTAssertTrue(markdown.linkEmails)
        XCTAssertEqual("<p><a href=\"&#",
            (markdown.transform("<aa@bb.com>") as NSString).substring(with: NSMakeRange(0, 14)))
        
        markdown.linkEmails = false
        XCTAssertEqual("<p><aa@bb.com></p>\n", markdown.transform("<aa@bb.com>"))
    }
    
    func testStrictBoldItalic() {
        var markdown = Markdown()
        XCTAssertFalse(markdown.strictBoldItalic)
        XCTAssertEqual("<p>before<strong>bold</strong>after before<em>italic</em>after</p>\n",
            markdown.transform("before**bold**after before_italic_after"))
        
        markdown.strictBoldItalic = true
        XCTAssertEqual("<p>before*bold*after before_italic_after</p>\n",
            markdown.transform("before*bold*after before_italic_after"))
    }
}
