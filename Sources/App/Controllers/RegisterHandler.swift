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
			print("User nick is required")
			return invalidJson
		}

		let url = "http://app-data-mobile.appspot.com/test/fetchuser?nick=\(id)"
		//let url = "https://api.github.com/users/\(id)"

		print("Fetching user data for \(id)")

		do {
			// headers: ["User-Agent":"swiftforums"]
			let response = try drop.client.get(url)
			let json = response.json
			
			//print("Response: \(response)")
			//print("Response body: \(response.body)")
			//print("Response json: \(response.json)")
			print("Github name: \(json?["name"]?.string)")

			//let json = String(data: response.body, encoding: .utf8)

			guard let nick = json?["login"]?.string,
				  let name = json?["name"]?.string,
				  let avatar = json?["avatar_url"]?.string
			else {
				print("User info: Invalid json data")
				return invalidJson
			}

			print("User info: \(nick), \(name), \(avatar)")

			let user = User()
			user.nick = nick
			user.name = name
			user.avatar = avatar
			user.register()
			print("User registered")

			let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
			print("Json: \(info)")

			return info
		} catch {
			print("Error fetching user data: \(error)")
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
			print("User nick is required")
			callback(invalidJson)
			return
		}

		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			print("Invalid user nick")
			callback(invalidJson)
			return
		}

		print("Fetching user data...")

        var fetch = URLRequest(url: url)
        fetch.httpMethod = "GET"
        fetch.addValue("swiftforums", forHTTPHeaderField: "User-Agent")

		let task = URLSession.shared.dataTask(with: fetch) { data, req, err in
			guard err == nil else {
				print("UserInfo error: ", err!)
				callback(invalidJson)
				return
			}

			guard let data = data else { 
				print("UserInfo: No data")
				callback(invalidJson)
				return
			}

			do {
				//print("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

				guard let nick = json?["login"] as? String,
					  let name = json?["name"] as? String,
					  let avatar = json?["avatar_url"] as? String
				else {
					print("User info: Invalid data")
					callback(invalidJson)
					return
				}

				print("User info: ", nick, name, avatar)

				let user = User()
				user.nick = nick
				user.name = name
				user.avatar = avatar
				user.register()
				print("User registered")

				let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
				print("Json: ", info)
				callback(info)
				return
			} catch {
				print("Error accessing Github: ", error)
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
			print("User nick is required")
			callback(invalidJson)
			return
		}

		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			print("Invalid user nick")
			callback(invalidJson)
			return
		}

		print("Fetching user data...")

        var fetch = URLRequest(url: url)
        fetch.httpMethod = "GET"
        fetch.addValue("swiftforums", forHTTPHeaderField: "User-Agent")

		let task = URLSession.shared.dataTask(with: fetch) { data, req, err in
			guard err == nil else {
				print("UserInfo error: ", err!)
				callback(invalidJson)
				return
			}

			guard let data = data else { 
				print("UserInfo: No data")
				callback(invalidJson)
				return
			}

			do {
				//print("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]

				guard let nick = json?["login"] as? String,
					  let name = json?["name"] as? String,
					  let avatar = json?["avatar_url"] as? String
				else {
					print("User info: Invalid data")
					callback(invalidJson)
					return
				}

				print("User info: ", nick, name, avatar)

				//let user = User()
				//user.nick = nick
				//user.name = name
				//user.avatar = avatar
				//user.register()
				//print("User registered")

				let info = self.easyJson(["nick": nick, "name": name, "avatar": avatar])
				print("Json: ", info)
				callback(info)
				return
			} catch {
				print("Error accessing Github: ", error)
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
			print("User nick is required")
			return failJson(.userNickRequired)
		}
		guard let url = URL(string: "http://api.github.com/users/\(user)") else {
			print("Invalid user nick")
			return failJson(.userInfoInvalid)
		}

		do {
			print("Fetching user data...")
			let data = try Data(contentsOf: url) // Sync fetch

			print("User Info: \n", String(data: data, encoding: .utf8) ?? "No data")

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
			print("User registered")

			let info = easyJson(["nick": nick, "name": name, "avatar": avatar])

			let response = Response(status: .ok, body: info)
			response.headers["Content-Type"] = "application/json"
			response.cookies["nick"] = nick

			print("Session info: ", nick, name, avatar)
			try request.session().data["id"] = Node(user.userid)
			try request.session().data["nick"] = Node(user.nick)
			try request.session().data["name"] = Node(user.name)
			try request.session().data["avatar"] = Node(user.avatar)
			print("User in session")

			return response

		} catch {
			print("Error accessing Github: ", error)
			return failJson(.errorAccessingGithub)
		}

	}
*/

}

// End