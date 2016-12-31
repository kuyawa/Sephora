#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
	import Darwin
#elseif os(Linux)
	import Glibc
#endif

import Foundation


// Kuyawa - 2016/30/12. Used in regex for linux, also in StringUtils.swift

/*

- Linux compatibility:
  Uses a Typealias
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


extension NSMutableString {
    
    func matchAndReplace(_ rex: String, _ rep: String, options: NSRegularExpression.Options? = []) {
        let regex = try? NSRegularExpression.init(pattern: rex, options: options!)
        let range = NSRange(location: 0, length: self.length)
        regex?.replaceMatches(in: self, options: [], range: range, withTemplate: rep)
    }
    
}


/*
 
 TODO: 
 - insert p and br tags for paragraphs, loop all lines?
 - if line does not start with < consider it a starting paragraph
 - if it ends in double newline consider it an end of paragraph (furst pass before BR)
 - if it ends in a single newline without block tag consider it a BR tag
 
 */

class Markdown {
    
    func parse(_ text: String) -> String {
        var md = NSMutableString(string: text)
        
        cleanHtml(&md)
        parseHeaders(&md)
        parseBold(&md)
        parseItalic(&md)
        parseDeleted(&md)
        parseImages(&md)
        parseLinks(&md)
        parseUnorderedLists(&md)
        parseOrderedLists(&md)    // TODO
        parseQuotes(&md)          // TODO
        parseBlockquotes(&md)     // Partial
        parseCodeBlock(&md)
        parseCodeInline(&md)
        parseHorizontalRule(&md)
        parseParagraphs(&md)      // TODO
        
        return String(md)
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
    
    func parseImages(_ md: inout NSMutableString) {
        md.matchAndReplace("!\\[(\\d+)x(\\d+)\\]\\((.*?)\\)", "<img src=\"$3\" width=\"$1\" height=\"$2\" />")
        md.matchAndReplace("!\\[(.*?)\\]\\((.*?)\\)", "<img alt=\"$1\" src=\"$2\" />")
    }
    
    func parseLinks(_ md: inout NSMutableString) {
        md.matchAndReplace("\\[(.*?)\\]\\((.*?)\\)", "<a href=\"$2\">$1</a>")
        md.matchAndReplace("\\[http(.*?)\\]", "<a href=\"http$1\">http$1</a>")
        md.matchAndReplace("\\shttp(.*?)\\s", " <a href=\"http$1\">http$1</a> ")
    }
    
    func parseUnorderedLists(_ md: inout NSMutableString) {
        md.matchAndReplace("^\\*(.*)?", "<li>$1</li>", options: [.anchorsMatchLines])
    }
    
    func parseOrderedLists(_ md: inout NSMutableString) {
        md.matchAndReplace("", "")
    }
    
    func parseQuotes(_ md: inout NSMutableString) {
        md.matchAndReplace("", "")
    }
    
    func parseBlockquotes(_ md: inout NSMutableString) {
        md.matchAndReplace("^>(.*)?", "<blockquote>$1</blockquote>", options: [.anchorsMatchLines])
    }
    
    func parseCodeBlock(_ md: inout NSMutableString) {
        md.matchAndReplace("````(.*?)````", "<pre>$1</pre>", options: [.dotMatchesLineSeparators])
    }
    
    func parseCodeInline(_ md: inout NSMutableString) {
        md.matchAndReplace("`(.*?)`", "<code>$1</code>")
    }
    
    func parseHorizontalRule(_ md: inout NSMutableString) {
        md.matchAndReplace("----", "<hr>")
    }
    
    func parseParagraphs(_ md: inout NSMutableString) {
        md.matchAndReplace("", "")
    }
    
}


// End