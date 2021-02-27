//
//  User+CoreDataProperties.swift
//  AtlanaTask
//
//  Created by Yevhen Alexandrov on 27.02.2021.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userName: String?
    @NSManaged public var userID: Int64
    @NSManaged public var avatarURL: String?
    @NSManaged public var email: String?
    @NSManaged public var location: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var followersCount: Int64
    @NSManaged public var followingCount: Int64
    @NSManaged public var accountName: String?
    @NSManaged public var reposCount: Int64
    @NSManaged public var bio: String?
    @NSManaged public var repos: NSOrderedSet?

}

// MARK: Generated accessors for repos
extension User {

    @objc(insertObject:inReposAtIndex:)
    @NSManaged public func insertIntoRepos(_ value: Repo, at idx: Int)

    @objc(removeObjectFromReposAtIndex:)
    @NSManaged public func removeFromRepos(at idx: Int)

    @objc(insertRepos:atIndexes:)
    @NSManaged public func insertIntoRepos(_ values: [Repo], at indexes: NSIndexSet)

    @objc(removeReposAtIndexes:)
    @NSManaged public func removeFromRepos(at indexes: NSIndexSet)

    @objc(replaceObjectInReposAtIndex:withObject:)
    @NSManaged public func replaceRepos(at idx: Int, with value: Repo)

    @objc(replaceReposAtIndexes:withRepos:)
    @NSManaged public func replaceRepos(at indexes: NSIndexSet, with values: [Repo])

    @objc(addReposObject:)
    @NSManaged public func addToRepos(_ value: Repo)

    @objc(removeReposObject:)
    @NSManaged public func removeFromRepos(_ value: Repo)

    @objc(addRepos:)
    @NSManaged public func addToRepos(_ values: NSOrderedSet)

    @objc(removeRepos:)
    @NSManaged public func removeFromRepos(_ values: NSOrderedSet)

}

extension User : Identifiable {

}
