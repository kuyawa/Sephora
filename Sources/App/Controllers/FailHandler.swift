import Vapor
import HTTP
import Foundation

enum FailType: String {
	case unknownServerError   = "Server Error. Something went wrong and we will try to fix it ASAP!"
	case dataDriverError      = "Data Driver Error. SQL driver not available"
	case dataCreationError    = "Data Creation Error. SQL driver could not create database"
	case databaseUnavailable  = "Database unavailable. Check database drivers are installed and running"
	case forumNotAvailable    = "Forum not available. Check the correct forum name you want to access"
	case postNotAvailable     = "Post not available. Check the correct post you want to access"
	case replyNotAvailable    = "Message not available. Check the correct message you want to access"
	case badRequest           = "Bad request. Check the correct parameters for the request"
	case authorizationError   = "Authorization error. Failed to access authorization server"
	case missingCredentials   = "Authorization error. Missing credentials from the server"
	case invalidCredentials   = "Unauthorized access. Invalid credentials sent by server"
	case unauthorizedAccess   = "Unauthorized access. Login is required to access that feature"
	case userNickRequired     = "Register failed. User nick is required" 
	case userNickInvalid      = "Register failed. User nick is invalid" 
	case userInfoInvalid      = "Register failed. User info is invalid" 
	case errorAccessingGithub = "Error accessing Github servers"
	case errorParsingTemplate = "Error rendering template. Our minions will fix this issue ASAP!"
	case invalidJsonError     = "{\"error\":\"Invalid json\"}"       
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

	// Convenience use: failJson(.pageNotFound)
	func failJson(asText fail: FailType) -> String {
		return errorJson(fail.rawValue)
	}

	func failJson(_ fail: FailType) -> ResponseRepresentable {
		return failJson(message: fail.rawValue)
	}

	// Convenience use: failJson("Page not found")
	func failJson(message: String) -> ResponseRepresentable {
		return failJson(node: ["error": Node(message)])
	}

	// Use: failJson(["code": 404, "error": "Page not found"])
	func failJson(node: Node) -> ResponseRepresentable {
		//let header = ["Content-Type": "application/json"]
		//let body = easyJson(node)
		//let response = HTTP.Response(status: .ok, headers: header, body: body)
		guard let json = try? JSON(node: node),
			  let response = try? json.makeResponse() else {
			return FailType.invalidJsonError.rawValue
		}
		return response
	}

	/*		
	func failJson(json: [String:Any]) -> ResponseRepresentable {
		let header = ["Content-Type": "application/json"]
		let body = easyJson(json)
		let response = Response(status: .ok, headers: header, body: body)
		return response
	}
	*/

	func errorJson(_ text: String) -> String {
		return easyJson(["error":text])
	}

	func easyJson(_ data: Node) -> String {
		let json = try? JSON(node: Node(data)) 
		if json == nil {
			return FailType.invalidJsonError.rawValue
		}
		return json!.string!
	}

	func easyJson(_ dixy: [String: Any]) -> String {
		guard let data = try? JSONSerialization.data(withJSONObject: dixy, options: .prettyPrinted) else { 
			return FailType.invalidJsonError.rawValue
		}
		let json = String(data: data, encoding: .utf8) ?? FailType.invalidJsonError.rawValue
		return json
	}

}


// End