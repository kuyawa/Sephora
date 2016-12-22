import Vapor
import HTTP
import Foundation

class ForumHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {
		guard let dirName = request.parameters["forum"]?.string else { return fail(.forumNotAvailable) }
		guard let forum = Forum(in: db).get(dir: dirName) else { return fail(.forumNotAvailable) }
		guard let posts = Posts(in: db).getLatest(forumId: forum.forumid) else { return fail(.badRequest) }
/*
		for item in posts.array! {
			let sdate = item.object!["date"]!.string!
			let date = sdate.subtext(to: 19).toDate()
			print(sdate, date, date.timeAgo())
		}
*/
		let data: Node = ["forum": try! forum.makeNode(), "posts": posts]
		let view = getView("forum", with: data) 

		return view!
	}


}

// End