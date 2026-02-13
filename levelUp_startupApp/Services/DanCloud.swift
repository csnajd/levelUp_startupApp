//
//  DanCloud.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 10/02/2026.
//

//
//  import Foundation
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
        print("💾 Attempting to save community: \(community.name)")
        let record = community.toCKRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            print("✅ Community saved successfully!")
            
            guard let savedCommunity = Community(from: savedRecord) else {
                throw NSError(domain: "CloudKitServices", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create community from saved record"])
            }
            
            return savedCommunity
        } catch {
            print("❌ Error saving community: \(error)")
            throw error
        }
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
        // ✅ NO sortDescriptors line here!
        
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
        
        // ✅ Sort in memory instead
        return communities.sorted { $0.createdAt > $1.createdAt }
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
        // ✅ REMOVED sortDescriptors - sorting in memory instead
        
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
        
        // ✅ Sort in memory by createdAt
        return projects.sorted { $0.createdAt > $1.createdAt }
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
    
    // MARK: - Community Members
    
    /// Fetch all members of a specific community
    /// - Parameter communityID: The ID of the community
    /// - Returns: Array of User objects who are members of the community
    func fetchCommunityMembers(communityID: String) async throws -> [User] {
        // Fetch the community by ID
        let communityRecordID = CKRecord.ID(recordName: communityID)
        let communityRecord = try await publicDatabase.record(for: communityRecordID)
        
        guard let community = Community(from: communityRecord) else {
            throw NSError(
                domain: "CloudKitServices",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Could not parse community"]
            )
        }
        
        var members: [User] = []
        
        // Fetch each member's user profile from publicDatabase
        for memberID in community.memberIDs {
            let userPredicate = NSPredicate(format: "appleUserID == %@", memberID)
            let userQuery = CKQuery(recordType: "UserProfile", predicate: userPredicate)
            
            let (userResults, _) = try await publicDatabase.records(matching: userQuery)
            
            for (_, userResult) in userResults {
                switch userResult {
                case .success(let record):
                    if let user = try? User(from: record) {
                        // Only include users who have visible profiles
                        if user.profileVisible {
                            members.append(user)
                        }
                    }
                case .failure(let error):
                    print("⚠️ Error fetching user \(memberID): \(error)")
                }
            }
        }
        
        // Sort alphabetically by full name
        return members.sorted { $0.fullName < $1.fullName }
    }
}

// MARK: - Placeholder Models (to be implemented later)

struct CloudProject: Identifiable {
    var id: String
    var name: String
    var description: String
    var communityID: String
    var createdAt: Date
}

struct CloudTask: Identifiable {
    var id: String
    var title: String
    var description: String
    var projectID: String
    var assignedUserIDs: [String]
    var status: String
    var createdAt: Date
}
