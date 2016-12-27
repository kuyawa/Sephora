import Vapor
import HTTP

class IndexHandler {

	func index(_ request: Request) -> ResponseRepresentable {
		var drop = Droplet()
		let data: Node = ["forum": ["name": "Latest Messages", "descrip": "From all forums"]]
		let view = try! drop.view.make("index", data)

		return view
	}

}

// End