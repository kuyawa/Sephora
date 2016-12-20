import Vapor
import HTTP

class ForumHandler: WebController {

	var view: View {
		let dirName = request.parameters["forum"]?.string ?? "general"
		//print(dirName)
		let forum   = db?.getForum(dir: dirName)
		//print(forum!)
		let forumId = forum?["forumid"]?.int ?? 1
		//print(forumId)
		let posts   = db?.getPosts(forumId: forumId)
		//print(posts!)
		let data: Node = ["forum": forum!, "posts": posts!]
		print(data)
		let view = getView("forum", with: data) 

		//let data: Node = ["code": 123, "text": "Error accessing database. Incorrect parameters"]
		//let view = getView("fail", with: data) 

		return view!
	}

}