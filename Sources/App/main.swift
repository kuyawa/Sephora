import Vapor
import HTTP

let drop = Droplet()
if drop.environment == .development { print("Sephora is running in dev mode") }


// Public
drop.get(handler: IndexHandler().index)
drop.get("/x", handler: IndexHandler().index)
drop.get("index", handler: IndexHandler().index)
drop.get("register", handler: RegisterHandler().form)
drop.get("login", handler: LoginHandler().form)
drop.get("logout", handler: TodoHandler().show)
drop.get("profile", handler: TodoHandler().show)
drop.get("user", handler: AppHandler().redirectToIndex)
drop.get("user/:user", handler: UserHandler().show)
drop.get("forum") { request in Response(redirect: "/forum/general") }
drop.get("forum/:forum", handler: ForumHandler().show)
drop.post("forum/:forum/submit", handler: ForumHandler().submit)
drop.get("forum/:forum/post/:post", handler: ThreadHandler().show)
drop.get("test", handler: TestHandler().show)
drop.get("404") { request in throw Abort.notFound }

// Admin
drop.get("admin/dbinfo", handler: AdminHandler().dbinfo)
drop.get("admin/users", handler: AdminHandler().users)


drop.run()
