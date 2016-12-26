import Vapor
import HTTP
import Foundation

class RegisterHandler: WebController {

	func form(_ request: Request) -> ResponseRepresentable {
		let context = getContext(request)
		let data: Node = ["text": "Not ready"]
		let view = getView("register", with: data, in: context) 
		return view!
	}

	func fetchUser(_ request: Request) -> ResponseRepresentable {
		guard let user = request.parameters["user"]?.string else {
			print("User nick is required")
			return failJson(.userNickRequired)
		}
		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			print("Invalid user nick")
			return failJson(.userInfoInvalid)
		}

		do {
			let data = try Data(contentsOf: url)

			//print("User Info: \n", String(data: data, encoding: .utf8))

			let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

			guard let nick = json?["login"] as? String,
				  let name = json?["name"] as? String,
				  let avatar = json?["avatar_url"] as? String
			else {
				print("User info: Invalid data")
				return failJson(.userInfoInvalid)
			}

			print("User info: ", nick, name, avatar)

			let user = User()
			user.nick = nick
			user.name = name
			user.avatar = avatar
			user.register()
			
			// Save session info
			//try request.session().data["nick"] = Node(nick)
			//try request.session().data["name"] = Node(name)
			//try request.session().data["avatar"] = Node(avatar)

			let info = easyJson(["nick": nick, "name": name, "avatar": avatar])

			let response = Response(status: .ok, body: info)
			response.headers["Content-Type"] = "application/json"
			response.cookies["nick"] = nick

			print("Session info: ", nick, name, avatar)
			try request.session().data["nick"] = Node(nick)
			try request.session().data["name"] = Node(name)
			try request.session().data["avatar"] = Node(avatar)

			return response

		} catch {
			print("Error accessing Github: ", error)
			return failJson(.errorAccessingGithub)
		}

	}

}

// End