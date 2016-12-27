import Vapor
import Foundation

class Stats: DataQuery {
	var users     = 0
	var threads   = 0
	var replies   = 0
	var questions = 0
	var answered  = 0

	func gather() -> Stats {
		// TODO: query stats from DB
		users     =  320
		threads   = 1234
		replies   = 3542
		questions =  156
		answered  =   72

		return self
	}

	func toNode() -> Node {
		let node = try! Node(node: [
			"users"     : Node(users),
			"threads"   : Node(threads),
			"replies"   : Node(replies),
			"questions" : Node(questions),
			"answered"  : Node(answered),
		])

		return node
	}
}