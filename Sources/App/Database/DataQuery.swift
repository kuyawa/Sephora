import Foundation

class DataQuery: NSObject {

    var db: DataStore

    override init() {
        self.db = DataStore()  	// Create new DS instance
    }
    
    init(in context: DataStore) {
        self.db = context 		// Use existing connection
    }
    
}

// End