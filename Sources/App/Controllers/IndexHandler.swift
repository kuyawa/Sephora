import Vapor
import HTTP
import PostgreSQL

class IndexHandler: WebController {

	func index(_ request: Request) -> ResponseRepresentable {
		let data: Node = ["forum": ["name": "Latest Messages", "descrip": "From all forums"]]
		//let context = getContext(request)
		let view = getView("index", with: data)

		return view!
	}

}

// End