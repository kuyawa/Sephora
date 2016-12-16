import Vapor
import HTTP

class WebController {

	var request : Request

	init(_ request: Request) {
		self.request = request
	}

	func getView(_ name: String, with data: Node?) -> View? {
		let drop = Droplet()
		do { 
			let view = try drop.view.make(name, data!) 
			return view
		}
		catch { 
			print(error) 
			// TODO: return errorView with error info
		}

		return nil
	}

	func getStaticView(_ name: String) -> View? {
		let folder = "../../public/"
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

}