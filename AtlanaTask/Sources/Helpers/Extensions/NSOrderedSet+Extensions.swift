//
//  NSOrderedSet+Extensions.swift
//  AtlanaTask
//
//  Created by Yevhen Alexandrov on 27.02.2021.
//

import Foundation


extension NSOrderedSet {
    
    func toArray<T>() -> [T] {
        guard let array = array as? [T] else {
            return []
        }
        return array
    }
}


extension NSSet {
    
    func toArray<T>() -> [T] {
        let array = self.map { $0 as! T }
        return array
    }
}
