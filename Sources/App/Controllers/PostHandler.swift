import Vapor
import HTTP
import Foundation

class PostHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		guard let dirname = request.parameters["forum"]?.string else { return fail(.badRequest) }
		guard let postid  = request.parameters["post"]?.int else { return fail(.badRequest) }
		guard let forum   = Forum(in: db).get(dir: dirname) else { return fail(.badRequest) }
		guard let post    = Post(in: db).get(id: postid) else { return fail(.badRequest) }
		guard let replies = post.getReplies() else { return fail(.badRequest) }

		post.countView()

		do {
			let context    = getContext(request)
			let data: Node = ["forum": try forum.makeNode(), "post": try post.makeNode(), "replies": replies]
			if let view = getView("post", with: data, in: context) { return view }
		} catch {
			print("Server error: ", error)
			db.log("Server error: \(error)")
		}

		return fail(.errorParsingTemplate)
	}

	func redirect(_ request: Request) -> ResponseRepresentable {
		guard let dirname = request.parameters["forum"]?.string else { return fail(.badRequest) }
		guard let postid  = request.parameters["post"]?.int else { return fail(.badRequest) }
		guard let replyid = request.parameters["reply"]?.int else { return fail(.badRequest) }

		return AppHandler().redirect("/forum/\(dirname)/post/\(postid)#\(replyid)")
	}

	func submit(_ request: Request) -> ResponseRepresentable {
		guard let dirname  = request.parameters["forum"]?.string else { return fail(.forumNotAvailable) }
		guard let title    = request.data["title"]?.string else { return fail(.badRequest) }
		guard let content  = request.data["content"]?.string else { return fail(.badRequest) }
		guard let postType = request.data["type"]?.int else { return fail(.badRequest) }

		let forumid = Forum(in: db).getId(dir: dirname)
		guard forumid > 0 else { return fail(.forumNotAvailable) }

		let info = UserInfo(in: db).fromSession(request)
		if info.userid == 0 { 
			print("Error posting. Must be logged in to post")
			return fail(.unauthorizedAccess)
		}

		let userid = info.userid
		let nick   = info.nick

		let post = Post(in: db)
		post.postid   	= 0  // Used for insert
		post.forumid   	= forumid
		post.type   	= postType
		post.date   	= Date()
		post.userid   	= userid
		post.nick   	= nick
		post.title   	= title
		post.content   	= content
		// Everything else is default

		post.save()

		// if ok redirect /forum/:name
		// else redirect /post/:postid with action:draft

		return AppHandler().redirect("/forum/\(dirname)")
	}

	// POST /api/post/123 body:title,content
	func apiModify(_ request: Request) -> ResponseRepresentable {
		// Validate user is owner
		guard let postId = request.parameters["post"]?.int
		else {
			print("API Modify. Post id is required")
			return "NO"
		}

		guard let title   = request.data["title"]?.string,
		 	  let content = request.data["content"]?.string
		else {
			print("API Modify. Post title and content are required")
			return "NO"
		}

		let user = UserInfo(in: db).fromSession(request)
		if user.userid == 0 { 
			print("Error modifying post. Must be logged in")
			return "NO"
		}

		guard let post = Post().get(id: postId) else {
			print("Post \(postId) not found")
			return "NO"
		}

		if post.userid != user.userid {
			print("User can only modify own posts. Owner: \(post.userid) - User: \(user.userid)")
			return "NO"
		}

		post.title = title
		post.content = content
		post.save()

		return "OK"
	}

	// DELETE /api/post/123
	func apiDelete(_ request: Request) -> ResponseRepresentable {
		// Validate user is owner
		// Don't delete, mark as hidden
		guard let postId = request.parameters["post"]?.int
		else {
			print("API Delete. Post id is required")
			return "NO"
		}

		let user = UserInfo(in: db).fromSession(request)
		if user.userid == 0 { 
			print("Error deleting post. Must be logged in")
			return "NO"
		}

		guard let post = Post().get(id: postId) else {
			print("Post \(postId) not found")
			return "NO"
		}

		if post.userid != user.userid {
			print("User can only delete own posts. Owner: \(post.userid) - User: \(user.userid)")
			return "NO"
		}

		// Don't delete, mark as hidden
		post.hide()

		return "OK"
	}

	// POST /api/post/456/reported
	func apiReport(_ request: Request) -> ResponseRepresentable {
		guard let postId = request.parameters["post"]?.int
		else {
			print("API Report. Post id is required")
			return "NO"
		}

		let user = UserInfo(in: db).fromSession(request)
		if user.userid == 0 { 
			print("Error reporting post. Must be logged in")
			return "NO"
		}

		guard let post = Post().get(id: postId) else {
			print("Post \(postId) not found")
			return "NO"
		}

		if post.userid == user.userid {
			print("User can not report own posts. Owner: \(post.userid) - User: \(user.userid)")
			return "NO"
		}

		// TODO: Add to reports table, add flagged field to posts
		//post.report(userid, reason)

		return "OK"
	}



	func debug(_ request: Request) -> ResponseRepresentable {
		print("0")
		guard let postid  = request.parameters["post"]?.int else { return "fail(.badRequest)" }
		print("1")
		guard let post    = Post(in: db).get(id: postid) else { return "fail(.postNotAvailable)" }

		print("2")
		do {
			print("3")
			print("Post: ", post)
			var text = "Post: \(post) \n"
			print("4")
			let bytes = [UInt8](post.content.utf8)
			print("5")
			let bytex = bytes.map{"\($0) "}.joined()
			print("6")
			print("Bytes: ", bytex)
			text = text + "\nBytes: \(bytex)"
			print("7")
			let postInfo = try post.makeNode() // Error here
			print("Post: \(postInfo)")
			return "\(text)"
		} catch {
			print("8")
			print("Server error: ", error)
		}
		print("9")

		return "fail(.unknownServerError)"
	}


}

// End