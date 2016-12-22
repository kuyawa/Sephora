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
        print("Saving post: ", postid)
        if postid < 1 { // New post, id not generated yet
            insert()
        } else {
            update()
        }
    }
    
    func insert() {
        // Map data to sql and insert
        let exclude = ["postid", "date", "views", "replies", "answered", "sticky", "closed", "hidden"]
        let fields = getFields(except: exclude)
        print(fields)
        let params = getBindingsNode(for: fields)
        print(params)
        let sql    = getSqlInsert(table: "posts", fields: fields)
        print(sql)
        let newId  = db.execute(sql, params: params)
        print("New ID: ", newId)
        //postid = newId!.int!
        //print("New post Id:", postid)
    }
    
    func update() {
        let exclude = ["postid"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsNode(for: fields)
        let sql     = getSqlUpdate(table: "posts", fields: fields, params: params, key: "postid", id: postid)
        let num     = db.execute(sql, params: params)
        
        if num!.int! < 1 {
            print("Error \(num) updating post ", postid)
        }
    }
    
    func delete() {
        let sql = getSqlDelete(table: "posts", key: "postid")
        let args: [Node] = [Node(postid)]
        let num = db.execute(sql, params: args)
        
        if num!.int! < 1 {
            print("Error \(num) deleting post ", postid)
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
        let sql = "Select * from replies where postid = $1 order by date"
        let args: [Node] = [Node(postid)]
        guard let rows = db.query(sql, params: args) else { return nil }
        
        return rows
    }

    func countView() {
        let sql = "Update posts set views = views+1 where postid = $1"
        let args: [Node] = [Node(postid)]
        _ = db.execute(sql, params: args)
    }

} 

// End