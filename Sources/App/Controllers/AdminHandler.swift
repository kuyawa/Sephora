import Vapor
import HTTP

class AdminHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let data: Node = ["name": "Kuyawa", "phone":"555-1234", "email":"kuyawa@example.com"]
		let context = getContext(request)
		let view = getView("test", with: data, in: context)
		return view!
	}

	func dbinfo(_ request: Request) -> ResponseRepresentable {
		let version = db.queryValue("Select version() as value") ?? "No db connection"
		let tables = db.getTables()
		let data: Node = ["Version": version, "Tables": .array(tables.map{Node($0)})]
		//print(data)
		let context = getContext(request)
		let view = getView("admin.dbinfo.leaf", with: data, in: context)
		return view!
	}

	func users(_ request: Request) -> ResponseRepresentable {
		guard let users = Users().all() else { return fail(.databaseUnavailable) }
		let data: Node = ["users": users]
		let context = getContext(request)
		let view = getView("admin.users.leaf", with: data, in: context)
		return view!
	}

	func logs(_ request: Request) -> ResponseRepresentable {
		// TODO: filter by type, limit by num
		guard let logs = db.query("Select * from weblogs order by date desc limit 100") else { return fail(.databaseUnavailable) }
		let data: Node = ["logs": logs]
		let view = getView("admin.logs.leaf", with: data)
		return view!
	}

	func clearLogs(_ request: Request) -> ResponseRepresentable {
		_ = db.execute("Delete from weblogs")
		return Response(redirect: "/admin/logs")
	}

}