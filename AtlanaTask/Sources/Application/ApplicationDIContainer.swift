
import Foundation
import Swinject


class ApplicationDIContainer {
    
    let container = Container()
    
    init() {
        registerServices()
    }
}


private extension ApplicationDIContainer {
    
    func registerServices() {
        container.register(NetworkServiceProtocol.self) { resolver in
            return NetworkService()
        }.inObjectScope(.container)
        
        container.register(GithubServiceProtocol.self) { resolver in
            let networkService = resolver.resolve(NetworkServiceProtocol.self)!
            return GithubService(networkService: networkService)
        }.inObjectScope(.container)
        
        container.register(StorageServiceProtocol.self) { resolver in
            return StorageService()
        }.inObjectScope(.container)
    }
    
}
