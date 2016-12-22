class Stats: DataQuery {
	var users     = 0
	var threads   = 0
	var replies   = 0
	var questions = 0
	var answered  = 0

	func gather() {
		// TODO: query stats from DB
		users     =  320
		threads   = 1234
		replies   = 3542
		questions =  156
		answered  =   72
	}
}