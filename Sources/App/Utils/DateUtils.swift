import Foundation

extension Date {

	static var epoch      : Date { return Date(timeIntervalSince1970: 0) }
	static var nextYear   : Date { return Date().addingTimeInterval(60*60*24*365) }
	static var endOfTimes : Date { return Date(timeIntervalSince1970: 9999999999) }

    static func fromString(text: String) -> Date {
    	return Date.fromString(text: text, format: "yyyy-MM-dd HH:mm:ss") // No format, use default
    }
    
    static func fromString(text: String, format: String) -> Date {
        if text.isEmpty { return self.epoch }

        var time = text
        if text.characters.count > 19 { time = text.subtext(to: 19) }

        let formatter = DateFormatter()
        formatter.dateFormat = format
        guard let date = formatter.date(from: time) else { return self.epoch }

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
	    let secs1 = self.timeIntervalSince1970
	    let secs2 = now.timeIntervalSince1970
	    let diff = secs2 - secs1

	    if diff > 60*60*24*365*2 { return "\(Int(diff / Double(60*60*24*365))) years ago" } 
	    if diff > 60*60*24*365   { return "Last year" } 

	    if diff > 60*60*24*30*2 { return "\(Int(diff / Double(60*60*24*30))) months ago" } 
	    if diff > 60*60*24*30   { return "Last month" } 

	    if diff > 60*60*24*7*2 { return "\(Int(diff / Double(60*60*24*7))) weeks ago" } 
	    if diff > 60*60*24*7   { return "Last week" } 

	    if diff > 60*60*24*2 { return "\(Int(diff / Double(60*60*24))) days ago" } 
	    if diff > 60*60*24   { return "Yesterday" } 

	    if diff > 60*60*2 { return "\(Int(diff / Double(60*60))) hours ago" } 
	    if diff > 60*60   { return "An hour ago" } 

	    if diff > 60*2 { return "\(Int(diff / Double(60))) minutes ago" } 
	    if diff > 60   { return "A minute ago" } 

	    if diff > 5 { return "\(Int(diff)) seconds ago" } 

	    return "Just now"
	}

}

// END