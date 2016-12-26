import Vapor
import HTTP

let drop = Droplet()

drop.get(handler: IndexHandler().index)

drop.run()

// End