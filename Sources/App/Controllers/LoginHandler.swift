import Vapor
import HTTP
import Foundation


typealias Callback1 = (_ token: String?) -> Void
typealias Callback2 = (_ nick: String?) -> Void

class LoginHandler: WebController {

	func login(_ request: Request) -> ResponseRepresentable {
		//if drop.environment == .development { login_dev(request) } else { login_live(request) }
		return login_live(request) // test
	}

	func login_dev(_ request: Request) -> ResponseRepresentable {
		let data: Node = ["text": "Not ready"]
		let view = getView("todo", with: data) 
		return view!
	}

	func login_live(_ request: Request) -> ResponseRepresentable {
		// TODO: User session
		// Send to Github for login
		// on authorize, redirect to index
		let stateId  = UUID().uuidString  // save in session
		let clientId = "swiftforums"
		let loginUrl = "https://github.com/login/oauth/authorize?client_id=\(clientId)&state=\(stateId)"
		print("Login url: ", loginUrl)

		// TODO: ENABLE WHEN LIVE IN HEROKU!!!
		return AppHandler().redirect(loginUrl)
		//return loginUrl
	}

	func logout(_ request: Request) -> ResponseRepresentable {
		// TODO: clear cookies and session, remove token from user.token
		print("Logged out")
		return AppHandler().redirectToIndex()
	}

	// Callback grom Github oAuth reqeust
	func authorize(_ request: Request) -> ResponseRepresentable {
		debugPrint(request)

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

		print("Login Code: ", code, state)

/*
		do {
			try requestAuthToken(code) { token in
				print("Token: ", token)
				guard let token = token else { 
					return //self.fail(.invalidCredentials)
				}

				print("Token: ", token)

				do {
					try self.requestUserInfo(token) { nick in 
						print("User nick: ", nick)
						// save user info
						// Redirect to index
						return //AppHandler().redirectToIndex()
					}
				} catch {
					print("Nick error: ", error)
				}
			}
        } catch {
            print(error)
        }
*/

		//	print("Authorization Error: ", error)
		//	return self.fail(.authorizationError)

		print("Exiting /authorize...")
		return AppHandler().redirectToIndex()
	}

	func requestAuthToken(_ code: String, callback: @escaping (_ token: String?) -> Void) throws {
		// TODO: make POST request to github in order to get user info
		// URLRequest post 
		let clientId = "swiftforums"
		let secret = "GITHUB_SECRET" // get from environment?
		let url = URL(string: "https://github.com/login/oauth/access_token?client_id=\(clientId)&client_secret=\(secret)&code=\(code)")

		let task = URLSession.shared.dataTask(with: url!) { data, response, error in 
			guard error == nil else {
				print("RequestAuthToken error: ", error)
				callback(nil)
				return
			}
			guard data != nil else { 
				print("No data")
				callback(nil)
				return
			}
			do {
				let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
				guard let token = json?["access_token"] as? String, 
				      let ttype = json?["token_type"] as? String
				else {
					print("Invalid credentials")
					//let error = NSError(domain: "RequestAuthToken", code: 500, userInfo: ["error":"Token not received"])
					callback(nil)
					return
				}
				print(token, ttype)
				callback(token)
			} catch {
				print("JSON Error: ", error)
			}
		}
		task.resume()

		print("Exiting authtoken")
		return
	}

	func requestUserInfo(_ token: String, callback: @escaping (_ nick: String?) -> Void) throws {
		// Use GET with token in header
		//   Authorization: token OAUTH-TOKEN
		//   https://api.github.com/user
		// or use GET with args
		//   https://api.github.com/user?access_token=xxx order
		let url = URL(string: "htps://api.github.com/user")

		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				print("RequestUserInfo error: ", error)
				callback(nil)
				return
			}

			guard data != nil else { 
				print("No data")
				callback(nil)
				return
			}

			do {
				let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
				let nick = json?["user-login"] as? String
				callback(nick)
			} catch {
				print("Json error: ", error)
			}
		}
		task.resume()

		print("Exiting userInfo")
		return
	}

}