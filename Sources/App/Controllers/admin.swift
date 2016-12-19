import Vapor
import HTTP

class AdminHandler: WebController {

	var view: View {
		let data: Node = ["name": "Kuyawa", "phone":"555-1234", "email":"kuyawa@example.com"]
		let view = getView("test", with: data)
		return view!
	}

	var dbinfo: View {
		//var data: Node
		let version = db?.queryValue("Select version() as value") ?? "No db connection"
		//let dbs = db?.getDatabases()
		let tables = db?.getTables()
		//let data: Node = ["Version": version, "Databases": .array(dbs!.map{Node($0)}), "Tables": .array(tables!.map{Node($0)})]
		let data: Node = ["Version": version, "Tables": .array(tables!.map{Node($0)})]
		//print(data)
		let view = getView("admin.dbinfo.leaf", with: data)
		return view!
	}

	var users: View {
		let users = db?.getUsers()
		let data: Node = ["users": users!]
		let view = getView("admin.users.leaf", with: data)
		return view!
	}

}