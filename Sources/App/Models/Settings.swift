import Vapor
import Foundation

class Settings: DataQuery {
	var list: [String: String] = [:]

	subscript(key: String) -> String? { 
		get { return list[key] }
		set { list[key] = newValue }
	}

	// Load all settings at once
	func load() -> Settings {
		// TODO: Get from db 
		list = ["forumName": "Sephora - Forums in Swift",
		        "forumTitle": "Join Swift enthusiasts around the world"]
		return self
	}

	// Save all settings
	func save() {
		// TODO: save all key:val to db
	}

	// Save one setting at a time
	func save(key: String, value: String) {
		// TODO: save key:val to db
	}

	func toNode() -> Node {
		var all: [String: Node] = [:]
		for (key,val) in list {
			all[key] = Node(val)
		}
		return try! Node(node: all)
	}
}