import Vapor

let drop = Droplet()

let indexHandler = IndexHandler()
drop.get(){ IndexHandler().index($0) }
drop.get("index", handler: indexHandler.index)

drop.run()

// End