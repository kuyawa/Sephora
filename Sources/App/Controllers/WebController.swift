import Vapor
import HTTP

class WebController {

	var request : Request
	var drop    : Droplet?
	var db      : DataStore?

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

}