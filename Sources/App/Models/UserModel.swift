import Vapor
import HTTP
import Foundation

class User: DataModel {
    var userid   : Int    = 0
    var nick     : String = ""
    var name     : String = ""
    var avatar   : String = ""
    var status   : String = ""
    var timezone : Int    = 0
    var lastact  : Date   = Date()
    var isnoob   : Bool   = true
    var ismod    : Bool   = false
    var banned   : Bool   = false

    func fromNode(_ node: Node) throws {
        userid   = try node.extract("userid")
        nick     = try node.extract("nick")
        name     = try node.extract("name")
        avatar   = try node.extract("avatar")
        status   = try node.extract("status")
        timezone = try node.extract("timezone")
        lastact  = try node.extract("lastact", transform: Date.fromString)
        isnoob   = try node.extract("isnoob")
        ismod    = try node.extract("ismod")
        banned   = try node.extract("banned")
    }

    func makeNode() throws -> Node {
        let node = try Node(node: [
            "userid"   : userid,
            "nick"     : nick,
            "name"     : name,
            "avatar"   : avatar,
            "status"   : status,
            "timezone" : timezone,
            "lastact"  : lastact.toString(),
            "isnoob"   : isnoob,
            "ismod"    : ismod,
            "banned"   : banned
        ])

        return node
    }
}

extension User {
    func save() {
        if userid < 1 { // New user, id not generated yet
            insert()
        } else {
            update()
        }
    }
    
    func register() {
    	if self.get(nick: nick) == nil {
    		insert()
    	} else {
    		// Already registered
    	}
    }

    func insert() {
        print("Saving user...")
        // Map data to sql and insert
        let fields = ["nick", "name", "avatar"]
        let params = getBindingsNode(for: fields)
        let sql    = getSqlInsert(table: "users", fields: fields, returning: "userid")
        let newId  = db.execute(sql, params: params)

        let id = newId?[0]?["userid"]?.int
        if id == nil {
        	print("Error inserting user, new id not provided")
        	return 
        }

        self.userid = id!
        print("New user Id: ", id!)
    }
    
    func update() {
        print("Updating user ", userid)
        let exclude = ["userid"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsNode(for: fields)
        let sql     = getSqlUpdate(table: "users", fields: fields, params: params, key: "userid", id: userid)
        let num     = db.execute(sql, params: params)
        
        if num == nil {
            print("Error updating user ", userid)
        }
    }
    
    func delete() {
        // FORBIDDEN
        /*
        let sql = getSqlDelete(table: "users", key: "userid")
        var params: [Node]() = [Node(userid)]
        let num = context.execute(sql, params: params)
        
        if num == nil {
            print("Error deleting user ", userid)
        }
        */
    }
    
    func getId(nick: String) -> Int {
        var id = 0
        let sql = "Select userid From users Where nick=$1 Limit 1"
        if let result = db.query(sql, params: [Node(nick)]) {
            id = result[0]?["userid"]?.int ?? 0
        }
        return id
    }

    func get(id: Int) -> User? {
        let sql = "Select * From users Where userid=$1 Limit 1"
        if let result = db.query(sql, params: [Node(id)]) {
            guard let node = result[0] else { return nil }
            try? self.fromNode(node)    // assign values to itself
            return self
        }
        return nil
    }

    func get(nick: String) -> User? {
        let sql = "Select * From users Where dirname=$1 Limit 1"
        if let result = db.query(sql, params: [Node(nick)]) {
            guard let node = result[0] else { return nil }
            try? self.fromNode(node)    // assign values to itself
            return self
        }
        return nil
    }

} 


// End