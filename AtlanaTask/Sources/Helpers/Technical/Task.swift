
import Foundation


struct Task {
    
    typealias Closure = (Controller) -> Void
    
    typealias OutcomeTask = Result<Void, Error>
    
    enum Outcome {
        case success
        case failure(Error)
    }
    
    struct Controller {
        fileprivate let queue: DispatchQueue
        fileprivate let handler: (OutcomeTask) -> Void

        func finish() {
            handler(.success(()))
        }

        func failure(with error: Error) {
            handler(.failure(error))
        }
    }
    
    // MARK: - Private Methods

    private let closure: Closure

    // MARK: - Lifecycle
    
    init(closure: @escaping Closure) {
        self.closure = closure
    }
    
    // MARK: - Public Methods
    
    func perform(on queue: DispatchQueue = .global(), then handler: @escaping (OutcomeTask) -> Void) {
        queue.async {
            let controller = Controller(
                queue: queue,
                handler: handler
            )

            self.closure(controller)
        }
    }
    
    
    // MARK: Static Methods
    
    static func group(_ tasks: [Task]) -> Task {
        return Task { controller in
            let group = DispatchGroup()
            
            let errorSyncQueue = DispatchQueue(label: "Task.ErrorSync")
            var anyError: Error?

            for task in tasks {
                group.enter()
                
                task.perform(on: controller.queue) { outcome in
                    switch outcome {
                    case .success:
                        break
                    case .failure(let error):
                        errorSyncQueue.sync {
                            anyError = anyError ?? error
                        }
                    }
                    
                    group.leave()
                }
            }

            group.notify(queue: controller.queue) {
                if let error = anyError {
                    controller.failure(with: error)
                } else {
                    controller.finish()
                }
            }
        }
    }
    
    static func sequence(_ tasks: [Task]) -> Task {
        var index = 0
        
        func performNext(using controller: Controller) {
            guard index < tasks.count else {
                controller.finish()
                return
            }

            let task = tasks[index]
            index += 1

            task.perform(on: controller.queue) { outcome in
                switch outcome {
                case .success:
                    performNext(using: controller)
                case .failure(let error):
                    controller.failure(with: error)
                }
            }
        }

        return Task(closure: performNext)
    }
    
}
