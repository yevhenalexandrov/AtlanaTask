
public protocol Instantiatable: class {
    
    static var identifier: String { get }
}


extension Instantiatable {
    
    public static var identifier: String {
        return String(describing: self)
    }
}
