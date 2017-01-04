import Vapor
import HTTP
import Foundation

class ForumHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		guard let dirName = request.parameters["forum"]?.string else { return fail(.forumNotAvailable) }
		guard let forum = Forum(in: db).get(dir: dirName) else { return fail(.forumNotAvailable) }
		guard let posts = Posts(in: db).getLatest(forumId: forum.forumid) else { return fail(.badRequest) }

		let context = getContext(request)
		let data: Node = ["forum": try! forum.makeNode(), "posts": posts]
		let view = getView("forum", with: data, in: context) 

		return view!
	}

}

// End