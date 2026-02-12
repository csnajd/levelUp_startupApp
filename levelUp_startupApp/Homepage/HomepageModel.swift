//
//  HomepageModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

//
//  HomepageModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import Foundation
import CloudKit

struct Project: Identifiable {
    var id = UUID()
    var name: String
    var memberIDs: [String]
    var isBlocked: Bool
    var blockReason: String?
    var createdAt: Date
    var communityID: String
    
    // CloudKit record (optional)
    var record: CKRecord?
    
    var memberCount: Int {
        return memberIDs.count
    }
    
    // Initialize from CloudKit record
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let memberIDs = record["memberIDs"] as? [String],
              let communityID = record["communityID"] as? String else {
            return nil
        }
        
        self.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        self.name = name
        self.memberIDs = memberIDs
        self.isBlocked = record["isBlocked"] as? Bool ?? false
        self.blockReason = record["blockReason"] as? String
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.communityID = communityID
        self.record = record
    }
    
    // Regular initializer
    init(id: UUID = UUID(), name: String, memberIDs: [String], isBlocked: Bool, blockReason: String?, createdAt: Date, communityID: String) {
        self.id = id
        self.name = name
        self.memberIDs = memberIDs
        self.isBlocked = isBlocked
        self.blockReason = blockReason
        self.createdAt = createdAt
        self.communityID = communityID
    }
    
    // Convert to CloudKit record
    func toCKRecord() -> CKRecord {
        let record = self.record ?? CKRecord(recordType: "Project", recordID: CKRecord.ID(recordName: id.uuidString))
        
        record["name"] = name
        record["memberIDs"] = memberIDs
        record["isBlocked"] = isBlocked
        record["blockReason"] = blockReason
        record["createdAt"] = createdAt
        record["communityID"] = communityID
        
        return record
    }
}

class ProjectData {
    // ✅ Default: Empty state
    static var emptyProjects: [Project] = []
    
    // ✅ For testing only - you can manually switch to this if you want to see dummy data
    static var dummyProjects: [Project] = [
        Project(
            name: "New Company App",
            memberIDs: ["user1", "user2", "user3", "user4"],
            isBlocked: false,
            blockReason: nil,
            createdAt: Date(),
            communityID: "community1"
        ),
        Project(
            name: "Design UI/UX",
            memberIDs: ["user1", "user2"],
            isBlocked: true,
            blockReason: "Waiting for design approval",
            createdAt: Date(),
            communityID: "community1"
        ),
        Project(
            name: "Backend Development",
            memberIDs: ["user3", "user4", "user5"],
            isBlocked: true,
            blockReason: "API documentation incomplete",
            createdAt: Date(),
            communityID: "community1"
        ),
        Project(
            name: "Marketing Campaign",
            memberIDs: ["user2"],
            isBlocked: true,
            blockReason: "Budget approval pending",
            createdAt: Date(),
            communityID: "community1"
        ),
        Project(
            name: "QA Testing",
            memberIDs: ["user1", "user3"],
            isBlocked: true,
            blockReason: "Development not complete",
            createdAt: Date(),
            communityID: "community1"
        )
    ]
}
