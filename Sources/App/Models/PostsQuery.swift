import Vapor
import Foundation

class Posts: DataQuery {

	// Get latests posts from all forums
	// let posts = Posts().getLatest()

	func getLatest(start: Int? = 0, limit: Int? = 30) -> Node? {
		//OLD: let sql = "Select p.*, f.name, f.dirname From posts p, forums f Where f.forumid = p.forumid And p.hidden = false Order by date Desc Offset $1 Limit $2"

		// Select latest posts or replies order by date desc. Not an easy query but SQL is magic
		let sub = "Select Distinct on (p.postid) p.postid, p.type, p.title, p.nick, p.date, p.views, p.replies, p.answered, f.name, f.dirname, coalesce(r.date, p.date) as datex From posts p Left Outer Join forums f On p.forumid = f.forumid Left Outer Join replies r On p.postid = r.postid Where p.hidden = false Order by p.postid, datex desc"
		let sql = "Select * From (\(sub)) latest Order by datex desc Offset $1 Limit $2"

		let args:[Node] = try! [start!.makeNode(), limit!.makeNode()]
		let rows = db.query(sql, params: args)

		return rows
	}

	// Get latests posts by forumid
	// let posts = Posts().getLatest(4) //forum/swift

	func getLatest(forumId: Int, start: Int? = 0, limit: Int? = 30) -> Node? {
		//OLD: let sql  = "Select p.*, f.name, f.dirname From posts p, forums f Where p.forumid = $1 And f.forumid = p.forumid And p.hidden = false Order by date Desc Offset $2 Limit $3"

		// Select latest posts or replies order by date desc. Not an easy query but SQL is magic
		let sub = "Select Distinct on (p.postid) p.postid, p.type, p.title, p.nick, p.date, p.views, p.replies, p.answered, f.name, f.dirname, coalesce(r.date, p.date) as datex From posts p Left Outer Join forums f On p.forumid = f.forumid Left Outer Join replies r On p.postid = r.postid Where p.forumid = $1 And p.hidden = false Order by p.postid, datex desc"
		let sql = "Select * From (\(sub)) latest Order by datex desc Offset $2 Limit $3"

		let args:[Node] = try! [forumId.makeNode(), start!.makeNode(), limit!.makeNode()]
		let rows = db.query(sql, params: args)

		return rows
	}

} 

// End