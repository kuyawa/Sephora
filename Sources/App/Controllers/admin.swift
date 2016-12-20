import Vapor
import HTTP

class AdminHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let data: Node = ["name": "Kuyawa", "phone":"555-1234", "email":"kuyawa@example.com"]
		let view = getView("test", with: data)
		return view!
	}

	func dbinfo(_ request: Request) -> ResponseRepresentable {
		let version = db.queryValue("Select version() as value") ?? "No db connection"
		let tables = db.getTables()
		let data: Node = ["Version": version, "Tables": .array(tables.map{Node($0)})]
		//print(data)
		let view = getView("admin.dbinfo.leaf", with: data)
		return view!
	}

	func users(_ request: Request) -> ResponseRepresentable {
		let users = db.getUsers()
		let data: Node = ["users": users!]
		let view = getView("admin.users.leaf", with: data)
		return view!
	}

}