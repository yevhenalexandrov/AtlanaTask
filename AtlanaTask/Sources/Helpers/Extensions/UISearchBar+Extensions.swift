
import UIKit


extension UISearchBar {

    /// Returns the`UITextField` that is placed inside the text field.
    var textField: UITextField {
        if #available(iOS 13, *) {
            return searchTextField
        } else {
            return self.value(forKey: "_searchField") as! UITextField
        }
    }

}
