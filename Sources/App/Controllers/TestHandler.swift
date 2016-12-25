import Vapor
import HTTP

class TestHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let context = getContext(request)
		//let data = DB.getUser("kuyawa")
		let data: Node = try! Node(node: ["name": "Kuyawa", "phone": "555-1234", "email": "kuyawa@example.com"])
		let view = getView("test", with: data, in: context)
		return view!
	}

}