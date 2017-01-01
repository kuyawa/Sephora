import Vapor
import HTTP

class TestHandler: WebController {

	func show(_ request: Request) -> ResponseRepresentable {

		// Tests here
		let result = testRegex()

		let data: Node = try! Node(node: ["$test": Node(result)])
		//let data: Node = try! Node(node: ["name": "Kuyawa", "phone": "555-1234", "email": "kuyawa@example.com"])

		let context = getContext(request)
		let view = getView("test", with: data, in: context)
		
		return view!

	}

	func testRegex() -> String{
		let regx = "<img src='(.*?)'>"
		let html = "<html> <img src='image.png'> <img src='album.png'> </html>"
		let img  = html.matchFirst(regx)
		let imgs = html.matchAll(regx)
		let res  = "Test regex: \(img) + \(imgs)"
		db.log(res)
		return res
	}

}