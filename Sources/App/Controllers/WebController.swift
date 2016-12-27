import Vapor
import HTTP

class WebController {

	var drop     = Droplet()

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
 				//leaf.stem.register(LeafTimeAgo())
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


}