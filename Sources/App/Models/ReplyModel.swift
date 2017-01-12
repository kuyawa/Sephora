import Vapor
import Foundation

class Reply: DataModel {
    var replyid  : Int    = 0
    var postid   : Int    = 0
    var userid   : Int    = 0
    var nick     : String = ""
    var date     : Date   = Date()
    var content  : String = ""
    var votes    : Int    = 0
    var votesup  : Int    = 0
    var votesdn  : Int    = 0
    var answer   : Bool   = false
    var hidden   : Bool   = false

    // init() { }

    func fromNode(_ node: Node) throws {
		replyid	= try node.extract("replyid")
		postid	= try node.extract("postid")
		userid	= try node.extract("userid")
		nick	= try node.extract("nick")
		date	= try node.extract("date", transform: Date.fromString)
		content	= try node.extract("content")
		votes	= try node.extract("votes")
		votesup	= try node.extract("votesup")
		votesdn	= try node.extract("votesdn")
		answer	= try node.extract("answer")
		hidden	= try node.extract("hidden")
    }

    func makeNode() throws -> Node {
        let node = try Node(node: [
			"replyid" : replyid,
			"postid"  : postid,
			"userid"  : userid,
			"nick"	  : nick,
			"date"	  : date.toString(),
			"content" : content,
			"votes"	  : votes,
			"votesup" : votesup,
			"votesdn" : votesdn,
			"answer"  : answer,
			"hidden"  : hidden
        ])

        return node
    }
}

extension Reply {
    func save() {
        // Remove CRs from content, crashing linux
        content = content.removeCR()

        if replyid < 1 { // New post, id not generated yet
            insert()
        } else {
            update()
        }
    }
    
    func insert() {
        print("Saving reply...")
        // Map data to sql and insert
        let exclude = ["replyid", "date", "votes", "votesup", "votesdn", "answer", "hidden"]
        let fields = getFields(except: exclude)
        let params = getBindingsNode(for: fields)
        let sql    = getSqlInsert(table: "replies", fields: fields, returning: "replyid")
        let newId  = db.execute(sql, params: params)
        
        let id = newId?[0]?["replyid"]?.int
        if id == nil {
        	print("Error inserting reply, new id not provided")
        	return 
        }

        self.replyid = id!
        print("New reply Id: ", id!)

        countReply(postid)
    }
    
    func update() {
        print("Updating reply: ", replyid)
        let exclude = ["reply"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsNode(for: fields)
        let sql     = getSqlUpdate(table: "replies", fields: fields, key: "replyid", id: replyid)
        let num     = db.execute(sql, params: params)
        
        if num == nil {
            print("Error updating reply ", replyid)
        }
    }
    
    func delete() {
        let sql = getSqlDelete(table: "replies", key: "replyid")
        let args: [Node] = [Node(replyid)]
        let num = db.execute(sql, params: args)
        
        if num == nil {
            print("Error deleting reply ", replyid)
        }
    }
    
    func get(id :Int) -> Reply? {
        let sql = "Select * from replies where replyid = $1 limit 1"
        let args: [Node] = [Node(id)]
        guard let rows = db.query(sql, params: args) else { return nil }
        guard let node = rows[0] else { return nil }
        try? self.fromNode(node)
        return self
    }

    func countReply(_ postId: Int) {
        let sql = "Update posts set replies = replies+1 where postid = $1"
        let args: [Node] = [Node(postid)]
        _ = db.execute(sql, params: args)
    }

    func hide() {
        let sql = "Update replies Set hidden = true Where replyid = $1"
        let args: [Node] = [Node(replyid)]
        let num = db.execute(sql, params: args)
        
        if num == nil {
            print("Error deleting reply ", replyid)
        }
    }

    func answer(_ ok: Int) {
    	var sql = ""
    	if ok == 1 {
        	sql = "Update replies Set answer = true Where replyid = $1"
    	} else {
        	sql = "Update replies Set answer = false Where replyid = $1"
    	}

        let args: [Node] = [Node(replyid)]
        let num = db.execute(sql, params: args)
        
        if num == nil {
            print("Error selecting answer for reply ", replyid)
        }

        // Update post
       	let sql2 = "Update posts Set answered = true Where postid = $1"
        let args2: [Node] = [Node(postid)]
        let num2 = db.execute(sql2, params: args2)

        if num2 == nil {
            print("Error selecting answer for post ", postid)
        }
    }

    func star(_ state: Int) {
		print("API Star \(state) for reply id: ", replyid)

    	var sql = ""
    	if state == 1 {
        	sql = "Update replies Set votes = votes + 1, votesup = votesup + 1 Where replyid = $1"
    	} else {
        	sql = "Update replies Set votes = votes - 1, votesup = votesup - 1 Where replyid = $1"
    	}

        let args: [Node] = [Node(replyid)]
        let num = db.execute(sql, params: args)
        
        if num == nil {
            print("Error starring reply ", replyid)
        }
    }

    // karma up/down on comment star
    func karma(_ state: Int) {
		print("API Karma \(state) for reply id: ", replyid)
    	if self.nick.isEmpty { return }
    	
    	var sql  = "Update users Set karma = karma + 1 Where nick = $1"
    	if state == 0 { sql  = "Update users Set karma = karma - 1 Where nick = $1" }

    	let args = [Node(self.nick)]
        _ = db.execute(sql, params: args)
    }

} 

// End