import Vapor
import HTTP

class WebController {

	var request  : Request
	var drop     : Droplet?
	var db       : DataStore?
	var settings : Node?
	var userInfo : Node?
	var stats    : Node?
	var forums   : Node?

	init(_ request: Request) {
		self.request = request
	}

	// Use drop
	init(_ request: Request, drop: Droplet) {
		self.request = request
		self.drop = drop
	}

	// Use database
	init(_ request: Request, db: DataStore) {
		self.request = request
		self.db = db
	}

	func getView(_ name: String, with node: Node?) -> View? {
		let drop = Droplet()
		var data = Node(["userIsLogged": false])
		if node != nil { data = node! }

		getBaseInfo()
		data["settings"]     = settings ?? ""
		data["user"]         = userInfo ?? ""
		data["stats"]        = stats ?? ""
		data["forums"]       = forums ?? ""
		data["userIsLogged"] = false // userInfo.isLogged

		do { 
			let view = try drop.view.make(name, data) 
			return view
		}
		catch { 
			print(error) 
			// TODO: return errorView with error info
		}

		return nil
	}

	func getStaticView(_ name: String) -> View? {
		let folder = "../../public/static/"
		let file = folder+name
		let drop = Droplet()

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

		settings = [
			"forum.name" : "Sephora",
			"forum.title": "Join us in our quest to conquer the app world"
		]

		userInfo = [
			"isLogged"  : true,
			"nick"      : "Test",
			"token"     : "e65c4477-b782-4d49-a689-2b6f9bb5419b"
		]

		stats = [
			"users"     :  320,
			"threads"   : 1234,
			"replies"   : 3542,
			"questions" :  156,
			"answered"  :   72,
		]

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