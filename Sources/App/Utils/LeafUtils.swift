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