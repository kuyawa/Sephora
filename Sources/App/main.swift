import Vapor

let drop = Droplet()

drop.get("index")                   { IndexHandler($0).view }
drop.get                            { IndexHandler($0).view }
drop.get("test")                    { TestHandler($0).view }
drop.get("login")                   { LoginHandler($0).view }
drop.get("register")                { RegisterHandler($0).view }
drop.get("user")                    { AppHandler($0).redirect("/") }
drop.get("user/:user")              { UserHandler($0).view }
drop.get("forum")                   { AppHandler($0).redirect("/forum/general") }
drop.get("forum/:forum")            { ForumHandler($0).view }
drop.get("forum/:forum/post/:post") { ThreadHandler($0).view }

drop.run()
