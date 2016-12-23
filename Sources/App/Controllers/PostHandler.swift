import Vapor
import HTTP
import Foundation

class PostHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		guard let dirname = request.parameters["forum"]?.string else { return fail(.forumNotAvailable) }
		guard let postid  = request.parameters["post"]?.int else { return fail(.badRequest) }
		guard let forum   = Forum(in: db).get(dir: dirname) else { return fail(.forumNotAvailable) }
		guard let post    = Post(in: db).get(id: postid) else { return fail(.postNotAvailable) }
		guard let replies = post.getReplies() else { return fail(.badRequest) }

		post.countView()

		var markdown = Markdown()
		let md = "hi *italics* **bold** there"
		let html = markdown.transform("hi *italics* **bold** there")
		//let html = Node(md).markdown
		//print("MD: ", html!)
		let data: Node = ["forum": try! forum.makeNode(), "post": try! post.makeNode(), "replies": replies, "markdown": Node(md), "html": Node(html)]
		let view = getView("post", with: data) 

		return view!
	}

	func submit(_ request: Request) throws -> ResponseRepresentable {
		// TODO: get forum name from form post token, validate if user can post in that forum
		guard let dirname = request.parameters["forum"]?.string else { return fail(.forumNotAvailable) }
		guard let title   = request.data["title"]?.string else { return fail(.badRequest) }
		guard let content = request.data["content"]?.string else { return fail(.badRequest) }
		print(dirname, title, content)

		let forumid = Forum(in: db).getId(dir: dirname)
		guard forumid > 0 else { return fail(.forumNotAvailable) }

		let type = 0     		// get from form 
		let userid = 5   		// get from session
		let nick = "Kuyawa"		// get from session

		let post = Post(in: db)
		post.postid   	= 0  // Used for insert
		post.forumid   	= forumid
		post.type   	= type
		post.date   	= Date()
		post.userid   	= userid
		post.nick   	= nick
		post.title   	= title
		post.content   	= content
		// Everything else is default

		post.save()
		print("Post created")

		// if ok redirect /forums/:name
		// else redirect /post/:postid with action:draft

		return AppHandler().redirect("/forum/\(dirname)")
	}

}