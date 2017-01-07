import Vapor
import HTTP
import PostgreSQL

class IndexHandler: WebController {

	func index(_ request: Request) -> ResponseRepresentable {
		let page = request.parameters["n"]?.int ?? 1
		let max = 30  // get from Config.pagination.max
		let ini = max * (page-1)

		guard let posts = Posts(in: db).getLatest(start: ini, limit: max) else { 
			return fail(.databaseUnavailable) 
		}

		let paginate = (posts.array!.count >= max || page > 1)

		let data: Node = [
			"forum": ["name": "Latest Messages", "descrip": "From all forums"],
			"posts": posts,
			"page" : Node(page),
			"paginate": Node(paginate)
		]

		let context = getContext(request)
		let view = getView("index", with: data, in: context)

		return view!
	}

}

// End