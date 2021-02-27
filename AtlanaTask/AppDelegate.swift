

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appRouter: ApplicationRouter!
    var applicationDIContainer = ApplicationDIContainer()
    var coredataManager = CoreDataManager.shared.persistentContainer
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        
        appRouter = ApplicationRouter(window: window!, diContainer: applicationDIContainer.container)
        appRouter.presentStartupScreen()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Private methods
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
    }
    
}

