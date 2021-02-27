
import UIKit


extension UIColor {
    
    convenience public init(hexRGB: CUnsignedLongLong) {
        let red: CGFloat = CGFloat((hexRGB & 0xFF0000) >> 16) / CGFloat(255)
        let green: CGFloat = CGFloat((hexRGB & 0xFF00) >> 8) / CGFloat(255)
        let blue: CGFloat = CGFloat(hexRGB & 0xFF) / CGFloat(255)
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
