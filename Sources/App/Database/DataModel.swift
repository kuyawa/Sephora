import Vapor
import Foundation



/* WARNING : LINUX DOESN'T LIKE NSOBJECT

   Methods not allowed:
     .value
     .setValue
     .dictionaryFromValues

*/

typealias Parameters = [String:Any]

class DataModel: NSObject {
    
    var db: DataStore
    
    var isNew      = false
    var isModified = false
    var isDeleted  = false

    override var description : String { return self.toDictionary().description }

    // DataModel needs a context for storage, if not provided, create one
    override convenience init() {
    	self.init(in: DataStore())
    }

    init(in context: DataStore) {
    	self.db = context
    	super.init()
    }
/*
    func fromDictionary(_ dict: [String:Any], except: [String]? = [""]) {
        for (key,val) in dict {
            if (except?.index(of: key)) == nil {
                self.setValue(val, forKey: key)
            }
        }
    }
*/    

    func toDictionary() -> Parameters {
        var data = [String:Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                data[key] = child.value
            }
        }
        
        return data
    }

    func toDictionary(fields: [String]) -> Parameters {
        var data = [String:Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                if (fields.index(of: key)) != nil {
                    data[key] = child.value
                }
            }
        }
        
        return data
    }

    func toDictionary(except: [String]) -> Parameters {
        var data = [String:Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                if (except.index(of: key)) == nil {
                    data[key] = child.value
                }
            }
        }
        
        return data
    }

/*    
    func toDictionary() -> Parameters {
        let fields = self.getFields()
        let data   = self.dictionaryWithValues(forKeys: fields)
        return data
    }

    
    func toDictionary(fields: [String]) -> Parameters {
        let data = self.dictionaryWithValues(forKeys: fields)
        return data
    }

    
    func toMutableDictionary() -> NSMutableDictionary {
        let fields = self.getFields()
        let data   = self.dictionaryWithValues(forKeys: fields)
        let dixy   = NSMutableDictionary(dictionary: data)
        return dixy
    }
*/    
    
    // Returns a list of fields from the table
    func getFields(except: [String]? = [""]) -> [String] {
        var keys = [String]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                if (except?.index(of: key)) == nil {
                    keys.append(key)
                }
            }
        }
        
        return keys
    }
    
    // Returns a list of :placeholders for sql binding
    func getPlaceholders(for fields: [String]) -> [String] {
        var keys = [String]()
        for field in fields {
            let key = ":"+field
            keys.append(key)
        }
        
        return keys
    }
    
    // OBSOLETE: Use mirror
    func getPlaceholders(except: [String]? = [""]) -> [String] {
        var keys = [String]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                if (except?.index(of: key)) == nil {
                    keys.append(":"+key)
                }
            }
        }
        
        return keys
    }
    
    // Dictionary of fields and placeholders
    // Placeholders are fields prepended with ":" for sql binding

