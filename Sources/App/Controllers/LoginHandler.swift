import Vapor
import HTTP
import Foundation
import Cookies

/*

	On register, user provides github ID and id is saved in db
	To log in, user gets code from github, code is saved in db using nick from cookies

*/


class LoginHandler: WebController {

	func login(_ request: Request) -> ResponseRepresentable {
		// If we already have a nick send him to github directly
		if let nick = request.cookies["nick"] {
			if !nick.isEmpty {
				return Response(redirect: "/login/github/\(nick)")  // Redirect
			}
		}

		// else ask for nick, verify info
		let context = getContext(request)
		let view = getView("login", in: context)

		return view!

	}

	func loginGithub(_ request: Request) -> ResponseRepresentable {
		print("Starting authentication...")

		guard let nick = request.parameters["user"]?.string else {
			return fail(.unauthorizedAccess, content: "Error: Incorrect login credentials") 
		}

		try? request.session().data["nick"] = Node(nick) // Assign to session

		// Change accordingly to live, dev, local
		print("Host: \(request.uri.host)")
		let (clientId, secretId) = getConfigSecrets(host: request.uri.host)
		//print("\(clientId)\(secretId)")

		if clientId.isEmpty || secretId.isEmpty {
			print("Secret credentials not found")
			return fail(.missingCredentials)
		}

		let stateId  = UUID().uuidString

		if let user = User(in: db).get(nick: nick) {
			print("Saving user in session...")
			user.saveAuthState(stateId)
		} else { /* Register */
			print("Registering user after login...")
			let user = User(in: db)
			user.nick = nick
			user.state = stateId
			user.save()
		}

		let loginUrl = "https://github.com/login/oauth/authorize?client_id=\(clientId)&state=\(stateId)"
		let response = Response(redirect: loginUrl)
		
		let cookieNick = Cookie(
			name     : "nick", 
			value    : nick, 
			expires  : Date.nextYear,
			maxAge   : 60*60*24*365,
    		domain   : "",
    		path     : "",
    		secure   : false,
    		httpOnly : false
    	)

		//response.cookies["nick"] = nick
		response.cookies.insert(cookieNick)
		//print("Cookies: ", cookieNick.serialize())

		return response
	}


