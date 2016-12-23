import Vapor
import VaporPostgreSQL
import Foundation
import HTTP

class WebController {

	var drop     = Droplet()
	var db       = DataStore()
//	var request  : Request?
	var settings = Node(["settings":""])
	var userInfo = Node(["user":""])
	var stats    = Node(["stats":""])
	var forums   = Node(["forums":""])

//	init() {}
/*
	func connect()
		var isLive = false
		if let envDatabase = ProcessInfo.processInfo.environment["DATABASE_URL"] {
			isLive = envDatabase.hasPrefix("postgres")
		}

		self.drop = Droplet()
		try? drop.addProvider(VaporPostgreSQL.Provider.self)
		let driver = drop.database?.driver as! PostgreSQLDriver
		self.db = DataStore(driver, production: isLive)
	}
*/
	func getView(_ name: String, with node: Node?) -> View? {
		var data = Node(["userIsLogged": false])
		if node != nil { data = node! }

		getBaseInfo()
		data["settings"]     = settings
		data["user"]         = userInfo
		data["stats"]        = stats
		data["forums"]       = forums
		data["userIsLogged"] = false // userInfo.isLogged

		do { 
			if let leaf = drop.view as? LeafRenderer {
				// TODO: REGISTER ALL TEMPLATE FILTERS?
 				leaf.stem.register(LeafTimeAgo())
 				leaf.stem.register(LeafMarkdown())
				let view = try leaf.make(name, data) 
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

	func getBaseInfo() {
		// TODO: get all from database
		// TODO: Get from cache to avoid data hits

		// TODO: let settings = Settings(in: db).load()
		settings = [
			"forum.name" : "Sephora",
			"forum.title": "Join us in our quest to conquer the app world"
		]

		// TODO: let user = User(in: db).fromSession()
		userInfo = [
			"isLogged"  : true,
			"nick"      : "Test",
			"token"     : "e65c4477-b782-4d49-a689-2b6f9bb5419b"
		]

		// TODO: let stats = Stats(in: db).gather()
		stats = [
			"users"     :  320,
			"threads"   : 1234,
			"replies"   : 3542,
			"questions" :  156,
			"answered"  :   72,
		]

		// TODO: let forums = Forums(in: db).list()
		forums = [
			["Welcome", "/forum/welcome", 342],
			["General discussion", "/forum/general", 123],
			["Tutorials", "/forum/tutorials", 32],
			["Swift", "/forum/swift", 45],
			["iOS", "/forum/ios", 95],
			["macOS", "/forum/macos", 64],
			["watchOS", "/forum/watchos", 9],
			["tvOS", "/forum/tvos", 22],
			["Server", "/forum/server", 45],
			["Linux", "/forum/linux", 32],
			["Frameworks", "/forum/frameworks", 38],
			["Apps Showcase", "/forum/showcase", 20],
			["Request Apps", "/forum/request", 15],
			["Jobs - Hiring", "/forum/jobs", 32],
			["Jobs - For Hire", "/forum/forhire", 78],
			["Meta", "/forum/meta", 7]
		]
	}

}