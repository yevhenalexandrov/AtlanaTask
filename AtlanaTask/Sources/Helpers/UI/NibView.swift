
import UIKit


open class NibView: UIView {
    
    private lazy var nibView: UIView = self.loadViewFromNib()
    
    open override var backgroundColor: UIColor? {
        didSet {
            nibView.backgroundColor = backgroundColor
        }
    }
    
    open override var isHidden: Bool {
        didSet {
            nibView.isHidden = isHidden
        }
    }
    
    open override var alpha: CGFloat {
        didSet {
            nibView.alpha = alpha
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupNib()
        awakeFromNib()
    }
    
}


private extension NibView {
    
    func setupNib() {
        nibView.frame = bounds
        nibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(nibView, at: 0)
    }
    
    func loadViewFromNib() -> UIView {
        let nibName = String(describing: type(of: self))
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        let topLevelViews  = nib.instantiate(withOwner: self, options: nil)
        
        guard let nibView = topLevelViews.first as? UIView else {
            fatalError("Unable to load view from XIB \(nibName)")
        }
        
        return nibView
    }
    
}

