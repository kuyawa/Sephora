import Vapor
import Foundation

class Post: DataModel {
    var postid   : Int    = 0
    var forumid  : Int    = 0
    var type     : Int    = 0
    var date     : Date   = Date()
    var userid   : Int    = 0
    var nick     : String = ""
    var title    : String = ""
    var content  : String = ""
    var views    : Int    = 0
    var replies  : Int    = 0
    var answered : Bool   = false
    var sticky   : Bool   = false
    var closed   : Bool   = false
    var hidden   : Bool   = false

    // init() { }

    func fromNode(_ node: Node) throws {
        postid   = try node.extract("postid")
        forumid  = try node.extract("forumid")
        type     = try node.extract("type")
        date     = try node.extract("date", transform: Date.fromString)
        userid   = try node.extract("userid")
        nick     = try node.extract("nick")
        title    = try node.extract("title")
        content  = try node.extract("content")
        views    = try node.extract("views")
        replies  = try node.extract("replies")
        answered = try node.extract("answered")
        sticky   = try node.extract("sticky")
        closed   = try node.extract("closed")
        hidden   = try node.extract("hidden")
    }

    func makeNode() throws -> Node {
        let node = try Node(node: [
            "postid"  : postid,
            "forumid" : forumid,
            "type"    : type,
            "date"    : date.toString(),
            "userid"  : userid,
            "nick"    : nick,
            "title"   : title,
            "content" : content,
            "views"   : views,
            "replies" : replies,
            "answered": answered,
            "sticky"  : sticky,
            "closed"  : closed,
            "hidden"  : hidden
        ])

        return node
    }
}

extension Post {
    func save() {
        // Remove CRs from content, crashing linux
        content = content.removeCR()

        if postid < 1 { // New post, id not generated yet
            insert()
        } else {
            update()
        }
    }
    
    func insert() {
        print("Saving post...")
        // Map data to sql and insert
        let exclude = ["postid", "date", "views", "replies", "answered", "sticky", "closed", "hidden"]
        let fields = getFields(except: exclude)
        let params = getBindingsNode(for: fields)
        let sql    = getSqlInsert(table: "posts", fields: fields, returning: "postid")
        let newId  = db.execute(sql, params: params)

        let id = newId?[0]?["postid"]?.int
        if id == nil {
        	print("Error inserting post, new id not provided")
        	return 
        }

        self.postid = id!
        print("New post Id: ", id!)
    }
    
    func update() {
        print("Updating post: ", postid)
        let exclude = ["postid"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsNode(for: fields)
        let sql     = getSqlUpdate(table: "posts", fields: fields, key: "postid", id: postid)
        let num     = db.execute(sql, params: params)
        
        if num == nil {
            print("Error updating post ", postid)
        }
    }
    
    func delete() {
        let sql = getSqlDelete(table: "posts", key: "postid")
        let args: [Node] = [Node(postid)]
        let num = db.execute(sql, params: args)
        
        if num == nil {
            print("Error deleting post ", postid)
        }
    }
    
    func get(id :Int) -> Post? {
        let sql = "Select * from posts where postid = $1 limit 1"
        let args: [Node] = [Node(id)]
        guard let rows = db.query(sql, params: args) else { return nil }
        guard let node = rows[0] else { return nil }
        try? self.fromNode(node) // Here, if fails, some fields will be set
        return self
    }

    func getReplies() -> Node? {
    	// This sql gets replies including if user voted for it o highlight star
    	/*
    	let sqlx =  "Select r.postid, r.replyid, r.userid, r.nick, r.content, r.date, r.votes, r.answer, v.state as star " + 
    				"From replies r " +
					"Left outer join votes v On r.replyid = v.replyid and v.userid = $1 " + 
					"Where r.postid = $2 And hidden = false " + 
					"Order by r.replyid "
		*/
        let sql = "Select * From replies Where postid = $1 And hidden = false Order by date"
        let args: [Node] = [Node(postid)]
        guard let rows = db.query(sql, params: args) else { return nil }
        
        return rows
    }

    func countView() {
        let sql = "Update posts Set views = views+1 Where postid = $1"
        let args: [Node] = [Node(postid)]
        _ = db.execute(sql, params: args)
    }

    func countReplies() {
        let sql = "Update posts Set replies = replies+1 Where postid = $1"
        let args: [Node] = [Node(postid)]
        _ = db.execute(sql, params: args)
    }

    func hide() {
    	hidden = true
        let sql = "Update posts Set hidden = true Where postid = $1"
        let args: [Node] = [Node(postid)]
        _ = db.execute(sql, params: args)
    }

} 

// End