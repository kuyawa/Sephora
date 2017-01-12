import Vapor
import HTTP
import Foundation

// Used to store session info
class UserInfo: DataQuery {
	var userid : Int    = 0
	var nick   : String = "anonymous"
	var name   : String = "John Doe"
	var avatar : String = "/images/unknown.png"
	var karma  : Int    = 0
	var isLogged = false

	func fromSession(_ request: Request) -> UserInfo {
		//print("Checking session...")
		guard let session = try? request.session(), let nick = session.data["nick"]?.string else {
			print("No session. Checking cookies...")
			if let nick = request.cookies["nick"] {
				if !nick.isEmpty {
					print("Cookie nick: ", nick)
					getByNick(nick)
					setUserSession(request)
					self.isLogged = true
				}
			}
			// No cookies either, logged off
			return self 
		}

		// Session info
		if nick.isEmpty || nick == "anonymous" { 
			if let nick = request.cookies["nick"] {
				print("Cookie nick: ", nick)
				if !nick.isEmpty {
					getByNick(nick)
					setUserSession(request)
					self.isLogged = true
				}
			}
		} else {
			self.nick = nick
			if let userid = session.data["userid"]?.int    { self.userid = userid }
			if let name   = session.data["name"]?.string   { self.name   = name   }
			if let avatar = session.data["avatar"]?.string { self.avatar = avatar }
			if let karma  = session.data["karma"]?.int     { self.karma  = karma  }
			self.isLogged = true
		}

		//print("User info: \(self.toNode())")
		//print("Session info: \(session)")
		//print("Cookies info: \(request.cookies)")

	    return self
	}

	func toNode() -> Node {
		let node: Node = Node([
			"userid"  : Node(userid),
			"nick"    : Node.string(nick),
			"name"    : Node.string(name),
			"avatar"  : Node.string(avatar),
			"karma"   : Node(karma),
			"isLogged": Node.bool(isLogged)
		])

		return node
	}

    func fromNode(_ node: Node) throws {
        userid   = try node.extract("userid")
        nick     = try node.extract("nick")
        name     = try node.extract("name")
        avatar   = try node.extract("avatar")
        karma    = try node.extract("karma")
        isLogged = true
	}

	func getByNick(_ nick: String) {
		print("Fetching user info from DB")
		let sql = "Select userid, nick, name, avatar, karma From users Where nick=$1 Limit 1"
		let params = [Node(nick)]
		let rows = db.query(sql, params: params)
		if rows != nil {
			let row = rows![0]
			try? fromNode(row!)
		}
	}

	func setUserSession(_ request: Request) {
		print("Setting user session")
		try? request.session().data["userid"]   = Node(userid)
		try? request.session().data["nick"]     = Node(nick)
		try? request.session().data["name"]     = Node(name)
		try? request.session().data["avatar"]   = Node(avatar)
		try? request.session().data["karma"]    = Node(karma)
		try? request.session().data["isLogged"] = Node(true)
	}
/*
	func updateKarma(_ state: Int) {
		var num = 1
		if state == 0 { num = -1 }
		if nick.isEmpty || nick == "anonymous" { return }
		try? request.session().data["karma"] = Node(karma+num)
	}
*/
}

// End