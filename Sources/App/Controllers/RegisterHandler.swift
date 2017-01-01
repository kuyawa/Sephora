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
			db.log("User nick is required")
			return invalidJson
		}

		let url = "http://app-data-mobile.appspot.com/test/fetchuser?nick=\(id)"
		//let url = "https://api.github.com/users/\(id)"

		db.log("Fetching user data for \(id)")

		do {
			// headers: ["User-Agent":"swiftforums"]
			let response = try drop.client.get(url)
			let json = response.json
			
			//db.log("Response: \(response)")
			//db.log("Response body: \(response.body)")
			//db.log("Response json: \(response.json)")
			db.log("Github name: \(json?["name"]?.string)")

			//let json = String(data: response.body, encoding: .utf8)

			guard let nick = json?["login"]?.string,
				  let name = json?["name"]?.string,
				  let avatar = json?["avatar_url"]?.string
			else {
				db.log("User info: Invalid json data")
				return invalidJson
			}

			db.log("User info: \(nick), \(name), \(avatar)")

			let user = User()
			user.nick = nick
			user.name = name
			user.avatar = avatar
			user.register()
			db.log("User registered")

			let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
			db.log("Json: \(info)")

			return info
		} catch {
			db.log("Error fetching user data: \(error)")
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
			db.log("User nick is required")
			callback(invalidJson)
			return
		}

		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			db.log("Invalid user nick")
			callback(invalidJson)
			return
		}

		db.log("Fetching user data...")

        var fetch = URLRequest(url: url)
        fetch.httpMethod = "GET"
        fetch.addValue("swiftforums", forHTTPHeaderField: "User-Agent")

		let task = URLSession.shared.dataTask(with: fetch) { data, req, err in
			guard err == nil else {
				db.log("UserInfo error: ", err!)
				callback(invalidJson)
				return
			}

			guard let data = data else { 
				db.log("UserInfo: No data")
				callback(invalidJson)
				return
			}

			do {
				//db.log("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

				guard let nick = json?["login"] as? String,
					  let name = json?["name"] as? String,
					  let avatar = json?["avatar_url"] as? String
				else {
					db.log("User info: Invalid data")
					callback(invalidJson)
					return
				}

				db.log("User info: ", nick, name, avatar)

				let user = User()
				user.nick = nick
				user.name = name
				user.avatar = avatar
				user.register()
				db.log("User registered")

				let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
				db.log("Json: ", info)
				callback(info)
				return
			} catch {
				db.log("Error accessing Github: ", error)
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
			db.log("User nick is required")
			callback(invalidJson)
			return
		}

		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			db.log("Invalid user nick")
			callback(invalidJson)
			return
		}

		db.log("Fetching user data...")

        var fetch = URLRequest(url: url)
        fetch.httpMethod = "GET"
        fetch.addValue("swiftforums", forHTTPHeaderField: "User-Agent")

		let task = URLSession.shared.dataTask(with: fetch) { data, req, err in
			guard err == nil else {
				db.log("UserInfo error: ", err!)
				callback(invalidJson)
				return
			}

			guard let data = data else { 
				db.log("UserInfo: No data")
				callback(invalidJson)
				return
			}

			do {
				//db.log("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

				guard let nick = json?["login"] as? String,
					  let name = json?["name"] as? String,
					  let avatar = json?["avatar_url"] as? String
				else {
					db.log("User info: Invalid data")
					callback(invalidJson)
					return
				}

				db.log("User info: ", nick, name, avatar)

				//let user = User()
				//user.nick = nick
				//user.name = name
				//user.avatar = avatar
				//user.register()
				//db.log("User registered")

				let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
				db.log("Json: ", info)
				callback(info)
				return
			} catch {
				db.log("Error accessing Github: ", error)
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
			db.log("User nick is required")
			return failJson(.userNickRequired)
		}
		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			db.log("Invalid user nick")
			return failJson(.userInfoInvalid)
		}

		do {
			db.log("Fetching user data...")
			let data = try Data(contentsOf: url) // Sync fetch

			db.log("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

			let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

			guard let nick = json?["login"] as? String,
				  let name = json?["name"] as? String,
				  let avatar = json?["avatar_url"] as? String
			else {
				db.log("User info: Invalid data")
				return failJson(.userInfoInvalid)
			}

			db.log("User info: ", nick, name, avatar)

			let user = User()
			user.nick = nick
			user.name = name
			user.avatar = avatar
			user.register()
			db.log("User registered")

			let info = easyJson(["nick": nick, "name": name, "avatar": avatar])

			let response = Response(status: .ok, body: info)
			response.headers["Content-Type"] = "application/json"
			response.cookies["nick"] = nick

			db.log("Session info: ", nick, name, avatar)
			try request.session().data["id"] = Node(user.userid)
			try request.session().data["nick"] = Node(user.nick)
			try request.session().data["name"] = Node(user.name)
			try request.session().data["avatar"] = Node(user.avatar)
			db.log("User in session")

			return response

		} catch {
			db.log("Error accessing Github: ", error)
			return failJson(.errorAccessingGithub)
		}

	}
*/

}

// End