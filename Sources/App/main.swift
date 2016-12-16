import Vapor

let drop = Droplet()

drop.get         { IndexController($0).view }
drop.get("test") { TestController($0).view }

drop.run()
