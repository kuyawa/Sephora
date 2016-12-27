import Vapor
import Foundation

class Users: DataQuery {

	// Get all users
	// let users = Users().all()

	func all() -> Node? {
		let sql  = "Select * From Users Order by userid"
		if let rows = db.query(sql) {
			return rows
		}
		return nil
	}

	// Get all users paginated
	// let users = Users().list(start: 0, limit: 100)

	func list(start: Int? = 0, limit: Int? = 30) -> Node? {
		let sql  = "Select * From Users Order by userid Offset $1 Limit $2"
		let args:[Node] = try! [start!.makeNode(), limit!.makeNode()]
		if let rows = db.query(sql, params: args) {
			return rows
		}
		return nil
	}

} 

// End