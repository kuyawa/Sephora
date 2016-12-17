import Vapor
import HTTP

class TestHandler: WebController {

	var view: View {
		//let data = DB.getUser("kuyawa")
		let data = ["name": "Kuyawa", "phone":"555-1234", "email":"kuyawa@example.com"] as! Node
		let view = getView("test", with: data)
		return view!
	}

}