
import Foundation


public protocol ReadOnlyType {
    
    func isReadOnlyRepresentation(of storageEntity: Any) -> Bool
}


 protocol ReadOnlyConvertible: TypeErasedReadOnlyConvertible {
    
    associatedtype ReadOnlyType
    
    func update(with entity: ReadOnlyType)
    
    func toReadOnly() -> ReadOnlyType
}


protocol TypeErasedReadOnlyConvertible {
    
    func toTypeErasedReadOnly() -> Any
}


extension ReadOnlyConvertible {

    public func toTypeErasedReadOnly() -> Any {
        return toReadOnly()
    }
}
