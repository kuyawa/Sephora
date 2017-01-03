import Foundation

extension Date {

	static var epoch      : Date { return Date(timeIntervalSince1970: 0) }
	static var endOfTimes : Date { return Date(timeIntervalSince1970: 9999999999) }

    static func fromString(text: String) -> Date {
    	return Date.fromString(text: text, format: "yyyy-MM-dd HH:mm:ss") // No format, use default
    }
    
    static func fromString(text: String, format: String) -> Date {
        let epoch = Date(timeIntervalSince1970: 0)
        if text.isEmpty { return epoch }

        var time = text
        if text.characters.count > 19 { time = text.subtext(to: 19) }

        let formatter = DateFormatter()
        formatter.dateFormat = format
        guard let date = formatter.date(from: time) else { return epoch }

        return date
    }
    
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let text = formatter.string(from: self)
        return text
    }
    
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let text = formatter.string(from: self)
        return text
    }

    // Linux compatible
	func timeAgo() -> String {

	    let now = Date()
	    let calendar = Calendar.current
	    let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfYear, .month, .year])
	    let date1 = calendar.dateComponents(unitFlags, from: self)
	    let date2 = calendar.dateComponents(unitFlags, from: now)

	    if let years2 = date2.year, let years1 = date1.year {
	    	if years2-years1 >= 2 {	return "\(years2-years1) years ago" }
	    	if years2-years1 >= 1 {	return "Last year" }
	    } 

	    if let months2 = date2.month, let months1 = date1.month {
	    	if months2-months1 >= 2 { return "\(months2-months1) months ago" }
	    	if months2-months1 >= 1 { return "Last month" }
	    }
	    
	    if let weeks2 = date2.weekOfYear, let weeks1 = date1.weekOfYear {
	    	if weeks2-weeks1 >= 2 { return "\(weeks2-weeks1) weeks ago" }
	    	if weeks2-weeks1 >= 1 { return "Last week" }
	    }
	    
	    if let days2 = date2.day, let days1 = date1.day {
	    	if days2-days1 >= 2 { return "\(days2-days1) days ago" }
	    	if days2-days1 >= 1 { return "Yesterday" }
	    }
	    
	    if let hours2 = date2.hour, let hours1 = date1.hour {
	    	if hours2-hours1 >= 2 { return "\(hours2-hours1) hours ago" }
	    	if hours2-hours1 >= 1 { return "An hour ago" }
	    }
	    
	    if let minutes2 = date2.minute, let minutes1 = date1.minute {
	    	if minutes2-minutes1 >= 2 { return "\(minutes2-minutes1) minutes ago" }
	    	if minutes2-minutes1 >= 1 { return "A minute ago" }
	    }
	    
	    if let seconds2 = date2.second, let seconds1 = date1.second {
	    	if seconds2-seconds1 >= 3 { return "\(seconds2-seconds1) seconds ago" }
	    }
	    
	    return "Just now"
	}

}

// END