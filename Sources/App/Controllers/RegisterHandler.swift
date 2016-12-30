import Vapor
import HTTP
import Foundation

class RegisterHandler: WebController {

	func form(_ request: Request) -> ResponseRepresentable {
		let context = getContext(request)
		let view = getView("register", in: context) 
		return view!
	}

	// API to get user info from github, returns json

	func fetch(_ request: Request) -> ResponseRepresentable {
		return try! Response.async { stream in 
			let info = self.fetchUser(request)
			stream.close(with: info) 
		}
	}

	func fetchUser(_ request: Request) -> ResponseRepresentable {
		let invalidJson: String = errorJson(FailType.userInfoInvalid.rawValue)

		guard let id = request.parameters["user"]?.string else {
			weblog("User nick is required")
			return invalidJson
		}

		let url = "http://app-data-mobile.appspot.com/test/fetchuser?nick=\(id)"
		//let url = "https://api.github.com/users/\(id)"

		weblog("Fetching user data...")

		do {
			// headers: ["User-Agent":"swiftforums"]
			let response = try drop.client.get(url)
			let json = response.json
			
			weblog("Response: \(response)")
			weblog("Response body: \(response.body)")
			weblog("Response json: \(response.json)")
			weblog("Response name: \(json?["name"]?.string)")

			//let json = String(data: response.body, encoding: .utf8)

			guard let nick = json?["login"]?.string,
				  let name = json?["name"]?.string,
				  let avatar = json?["avatar_url"]?.string
			else {
				weblog("User info: Invalid json data")
				return invalidJson
			}

			weblog("User info: \(nick), \(name), \(avatar)")

			let user = User()
			user.nick = nick
			user.name = name
			user.avatar = avatar
			user.register()
			weblog("User registered")

			let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
			weblog("Json: \(info)")

			return info
		} catch {
			weblog("Error fetching user data: \(error)")
			return invalidJson
		}
	}

/*

	func fetchOLD2(_ request: Request) -> ResponseRepresentable {
		return try! Response.async { stream in 
			self.fetchUser(request) { info in 
				stream.close(with: info) 
			}
		}
	}
	

	func fetchUserOLD2(_ request: Request, callback: @escaping (_ userInfo: String) -> Void) {
		let invalidJson: String = errorJson(FailType.userInfoInvalid.rawValue)

		guard let user = request.parameters["user"]?.string else {
			weblog("User nick is required")
			callback(invalidJson)
			return
		}

		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			weblog("Invalid user nick")
			callback(invalidJson)
			return
		}

		weblog("Fetching user data...")

        var fetch = URLRequest(url: url)
        fetch.httpMethod = "GET"
        fetch.addValue("swiftforums", forHTTPHeaderField: "User-Agent")

		let task = URLSession.shared.dataTask(with: fetch) { data, req, err in
			guard err == nil else {
				weblog("UserInfo error: ", err!)
				callback(invalidJson)
				return
			}

			guard let data = data else { 
				weblog("UserInfo: No data")
				callback(invalidJson)
				return
			}

			do {
				//weblog("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

				guard let nick = json?["login"] as? String,
					  let name = json?["name"] as? String,
					  let avatar = json?["avatar_url"] as? String
				else {
					weblog("User info: Invalid data")
					callback(invalidJson)
					return
				}

				weblog("User info: ", nick, name, avatar)

				let user = User()
				user.nick = nick
				user.name = name
				user.avatar = avatar
				user.register()
				weblog("User registered")

				let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
				weblog("Json: ", info)
				callback(info)
				return
			} catch {
				weblog("Error accessing Github: ", error)
				callback(invalidJson)
				return
			}
		}
		task.resume()

	}
*/

/*
	func fetchUserOLD1(_ request: Request, callback: @escaping (_ userInfo: String) -> Void) {
		let invalidJson: String = errorJson(FailType.userInfoInvalid.rawValue)

		guard let user = request.parameters["user"]?.string else {
			weblog("User nick is required")
			callback(invalidJson)
			return
		}

		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			weblog("Invalid user nick")
			callback(invalidJson)
			return
		}

		weblog("Fetching user data...")

        var fetch = URLRequest(url: url)
        fetch.httpMethod = "GET"
        fetch.addValue("swiftforums", forHTTPHeaderField: "User-Agent")

		let task = URLSession.shared.dataTask(with: fetch) { data, req, err in
			guard err == nil else {
				weblog("UserInfo error: ", err!)
				callback(invalidJson)
				return
			}

			guard let data = data else { 
				weblog("UserInfo: No data")
				callback(invalidJson)
				return
			}

			do {
				//weblog("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

				guard let nick = json?["login"] as? String,
					  let name = json?["name"] as? String,
					  let avatar = json?["avatar_url"] as? String
				else {
					weblog("User info: Invalid data")
					callback(invalidJson)
					return
				}

				weblog("User info: ", nick, name, avatar)

				//let user = User()
				//user.nick = nick
				//user.name = name
				//user.avatar = avatar
				//user.register()
				//weblog("User registered")

				let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
				weblog("Json: ", info)
				callback(info)
				return
			} catch {
				weblog("Error accessing Github: ", error)
				callback(invalidJson)
				return
			}
		}
		task.resume()

	}
*/

/*
	// API to get user info from github, returns json
	func fetchUserOLD0(_ request: Request) -> ResponseRepresentable {
		guard let user = request.parameters["user"]?.string else {
			weblog("User nick is required")
			return failJson(.userNickRequired)
		}
		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			weblog("Invalid user nick")
			return failJson(.userInfoInvalid)
		}

		do {
			weblog("Fetching user data...")
			let data = try Data(contentsOf: url) // Sync fetch

			weblog("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

			let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

			guard let nick = json?["login"] as? String,
				  let name = json?["name"] as? String,
				  let avatar = json?["avatar_url"] as? String
			else {
				weblog("User info: Invalid data")
				return failJson(.userInfoInvalid)
			}

			weblog("User info: ", nick, name, avatar)

			let user = User()
			user.nick = nick
			user.name = name
			user.avatar = avatar
			user.register()
			weblog("User registered")

			let info = easyJson(["nick": nick, "name": name, "avatar": avatar])

			let response = Response(status: .ok, body: info)
			response.headers["Content-Type"] = "application/json"
			response.cookies["nick"] = nick

			weblog("Session info: ", nick, name, avatar)
			try request.session().data["id"] = Node(user.userid)
			try request.session().data["nick"] = Node(user.nick)
			try request.session().data["name"] = Node(user.name)
			try request.session().data["avatar"] = Node(user.avatar)
			weblog("User in session")

			return response

		} catch {
			weblog("Error accessing Github: ", error)
			return failJson(.errorAccessingGithub)
		}

	}
*/

}

// End