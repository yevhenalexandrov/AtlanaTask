
import Foundation


func DebugLog(_ str: String) {
    #if DEBUG
        print(str)
    #endif
}

