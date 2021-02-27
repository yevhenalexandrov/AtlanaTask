
import UIKit
import Swinject
import SafariServices


class ApplicationRouter: NSObject {
    
    private enum RoutingSection {
        case userList
    }
    
    // MARK: - Private Properties
    
    private var window: UIWindow
    
    private var safariViewController: SFSafariViewController?
    
    private let diContainer: Container
    
    private var routingSection: RoutingSection = .userList
    
    init(window: UIWindow, diContainer: Container) {
        self.window = window
        self.diContainer = diContainer
    }
    
    // MARK: - Public Methods
    
    func presentStartupScreen() {
        switch routingSection {
        case .userList:
            presentUserListModule()
        }
    }
    
    // MARK: - Private methods
    
    private func presentUserListModule() {
        let configurator = UserListConfigurator(diContainer: diContainer)
        let moduleView = configurator.moduleViewAndInput(withOutput: self)
        
        let navigationController = BaseNavigationController(rootViewController: moduleView)
        navigationController.navigationBar.isTranslucent = false
        
        window.switchRootViewController(navigationController)
    }
    
    private func presentUserViewerModule(with user: GithubUserServerModel) {
        let configurator = UserViewerConfigurator(diContainer: diContainer)
        let moduleView = configurator.moduleViewAndInput(withOutput: self)
        
        moduleView.viewModel.configure(for: user)
        
        if let navigation = window.rootViewController as? BaseNavigationController {
            navigation.pushViewController(moduleView, animated: true)
        }
    }
}


// MARK: - UserListModuleOutput

extension ApplicationRouter: UserListModuleOutput {
    
    func showUserViewer(with user: GithubUserServerModel) {
        presentUserViewerModule(with: user)
    }
}


// MARK: - UserViewerModuleOutput

extension ApplicationRouter: UserViewerModuleOutput {
    
    func openLink(_ url: URL) {
        DebugLog("Open Link for url: \(url.absoluteString)")
        
        guard let navigationController = window.rootViewController as? BaseNavigationController else {
            return
        }
        
        let viewController = SFSafariViewController(url: url)
        viewController.delegate = self
        navigationController.present(viewController, animated: true, completion: nil)
        
        safariViewController = viewController
    }
    
}


// MARK: - SFSafariViewControllerDelegate

extension ApplicationRouter: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        safariViewController?.dismiss(animated: true)
    }
    
}
