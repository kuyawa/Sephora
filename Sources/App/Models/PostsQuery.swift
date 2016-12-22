import Vapor
import Foundation

class Posts: DataQuery {

	// Get latests posts from all forums
	// let posts = Posts().getLatest()

	func getLatest(start: Int? = 0, limit: Int? = 30) -> Node? {
		let sql  = "Select p.*, f.name, f.dirname From posts p, forums f Where f.forumid = p.forumid Order by date Desc Offset $1 Limit $2"
		let args:[Node] = try! [start!.makeNode(), limit!.makeNode()]
		if let rows = db.query(sql, params: args) {
			return rows
		}
		return nil
	}

	// Get latests posts by forumid
	// let posts = Posts().getLatest("swift")

	func getLatest(forumId: Int, start: Int? = 0, limit: Int? = 30) -> Node? {
		let sql  = "Select p.*, f.name, f.dirname From posts p, forums f Where p.forumid=$1 and f.forumid = p.forumid Order by date Desc Offset $2 Limit $3"
		let args:[Node] = try! [forumId.makeNode(), start!.makeNode(), limit!.makeNode()]
		if let rows = db.query(sql, params: args) {
			return rows
		}
		return nil
	}

} 

// End