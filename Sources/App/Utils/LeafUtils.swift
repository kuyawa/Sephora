import Vapor
import Leaf
import Foundation

class LeafTimeAgo: BasicTag {
	let name = "timeago"

	func run(arguments: [Argument]) throws -> Node? {
    	guard arguments.count == 1,
      		let sdate = arguments[0].value?.string,
      		sdate.characters.count > 18
    	else { return nil }
        let ago: String = sdate.subtext(to: 19).toDate().timeAgo()
        return Node(ago)
    }
}

/*
class LeafMarkdown: BasicTag {
	let name = "markdown"

	func run(arguments: [Argument]) throws -> Node? {
    	guard let text = arguments.first?.value?.string else { return nil }
        var markdown = Markdown()
        let html: String = markdown.transform(text)
        let unescaped = html.bytes
        return .bytes(unescaped)
    }
}
*/

/*
extension Node {

	var markdown : Node? {
		guard let text = self.string else { return Node("some **bold** here") }
		var markdown = Markdown()
		let html = markdown.transform(text)
		return Node(html)
	}

	func markdown(options: MarkdownOptions) -> Node? {
		guard let text = self.string else { return Node("some **bold** here") }
		var markdown = Markdown()
		let html = markdown.transform(text)
		print("Marked: ", html)
		return Node(html)
	}

}
*/

// End
