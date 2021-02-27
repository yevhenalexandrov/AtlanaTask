
import UIKit


extension UIStoryboard {
    
    public func instantiate<T: UIViewController>(_ viewControllerType: T.Type = T.self) -> T where T: Instantiatable {
        let identifier = T.identifier
        guard let viewController = instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("\(identifier) cannot be instantiated")
        }
        return viewController
    }
    
}
