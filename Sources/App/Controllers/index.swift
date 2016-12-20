import Vapor
import HTTP
import PostgreSQL

class IndexHandler: WebController {

	var view : View {
		let data = getData()
		let view = getView("index", with: data)
		return view!
	}

	func index(_ request: Request) -> ResponseRepresentable {
		let data = getData()
		let view = getView("index", with: data)
		return view!
	}

	func getData() -> Node {
		//db.connect()
		// Test data
		let result = db.query("Select Version() as version")
		print(result)
		let data: Node = [
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