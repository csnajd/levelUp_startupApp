import Foundation
import CloudKit
import UIKit

/// Unified CloudKit service - replaces both Cloudkit.swift and CloudKitServices.swift
final class CloudKitService {
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
        
        _ = try await publicDatabase.save(record)
    }
    
    func fetchUserProfileRecord(appleUserID: String) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: appleUserID)
        return try await publicDatabase.record(for: recordID)
    }
    
    // MARK: - Community Operations
    
    func saveCommunity(_ community: Community) async throws -> Community {
        let record = community.toCKRecord()
        let savedRecord = try await privateDatabase.save(record)
        
        guard let savedCommunity = Community(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create community from saved record"])
        }
        
        return savedCommunity
    }
    
    func updateCommunity(_ community: Community) async throws -> Community {
        let record = community.toCKRecord()
        let savedRecord = try await privateDatabase.save(record)
        
        guard let updatedCommunity = Community(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create community from saved record"])
        }
        
        return updatedCommunity
    }
    
    func fetchUserCommunities() async throws -> [Community] {
        guard let userID = try await getCurrentUserID() else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Could not get user ID"])
        }
        
        let predicate = NSPredicate(format: "memberIDs CONTAINS %@", userID)
        let query = CKQuery(recordType: "Community", predicate: predicate)
        
        let (results, _) = try await privateDatabase.records(matching: query)
        
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
        
        return communities.sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchCommunityByID(_ communityID: String) async throws -> Community? {
        let recordID = CKRecord.ID(recordName: communityID)
        
        do {
            let record = try await privateDatabase.record(for: recordID)
            return Community(from: record)
        } catch {
            print("Error fetching community by ID: \(error)")
            throw error
        }
    }
    
    func findCommunityByInviteCode(_ code: String) async throws -> Community? {
        let predicate = NSPredicate(format: "inviteCode == %@", code)
        let query = CKQuery(recordType: "Community", predicate: predicate)
        
        let (results, _) = try await privateDatabase.records(matching: query, desiredKeys: nil)
        
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
        try await privateDatabase.deleteRecord(withID: recordID)
    }
    
    func fetchCommunityMembers(communityID: String) async throws -> [User] {
        let communityRecordID = CKRecord.ID(recordName: communityID)
        let communityRecord = try await publicDatabase.record(for: communityRecordID)
        
        guard let community = Community(from: communityRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Could not parse community"])
        }
        
        var members: [User] = []
        
        for memberID in community.memberIDs {
            let userPredicate = NSPredicate(format: "appleUserID == %@", memberID)
            let userQuery = CKQuery(recordType: "UserProfile", predicate: userPredicate)
            
            let (userResults, _) = try await publicDatabase.records(matching: userQuery)
            
            for (_, userResult) in userResults {
                switch userResult {
                case .success(let record):
                    if let user = try? User(from: record), user.profileVisible {
                        members.append(user)
                    }
                case .failure(let error):
                    print("Error fetching user \(memberID): \(error)")
                }
            }
        }
        
        return members.sorted { $0.fullName < $1.fullName }
    }
    
    // MARK: - Project Operations
    
    func saveProject(_ project: Project) async throws -> Project {
        let record = project.toCKRecord()
        let savedRecord = try await privateDatabase.save(record)
        
        guard let savedProject = Project(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create project from saved record"])
        }
        
        return savedProject
    }
    
    func fetchCommunityProjects(communityID: String) async throws -> [Project] {
        let predicate = NSPredicate(format: "communityID == %@", communityID)
        let query = CKQuery(recordType: "Project", predicate: predicate)
        
        let (results, _) = try await privateDatabase.records(matching: query)
        
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
        
        return projects.sorted { $0.createdAt > $1.createdAt }
    }
    
    func updateProject(_ project: Project) async throws -> Project {
        let record = project.toCKRecord()
        let savedRecord = try await privateDatabase.save(record)
        
        guard let updatedProject = Project(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create project from saved record"])
        }
        
        return updatedProject
    }
    
    func deleteProject(_ projectID: String) async throws {
        let recordID = CKRecord.ID(recordName: projectID)
        try await privateDatabase.deleteRecord(withID: recordID)
    }
    
    // MARK: - Task Operations (Project Tasks)
    
    func saveProjectTask(_ task: ProjectTask) async throws -> ProjectTask {
        let record = task.toCKRecord()
        let savedRecord = try await privateDatabase.save(record)
        
        guard let savedTask = ProjectTask(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create task from saved record"])
        }
        
        return savedTask
    }
    
    func fetchProjectTasks(projectID: String) async throws -> [ProjectTask] {
        let predicate = NSPredicate(format: "projectID == %@", projectID)
        let query = CKQuery(recordType: "ProjectTask", predicate: predicate)
        
        let (results, _) = try await privateDatabase.records(matching: query)
        
        var tasks: [ProjectTask] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                if let task = ProjectTask(from: record) {
                    tasks.append(task)
                }
            case .failure(let error):
                print("Error fetching task: \(error)")
            }
        }
        
        return tasks.sorted { $0.createdAt < $1.createdAt }
    }
    
    func updateProjectTask(_ task: ProjectTask) async throws -> ProjectTask {
        let record = task.toCKRecord()
        let savedRecord = try await privateDatabase.save(record)
        
        guard let updatedTask = ProjectTask(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create task from saved record"])
        }
        
        return updatedTask
    }
    
    func deleteProjectTask(_ taskID: String) async throws {
        let recordID = CKRecord.ID(recordName: taskID)
        try await privateDatabase.deleteRecord(withID: recordID)
    }
    
    // MARK: - Personal Task Operations
    
    func fetchTasks(ownerUserID: String) async throws -> [AppTask] {
        let predicate = NSPredicate(format: "ownerUserID == %@", ownerUserID)
        let query = CKQuery(recordType: "Task", predicate: predicate)
        
        let (matchResults, _) = try await privateDatabase.records(matching: query, resultsLimit: 200)
        
        var tasks: [AppTask] = []
        tasks.reserveCapacity(matchResults.count)
        
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                tasks.append(AppTask(record: record))
            case .failure:
                continue
            }
        }
        
        return tasks
    }
    
    func addTask(
        ownerUserID: String,
        title: String,
        projectName: String,
        details: String? = nil,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date? = nil
    ) async throws {
        let record = CKRecord(recordType: "Task")
        record["ownerUserID"] = ownerUserID as CKRecordValue
        record["title"] = title as CKRecordValue
        record["projectName"] = projectName as CKRecordValue
        if let details { record["details"] = details as CKRecordValue }
        
        record["priority"] = priority.rawValue as CKRecordValue
        record["status"] = status.rawValue as CKRecordValue
        
        if let dueDate { record["dueDate"] = dueDate as CKRecordValue }
        
        let now = Date()
        record["createdAt"] = now as CKRecordValue
        record["updatedAt"] = now as CKRecordValue
        
        _ = try await privateDatabase.save(record)
    }
    
    // MARK: - Meeting Operations
    
    func saveMeeting(_ meeting: Meeting) async throws -> Meeting {
        let record = meeting.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let savedMeeting = Meeting(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create meeting from saved record"])
        }
        
        return savedMeeting
    }
    
    func fetchCommunityMeetings(communityID: String) async throws -> [Meeting] {
        let predicate = NSPredicate(format: "communityID == %@", communityID)
        let query = CKQuery(recordType: "Meeting", predicate: predicate)
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var meetings: [Meeting] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                if let meeting = Meeting(from: record) {
                    meetings.append(meeting)
                }
            case .failure(let error):
                print("Error fetching meeting: \(error)")
            }
        }
        
        return meetings.sorted { $0.dateTime < $1.dateTime }
    }
    
    func fetchProjectMeetings(projectID: String) async throws -> [Meeting] {
        let predicate = NSPredicate(format: "projectID == %@", projectID)
        let query = CKQuery(recordType: "Meeting", predicate: predicate)
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var meetings: [Meeting] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                if let meeting = Meeting(from: record) {
                    meetings.append(meeting)
                }
            case .failure(let error):
                print("Error fetching meeting: \(error)")
            }
        }
        
        return meetings.sorted { $0.dateTime < $1.dateTime }
    }
    
    func fetchUserMeetings(userID: String) async throws -> [Meeting] {
        let predicate = NSPredicate(format: "attendeeIDs CONTAINS %@", userID)
        let query = CKQuery(recordType: "Meeting", predicate: predicate)
        
        let (results, _) = try await publicDatabase.records(matching: query)
        
        var meetings: [Meeting] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                if let meeting = Meeting(from: record) {
                    meetings.append(meeting)
                }
            case .failure(let error):
                print("Error fetching meeting: \(error)")
            }
        }
        
        return meetings.sorted { $0.dateTime < $1.dateTime }
    }
    
    func updateMeeting(_ meeting: Meeting) async throws -> Meeting {
        let record = meeting.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let updatedMeeting = Meeting(from: savedRecord) else {
            throw NSError(domain: "CloudKitService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create meeting from saved record"])
        }
        
        return updatedMeeting
    }
    
    func deleteMeeting(_ meetingID: String) async throws {
        let recordID = CKRecord.ID(recordName: meetingID)
        try await publicDatabase.deleteRecord(withID: recordID)
    }
}
