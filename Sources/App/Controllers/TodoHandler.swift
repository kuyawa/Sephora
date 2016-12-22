import Vapor
import HTTP

class TodoHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let data: Node = ["text": "Not ready"]
		let view = getView("todo", with: data) 
		return view!
	}

}