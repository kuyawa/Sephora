import Vapor
import HTTP
import Sessions

let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)

let drop = Droplet()
drop.middleware.append(sessions)
if drop.environment == .development { print("Sephora is running in dev mode") }


// Index
drop.get(){ IndexHandler().index($0)}
drop.get("index"){ IndexHandler().index($0)}

// Users
drop.get("register"){ RegisterHandler().form($0) }
drop.get("register/user/:user"){ RegisterHandler().fetchUser($0) }
drop.get("login"){ LoginHandler().login($0) }
drop.get("login/github/:nick"){ LoginHandler().loginGithub($0) }
drop.get("authorize"){ LoginHandler().authorize($0) }
drop.get("profile"){ TodoHandler().show($0) }
drop.get("user"){ AppHandler().redirectToIndex($0) }
drop.get("user/:user"){ UserHandler().show($0) }
drop.get("logout"){ LoginHandler().logout($0) }

// Forums
drop.get("forum") { request in Response(redirect: "/forum/general") }
drop.get("forum/:forum"){ ForumHandler().show($0) }
drop.post("forum/:forum/submit"){ PostHandler().submit($0) }
drop.get("forum/:forum/post/:post"){ PostHandler().show($0) }
drop.post("forum/:forum/post/:post/reply"){ ReplyHandler().submit($0) }

// Admin
drop.get("admin/dbinfo"){ AdminHandler().dbinfo($0) }
drop.get("admin/users"){ AdminHandler().users($0) }
drop.get("test"){ TestHandler().show($0) }
drop.get("404") { request in throw Abort.notFound }


/*
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
*/

drop.run()


// End