import Vapor
import Foundation

class Forums: DataQuery {

	// Get latests posts of all forums
	// let posts = Posts().getLatest()

	func getForumId(dir: String) -> Int {
		let sql = "Select forumid From forums Where dirname=$1 Limit 1"
		if let result = db.query(sql, params: [Node(dir)]) {
			guard let row = result[0], let id = row["forumid"]!.int else { return 0 }
			return id
		}
		return 0
	}


	func list(start: Int? = 0, limit: Int? = 30) -> Node? {
		let sql  = "Select * From posts Order by date Desc Offset $1 Limit $2"
		let args:[Node] = try! [start!.makeNode(), limit!.makeNode()]
		if let rows = db.query(sql, params: args) {
			return rows
		}
		return nil
	}

	func getSidebar() -> Node? {
		/* TODO: Enable when live
		let sql = "Select * From forums Order by rowpos"
		if let rows = db.query(sql) {
			return rows
		}
		return nil
		*/

		let rows = [
			["Welcome", "/forum/welcome", 342],
			["General discussion", "/forum/general", 123],
			["Tutorials", "/forum/tutorials", 32],
			["Swift", "/forum/swift", 45],
			["iOS", "/forum/ios", 95],
			["macOS", "/forum/macos", 64],
			["watchOS", "/forum/watchos", 9],
			["tvOS", "/forum/tvos", 22],
			["Server", "/forum/server", 45],
			["Linux", "/forum/linux", 32],
			["Frameworks", "/forum/frameworks", 38],
			["Apps Showcase", "/forum/showcase", 20],
			["Request Apps", "/forum/request", 15],
			["Jobs - Hiring", "/forum/jobs", 32],
			["Jobs - For Hire", "/forum/forhire", 78],
			["Meta", "/forum/meta", 7]
		]

		var nodes: [Node?] = []
		for item in rows {
			let node = [
				Node.string(item[0] as! String), 
				Node.string(item[1] as! String), 
				Node(item[2] as! Int)
			]
			nodes.append(try? Node(node: node))
		}

		return try? Node(node: nodes)

	}

	// Get latests posts by forumid
	// let posts = Posts().getLatest("swift")

	func getLatest(forumId: Int, start: Int? = 0, limit: Int? = 30) -> Node? {
		let sql  = "Select * From posts Where forumid=$1 Order by date Desc Offset $2 Limit $3"
		let args:[Node] = try! [forumId.makeNode(), start!.makeNode(), limit!.makeNode()]
		if let rows = db.query(sql, params: args) {
			return rows
		}
		return nil
	}

} 

// End