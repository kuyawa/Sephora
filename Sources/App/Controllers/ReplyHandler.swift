import Vapor
import HTTP
import Foundation

class ReplyHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		let context = getContext(request)
		let data: Node = ["text": "Not ready"]
		let view = getView("todo", with: data, in: context) 
		return view!
	}

	func submit(_ request: Request) -> ResponseRepresentable {
		// TODO: If not logged in, ask to login or register
		guard let dirname = request.parameters["forum"]?.string else { return fail(.forumNotAvailable) }
		guard let postid  = request.parameters["post"]?.int else { return fail(.badRequest) }
		guard let content = request.data["content"]?.string else { return fail(.badRequest) }
		//print(dirname, postid, content)

		let userid = 5   		// get from session
		let nick = "Kuyawa"		// get from session

		let reply = Reply(in: db)
		reply.replyid   = 0  // Used for insert
		reply.postid   	= postid
		reply.date   	= Date()
		reply.userid   	= userid
		reply.nick   	= nick
		reply.content   = content
		// Everything else is default

		reply.save()
		print("Reply saved")

		// if ok redirect /forums/:name
		// else redirect /post/:postid with action:draft

		return AppHandler().redirect("/forum/\(dirname)/post/\(postid)")
	}

}