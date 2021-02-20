//
//  HomeTimelineIndex.swift
//  CoreDataStack
//
//  Created by MainasuK Cirno on 2021/1/27.
//

import Foundation
import CoreData

final public class HomeTimelineIndex: NSManagedObject {
    
    public typealias ID = String
    @NSManaged public private(set) var identifier: ID
    @NSManaged public private(set) var domain: String
    @NSManaged public private(set) var userID: String
    
    @NSManaged public private(set) var hasMore: Bool    // default NO
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var deletedAt: Date?

    
    // many-to-one relationship
    @NSManaged public private(set) var toot: Toot
    
}

extension HomeTimelineIndex {
    
    @discardableResult
    public static func insert(
        into context: NSManagedObjectContext,
        property: Property,
        toot: Toot
    ) -> HomeTimelineIndex {
        let index: HomeTimelineIndex = context.insertObject()
        
        index.identifier = property.identifier
        index.domain = property.domain
        index.userID = property.userID
        index.createdAt = toot.createdAt
        
        index.toot = toot
        
        return index
    }
    
    public func update(hasMore: Bool) {
        if self.hasMore != hasMore {
            self.hasMore = hasMore
        }
    }
    
    // internal method for Toot call
    func softDelete() {
        deletedAt = Date()
    }
    
}

extension HomeTimelineIndex {
    public struct Property {
        public let identifier: String
        public let domain: String
        public let userID: String
     
        public init(domain: String,userID: String) {
            self.identifier = UUID().uuidString + "@" + domain
            self.domain = domain
            self.userID = userID
        }
    }
}

extension HomeTimelineIndex: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \HomeTimelineIndex.createdAt, ascending: false)]
    }
}
extension HomeTimelineIndex {
    
    public static func predicate(userID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(HomeTimelineIndex.userID), userID)
    }
    
    
    public static func notDeleted() -> NSPredicate {
        return NSPredicate(format: "%K == nil", #keyPath(HomeTimelineIndex.deletedAt))
    }
    
}