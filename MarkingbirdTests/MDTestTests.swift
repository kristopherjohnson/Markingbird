import Cocoa
import XCTest
import Markingbird

class MDTestTests: XCTestCase {

    let folder = "testfiles/mdtest-1.1"
    
    /// For each .text file in testfiles/mdtest-1.1, invoke the Markdown transformation
    /// and then compare the result with the corresponding .html file
    func testTests() {
        for test in getTests() {
            XCTAssertEqual(test.actualContent, test.expectedContent,
                "Mismatch between '\(test.actualName)' and the transformed '\(test.expectedName)'")
        }
    }

    struct TestCaseData {
        var actualName: String
        var expectedName: String
        var actualContent: String
        var expectedContent: String
        
        init(actualName: String, expectedName: String, actualContent: String, expectedContent: String) {
            self.actualName = actualName
            self.expectedName = expectedName
            self.actualContent = actualContent
            self.expectedContent = expectedContent
        }
    }
    
    func getTests() -> [TestCaseData] {
        var tests = Array<TestCaseData>()
        
        var m = Markdown()
        
        let bundle = NSBundle(forClass: MDTestTests.self)
        let resourcePath = bundle.resourcePath!
        let folderPath = resourcePath.stringByAppendingPathComponent(folder)
        
        var error: NSError?
        let folderContents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath, error: &error)
        XCTAssertNil(error)
        XCTAssertNotNil(folderContents)
        XCTAssertEqual(49, folderContents!.count, "should find 49 files in the testfiles/mdtest-1.1 directory")
        
        for object in folderContents! {
            if let filename = object as? String {
                if filename.hasSuffix(".html") {
                    let expectedName = filename
                    let expectedPath = folderPath.stringByAppendingPathComponent(expectedName)
                    let actualName = expectedName.stringByDeletingPathExtension.stringByAppendingPathExtension("text")!
                    let actualPath = folderPath.stringByAppendingPathComponent(actualName)
                    
                    let expectedContent = NSString(contentsOfFile: expectedPath,
                        encoding: NSUTF8StringEncoding,
                        error: &error)
                    XCTAssertNil(error)
                    
                    let actualContent = m.transform(expectedContent)
                    
                    let expectedNormalized = removeWhitespace(expectedContent)
                    let actualNormalized = removeWhitespace(actualContent)
                    
                    let testCaseData = TestCaseData(
                        actualName: actualName,
                        expectedName: expectedName,
                        actualContent: actualNormalized,
                        expectedContent: expectedNormalized)
                    tests.append(testCaseData)
                }
            }
        }
        
        return tests
    }
    
    /// Removes any empty newlines and any leading spaces at the start of lines
    /// all tabs, and all carriage returns
    func removeWhitespace(s: String) -> String {
        var str = s as NSString
        
        // Standardize line endings
        str = str.stringByReplacingOccurrencesOfString("\r\n", withString: "\n")    // DOS to Unix
        str = str.stringByReplacingOccurrencesOfString("\r", withString:"\n")       // Mac to Unix
    
        // remove any tabs entirely
        str = str.stringByReplacingOccurrencesOfString("\t", withString: "")
    
        // remove empty newlines
        var error: NSError?
        let newlineRegex = NSRegularExpression(pattern: "^\\n", options: NSRegularExpressionOptions.AnchorsMatchLines, error: &error);
        str = newlineRegex.stringByReplacingMatchesInString(str, options: NSMatchingOptions(0), range: NSMakeRange(0, str.length), withTemplate: "")
    
        // remove leading space at the start of lines
        let leadingSpaceRegex = NSRegularExpression(pattern: "^\\s+", options: NSRegularExpressionOptions.AnchorsMatchLines, error: &error);
        str = leadingSpaceRegex.stringByReplacingMatchesInString(str, options: NSMatchingOptions(0), range: NSMakeRange(0, str.length), withTemplate: "")
    
        // remove all newlines
        str = str.stringByReplacingOccurrencesOfString("\n", withString: "")
    
        return str as String
    }
}
