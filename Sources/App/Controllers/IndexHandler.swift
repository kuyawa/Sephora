import Vapor
import HTTP
import Cookies
import Foundation

class IndexHandler: WebController {

	func index(_ request: Request) -> ResponseRepresentable {
		let page = request.parameters["n"]?.int ?? 1
		let max = 30  // get from Config.pagination.max
		let ini = max * (page-1)

		guard let posts = Posts(in: db).getLatest(start: ini, limit: max) else { 
			return fail(.databaseUnavailable) 
		}

		let paginate = (posts.array!.count >= max || page > 1)

		var cookieNick = Cookie(name: "nick", value: "") 

		if let nick = request.cookies["nick"], !nick.isEmpty {
			cookieNick = Cookie(
				name     : "nick", 
				value    : nick, 
				expires  : Date.nextYear,
				maxAge   : 60*60*24*365,
	    		domain   : "",
	    		path     : "",
	    		secure   : false,
	    		httpOnly : false
	    	)
		}

		let data: Node = [
			"forum": ["name": "Latest Messages", "descrip": "From all forums"],
			"posts": posts,
			"page" : Node(page),
			"paginate": Node(paginate)
		]

		let context = getContext(request)
		let view = getView("index", with: data, in: context)

		if let response = view?.makeResponse() {
			response.cookies.insert(cookieNick)
			//print("Cookies: ", cookieNick.serialize())
			return response
		}

		return fail(.errorParsingTemplate)
	}

}

// End