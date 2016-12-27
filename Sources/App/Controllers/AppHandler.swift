import Vapor
import Foundation
import HTTP

/*
class App {
	var isLive = false

	static func checkIsLive() {
		//if drop.environment == .production { print("Sephora is live!") } else { print("Sephora is running in dev mode") }

		if let envDatabase = ProcessInfo.processInfo.environment["DATABASE_URL"] {
			isLive = envDatabase.hasPrefix("postgres")
		}
		if isLive { print("Sephora is live!") } else { print("Sephora is running in dev mode") }
	}
}
*/

class AppHandler: WebController {

	func redirect(_ url: String) -> ResponseRepresentable {
		return Response(redirect: url)
	}

	func redirectToIndex() -> ResponseRepresentable {
		return Response(redirect: "/")
	}

	func redirectToIndex(_ request: Request) -> ResponseRepresentable {
		return Response(redirect: "/")
	}

	func fail(_ error: Error) throws -> ResponseRepresentable {
		throw error
	}

}