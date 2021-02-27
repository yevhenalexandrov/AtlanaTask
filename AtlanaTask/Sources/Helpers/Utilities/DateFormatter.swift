
import Foundation


protocol Formatter {
    associatedtype Input
    func string(from value: Input) -> String?
}


struct UserDateFormatter: Formatter {
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    func string(from date: Date) -> String? {
        return UserDateFormatter.formatter.string(from: date)
    }
    
}
