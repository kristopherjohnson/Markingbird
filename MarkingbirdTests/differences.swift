import Foundation


/// Find first differing character between two strings
///
/// - parameter s1: First String
/// - parameter s2: Second String
///
/// - returns: .DifferenceAtIndex(i) or .NoDifference
public func firstDifferenceBetweenStrings(_ s1: NSString, s2: NSString) -> FirstDifferenceResult {
    let len1 = s1.length
    let len2 = s2.length
    
    let lenMin = min(len1, len2)
    
    for i in 0..<lenMin {
        if s1.character(at: i) != s2.character(at: i) {
            return .differenceAtIndex(i)
        }
    }
    
    if len1 < len2 {
        return .differenceAtIndex(len1)
    }

    if len2 < len1 {
        return .differenceAtIndex(len2)
    }

    return .noDifference
}


/// Create a formatted String representation of difference between strings
///
/// - parameter s1: First string
/// - parameter s2: Second string
///
/// - returns: a string, possibly containing significant whitespace and newlines
public func prettyFirstDifferenceBetweenStrings(_ s1: NSString, s2: NSString) -> NSString {
    let firstDifferenceResult = firstDifferenceBetweenStrings(s1, s2: s2)
    return prettyDescriptionOfFirstDifferenceResult(firstDifferenceResult, s1: s1, s2: s2)
}


/// Create a formatted String representation of a FirstDifferenceResult for two strings
///
/// - parameter firstDifferenceResult: FirstDifferenceResult
/// - parameter s1: First string used in generation of firstDifferenceResult
/// - parameter s2: Second string used in generation of firstDifferenceResult
///
/// - returns: a printable string, possibly containing significant whitespace and newlines
public func prettyDescriptionOfFirstDifferenceResult(_ firstDifferenceResult: FirstDifferenceResult, s1: NSString, s2: NSString) -> NSString {

    func diffString(_ index: Int, s1: NSString, s2: NSString) -> NSString {
        let markerArrow = "\u{2b06}"  // "⬆"
        let ellipsis    = "\u{2026}"  // "…"

        /// Given a string and a range, return a string representing that substring.
        ///
        /// If the range starts at a position other than 0, an ellipsis
        /// will be included at the beginning.
        ///
        /// If the range ends before the actual end of the string,
        /// an ellipsis is added at the end.
        func windowSubstring(_ s: NSString, range: NSRange) -> String {
            let validRange = NSMakeRange(range.location, min(range.length, s.length - range.location))
            let substring = s.substring(with: validRange)

            let prefix = range.location > 0 ? ellipsis : ""
            let suffix = (s.length - range.location > range.length) ? ellipsis : ""

            return "\(prefix)\(substring)\(suffix)"
        }

        // Show this many characters before and after the first difference
        let windowPrefixLength = 10
        let windowSuffixLength = 10
        let windowLength = windowPrefixLength + 1 + windowSuffixLength

        let windowIndex = max(index - windowPrefixLength, 0)
        let windowRange = NSMakeRange(windowIndex, windowLength)

        let sub1 = windowSubstring(s1, range: windowRange)
        let sub2 = windowSubstring(s2, range: windowRange)

        let markerPosition = min(windowSuffixLength, index) + (windowIndex > 0 ? 1 : 0)

        let markerPrefix = String(repeating: " ", count: markerPosition)
        let markerLine = "\(markerPrefix)\(markerArrow)"

        return "Difference at index \(index):\n\(sub1)\n\(sub2)\n\(markerLine)" as NSString
    }

    switch firstDifferenceResult {
    case .noDifference:                 return "No difference"
    case .differenceAtIndex(let index): return diffString(index, s1: s1, s2: s2)
    }
}


/// Result type for firstDifferenceBetweenStrings()
public enum FirstDifferenceResult {
    /// Strings are identical
    case noDifference

    /// Strings differ at the specified index.
    ///
    /// This could mean that characters at the specified index are different,
    /// or that one string is longer than the other
    case differenceAtIndex(Int)
}

extension FirstDifferenceResult: CustomStringConvertible, CustomDebugStringConvertible {
    /// Textual representation of a FirstDifferenceResult
    public var description: String {
        switch self {
        case .noDifference:
            return "NoDifference"
        case .differenceAtIndex(let index):
            return "DifferenceAtIndex(\(index))"
        }
    }

    /// Textual representation of a FirstDifferenceResult for debugging purposes
    public var debugDescription: String {
        return self.description
    }
}
