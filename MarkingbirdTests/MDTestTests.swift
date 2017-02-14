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
            switch firstDifferenceBetweenStrings(test.actualResult as NSString, s2: test.expectedResult as NSString) {
            case .noDifference:
                break;
            case .differenceAtIndex:
                let prettyDiff = prettyFirstDifferenceBetweenStrings(test.actualResult as NSString, s2: test.expectedResult as NSString)
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
        
        let bundle = Bundle(for: MDTestTests.self)
        let resourceURL = bundle.resourceURL!
        let folderURL = resourceURL.appendingPathComponent(folder)
        
        let folderContents: [AnyObject]?
        do {
            folderContents = try FileManager.default.contentsOfDirectory(atPath: folderURL.path) as [AnyObject]?
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
                    
                    let expectedURL = folderURL.appendingPathComponent(expectedName)
                    let expectedContent: String?
                    do {
                        expectedContent = try String(contentsOf: expectedURL, encoding: String.Encoding.utf8)
                    } catch {
                        XCTAssertNil(error)
                        expectedContent = nil
                    }
                    
                    // Load the source content
                    let actualName = NSURL(string: expectedName)!.deletingPathExtension?.appendingPathExtension("text").path
                    let sourceURL = folderURL.appendingPathComponent(actualName!)
                    let sourceContent: String?
                    do {
                        sourceContent = try String(contentsOf: sourceURL, encoding: String.Encoding.utf8)
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
    func removeWhitespace(_ s: String) -> String {
        var str = s as NSString
        
        // Standardize line endings
        str = str.replacingOccurrences(of: "\r\n", with: "\n") as NSString    // DOS to Unix
        str = str.replacingOccurrences(of: "\r", with:"\n") as NSString       // Mac to Unix
    
        // remove any tabs entirely
        str = str.replacingOccurrences(of: "\t", with: "") as NSString
    
        // remove empty newlines
        let newlineRegex: NSRegularExpression?
        do {
            newlineRegex = try NSRegularExpression(
                        pattern: "^\\n",
                        options: NSRegularExpression.Options.anchorsMatchLines)
        } catch {
            XCTAssertNil(error)
            newlineRegex = nil
        }
        str = newlineRegex!.stringByReplacingMatches(in: str as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.length), withTemplate: "") as NSString
    
        // remove leading space at the start of lines
        let leadingSpaceRegex: NSRegularExpression?
        do {
            leadingSpaceRegex = try NSRegularExpression(
                        pattern: "^\\s+",
                        options: NSRegularExpression.Options.anchorsMatchLines)
        } catch {
            XCTAssertNil(error)
            leadingSpaceRegex = nil
        };
        str = leadingSpaceRegex!.stringByReplacingMatches(in: str as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.length), withTemplate: "") as NSString
    
        // remove all newlines
        str = str.replacingOccurrences(of: "\n", with: "") as NSString
    
        return str as String
    }
}
