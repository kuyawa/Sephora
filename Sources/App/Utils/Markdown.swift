#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
	import Darwin
#elseif os(Linux)
	import Glibc
#endif

import Foundation

/* Kuyawa - 2016/30/12. Used in regex for linux, also in StringUtils.swift

- Linux compatibility:
  Uses a Typealias for NSRegularExpression
  Uses an extension to TextCheckingResult

*/

#if os(Linux)
typealias NSRegularExpression = RegularExpression
typealias NSTextCheckingResult = TextCheckingResult
extension TextCheckingResult {
	func rangeAt(_ n: Int) -> NSRange {
		return self.range(at: n)
	}
}
#endif


extension String {
    /* Already defined in StringUtils
    func match(_ pattern: String) -> Bool {
        guard self.characters.count > 0 else { return false }
        if let first = self.range(of: pattern, options: .regularExpression) {
            let match = self.substring(with: first)
            return !match.isEmpty
        }
        
        return false
    }
    */

    /* Already defined in StringUtils
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    */
    
    func remove(_ pattern: String) -> String {
        guard self.characters.count > 0 else { return self }
        if let first = self.range(of: pattern, options: .regularExpression) {
            return self.replacingCharacters(in: first, with: "")
        }
        
        return self
    }
    
    func prepend(_ text: String) -> String {
    	if text.isEmpty { return self }
        return text + self
    }
    
    func append(_ text: String) -> String {
    	if text.isEmpty { return self }
        return self + text
    }
 
    func enclose(_ fence: (String, String)?) -> String {
        return (fence?.0 ?? " ") + self + (fence?.1 ?? " ")
    }
}

extension NSMutableString {
    func matchAndReplace(_ rex: String, _ rep: String, options: NSRegularExpression.Options? = []) {
        if let regex = try? NSRegularExpression(pattern: rex, options: options!) {
	        let range = NSRange(location: 0, length: self.length)
	        _ = regex.replaceMatches(in: self, options: [], range: range, withTemplate: rep)
	    } else {
	    	print("Regex not valid")
	    }
    }
}


class Markdown {
    
    func parse(_ text: String) throws -> String {
    	print("Markdown enter...")
        var md = NSMutableString(string: text)
        
        cleanHtml(&md)
        parseHeaders(&md)
        parseBold(&md)
        parseItalic(&md)
        parseDeleted(&md)
/*
        parseImages(&md)
        parseLinks(&md)
        parseUnorderedLists(&md)
        parseOrderedLists(&md)
        parseBlockquotes(&md)
        parseCodeBlock(&md)
        parseCodeInline(&md)
        parseHorizontalRule(&md)
        parseYoutubeVideos(&md)
        parseParagraphs(&md)
*/        
        return String(describing: md)
    }
    
    func cleanHtml(_ md: inout NSMutableString) {
        md.matchAndReplace("<.*?>", "")
    }
    
    func parseHeaders(_ md: inout NSMutableString) {
        md.matchAndReplace("^###(.*)?", "<h3>$1</h3>", options: [.anchorsMatchLines])
        md.matchAndReplace("^##(.*)?", "<h2>$1</h2>", options: [.anchorsMatchLines])
        md.matchAndReplace("^#(.*)?", "<h1>$1</h1>", options: [.anchorsMatchLines])
    }

    func parseBold(_ md: inout NSMutableString) {
        md.matchAndReplace("\\*\\*(.*?)\\*\\*", "<b>$1</b>")
    }
    
    func parseItalic(_ md: inout NSMutableString) {
        md.matchAndReplace("\\*(.*?)\\*", "<i>$1</i>")
    }
    
