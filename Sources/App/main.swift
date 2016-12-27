import Vapor

let drop = Droplet()

drop.get(){ IndexHandler().index($0) }

drop.run()

// End