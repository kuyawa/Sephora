import Vapor

let drop = Droplet()

drop.get(){ req in return "Hello world!" }

drop.run()

// End