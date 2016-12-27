import Vapor
import HTTP

class TodoHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let context = getContext(request)
		let data: Node = ["text": "Not ready"]
		let view = getView("todo", with: data, in: context) 
		return view!
	}

}