	// Callback from Github oAuth reqeust
	func authorize(_ request: Request) -> ResponseRepresentable {
		if let errorCode = request.data["error"] {
			print("Login error: ", errorCode)
			let message = request.data["error_description"]
			return fail(.unauthorizedAccess, content: message?.string)
		}

		guard let code  = request.data["code"]?.string, 
		      let state = request.data["state"]?.string 
		else { 
			return fail(.unauthorizedAccess, content: "Error: Incorrect response received from server") 
		}

		//print("Login Code: ", code, state)

		guard let user = User().get(state: state) else {
			// state from github not found in db
			return fail(.unauthorizedAccess, content: "Error: Incorrect credentials in database")
		}
		
		user.islogged = true

		let (clientId, secret) = getConfigSecrets(host: request.uri.host)
		//print("Secrets: ", clientId, secret)

		var validateUser = true
		if clientId.isEmpty || secret.isEmpty {
			print("Secret credentials not found")
			validateUser = false
		}

		if user.code == code {
			print("User already validated")
			validateUser = false
		} else {
			user.saveAuthCode(code)
			validateUser = true
		}
		print("Validate user? ", validateUser)
		
		// If credentials not valid yet: validate credentials
		// This async process does not affect main process


/* TODO: FIX TOMORROW

		if !user.isvalid && validateUser {
			do {
				try requestAuthToken(code: code, clientId: clientId, secret: secret) { token in
					guard let token = token else { 
						print("Error: Nil token")
						return
					}
					
					//user.saveAuthToken(token)

					do {
						try self.requestUserInfo(token) { info in 
							guard let info = info else {
								print("Error: User Info is nil")
								return
							}

							//print("User nick: ", info.nick)
							//print("User name: ", info.name)
							//print("User avatar: ", info.avatar)

							user.nick = info.nick
							user.name = info.name
							user.avatar = info.avatar
							user.token = token
							user.lastact = Date()
							user.isvalid = true
							user.save()

							return
						}
					} catch {
						print("User Info error: ", error)
	            		return
					}
				}
	        } catch {
	            print("User Auth Error: ", error)
	            return fail(.unauthorizedAccess, content: "Error: Incorrect response received from server") 
	        }
		}
*/

		try? request.session().data["userid"]   = Node(user.userid)
		try? request.session().data["nick"]     = Node(user.nick)
		try? request.session().data["name"]     = Node(user.name)
		try? request.session().data["avatar"]   = Node(user.avatar)
		try? request.session().data["isLogged"] = Node(true)

		let response = Response(redirect: "/")
		response.cookies["nick"] = user.nick

		print("Exiting /authorize...")
		return response
	}


/*
	// Auth token necessary for github API
	func requestAuthToken(code: String, clientId: String, secret: String, callback: @escaping (_ token: String?) -> Void) throws {
		guard !clientId.isEmpty, !secret.isEmpty else {
			print("Secret credentials not valid")
			callback(nil)
			return
		}

		let url = URL(string: "https://github.com/login/oauth/access_token?client_id=\(clientId)&client_secret=\(secret)&code=\(code)")

        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        //request.httpBody = text.data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // POST!
		let task = URLSession.shared.dataTask(with: request) { data, response, error in 
			guard error == nil else {
				print("AuthToken error: ", error!)
				callback(nil)
				return
			}
			guard data != nil else { 
				print("AuthToken: No data")
				callback(nil)
				return
			}

			do {
				let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
				guard let token = json?["access_token"] as? String
				      //let ttype = json?["token_type"] as? String,
				      //let ttype = json?["scope"] as? String
				else {
					print("AuthoToken: Invalid credentials")
					//let error = NSError(domain: "RequestAuthToken", code: 500, userInfo: ["error":"Token not received"])
					callback(nil)
					return
				}
				callback(token)
			} catch {
				print("AuthToken JSON Error: ", error)
			}
		}
		task.resume()

		print("Exiting authtoken")
		return
	}

	// TODO: Once code and state are received, request user info and update user in DB with info from github, check for impersonation
	func requestUserInfo(_ token: String, callback: @escaping (_ userInfo: UserInfo?) -> Void) throws {
		// Use GET with token in header
		//	 User-Agent: swiftforums
		//   Authorization: {token} OAUTH-TOKEN
		//   https://api.github.com/user
		// or use GET with args
		//   https://api.github.com/user?access_token=xxx

		// TODO: Use request, header as User-Agent: swiftforums
		let url = URL(string: "https://api.github.com/user?access_token="+token)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("swiftforums", forHTTPHeaderField: "User-Agent")

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				print("UserInfo error: ", error!)
				callback(nil)
				return
			}

			guard data != nil else { 
				print("UserInfo: No nick")
				callback(nil)
				return
			}

			do {
				let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
				let nick = json?["login"] as? String ?? ""
				let name = json?["name"] as? String ?? ""
				let avatar = json?["avatar_url"] as? String ?? ""
				//print("User info: ", nick, name, avatar)
				if nick.isEmpty { callback(nil) }

				let info = UserInfo()
				info.nick = nick
				info.name = name
				info.avatar = avatar

				callback(info)
			} catch {
				print("UserInfo Json error: ", error)
				callback(nil)
			}
		}
		task.resume()

		print("Exiting userInfo")
		return
	}
*/

	// Clear cookies and session, remove token from user.token, user.islogged=false, lastact=now
	func logout(_ request: Request) -> ResponseRepresentable {
		print("Logged out")

		if let session = try? request.session() {
			session.data["userid"]   = Node(0)
			session.data["nick"]     = Node("")
			session.data["name"]     = Node("")
			session.data["avatar"]   = Node("")
			session.data["karma"]    = Node(0)
			session.data["isLogged"] = Node(false)
		}

		let response = Response(redirect: "/")
		response.cookies["nick"] = ""

		return response
	}

}

// End