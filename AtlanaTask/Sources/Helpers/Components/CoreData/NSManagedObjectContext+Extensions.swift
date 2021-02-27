
import Foundation
import CoreData


public protocol Object: class {

    associatedtype ObjectID
    
    var objectID: ObjectID { get }
    
    static var entityName: String { get }
}


extension NSManagedObjectContext {
    
    public func deleteObject<T: Object>(_ object: T) {
        guard let object = object as? NSManagedObject else {
            fatalError("Invalid Object Kind")
        }

        delete(object)
    }
    
    public func firstObject<T: Object>(ofType type: T.Type) -> T? {
        return firstObject(ofType: type, matching: nil)
    }
    
    public func firstObject<T: Object>(ofType type: T.Type, matching predicate: NSPredicate?) -> T? {
        let request = fetchRequest(forType: type)
        request.predicate = predicate
        request.fetchLimit = 1

        return loadObjects(ofType: type, with: request).first
    }
    
    public func insertNewObject<T: Object>(ofType type: T.Type) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as! T
    }
    
    public func loadObject<T: Object>(ofType type: T.Type, with objectID: T.ObjectID) -> T? {
        guard let objectID = objectID as? NSManagedObjectID else {
            fatalError("Invalid ObjectID Kind")
        }

        do {
            return try existingObject(with: objectID) as? T
        } catch {
            debugPrint("Error loading Object [\(T.entityName)]")
        }

        return nil
    }
    
    public func saveIfNeeded() {
        guard hasChanges else {
            return
        }

        do {
            try save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func loadObjects<T: Object>(ofType type: T.Type, with request: NSFetchRequest<NSFetchRequestResult>) -> [T] {
        var objects: [T]?

        do {
            objects = try fetch(request) as? [T]
        } catch {
            debugPrint("Error loading Objects [\(T.entityName)")
            assertionFailure()
        }

        return objects ?? []
    }
    
    private func fetchRequest<T: Object>(forType type: T.Type) -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<NSFetchRequestResult>(entityName: type.entityName)
    }
}
