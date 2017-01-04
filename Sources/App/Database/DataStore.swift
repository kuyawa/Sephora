import Vapor
import VaporPostgreSQL
import Foundation

class DataStore {

	var db: PostgreSQLDriver
	var isLive: Bool = false

/*
	init(_ driver: PostgreSQLDriver, production: Bool) {
		self.db = driver
		self.isLive = production
	}
*/
	init(){
		let drop = Droplet()
		//let postgres = PostgreSQL(droplet.config["postgres"])
		try? drop.addProvider(VaporPostgreSQL.Provider.self)
		self.db = drop.database?.driver as! PostgreSQLDriver
	}

	//func connect() {}

	// SQL EXECUTION

	func log(_ text: String) {
		print("- ", text)
		_ = execute("Insert into weblogs(text) values($1)", params: [Node(text)])
	}

	func log(_ args: Any...) {
		//print("- ", args)
		let text = args.map{"\($0)"}.joined()
		//let text = args.reduce(""){ini, val in "\(ini) \(val)"}
		//let text = args.reduce(""){"\($0) \($1)"}
		print("- ", text)
		_ = execute("Insert into weblogs(text) values($1)", params: [Node(text)])
	}

	func execute(_ sql: String) -> Node? {
		do {
			let rows = try db.raw(sql)
			return rows
		} catch {
			print("DB Error: ", error)
		}
		return nil
	}

	func execute(_ sql: String, params: [Node]) -> Node? {
		do {
			let rows = try db.raw(sql, params)
			return rows
		} catch {
			print("DB Error: ", error)
		}
		return nil
	}

	func query(_ sql: String) -> Node? {
		if let rows = try? db.raw(sql) {
			return rows
		}
		return nil
	}

	func query(_ sql: String, params: [Node]) -> Node? {
		if let rows = try? db.raw(sql, params) {
			return rows
		}
		return nil
	}

	func queryValue(_ sql: String) -> Node? {
		if let rows = try? db.raw(sql) {
			if let val = rows[0]?["value"] {
				return val
			}
		}
		return nil
	}

	func queryValue(_ sql: String, params: [Node]) -> Node? {
		if let rows = try? db.raw(sql, params) {
			if let val = rows[0]?["value"] {
				return val
			}
		}
		return nil
	}

	// DEPRECATED
    // Heroku doesn't like String(contentsOfFile:...)
    /*
	func runJob(_ name: String) -> (Bool, String) {
		var ok   = false
		var text = ""
		let path = "public/static/\(name).sql"
		// TODO: move jobs to private/database/ folder?

        do {
        	print(FileManager.default.currentDirectoryPath)
            let sql = try String(contentsOfFile: path)
            try db.raw(sql)
            text = "Sql job run successfully"
            ok = true
        } catch {
        	text = "Error running job \n \(error)"
        }
        
        return (ok, text)
	}
	*/

	// DATABASE INTEGRITY

	func verifyIntegrity() {
		// TODO: get name from Config.databaseName
		var name = "forums"
		if isLive { name = "dedvgt6m07p4cf" } else { name = "forums" }
		if databaseExists(name) {
			// Everything fine
			print("Database 'forums' is available")
		} else {
			// TODO: Alert user and fail
			print("Database 'forums' not found")
		}
	}

	func databaseExists(_ name: String) -> Bool {
		let sql = "Select 1 as ok From pg_database where datname='\(name)'"
		if let rows = try? db.raw(sql) {
			for row in rows.array! {
				let ok = row.object!["ok"]!.int!
				return (ok==1)
			}
		}
		return false
	}
	
	// DEPRECATED
	// Heroku doesn't allow database creation
	/*
	func createDatabase() -> (Bool, String) {
		let (ok, text) = runJob("schema")
		return (ok, text)
	}
	*/

	func getDatabases() -> [String] {
		var databases = [String]()
		let sql = "Select datname as database From pg_database Where datistemplate=false Order by database Limit 10"

		if let rows = try? db.raw(sql) {
			for row in rows.array! { 
				let name = row.object!["database"]!.string!
				databases.append(name)
			}
		} else {
			print("Error fetching databases")
		}

		return databases
	}

	func getTables() -> [String] {
		var tables = [String]()
		let sql = "select table_name as table from information_schema.tables where table_schema = 'public' order by table_name"
		//extended info: Select * From pg_catalog.pg_tables Where schemaname != 'pg_catalog' And schemaname != 'information_schema'

		if let rows = try? db.raw(sql) {
			for row in rows.array! { 
				let table = row.object!["table"]!.string!
				tables.append(table)
			}
		} else {
			print("Error fetching tables")
		}

		return tables
	}


	//------------------------------------------------------------
	// DATA MODELS
	// TODO: Move to DataQuery classes

	/*
	func getUsers() -> Node? {
		if let users = query("Select * From users Order by userid") {
			return users
		}
		return []
	}
	
	func getStats() -> Stats {
		var stats = Stats()
		// TODO: query stats
		stats.users     =  320
		stats.threads   = 1234
		stats.replies   = 3542
		stats.questions =  156
		stats.answered  =   72
		return stats
	}

	func getForumId(_ forum: String) -> Int {
		var id = 0
		let sql = "Select forumid From forums Where dirname=$1 Limit 1"
		if let result = try? db.raw(sql, [forum]) {
			id = result[0]?["forumid"]?.int ?? 0
		}
		return id
	}

	func getForum(id: Int) -> Node? {
		let sql = "Select * From forums Where forumid=$1 Limit 1"
		if let result = try? db.raw(sql, [id]) {
			return result[0]
		}
		return nil
	}

	func getForum(dir: String) -> Node? {
		let sql = "Select * From forums Where dirname=$1 Limit 1"
		if let result = try? db.raw(sql, [dir]) {
			return result[0]
		}
		return nil
	}

	func getPosts(forumId: Int, start: Int? = 0, limit: Int? = 30) -> Node? {
		let sql  = "Select * From posts Where forumid=$1 Order by date Desc Offset $2 Limit $3"
		let args:[Node] = try! [forumId.makeNode(), start!.makeNode(), limit!.makeNode()]
		if let rows = query(sql, params: args) {
			return rows
		}
		return nil
	}

	func getLatestPosts(start: Int? = 0, limit: Int? = 30) -> Node? {
		let sql  = "Select * From posts Order by date Desc Offset $1 Limit $2"
		let args:[Node] = try! [start!.makeNode(), limit!.makeNode()]
		if let rows = query(sql, params: args) {
			return rows
		}
		return nil
	}
	*/

}

// End