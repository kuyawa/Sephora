import Vapor
import HTTP
import Foundation


typealias Callback1 = (_ token: String?) -> Void
typealias Callback2 = (_ nick: String?) -> Void

class LoginHandler: WebController {

	func login(_ request: Request) -> ResponseRepresentable {
		// TODO: User session
		// Send to Github for login
		// on authorize, redirect to index

		// TODO: CHANGE CALLBACK IN GITHUB OAUTH SETTINGS WHEN GOING LIVE IN HEROKU!!!

		print("Starting authentication...")
		guard let clientId = drop.config["github", "clientid"]?.string else {
			print("Secret credentials not found")
			return fail(.missingCredentials)
		}

		let stateId  = UUID().uuidString   // TODO: save in session
		let loginUrl = "https://github.com/login/oauth/authorize?client_id=\(clientId)&state=\(stateId)"

		//print("Login url: ", loginUrl)

		return AppHandler().redirect(loginUrl)
	}

	func logout(_ request: Request) -> ResponseRepresentable {
		// TODO: clear cookies and session, remove token from user.token
		print("Logged out")
		return AppHandler().redirectToIndex()
	}

	// Callback grom Github oAuth reqeust
	func authorize(_ request: Request) -> ResponseRepresentable {
		if let errorCode = request.data["error"] {
			print("Login error: ", errorCode)
			let message = request.data["error_description"]
			return fail(.unauthorizedAccess, content: message?.string)
		}

		guard let code  = request.data["code"]?.string 
		      //let state = request.data["state"]?.string 
		else { 
			return fail(.unauthorizedAccess, content: "Error: Incorrect response received from server") 
		}

		//print("Login Code: ", code, state)

		do {
			try requestAuthToken(code) { token in
				guard let token = token else { 
					print("Error: Nil token")
					return //self.fail(.invalidCredentials)
				}

				do {
					try self.requestUserInfo(token) { nick in 
						guard nick != nil else {
							print("Error: Nil nick")
							return  //self.fail(.invalidCredentials)
						}

						print("User nick: ", nick!)
						// save user info
						// Redirect to index
						return //AppHandler().redirectToIndex()
					}
				} catch {
					print("Nick error: ", error)
            		return //fail(.authorizationError)
				}
			}
        } catch {
            print(error)
            return fail(.authorizationError)
        }

		print("Exiting /authorize...")
		return AppHandler().redirectToIndex()
	}

	func requestAuthToken(_ code: String, callback: @escaping (_ token: String?) -> Void) throws {
		guard let clientId = drop.config["github", "clientid"]?.string,
		      let secret   = drop.config["github", "secret"]?.string
		else {
			print("Secret credentials not found")
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

	func requestUserInfo(_ token: String, callback: @escaping (_ nick: String?) -> Void) throws {
		// Use GET with token in header
		//   Authorization: token OAUTH-TOKEN
		//   https://api.github.com/user
		// or use GET with args
		//   https://api.github.com/user?access_token=xxx order
		let url = URL(string: "https://api.github.com/user?access_token="+token)

		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
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
				let nick = json?["login"] as? String
				let name = json?["name"] as? String
				let avatar = json?["avatar_url"] as? String
				print("User info: ", nick!, name!, avatar!)
				callback(nick)
			} catch {
				print("UserInfo Json error: ", error)
			}
		}
		task.resume()

		print("Exiting userInfo")
		return
	}

}

// End