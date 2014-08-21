import Cocoa
import XCTest
import Markingbird

class MDTestTests: XCTestCase {

    let folder = "testfiles/mdtest-1.1"
    
    /// For each .text file in testfiles/mdtest-1.1, invoke the Markdown transformation
    /// and then compare the result with the corresponding .html file
    func testTests() {
        for test in getTests() {
            println("Actual: \(test.actualName); Expected: \(test.expectedName)")
            XCTAssertEqual(test.actualResult, test.expectedResult,
                "Mismatch between '\(test.actualName)' and the transformed '\(test.expectedName)'")
        }
    }

    struct TestCaseData {
        var actualName: String
        var expectedName: String
        var actualResult: String
        var expectedResult: String
        
        init(actualName: String, expectedName: String, actualResult: String, expectedResult: String) {
            self.actualName = actualName
            self.expectedName = expectedName
            self.actualResult = actualResult
            self.expectedResult = expectedResult
        }
    }
    
    func getTests() -> [TestCaseData] {
        var tests = Array<TestCaseData>()
        
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
                    // Load the expected result content
                    let expectedName = filename
                    let expectedPath = folderPath.stringByAppendingPathComponent(expectedName)
                    let expectedContent = NSString(contentsOfFile: expectedPath,
                        encoding: NSUTF8StringEncoding,
                        error: &error)
                    XCTAssertNil(error)
                    
                    // Load the source content
                    let actualName = expectedName.stringByDeletingPathExtension.stringByAppendingPathExtension("text")!
                    let sourcePath = folderPath.stringByAppendingPathComponent(actualName)
                    let sourceContent = NSString(contentsOfFile: sourcePath,
                        encoding: NSUTF8StringEncoding,
                        error: &error)
                    XCTAssertNil(error)
                    
                    // Transform the source into the actual result, and
                    // normalize both the actual and expected results
                    var m = Markdown()                    
                    let actualResult = removeWhitespace(m.transform(sourceContent))
                    let expectedResult = removeWhitespace(expectedContent)
                    
                    let testCaseData = TestCaseData(
                        actualName: actualName,
                        expectedName: expectedName,
                        actualResult: actualResult,
                        expectedResult: expectedResult)
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
        let newlineRegex = NSRegularExpression(
            pattern: "^\\n",
            options: NSRegularExpressionOptions.AnchorsMatchLines,
            error: &error)
        XCTAssertNil(error)
        str = newlineRegex.stringByReplacingMatchesInString(str, options: NSMatchingOptions(0), range: NSMakeRange(0, str.length), withTemplate: "")
    
        // remove leading space at the start of lines
        let leadingSpaceRegex = NSRegularExpression(
            pattern: "^\\s+",
            options: NSRegularExpressionOptions.AnchorsMatchLines,
            error: &error);
        str = leadingSpaceRegex.stringByReplacingMatchesInString(str, options: NSMatchingOptions(0), range: NSMakeRange(0, str.length), withTemplate: "")
    
        // remove all newlines
        str = str.stringByReplacingOccurrencesOfString("\n", withString: "")
    
        return str as String
    }
}
