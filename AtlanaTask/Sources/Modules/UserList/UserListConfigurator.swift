
import UIKit
import Swinject


protocol UserListModuleOutput: class {
    
    func showUserViewer(with user: GithubUserServerModel)
}


class UserListConfigurator {

    private enum Constants {
        static let storyboardName = "UserList"
    }

    private let diContainer: Container
    
    init(diContainer: Container) {
        self.diContainer = diContainer
    }

    func moduleViewAndInput(withOutput output: UserListModuleOutput?) -> UserListViewController {
        let moduleView = moduleViewController()
        moduleConfigured(for: moduleView, withOutput: output)
        return moduleView
    }

    // MARK: - Private Methods
    
    private func moduleViewController() -> UserListViewController {
        let storyboard = UIStoryboard(name: Constants.storyboardName, bundle: Bundle.main)
        return storyboard.instantiate() as UserListViewController
    }
    
    private func moduleConfigured(
        for viewController: UserListViewController,
        withOutput output: UserListModuleOutput?)
    {
        let githubService = diContainer.resolve(GithubServiceProtocol.self)!
        let storageService = diContainer.resolve(StorageServiceProtocol.self)!
        
        let viewModel = UserListViewModel(githubService: githubService, storageService: storageService)
        viewController.output = output
        viewController.bind(viewModel: viewModel)
    }
    
}
