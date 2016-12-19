import Vapor
import HTTP

class TestHandler: WebController {

	var view: View {
		//let data = DB.getUser("kuyawa")
		let data: Node = ["name": "Kuyawa", "phone":"555-1234", "email":"kuyawa@example.com"]
		let view = getView("test", with: data)
		return view!
	}

}