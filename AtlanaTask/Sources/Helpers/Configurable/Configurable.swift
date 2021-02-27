
import Foundation


protocol Configurable {
    associatedtype T
    
    func configure(with viewModel: T)
}
