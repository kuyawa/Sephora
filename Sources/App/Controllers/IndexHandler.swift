import Vapor
import HTTP
import PostgreSQL

class IndexHandler: WebController {

	func index(_ request: Request) -> ResponseRepresentable {
		let ini =  0  // get from pagination
		let max = 50  // get from Config.latestPosts.max

		guard let posts = Posts(in: db).getLatest(start: ini, limit: max) else { 
			return fail(.databaseUnavailable) 
		}

		// TODO: Pagination from config max, total rec count, and current page
		let data: Node = [
			"forum": ["name": "Latest Messages", "descrip": "From all forums"],
			"posts": posts,
			"page" : 0,
			"pagination":[0,100,200,300,400]
		]

		let context = getContext(request)
		let view = getView("index", with: data, in: context)

		return view!
	}

}

// End