import Vapor
import HTTP

class ForumHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let dirName = request.parameters["forum"]?.string ?? "general"
		guard let forum = db.getForum(dir: dirName) else { return fail(.forumNotAvailable) }
		guard let forumId = forum["forumid"]?.int else { return fail(.forumNotAvailable) }
		guard let posts = db.getPosts(forumId: forumId) else { return fail(.badRequest) }

		let data: Node = ["forum": forum, "posts": posts]
		let view = getView("forum", with: data) 

		return view!
	}

	func submit(_ request: Request) throws -> ResponseRepresentable {
		// TODO: get forum name from form post token, validate if user can post in that forum
		guard let forum = request.parameters["forum"]?.string else { throw Abort.badRequest }
		guard let title = request.data["title"]?.string else { throw Abort.badRequest }
		guard let content = request.data["content"]?.string else { throw Abort.badRequest }
		print(forum, title, content)
		// get post data
		// validate post data
		// if ok redirect /forums/:name
		// else redirect /post/:postid with action:draft
		print("Post created")
		return AppHandler().redirect("/forum/\(forum)")
	}

}