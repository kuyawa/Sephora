import Vapor
import HTTP
import Sessions

let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)

let drop = Droplet()
drop.middleware.append(sessions)
if drop.environment == .development { print("Sephora is running in dev mode") }


// Index
drop.get(handler: IndexHandler().index)
drop.get("index", handler: IndexHandler().index)

// Users
drop.get("register", handler: RegisterHandler().form)
drop.get("register/user/:user", handler: RegisterHandler().fetchUser)
drop.get("login", handler: LoginHandler().login)
drop.get("login/github/:nick", handler: LoginHandler().loginGithub)
drop.get("authorize", handler: LoginHandler().authorize)
drop.get("profile", handler: TodoHandler().show)
drop.get("user", handler: AppHandler().redirectToIndex)
drop.get("user/:user", handler: UserHandler().show)
drop.get("logout", handler: LoginHandler().logout)

// Forums
drop.get("forum") { request in Response(redirect: "/forum/general") }
drop.get("forum/:forum", handler: ForumHandler().show)
drop.post("forum/:forum/submit", handler: PostHandler().submit)
drop.get("forum/:forum/post/:post", handler: PostHandler().show)
drop.post("forum/:forum/post/:post/reply", handler: ReplyHandler().submit)

// Admin
drop.get("admin/dbinfo", handler: AdminHandler().dbinfo)
drop.get("admin/users", handler: AdminHandler().users)
drop.get("test", handler: TestHandler().show)
drop.get("404") { request in throw Abort.notFound }


drop.run()


// End