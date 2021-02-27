
import UIKit
import Swinject


protocol UserViewerModuleOutput: class {
    
    func openLink(_ url: URL)
}


class UserViewerConfigurator {

    private enum Constants {
        static let storyboardName = "UserViewer"
    }

    private let diContainer: Container
    
    init(diContainer: Container) {
        self.diContainer = diContainer
    }

    func moduleViewAndInput(withOutput output: UserViewerModuleOutput?) -> UserViewerViewController {
        let moduleView = moduleViewController()
        moduleConfigured(for: moduleView, withOutput: output)
        return moduleView
    }

    // MARK: - Private Methods
    
    private func moduleViewController() -> UserViewerViewController {
        let storyboard = UIStoryboard(name: Constants.storyboardName, bundle: Bundle.main)
        return storyboard.instantiate() as UserViewerViewController
    }
    
    private func moduleConfigured(
        for viewController: UserViewerViewController,
        withOutput output: UserViewerModuleOutput?)
    {
        let networkService = diContainer.resolve(NetworkServiceProtocol.self)!
        let storageService = diContainer.resolve(StorageServiceProtocol.self)!
        
        let viewModel = UserViewerViewModel(networkService: networkService, storageService: storageService)
        viewModel.output = output
        viewController.viewModel = viewModel
    }
    
}
