
import UIKit


class BaseNavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self.viewControllers.first {
            self.setNavigationBarHidden(true, animated: animated)
        } else {
            self.setNavigationBarHidden(false, animated: animated)
        }
    }

}
