import Vapor
import HTTP

class RegisterHandler: WebController {

	func form(_ request: Request) -> ResponseRepresentable {
		let data: Node = ["text": "Not ready"]
		let view = getView("todo", with: data) 
		return view!
	}

}