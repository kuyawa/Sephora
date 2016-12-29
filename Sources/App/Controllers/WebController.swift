import Vapor
import VaporPostgreSQL
import Foundation
import HTTP

class WebController {

	var drop     = Droplet()
	var db       = DataStore()

	func getView(_ name: String, with data: Node? = nil, in context: Node? = nil) -> View? {
		var info = Node(["$test": "test"])

		// Add all data and context to main node
		if data != nil { 
			for (key,val) in data!.nodeObject! {
				info[key] = val 
			}
		}

		if context != nil { 
			for (key,val) in context!.nodeObject! {
				info[key] = val 
			}
		}

		do { 
			if let leaf = drop.view as? LeafRenderer {
 				leaf.stem.register(LeafTimeAgo())
 				leaf.stem.register(LeafTimeOnly())
 				//leaf.stem.register(LeafMarkdown())
				let view = try leaf.make(name, info) 
				return view
			}
		} catch { 
			print(error) 
			// TODO: return errorView with error info
		}

		return nil
	}


	func getStaticView(_ name: String) -> View? {
		let folder = "../../public/static/"
		let file = folder+name

		do { 
			let view = try drop.view.make(file)
			return view
		}
		catch { 
			print(error) 
			// TODO: return errorView with error info
		}

		return nil
	}


	func getContext(_ request: Request) -> Node {
		// TODO: get all from database
		// TODO: Get from cache to avoid data hits

		//print("--Cookies: ", request.cookies)
		//if let session = try? request.session() {
			//print("--Session: ", session.data)
		//}


		let userInfo = UserInfo(in: db).fromSession(request)
		let user     = userInfo.toNode()
		let logged   = Node(userInfo.isLogged)
		let settings = Settings(in: db).load().toNode()
		let stats    = Stats(in: db).gather().toNode()
		//let forums   = Forums(in: db).getSidebar()!

		// Context goes prefixed with $ to avoid collisions with request data
		let node: Node = try! Node(node: [
			"$userInfo"     : user,
			"$settings"     : settings,
			"$stats"        : stats,
			"$userIsLogged" : logged
			/*"$forums"       : forums*/
		])

		//print("--Context: ", node)
		return node
	}


	func getConfigSecrets(host: String) -> (String, String) {
		var clientLabel = "clientid-live"
		var secretLabel = "secret-live"

		if drop.environment == .development { 
			if host == "localhost" || host == "127.0.0.1" {
				clientLabel = "clientid-local"
				secretLabel = "secret-local"
			} else {
				clientLabel = "clientid-dev"
				secretLabel = "secret-dev"
			}
		}

		print(clientLabel, secretLabel)

		guard let clientId = drop.config["github", clientLabel]?.string,
		      let secret   = drop.config["github", secretLabel]?.string
		else {
			print("Secret credentials not found")
			return ("","")
		}
		
		return (clientId, secret)
	}

	func weblog(_ text: String) {
		print("- ", text)
		_ = db.execute("Insert into weblogs(text) values($1)", params: [Node(text)])
	}

}

// End