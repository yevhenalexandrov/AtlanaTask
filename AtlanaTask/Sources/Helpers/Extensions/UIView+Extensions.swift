
import UIKit


extension UIView {
    
    public func addSubviewAndScaleToFill(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        let viewDictionary = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                      options: .alignAllCenterX,
                                                      metrics: nil,
                                                      views: viewDictionary))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                      options: .alignAllCenterY,
                                                      metrics: nil,
                                                      views: viewDictionary))
    }

}


extension UIView {

    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}


@IBDesignable extension UIView {
    
    @IBInspectable
    var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
}
