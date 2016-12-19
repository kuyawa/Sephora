import Vapor
import VaporPostgreSQL

class DataStore {

	var db: PostgreSQLDriver

	init(_ driver: PostgreSQLDriver) {
		self.db = driver
	}

	func execute(_ sql: String, params: Node?=nil) -> Node? {
		// TODO: Bindings
		if let rows = try? db.raw(sql) {
			return rows
		}
		return nil
	}

	func query(_ sql: String, params: Node?=nil) -> Node? {
		// TODO: Bindings
		if let rows = try? db.raw(sql) {
			return rows
		}
		return nil
	}

	func queryValue(_ sql: String, params: Node?=nil) -> Node? {
		// TODO: Bindings
		if let rows = try? db.raw(sql) {
			if let val = rows[0]?["value"] {
				return val
			}
		}
		return nil
	}

	func verifyIntegrity() {
		// TODO: Config.databaseName
		let name = "forums" 
		if databaseExists(name) {
			// Everything fine
			print("Database FORUMS exists")
		} else {
			// TODO: Alert user and fail
			print("Database FORUMS not found")
		}

		//let dbs = getDatabases()
		//let tables = getTables()
		//print("DB: ", dbs)
		//print("Tables: ", tables)
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
	
	func getDatabases() -> [String] {
		var databases = [String]()
		let sql = "Select datname as database From pg_database Where datistemplate=false Order by database"

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

	func getUsers() -> Node? {
		if let users = query("Select * From users Order by nick") {
			return users
		}
		return []
	}
}