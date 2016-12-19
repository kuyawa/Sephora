import Vapor
import VaporPostgreSQL
import Foundation

var isLive = false
if let envDatabase = ProcessInfo.processInfo.environment["DATABASE_URL"] {
	isLive = envDatabase.hasPrefix("postgres")
}
if isLive{ print("Sephora is live!") } else { print("Sephora is running in dev mode") }

let drop = Droplet()
try? drop.addProvider(VaporPostgreSQL.Provider.self)
let driver = drop.database?.driver as? PostgreSQLDriver
let forums = DataStore(driver!, production: isLive)
forums.verifyIntegrity()


// Public
drop.get                            { IndexHandler($0).view }
drop.get("index")                   { IndexHandler($0).view }
drop.get("register")                { RegisterHandler($0).view }
drop.get("login")                   { LoginHandler($0).view }
drop.get("logout")                  { TodoHandler($0).view }
drop.get("profile")                 { TodoHandler($0).view }
drop.get("user")                    { AppHandler($0).redirect("/") }
drop.get("user/:user")              { UserHandler($0).view }
drop.get("forum")                   { AppHandler($0).redirect("/forum/general") }
drop.get("forum/:forum")            { ForumHandler($0).view }
drop.get("forum/:forum/post/:post") { ThreadHandler($0).view }
drop.get("test")                    { TestHandler($0).view }
drop.get("404")                     { response in throw Abort.notFound }

// Admin
drop.get("admin/dbinfo")            { AdminHandler($0, db: forums).dbinfo }
drop.get("admin/users")             { AdminHandler($0, db: forums).users }

drop.run()
