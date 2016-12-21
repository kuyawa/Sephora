import Vapor
import HTTP
import Foundation

class ForumHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let dirName = request.parameters["forum"]?.string ?? "general"
		guard let forum = db.getForum(dir: dirName) else { return fail(.forumNotAvailable) }
		guard let forumId = forum["forumid"]?.int else { return fail(.forumNotAvailable) }
		guard let posts = db.getPosts(forumId: forumId) else { return fail(.badRequest) }
/*
		for item in posts.array! {
			let sdate = item.object!["date"]!.string!
			let date = sdate.subtext(to: 19).toDate()
			print(sdate, date, date.timeAgo())
		}
*/
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

		let forumid = db.getForumId(forum)
		guard forumid > 0 else { throw Abort.badRequest }

		let type = 0     		// get from form 
		let userid = 5   		// get from session
		let nick = "Kuyawa"		// get from session

		let post = Post()
		post.postid   	= 0  // Used for insert
		post.forumid   	= forumid
		post.type   	= type
		post.date   	= Date()
		post.userid   	= userid
		post.nick   	= nick
		post.title   	= title
		post.content   	= content
		// Everything else is default

		post.save(in: db)
		print("Post created")

		// if ok redirect /forums/:name
		// else redirect /post/:postid with action:draft

		return AppHandler().redirect("/forum/\(forum)")
	}

}