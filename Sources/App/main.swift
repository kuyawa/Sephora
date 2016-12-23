import Vapor
import HTTP

let drop = Droplet()
if drop.environment == .development { print("Sephora is running in dev mode") }


// Public
drop.get(handler: IndexHandler().index)
drop.get("/x", handler: IndexHandler().index)
drop.get("index", handler: IndexHandler().index)

// Users
drop.get("register", handler: RegisterHandler().form)
drop.get("login", handler: LoginHandler().login)
drop.get("logout", handler: LoginHandler().logout)
drop.get("authorize", handler: LoginHandler().authorize)
drop.get("profile", handler: TodoHandler().show)
drop.get("user", handler: AppHandler().redirectToIndex)
drop.get("user/:user", handler: UserHandler().show)

// Forums
drop.get("forum") { request in Response(redirect: "/forum/general") }
drop.get("forum/:forum", handler: ForumHandler().show)
drop.post("forum/:forum/submit", handler: PostHandler().submit)
drop.get("forum/:forum/post/:post", handler: PostHandler().show)
drop.post("forum/:forum/post/:post/reply", handler: ReplyHandler().submit)
drop.get("test", handler: TestHandler().show)
drop.get("404") { request in throw Abort.notFound }

// Admin
drop.get("admin/dbinfo", handler: AdminHandler().dbinfo)
drop.get("admin/users", handler: AdminHandler().users)


drop.run()


// End