
import UIKit


public protocol Reusable: class {
    
    static var defaultReuseIdentifier: String { get }
}


extension Reusable {
    
    static public var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
