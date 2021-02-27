
import Foundation
import CoreData


/// Simple CoreData Manager
///
public class CoreDataManager {

    public static let shared = CoreDataManager()

    let model: String = "CoreDataModel"

    lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle.main
        let modelURL = bundle.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)

        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { (storeDescription, error) in
            if let err = error{
                fatalError("❌ Loading of store failed:\(err)")
            }
        }

        return container
    }()
    
    public var viewStorage: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func newDerivedStorage() -> NSManagedObjectContext {
        let childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childManagedObjectContext.parent = persistentContainer.viewContext
        childManagedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return childManagedObjectContext
    }
    
    public func saveDerivedType(derivedStorage: NSManagedObjectContext, _ closure: @escaping () -> Void) {
        derivedStorage.perform {
            derivedStorage.saveIfNeeded()

            self.viewStorage.perform {
                self.viewStorage.saveIfNeeded()
                closure()
            }
        }
    }
    
    public func loadUserRepo(userID: Int64) -> Repo? {
        let predicate = NSPredicate(format: "ownerID = %ld", userID)
        return persistentContainer.viewContext.firstObject(ofType: Repo.self, matching: predicate)
    }
    
    public func saveContext () {
        if viewStorage.hasChanges {
            do {
                try viewStorage.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


extension NSManagedObjectContext {
    
    func loadUser(userID: Int64) -> User? {
        let predicate = \User.userID == userID
        return firstObject(ofType: User.self, matching: predicate)
    }
}

extension NSManagedObject: Object {
    
    public class var entityName: String {
        return classNameWithoutNamespaces()
    }
}

extension NSObject {
    
    class func classNameWithoutNamespaces() -> String {
        guard let name = NSStringFromClass(self).components(separatedBy: ".").last else {
            fatalError()
        }
        return name
    }
}




// MARK: - typed predicate types

public protocol TypedPredicateProtocol: NSPredicate { associatedtype Root }
public final class CompoundPredicate<Root>: NSCompoundPredicate, TypedPredicateProtocol {}
public final class ComparisonPredicate<Root>: NSComparisonPredicate, TypedPredicateProtocol {}


// MARK: - compound operators
public func && <TP1: TypedPredicateProtocol, TP2: TypedPredicateProtocol>(p1: TP1, p2: TP2) -> CompoundPredicate<TP1.Root> where TP1.Root == TP2.Root {
    CompoundPredicate(type: .and, subpredicates: [p1, p2])
}

public func || <TP1: TypedPredicateProtocol, TP2: TypedPredicateProtocol>(p1: TP1, p2: TP2) -> CompoundPredicate<TP1.Root> where TP1.Root == TP2.Root {
    CompoundPredicate(type: .or, subpredicates: [p1, p2])
}

public prefix func ! <TP: TypedPredicateProtocol>(p: TP) -> CompoundPredicate<TP.Root> {
    CompoundPredicate(type: .not, subpredicates: [p])
}

// MARK: - comparison operators
public func == <E: Equatable, R, K: KeyPath<R, E>>(kp: K, value: E) -> ComparisonPredicate<R> {
    ComparisonPredicate(kp, .equalTo, value)
}

public func != <E: Equatable, R, K: KeyPath<R, E>>(kp: K, value: E) -> ComparisonPredicate<R> {
    ComparisonPredicate(kp, .notEqualTo, value)
}

public func > <C: Comparable, R, K: KeyPath<R, C>>(kp: K, value: C) -> ComparisonPredicate<R> {
    ComparisonPredicate(kp, .greaterThan, value)
}

public func < <C: Comparable, R, K: KeyPath<R, C>>(kp: K, value: C) -> ComparisonPredicate<R> {
    ComparisonPredicate(kp, .lessThan, value)
}

public func <= <C: Comparable, R, K: KeyPath<R, C>>(kp: K, value: C) -> ComparisonPredicate<R> {
    ComparisonPredicate(kp, .lessThanOrEqualTo, value)
}

public func >= <C: Comparable, R, K: KeyPath<R, C>>(kp: K, value: C) -> ComparisonPredicate<R> {
    ComparisonPredicate(kp, .greaterThanOrEqualTo, value)
}

public func === <S: Sequence, R, K: KeyPath<R, S.Element>>(kp: K, values: S) -> ComparisonPredicate<R> where S.Element: Equatable {
    ComparisonPredicate(kp, .in, values)
}


// MARK: - Internal

extension ComparisonPredicate {
    
    convenience init<VAL>(_ kp: KeyPath<Root, VAL>, _ op: NSComparisonPredicate.Operator, _ value: Any?) {
        let ex1 = \Root.self == kp ? NSExpression.expressionForEvaluatedObject() : NSExpression(forKeyPath: kp)
        let ex2 = NSExpression(forConstantValue: value)
        self.init(leftExpression: ex1, rightExpression: ex2, modifier: .direct, type: op)
    }
}
