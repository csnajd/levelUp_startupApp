//
//  CreateCommunityModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 10/02/2026.
//

//
//  CommunityModel.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

import Foundation
import CloudKit

struct Community: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var creatorID: String
    var organizationID: String
    var inviteCode: String
    
    // Permissions
    var anyoneCanJoin: Bool
    var inviteOnly: Bool
    var adminsOnlyPost: Bool
    var allMembersPost: Bool
    var adminManaged: Bool
    var moderatorManaged: Bool
    
    // Additional Settings
    var allowFileSharing: Bool
    var allowComments: Bool
    
    var createdAt: Date
    var memberIDs: [String]
    var adminIDs: [String]
    var moderatorIDs: [String]
    
    // CloudKit Record - not included in Codable/Hashable
    var record: CKRecord?
    
    // Custom Codable implementation to exclude record
    enum CodingKeys: String, CodingKey {
        case id, name, description, creatorID, organizationID, inviteCode
        case anyoneCanJoin, inviteOnly, adminsOnlyPost, allMembersPost
        case adminManaged, moderatorManaged, allowFileSharing, allowComments
        case createdAt, memberIDs, adminIDs, moderatorIDs
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Community, rhs: Community) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String,
         creatorID: String,
         organizationID: String,
         inviteCode: String = generateInviteCode(),
         anyoneCanJoin: Bool = true,
         inviteOnly: Bool = false,
         adminsOnlyPost: Bool = true,
         allMembersPost: Bool = false,
         adminManaged: Bool = true,
         moderatorManaged: Bool = false,
         allowFileSharing: Bool = true,
         allowComments: Bool = false,
         createdAt: Date = Date(),
         memberIDs: [String] = [],
         adminIDs: [String] = [],
         moderatorIDs: [String] = []) {
        
        self.id = id
        self.name = name
        self.description = description
        self.creatorID = creatorID
        self.organizationID = organizationID
        self.inviteCode = inviteCode
        self.anyoneCanJoin = anyoneCanJoin
        self.inviteOnly = inviteOnly
        self.adminsOnlyPost = adminsOnlyPost
        self.allMembersPost = allMembersPost
        self.adminManaged = adminManaged
        self.moderatorManaged = moderatorManaged
        self.allowFileSharing = allowFileSharing
        self.allowComments = allowComments
        self.createdAt = createdAt
        self.memberIDs = memberIDs
        self.adminIDs = adminIDs
        self.moderatorIDs = moderatorIDs
    }
    
    // Initialize from CloudKit Record
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let description = record["description"] as? String,
              let creatorID = record["creatorID"] as? String,
              let organizationID = record["organizationID"] as? String,
              let inviteCode = record["inviteCode"] as? String else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.name = name
        self.description = description
        self.creatorID = creatorID
        self.organizationID = organizationID
        self.inviteCode = inviteCode
        
        self.anyoneCanJoin = record["anyoneCanJoin"] as? Bool ?? true
        self.inviteOnly = record["inviteOnly"] as? Bool ?? false
        self.adminsOnlyPost = record["adminsOnlyPost"] as? Bool ?? true
        self.allMembersPost = record["allMembersPost"] as? Bool ?? false
        self.adminManaged = record["adminManaged"] as? Bool ?? true
        self.moderatorManaged = record["moderatorManaged"] as? Bool ?? false
        self.allowFileSharing = record["allowFileSharing"] as? Bool ?? true
        self.allowComments = record["allowComments"] as? Bool ?? false
        
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.memberIDs = record["memberIDs"] as? [String] ?? []
        self.adminIDs = record["adminIDs"] as? [String] ?? []
        self.moderatorIDs = record["moderatorIDs"] as? [String] ?? []
        
        self.record = record
    }
    
    // Convert to CloudKit Record
    func toCKRecord() -> CKRecord {
        let record = self.record ?? CKRecord(recordType: "Community", recordID: CKRecord.ID(recordName: id))
        
        record["name"] = name
        record["description"] = description
        record["creatorID"] = creatorID
        record["organizationID"] = organizationID
        record["inviteCode"] = inviteCode
        record["anyoneCanJoin"] = anyoneCanJoin
        record["inviteOnly"] = inviteOnly
        record["adminsOnlyPost"] = adminsOnlyPost
        record["allMembersPost"] = allMembersPost
        record["adminManaged"] = adminManaged
        record["moderatorManaged"] = moderatorManaged
        record["allowFileSharing"] = allowFileSharing
        record["allowComments"] = allowComments
        record["createdAt"] = createdAt
        record["memberIDs"] = memberIDs
        record["adminIDs"] = adminIDs
        record["moderatorIDs"] = moderatorIDs
        
        return record
    }
    
    static func generateInviteCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in characters.randomElement()! })
    }
}
