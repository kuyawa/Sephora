import Vapor
import HTTP
import Foundation

class ForumHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let page = request.parameters["n"]?.int ?? 1
		let max = 30  // get from Config.pagination.max
		let ini = max * (page-1)

		guard let dirName = request.parameters["forum"]?.string else { return fail(.forumNotAvailable) }
		guard let forum = Forum(in: db).get(dir: dirName) else { return fail(.forumNotAvailable) }
		guard let posts = Posts(in: db).getLatest(forumId: forum.forumid, start: ini, limit: max) else { return fail(.badRequest) }

		let paginate = (posts.array!.count >= max || page > 1)

		let data: Node = [
			"forum": try! forum.makeNode(),
			"posts": posts,
			"page" : Node(page),
			"paginate": Node(paginate)
		]

		let context = getContext(request)
		let view = getView("forum", with: data, in: context) 

		return view!
	}

}

// End