import Vapor
import Fluent
import Foundation

final class Post: DataModel {
	var postid		: Int    = 0
	var forumid		: Int    = 0
	var type		: Int    = 0
	var date		: Date   = Date()
	var userid		: Int    = 0
	var nick		: String = ""
	var title		: String = ""
	var content		: String = ""
	var views		: Int    = 0
	var replies		: Int    = 0
	var answered	: Bool   = false
	var sticky		: Bool   = false
	var closed		: Bool   = false
	var hidden		: Bool   = false

    // init() { }

    func fromNode(_ node: Node) throws {
		postid		= try node.extract("postid")
		forumid		= try node.extract("forumid")
		type		= try node.extract("type")
		date		= try node.extract("date").string.toDate()
		userid		= try node.extract("userid")
		nick		= try node.extract("nick")
		title		= try node.extract("title")
		content		= try node.extract("content")
		views		= try node.extract("views")
		replies		= try node.extract("replies")
		answered	= try node.extract("answered")
		sticky		= try node.extract("sticky")
		closed		= try node.extract("closed")
		hidden		= try node.extract("hidden")
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
    func save(in context: DataStore) {
        print("Saving post: ", postid)
        if postid < 1 { // New post, id not generated yet
            insert(in: context)
        } else {
            update(in: context)
        }
    }
    
    func insert(in context: DataStore) {
        // Map data to sql and insert
        let exclude = ["postid", "date", "views", "replies", "answered", "sticky", "closed", "hidden"]
        let fields = getFields(except: exclude)
        print(fields)
        let params = getBindingsNode(for: fields)
        print(params)
        let sql    = getSqlInsert(table: "posts", fields: fields)
        print(sql)
        let newId  = context.execute(sql, params: params)
        print("New ID: ", newId)
        //postid = newId!.int!
        //print("New post Id:", postid)
    }
    
    func update(in context: DataStore) {
        let exclude = ["postid"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsNode(for: fields)
        let sql     = getSqlUpdate(table: "posts", fields: fields, params: params, key: "postid", id: postid)
        let num     = context.execute(sql, params: params)
        
        if num!.int! < 1 {
            print("Error \(num) updating post ", postid)
        }
    }
    
    func delete(in context: DataStore) {
        let sql = getSqlDelete(table: "posts", key: "postid")
        var params = [Node]()
        let node: Node = Node(postid)
        params.append(node)
        let num = context.execute(sql, params: params)
        
        if num!.int! < 1 {
            print("Error \(num) deleting post ", postid)
        }
    }
    
    func get(_ id :Int, from context: DataStore) {
        let sql  = "Select * from posts where postid = :postid limit 1"
        var params = [Node]()
        let node: Node = try! Node([":postid":id.makeNode()])
        params.append(node)
        guard let rows = context.query(sql, params: params),
        	  let list = rows.array else { return }
        
        let dixy = list[0] as! Node
        try? fromNode(dixy)
    }
} 

// End