    func parseDeleted(_ md: inout NSMutableString) {
        md.matchAndReplace("~~(.*?)~~", "<s>$1</s>")
    }
    
/*    
    func parseImages(_ md: inout NSMutableString) {
        md.matchAndReplace("!\\[(\\d+)x(\\d+)\\]\\((.*?)\\)", "<img src=\"$3\" width=\"$1\" height=\"$2\" />")
        md.matchAndReplace("!\\[(.*?)\\]\\((.*?)\\)", "<img alt=\"$1\" src=\"$2\" />")
    }
    
    func parseLinks(_ md: inout NSMutableString) {
        md.matchAndReplace("\\[(.*?)\\]\\((.*?)\\)", "<a href=\"$2\">$1</a>")
        md.matchAndReplace("\\[http(.*?)\\]", "<a href=\"http$1\">http$1</a>")
        md.matchAndReplace("(^|\\s)http(.*?)(\\s|\\.\\s|\\.$|,|$)", "$1<a href=\"http$2\">http$2</a>$3 ", options: [.anchorsMatchLines])
    }
    
    func parseUnorderedLists(_ md: inout NSMutableString) {
        //md.matchAndReplace("^\\*(.*)?", "<li>$1</li>", options: [.anchorsMatchLines])
        parseBlock(&md, format: "^\\*", blockEnclose: ("<ul>", "</ul>"), lineEnclose: ("<li>", "</li>"))
    }
    
    func parseOrderedLists(_ md: inout NSMutableString) {
        parseBlock(&md, format: "^\\d+[\\.|-]", blockEnclose: ("<ol>", "</ol>"), lineEnclose: ("<li>", "</li>"))
    }
    
    func parseBlockquotes(_ md: inout NSMutableString) {
        //md.matchAndReplace("^>(.*)?", "<blockquote>$1</blockquote>", options: [.anchorsMatchLines])
        parseBlock(&md, format: "^>", blockEnclose: ("<blockquote>", "</blockquote>"))
        parseBlock(&md, format: "^:", blockEnclose: ("<blockquote>", "</blockquote>"))
    }
    
    func parseCodeBlock(_ md: inout NSMutableString) {
        md.matchAndReplace("```(.*?)```", "<pre>$1</pre>", options: [.dotMatchesLineSeparators])
        //parseBlock(&md, format: "^\\s{4}", blockEnclose: ("<pre>", "</pre>"))
    }
    
    func parseCodeInline(_ md: inout NSMutableString) {
        md.matchAndReplace("`(.*?)`", "<code>$1</code>")
    }
    
    func parseHorizontalRule(_ md: inout NSMutableString) {
        md.matchAndReplace("---", "<hr>")
    }
    
    func parseYoutubeVideos(_ md: inout NSMutableString) {
        md.matchAndReplace("\\[youtube (.*?)\\]", "<p><a href=\"http://www.youtube.com/watch?v=$1\" target=\"_blank\"><img src=\"http://img.youtube.com/vi/$1/0.jpg\" alt=\"Youtube video\" width=\"240\" height=\"180\" /></a></p>")
    }
    
    func parseParagraphs(_ md: inout NSMutableString) {
        md.matchAndReplace("\n\n([^\n]+)\n\n", "\n\n<p>$1</p>\n\n", options: [.dotMatchesLineSeparators])
    }
    
    func parseBlock(_ md: inout NSMutableString, format: String, blockEnclose: (String, String), lineEnclose: (String, String)? = nil) {
        let lines = md.components(separatedBy: .newlines)
        var result = [String]()
        var isBlock = false
        var isFirst = true
        
        for line in lines {
            var text = line
            if text.match(format) {
                isBlock = true
                if isFirst { result.append(blockEnclose.0); isFirst = false }
                text = text.remove(format)
                text = text.trim().enclose(lineEnclose)
            } else if isBlock {
                isBlock = false
                isFirst = true
                text = text.append(blockEnclose.1+"\n")
            }
            result.append(text)
        }

        if isBlock { result.append(blockEnclose.1) } // close open blocks
        
        md = NSMutableString(string: result.joined(separator: "\n"))
    }
*/    
}


// End