import Vapor
import HTTP

class MessageHandler: WebController {

	var view: View {
		let data = ["text": "Not ready"] as! Node
		let view = getView("todo", with: data) 
		return view!
	}

}