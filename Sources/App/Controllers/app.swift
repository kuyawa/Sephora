import Vapor
import HTTP

class AppHandler: WebController {

	func redirect(_ url: String) -> Response {
		return Response(redirect: url)
	}

	func fail(_ error: Error) throws -> Response {
		throw error
	}

}