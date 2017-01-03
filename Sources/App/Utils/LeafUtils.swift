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

class LeafTimeOnly: BasicTag {
	let name = "time"

	func run(arguments: [Argument]) throws -> Node? {
    	guard arguments.count == 1,
      		let sdate = arguments[0].value?.string,
      		sdate.characters.count > 18
    	else { return nil }
        let time: String = sdate.subtext(to: 19).toDate().toString(format: "HH:mm:ss")
        return Node(time)
    }
}


class LeafMarkdown: BasicTag {
	let name = "markdown"

	func run(arguments: [Argument]) throws -> Node? {
    	guard let text = arguments.first?.value?.string else { return nil }
    	do {
        	let html = try Markdown().parse(text)
        	let unescaped = html.bytes
        	return .bytes(unescaped)
        } catch {
        	print("Markdown error: ", error)
        }
        
        return "Markdown error"
    }
}


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
