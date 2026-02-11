//
//  DanCloud.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 10/02/2026.
//

//
//  CloudKitService.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

//
//  CloudKitService.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

import Foundation
import CloudKit

class CloudKitService {
    static let shared = CloudKitService()
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase
    
    private init() {
        container = CKContainer.default()
        publicDatabase = container.publicCloudDatabase
        privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - User Operations
    
    func getCurrentUserID() async throws -> String? {
        let recordID = try await container.userRecordID()
        return recordID.recordName
    }
    
    // MARK: - Community Operations
    
    func saveCommunity(_ community: Community) async throws -> Community {
        let record = community.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let savedCommunity = Community(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create community from saved record"])
        }
        
        return savedCommunity
    }
    
    func updateCommunity(_ community: Community) async throws -> Community {
        let record = community.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let updatedCommunity = Community(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create community from saved record"])
        }
        
        return updatedCommunity
    }
    
    func fetchUserCommunities() async throws -> [Community] {
        guard let userID = try await getCurrentUserID() else {
            throw NSError(domain: "CloudKitService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get user ID"])
        }
        
        let predicate = NSPredicate(format: "memberIDs CONTAINS %@", userID)
        let query = CKQuery(recordType: "Community", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var communities: [Community] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                if let community = Community(from: record) {
                    communities.append(community)
                }
            case .failure(let error):
                print("Error fetching community: \(error)")
            }
        }
        
        return communities
    }
    
    func findCommunityByInviteCode(_ code: String) async throws -> Community? {
        let predicate = NSPredicate(format: "inviteCode == %@", code)
        let query = CKQuery(recordType: "Community", predicate: predicate)
        
        let (results, _) = try await publicDatabase.records(matching: query, desiredKeys: nil)
        
        for (_, result) in results {
            switch result {
            case .success(let record):
                return Community(from: record)
            case .failure(let error):
                throw error
            }
        }
        
        return nil
    }
    
    func deleteCommunity(_ communityID: String) async throws {
        let recordID = CKRecord.ID(recordName: communityID)
        try await publicDatabase.deleteRecord(withID: recordID)
    }
    
    // MARK: - Project Operations (for future use)
    
    func saveProject(_ project: Project) async throws -> Project {
        // Implementation will be added when creating project features
        fatalError("Not implemented yet")
    }
    
    func fetchCommunityProjects(communityID: String) async throws -> [Project] {
        // Implementation will be added when creating project features
        return []
    }
    
    // MARK: - Task Operations (for future use)
    
    func saveTask(_ task: TaskItem) async throws -> TaskItem {
        // Implementation will be added when creating task features
        fatalError("Not implemented yet")
    }
    
    func fetchProjectTasks(projectID: String) async throws -> [TaskItem] {
        // Implementation will be added when creating task features
        return []
    }
}

// MARK: - Placeholder Models (to be implemented later)

struct Project: Identifiable {
    var id: String
    var name: String
    var description: String
    var communityID: String
    var createdAt: Date
}

struct TaskItem: Identifiable {
    var id: String
    var title: String
    var description: String
    var projectID: String
    var assignedUserIDs: [String]
    var status: String
    var createdAt: Date
}
