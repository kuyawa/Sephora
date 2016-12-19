import Vapor
import VaporPostgreSQL

class DataSchema {

	var context: DataStore

	init(_ ds: DataStore) {
		self.context = ds
	}

	func create() -> String {
		createDatabase()
		createTables()
		populateTables()
		return "Schema creation OK"
	}

	func createDatabase() {
		//runJob("createdatabase.sql")
	}

	func createTables() {
		//runJob("createtables.sql")
	}

	func populateTables() {
		//runJob("populatetables.sql")
	}

}