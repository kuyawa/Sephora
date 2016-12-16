import Vapor
import HTTP

let drop = Droplet()

drop.get                 { IndexController($0).view }
drop.get("test")         { TestController($0).view }
drop.get("login")        { TodoController($0).view }
drop.get("register")     { TodoController($0).view }
drop.get("forum")        { request in return Response(redirect: "/forum/general") }
drop.get("forum/:forum") { TodoController($0).view }
drop.get("user")         { request in return Response(redirect: "/") }
drop.get("user/:user")   { TodoController($0).view }

drop.run()