/*
    func getBindings(for fields: [String]) -> Parameters {
        var data = [String:Any]()
        for field in fields {
            let key = ":"+field
            data[key] = self.value(forKey: field)
        }
        
        return data
    }
    
    func getBindingsArray(for fields: [String]) -> [Any] {
        var data = [Any]()
        for field in fields {
            data.append(self.value(forKey: field)!)
        }
        
        return data
    }
   
    func getBindingsNode(for fields: [String]) -> [Node] {
        var data = [Node]()
        for field in fields {
        	let any = self.value(forKey: field)!
        	var node = Node("")
        	switch any {
    		case let any as String: let str: String = any; node = Node(str)
    		case let any as Int   : let int: Int = any; node = Node(int)
    		case let any as Double: let dbl: Double = any; node = Node(dbl)
    		default: let str: String = any as? String ?? ""; node = Node(str)
        	}
            data.append(node)
        }
        
        return data
    }
*/   

    func getBindingsNode(for fields: [String]) -> [Node] {
        var data: [Node] = [Node]()
        var binds = toDictionary(fields: fields)

        for field in fields {
        	let any = binds[field]
        	var node = Node("")
        	switch any {
    		case let any as String: let str: String = any; node = Node(str)
    		case let any as Int:    let int: Int    = any; node = Node(int)
    		case let any as Double: let dbl: Double = any; node = Node(dbl)
    		case let any as Date:   let dat: Date   = any; node = Node(dat.toString())
    		case let any as Bool:   let bol: Bool   = any; node = Node(bol)
    		default: let str: String = any as? String ?? ""; node = Node(str)
        	}
            data.append(node)
        }

        return data
    }
   
    func getValueFromMirror(for field: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        //mirror.children[field].value
        
        for child in mirror.children {
            if let label = child.label {
            	if field == label {
                	return child.value
                }
            }
        }
        
        return nil
    }

    func getBindingsFromMirror(for fields: [String]) -> Parameters {
        var data = [String: Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let label = child.label {
                if (fields.index(of: label)) != nil {
                    let key = ":"+label
                    data[key] = child.value
                }
            }
        }
        
        return data
    }
    
    
    // Insert into Invoices(field1, field2...) values(:field1, :field2...)
    func getSqlInsert(table: String, fields: [String], returning id: String? = nil) -> String {
        let props  = getInsertFields(fields)
        let values = getInsertPositions(fields.count)
        var sql = "Insert into \(table)(\(props)) values(\(values));"
        if id != nil {
        	sql = "Insert into \(table)(\(props)) values(\(values)) returning \(id!);"
        }
        return sql
    }
    
    // Update Invoices set field1 = $1, field2 = $2 where invoiceId = $3
    func getSqlUpdate(table: String, fields: [String], key: String, id: Int) -> String {
        let updates = getUpdateBindings(fields)
        //let updates = getUpdateValues(fields, params: params)
        let sql = "Update \(table) set \(updates) where \(key) = \(id);"
        return sql
    }
    
    // Delete from Invoices where invoiceId = :invoiceId limit 1
    func getSqlDelete(table: String, key: String) -> String {
        let sql = "Delete from \(table) where \(key) = ? limit 1;"
        //let sql = "Delete from \(table) where \(key) = :\(key) limit 1;"
        return sql
    }
    
    // Join all fields
    private func getInsertFields(_ fields: [String]) -> String {
        var places = [String]()
        for item in fields {
            places.append(item)
        }
        let inserts = places.joined(separator: ", ")
        
        return inserts
    }
    
    private func getInsertValues(_ fields: [String]) -> String {
        var places = [String]()
        for item in fields {
            places.append(":\(item)")
        }
        let inserts = places.joined(separator: ", ")
        
        return inserts
    }
    
    private func getInsertPositions(_ num: Int) -> String {
        var places = [String]()
        for index in 1...num {
            places.append("$\(index)")
        }
        let inserts = places.joined(separator: ", ")
        
        return inserts
    }
    
    // Not working, dunno why. Use direct values instead
    private func getUpdateBindings(_ fields: [String]) -> String {
        var places = [String]()
        for (index, item) in fields.enumerated() {
            places.append("\(item) = $\(index+1)")
            //places.append("\(item) = :\(item)")
        }
        let updates = places.joined(separator: ", ")
        
        return updates
    }
    
    private func getUpdateValues(_ fields: [String], params: [String:Any]) -> String {
        var places = [String]()
        for item in fields {
            let key = ":"+item
            let val = "\(params[key]!)"
            if val.contains("'") {
                //let fixed = val.replacingOccurrences(of: "'", with: "\'")
                //places.append("\(item) = '\(fixed)'")
                places.append("\(item) = \"\(params[key]!)\"") // May break if apostrophe in string
            } else {
                places.append("\(item) = '\(params[key]!)'")
            }
        }
        let updates = places.joined(separator: ", ")
        
        return updates
    }
}

