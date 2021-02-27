
import UIKit


extension UINavigationController {
    
    func removeShadow() {
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
}
