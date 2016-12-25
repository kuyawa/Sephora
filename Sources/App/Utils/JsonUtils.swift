import Foundation
import JSON

class EasyJson {
	static func easyJson(_ data: Node) -> String {
		let error =	"{\"error\":\"Invalid json\"}"
		let json = try? JSON(node: Node(data)) 
		print("EASYJSON: ", json)
		if json == nil {
			return error
		}
		return json!.string!
	}

	static func easyJson(_ dixy: [String: Any]) -> String {
		let error = "{\"error\":\"Invalid json\"}"
		guard let data = try? JSONSerialization.data(withJSONObject: dixy, options: .prettyPrinted) else { return error }
		let json = String(data: data, encoding: .utf8) ?? error
		print("EASYJSON: ", json)
		return json
	}
}

//END