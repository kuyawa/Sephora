import Vapor

enum FailType: String {
	case dataDriverError     = "Data Driver Error. SQL driver not available"
	case dataCreationError   = "Data Creation Error. SQL driver could not create database"
	case databaseUnavailable = "Database unavailable. Check database drivers are installed and running"
	case forumNotAvailable   = "Forum not available. Check the correct forum name you want to access"
	case postNotAvailable    = "Post not available. Check the correct post you want to access"
	case replyNotAvailable   = "Message not available. Check the correct message you want to access"
	case badRequest          = "Bad request. Check the correct parameters for the request"
	case authorizationError  = "Authorization error. Failed to access authorization server"
	case missingCredentials  = "Authorization error. Missing credentials from the server"
	case invalidCredentials  = "Unauthorized access. Invalid credentials sent by server"
	case unauthorizedAccess  = "Unauthorized access. Login is required to access that feature"
}

extension WebController {
	func fail(_ fail: FailType, content: String? = nil) -> View {
		return getFailView(fail.rawValue, content: content)!
	}

	func fail(message: String) -> View? {
		return getFailView(message)!
	}

	func fail(message: String, content: String) -> View? {
		return getFailView(message, content: content)!
	}

	func getFailView(_ message: String, content: String? = nil) -> View? {
		let data: Node = ["message": Node(message), "content": Node(content ?? "")]
		let view = getView("fail", with: data)
		return view
	}
}


// End