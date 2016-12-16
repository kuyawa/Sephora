import Vapor
import HTTP

class TestController : WebController {

	var view: View {
		//let data = DB.getUser("george")
		let data = ["name": "George", "phone":"555-1234", "email":"george@example.com"] as! Node
		let view = getView("test", with: data) 
		return view!
	}

}