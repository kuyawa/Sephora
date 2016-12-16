import Vapor
import HTTP

class IndexHandler: WebController {

	var view : View {
		let data = getData()
		let view = getView("index", with: data)
		return view!
	}

	func getData() -> Node {
		let data: Node = [
			"test":"tested",
			"settings": [
				"forumName" : "Sephora",
				"forumTitle": "Join us in our quest to conquer the app world"
			],
			"stats": [
				"users"     :  320,
				"threads"   : 1234,
				"replies"   : 3542,
				"questions" :  156,
				"answered"  :   72,
			],
			"forums": [
				["General discussion", "/forum/general", 123],
				["Tutorials", "/forum/tutorials", 32],
				["Swift 3", "/forum/swift3", 45],
				["Swift 2", "/forum/swift2", 12],
				["iOS", "/forum/ios", 95],
				["macOS", "/forum/macos", 64],
				["watchOS", "/forum/watchos", 9],
				["tvOS", "/forum/tvos", 22],
				["Server", "/forum/server", 45],
				["Frameworks", "/forum/frameworks", 38],
				["Apps Showcase", "/forum/showcase", 20],
				["Request Apps", "/forum/request", 15],
				["Jobs - Hiring", "/forum/hiring", 32],
				["Jobs - For Hire", "/forum/forhire", 78],
				["Meta", "/forum/meta", 7]
			],
			"messages":[
				[123456, 321, 12, 0, "XCode ate my homework", "General discussion", "2016-11-26 08:30:55", "Albatross"],
				[123455, 655, 15, 0, "How to create a segue programmatically?", "General discussion", "2016-11-26 07:45:22", "RosiePosie"],
				[123454, 128,  3, 1, "Icon size for watch?", "watchOS", "2016-11-26 07:39:54", "Unobtanium"],
				[123453, 269, 20, 0, "Postgres or MySql?", "Swift Server", "2016-11-26 06:14:31", "KhanKhan"]
			],
			"page":0,
			"pagination":[0,100,200,300,400]
		]

		return data
	}

}

// End