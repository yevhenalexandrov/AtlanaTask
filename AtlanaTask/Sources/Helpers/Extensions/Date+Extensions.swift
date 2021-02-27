
import Foundation


extension Date {
    
    init(dateString: String, dateFormatString: String = "yyyy-MM-dd'T'HH:mm:ssZ") {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatString
        self = formatter.date(from: dateString)!
    }
}
