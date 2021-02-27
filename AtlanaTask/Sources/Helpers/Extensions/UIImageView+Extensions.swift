
import UIKit
import Kingfisher


extension UIImageView {
    
    func setImage(imageURL: URL?) {
        guard let imageURL = imageURL else {
            image = nil
            return
        }
        
        let resource = ImageResource(downloadURL: imageURL, cacheKey: imageURL.absoluteString)
        self.kf.setImage(with: resource, options: [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.5))
        ])
    }
}
