//
//  Repo+CoreDataProperties.swift
//  AtlanaTask
//
//  Created by Yevhen Alexandrov on 26.02.2021.
//
//

import Foundation
import CoreData


extension Repo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Repo> {
        return NSFetchRequest<Repo>(entityName: "Repo")
    }

    @NSManaged public var repositoryName: String
    @NSManaged public var repoURL: String
    @NSManaged public var starsCount: Int64
    @NSManaged public var forksCount: Int64
    @NSManaged public var ownerID: Int64
    @NSManaged public var ownerName: String
    @NSManaged public var user: User?

}

extension Repo : Identifiable {

}
