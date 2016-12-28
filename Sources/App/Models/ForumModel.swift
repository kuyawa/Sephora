import Vapor
import Foundation

class Forum: DataModel {
    var forumid  : Int    = 0
    var name     : String = ""
    var dirname  : String = ""
    var descrip  : String = ""
    var rowpos   : Int    = 0
    var hidden   : Bool   = false
    var disabled : Bool   = false

    func fromNode(_ node: Node) throws {
        forumid  = try node.extract("forumid")
        name     = try node.extract("name")
        dirname  = try node.extract("dirname")
        descrip  = try node.extract("descrip")
        rowpos   = try node.extract("rowpos")
        hidden   = try node.extract("hidden")
        disabled = try node.extract("disabled")
    }

    func makeNode() throws -> Node {
        let node = try Node(node: [
            "forumid"   : forumid,
            "name"      : name,
            "dirname"   : dirname,
            "descrip"   : descrip,
            "rowpos"    : rowpos,
            "hidden"    : hidden,
            "disabled"  : disabled
        ])

        return node
    }
}

extension Forum {
    func save() {
        if forumid < 1 { // New forum, id not generated yet
            insert()
        } else {
            update()
        }
    }
    
    func insert() {
        print("Saving forum...")
        // Map data to sql and insert
        let exclude = ["forumid", "hidden", "disabled"]
        let fields = getFields(except: exclude)
        let params = getBindingsNode(for: fields)
        let sql    = getSqlInsert(table: "forums", fields: fields, returning: "forumid")
        let newId  = db.execute(sql, params: params)

        let id = newId?[0]?["forumid"]?.int
        if id == nil {
        	print("Error inserting forum, new id not provided")
        	return 
        }

        self.forumid = id!
        print("New forum Id: ", id!)
    }
    
    func update() {
        print("Updating forum ", forumid)
        let exclude = ["forumid"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsNode(for: fields)
        let sql     = getSqlUpdate(table: "forums", fields: fields, key: "forumid", id: forumid)
        let num     = db.execute(sql, params: params)
        
        if num == nil {
            print("Error updating forum ", forumid)
        }
    }
    
    func delete() {
        // FORBIDDEN
        /*
        let sql = getSqlDelete(table: "forums", key: "forumid")
        var params: [Node]() = [Node(forumid)]
        let num = context.execute(sql, params: params)
        
        if num == nil {
            print("Error deleting forum ", forumid)
        }
        */
    }
    
    func getId(dir: String) -> Int {
        var id = 0
        let sql = "Select forumid From forums Where dirname=$1 Limit 1"
        if let result = db.query(sql, params: [Node(dir)]) {
            id = result[0]?["forumid"]?.int ?? 0
        }
        return id
    }

    func get(id: Int) -> Forum? {
        let sql = "Select * From forums Where forumid=$1 Limit 1"
        if let result = db.query(sql, params: [Node(id)]) {
            guard let node = result[0] else { return nil }
            try? self.fromNode(node)    // assign values to itself
            return self
        }
        return nil
    }

    func get(dir: String) -> Forum? {
        let sql = "Select * From forums Where dirname=$1 Limit 1"
        if let result = db.query(sql, params: [Node(dir)]) {
            guard let node = result[0] else { return nil }
            try? self.fromNode(node)    // assign values to itself
            return self
        }
        return nil
    }

} 

// End