import Vapor

class Fail: WebController {

	var dataDriverError   : View { return failView(code:101, text:"Data Driver Error") }
	var dataCreationError : View { return failView(code:102, text:"Data Creation Error") }

	func failView(code:Int, text:String) -> View {
		let data: Node = ["code":Node(code), "text":Node(text)]
		let view = getView("fail", with: data)
		return view!
	}
}