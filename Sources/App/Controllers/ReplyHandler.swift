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
		print("Reply in \(dirname) to \(postid)")

		let info = UserInfo(in: db).fromSession(request)
		if info.userid == 0 { 
			print("Error posting. Must be logged in to post")
			return fail(.unauthorizedAccess)
		}

		let userid = info.userid
		let nick   = info.nick

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

	// POST /api/reply/456 body:content
	func apiModify(_ request: Request) -> ResponseRepresentable {
		// Validate user is owner
		print(request)

		guard let replyId = request.parameters["reply"]?.int else {
			print("API Modify. Reply id is required")
			return "NO"
		}

		guard let content = request.data["content"]?.string else {
			print("API Modify. Reply content is required")
			return "NO"
		}

		let user = UserInfo(in: db).fromSession(request)
		if user.userid == 0 { 
			print("Error modifying reply. Must be logged in")
			return "NO"
		}

		guard let reply = Reply().get(id: replyId) else {
			print("Reply \(replyId) not found")
			return "NO"
		}

		if reply.userid != user.userid {
			print("User can only modify own replies. Owner: \(reply.userid) - User: \(user.userid)")
			return "NO"
		}

		reply.content = content
		reply.save()

		print("API Modified reply \(replyId)")
		return "OK"
	}

	// DELETE /api/reply/456
	func apiDelete(_ request: Request) -> ResponseRepresentable {
		// Validate user is owner
		guard let replyId = request.parameters["reply"]?.int else {
			print("API Delete. Reply id is required")
			return "NO"
		}

		let user = UserInfo(in: db).fromSession(request)
		if user.userid == 0 { 
			print("Error deleting reply. Must be logged in")
			return "NO"
		}

		guard let reply = Reply().get(id: replyId) else {
			print("Reply \(replyId) not found")
			return "NO"
		}

		if reply.userid != user.userid {
			print("User can only delete own replies. Owner: \(reply.userid) - User: \(user.userid)")
			return "NO"
		}

		// Don't delete, mark as hidden
		reply.hide()

		print("API Deleted reply id: ", replyId)
		return "OK"
	}

	// POST /api/reply/456/report
	func apiReport(_ request: Request) -> ResponseRepresentable {
		guard let replyId = request.parameters["reply"]?.int else {
			print("API Report. Reply id is required")
			return "NO"
		}

		let user = UserInfo(in: db).fromSession(request)
		if user.userid == 0 { 
			print("Error reporting reply. Must be logged in")
			return "NO"
		}

		guard let reply = Reply().get(id: replyId) else {
			print("Reply \(replyId) not found")
			return "NO"
		}

		if reply.userid == user.userid {
			print("User can not report own messages. Owner: \(reply.userid) - User: \(user.userid)")
			return "NO"
		}

		// TODO: Add to reports table, add flagged field to replies
		//reply.report(userid, reason)

		print("API Report reply id: ", replyId)
		return "OK"
	}

	// POST /api/reply/456/answer
	func apiAnswer(_ request: Request) -> ResponseRepresentable {
		guard let replyId = request.parameters["reply"]?.int else {
			print("API Answer. Reply id is required")
			return "NO"
		}

		guard let answer = request.data["answer"]?.int else {
			print("API Answer. Answer value 0 or 1 is required")
			return "NO"
		}

		let user = UserInfo(in: db).fromSession(request)
		if user.userid == 0 { 
			print("Error selecting answer. Must be logged in")
			return "NO"
		}

		guard let reply = Reply().get(id: replyId) else {
			print("API Answer. Reply \(replyId) not found")
			return "NO"
		}
/*
		if reply.userid == user.userid {
			print("User can not answer own posts. Owner: \(reply.userid) - User: \(user.userid)")
			return "NO"
		}
*/
		reply.answer(answer)

		print("API Answer \(answer) for reply id: ", replyId)
		return "OK:\(answer)"
	}

	// POST /api/reply/456/star
	func apiStar(_ request: Request) -> ResponseRepresentable {
		guard let replyId = request.parameters["reply"]?.int else {
			print("API Star. Reply id is required")
			return "NO:1"
		}

		guard let state = request.data["state"]?.int else {
			print("API Star. State value 0 or 1 is required")
			return "NO:2"
		}

		let user = UserInfo(in: db).fromSession(request)
		if user.userid == 0 { 
			print("API Star. Error starring message, must be logged in")
			return "NO:3"
		}

		guard let reply = Reply().get(id: replyId) else {
			print("API Star. Reply \(replyId) not found")
			return "NO:4"
		}
/*
		if reply.userid == user.userid {
			print("User can not star own messages. Owner: \(reply.userid) - User: \(user.userid)")
			return "NO:5"
		}
*/
		reply.star(state)  		// update reply
		reply.karma(state) 		// update user
		//user.updateKarma(state) // update session
		var num = 1
		if state == 0 { num = -1 }
		if !user.nick.isEmpty && user.nick != "anonymous" { 
			try? request.session().data["karma"] = Node(user.karma+num) 
		}


		// TODO: send response, with session info and body 'OK'
		let response = Response(status: .ok, body: "OK:\(state)")

		return response
	}
}

// End