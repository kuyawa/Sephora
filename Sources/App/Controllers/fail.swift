import Vapor

enum FailType: String {
	case dataDriverError     = "Data Driver Error. SQL driver not available"
	case dataCreationError   = "Data Creation Error. SQL driver could not create database"
	case databaseUnavailable = "Database unavailable. Check database drivers are installed and running"
	case forumNotAvailable   = "Forum not available. Check the correct forum name you want to access"
	case badRequest          = "Bad request. Check the correct parameters for the request"
}

extension WebController {
	func fail(_ fail: FailType) -> View {
		return getFailView(fail.rawValue)!
	}

	func fail(message: String) -> View? {
		return getFailView(message)!
	}

	func getFailView(_ message: String) -> View? {
		let data: Node = ["message": Node(message)]
		let view = getView("fail", with: data)
		return view
	}
}


// End