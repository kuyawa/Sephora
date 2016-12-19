import Vapor
import HTTP

class TodoHandler: WebController {

	var view: View {
		let data: Node = ["text": "Not ready"]
		let view = getView("todo", with: data) 
		return view!
	}

}