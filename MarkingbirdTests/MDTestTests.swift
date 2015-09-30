import Cocoa
import XCTest
import Markingbird

class MDTestTests: XCTestCase {

    let folder = "testfiles/mdtest-1.1"
    
    /// For each .text file in testfiles/mdtest-1.1, invoke the Markdown transformation
    /// and then compare the result with the corresponding .html file
    func testTests() {
        for test in getTests() {
            
            // If there is a difference, print it in a more readable way than
            // XCTest does
            switch firstDifferenceBetweenStrings(test.actualResult, s2: test.expectedResult) {
            case .NoDifference:
                break;
            case .DifferenceAtIndex:
                let prettyDiff = prettyFirstDifferenceBetweenStrings(test.actualResult, s2: test.expectedResult)
                print("\n====\n\(test.actualName): \(prettyDiff)\n====\n")
            }
            
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
        let resourceURL = bundle.resourceURL!
        let folderURL = resourceURL.URLByAppendingPathComponent(folder)
        
        let folderContents: [AnyObject]?
        do {
            folderContents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderURL.path!)
        } catch {
            XCTAssertNil(error)
            folderContents = nil
        }
        XCTAssertNotNil(folderContents)
        XCTAssertEqual(49, folderContents!.count, "should find 49 files in the testfiles/mdtest-1.1 directory")
        
        for object in folderContents! {
            if let filename = object as? String {
                if filename.hasSuffix(".html") {
                    // Load the expected result content
                    let expectedName = filename
                    
                    let expectedURL = folderURL.URLByAppendingPathComponent(expectedName)
                    let expectedContent: String?
                    do {
                        expectedContent = try String(contentsOfURL: expectedURL, encoding: NSUTF8StringEncoding)
                    } catch {
                        XCTAssertNil(error)
                        expectedContent = nil
                    }
                    
                    // Load the source content
                    let actualName = NSURL(string: expectedName)!.URLByDeletingPathExtension?.URLByAppendingPathExtension("text").path
                    let sourceURL = folderURL.URLByAppendingPathComponent(actualName!)
                    let sourceContent: String?
                    do {
                        sourceContent = try String(contentsOfURL: sourceURL, encoding: NSUTF8StringEncoding)
                    } catch {
                        XCTAssertNil(error)
                        sourceContent = nil
                    }
                    
                    if sourceContent != nil {
                        // Transform the source into the actual result, and
                        // normalize both the actual and expected results
                        var m = Markdown()                    
                        let actualResult = removeWhitespace(m.transform(sourceContent!))
                        let expectedResult = removeWhitespace(expectedContent!)
                        
                        let testCaseData = TestCaseData(
                            actualName: actualName!,
                            expectedName: expectedName,
                            actualResult: actualResult,
                            expectedResult: expectedResult)
                        tests.append(testCaseData)
                    }
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
        let newlineRegex: NSRegularExpression?
        do {
            newlineRegex = try NSRegularExpression(
                        pattern: "^\\n",
                        options: NSRegularExpressionOptions.AnchorsMatchLines)
        } catch {
            XCTAssertNil(error)
            newlineRegex = nil
        }
        str = newlineRegex!.stringByReplacingMatchesInString(str as String, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, str.length), withTemplate: "")
    
        // remove leading space at the start of lines
        let leadingSpaceRegex: NSRegularExpression?
        do {
            leadingSpaceRegex = try NSRegularExpression(
                        pattern: "^\\s+",
                        options: NSRegularExpressionOptions.AnchorsMatchLines)
        } catch {
            XCTAssertNil(error)
            leadingSpaceRegex = nil
        };
        str = leadingSpaceRegex!.stringByReplacingMatchesInString(str as String, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, str.length), withTemplate: "")
    
        // remove all newlines
        str = str.stringByReplacingOccurrencesOfString("\n", withString: "")
    
        return str as String
    }
}
