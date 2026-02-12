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

//
//  CloudKitServices.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

//
//  CloudKitServices.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

//
//  CloudKitServices.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

//
//  CloudKitServices.swift
//  levelUp_startupApp
//
//  Unified CloudKit Service - Merged from all sources
//  Created on 2026-02-11
//

import Foundation
import CloudKit

class CloudKitServices {
    static let shared = CloudKitServices()
    
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
    
    // MARK: - User Profile Operations
    
    func saveUserProfile(_ user: User) async throws -> User {
        let record = try user.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        return try User(from: savedRecord)
    }
    
    func fetchUserProfile(appleUserID: String) async throws -> User? {
        let predicate = NSPredicate(format: "appleUserID == %@", appleUserID)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        for result in results {
            switch result.1 {
            case .success(let record):
                return try User(from: record)
            case .failure(let error):
                throw error
            }
        }
        
        return nil
    }
    
    func upsertUserProfile(
        appleUserID: String,
        email: String?,
        givenName: String?,
        familyName: String?
    ) async throws {
        let recordID = CKRecord.ID(recordName: appleUserID)
        
        let record: CKRecord
        do {
            record = try await publicDatabase.record(for: recordID)
        } catch let error as CKError {
            if error.code == .unknownItem {
                record = CKRecord(recordType: "UserProfile", recordID: recordID)
                record["createdAt"] = Date() as CKRecordValue
                record["appleUserID"] = appleUserID as CKRecordValue
            } else {
                throw error
            }
        }
        
        if let email, !email.isEmpty {
            record["email"] = email as CKRecordValue
        }
        if let givenName, !givenName.isEmpty {
            record["givenName"] = givenName as CKRecordValue
        }
        if let familyName, !familyName.isEmpty {
            record["familyName"] = familyName as CKRecordValue
        }
        
        record["lastLogin"] = Date() as CKRecordValue
        
        let saved = try await publicDatabase.save(record)
        print("✅ CloudKit saved:", saved.recordType, saved.recordID.recordName)
    }
    
    func fetchUserProfileRecord(appleUserID: String) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: appleUserID)
        let fetched = try await publicDatabase.record(for: recordID)
        print("✅ CloudKit fetched:", fetched.recordType, fetched.recordID.recordName)
        return fetched
    }
    
    // MARK: - Community Operations
    
    func saveCommunity(_ community: Community) async throws -> Community {
        let record = community.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let savedCommunity = Community(from: savedRecord) else {
            throw NSError(domain: "CloudKitServices", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create community from saved record"])
        }
        
        return savedCommunity
    }
    
    func updateCommunity(_ community: Community) async throws -> Community {
        let record = community.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let updatedCommunity = Community(from: savedRecord) else {
            throw NSError(domain: "CloudKitServices", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create community from saved record"])
        }
        
        return updatedCommunity
    }
    
    func fetchUserCommunities() async throws -> [Community] {
        guard let userID = try await getCurrentUserID() else {
            throw NSError(domain: "CloudKitServices", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get user ID"])
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
    
    // MARK: - Project Operations
    
    func saveProject(_ project: Project) async throws -> Project {
        let record = project.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let savedProject = Project(from: savedRecord) else {
            throw NSError(domain: "CloudKitServices", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create project from saved record"])
        }
        
        return savedProject
    }
    
    func fetchCommunityProjects(communityID: String) async throws -> [Project] {
        let predicate = NSPredicate(format: "communityID == %@", communityID)
        let query = CKQuery(recordType: "Project", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var projects: [Project] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                if let project = Project(from: record) {
                    projects.append(project)
                }
            case .failure(let error):
                print("Error fetching project: \(error)")
            }
        }
        
        return projects
    }
    
    func updateProject(_ project: Project) async throws -> Project {
        let record = project.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let updatedProject = Project(from: savedRecord) else {
            throw NSError(domain: "CloudKitServices", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create project from saved record"])
        }
        
        return updatedProject
    }
    
    func deleteProject(_ projectID: String) async throws {
        let recordID = CKRecord.ID(recordName: projectID)
        try await publicDatabase.deleteRecord(withID: recordID)
    }
    
    // MARK: - Task Operations (for future use)
    
    func saveTaskItem(
        title: String,
        description: String,
        projectID: String,
        assignedUserIDs: [String],
        status: String
    ) async throws {
        let record = CKRecord(recordType: "Task")
        record["title"] = title as CKRecordValue
        record["description"] = description as CKRecordValue
        record["projectID"] = projectID as CKRecordValue
        record["assignedUserIDs"] = assignedUserIDs as CKRecordValue
        record["status"] = status as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        _ = try await publicDatabase.save(record)
    }
    
    func fetchProjectTasks(projectID: String) async throws -> [String] {
        let predicate = NSPredicate(format: "projectID == %@", projectID)
        let query = CKQuery(recordType: "Task", predicate: predicate)
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var taskTitles: [String] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                if let title = record["title"] as? String {
                    taskTitles.append(title)
                }
            case .failure(let error):
                print("Error fetching task: \(error)")
            }
        }
        
        return taskTitles
    }
}
