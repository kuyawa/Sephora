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