
import UIKit


public extension UIViewController {
    
    func pushViewController(with viewControllerToPush: UIViewController, animated: Bool) {
        guard let navigation = self.navigationController else {
            assertionFailure("Doesn't have a navigation controller")
            return
        }
        navigation.pushViewController(viewControllerToPush, animated: animated)
    }
    
    func setBackBarButtonName(_ name: String) {
        guard let navigation = self.navigationController, navigation.viewControllers.count > 0 else { return }
        
        let backBarButton = UIBarButtonItem(title: name, style: .plain, target: nil, action: nil)
        navigation.viewControllers.last?.navigationItem.backBarButtonItem = backBarButton
    }
    
    func setNavigationItemTitle(_ title: String) {
        self.navigationItem.title = title
    }
    
}


public extension UIViewController {

    var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }

}


public extension UIViewController {
    
    func embed(_ viewToEmbed: UIView, into containerView: UIView, animated: Bool) {
        let embedAction: () -> Void = {
            containerView.addSubviewAndScaleToFill(viewToEmbed)
        }
        
        if animated {
            UIView.transition(
                with: containerView,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: embedAction,
                completion: nil
            )
        } else {
            embedAction()
        }
    }

    func embed(_ viewController: UIViewController, into containerView: UIView) {
        addChild(viewController)
        containerView.addSubviewAndScaleToFill(viewController.view)
        viewController.didMove(toParent: self)
    }

}
