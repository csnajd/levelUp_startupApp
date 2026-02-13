
//
//  Cloudkit.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 03/02/2026.
//

//
//  Cloudkit.swift
//  levelUp_startupApp
//
//  Created by Danyah Albarqawi on 03/02/2026.
//
import Foundation
import CloudKit

class Cloudkit {
    static let shared = Cloudkit()
    private let container = CKContainer.default()
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    
    private init() {}
    
    // Get current user's Apple ID
    func getCurrentUserID() async throws -> String? {
        let recordID = try await container.userRecordID()
        return recordID.recordName
    }
    
    // Save user profile
    func saveUserProfile(_ user: User) async throws -> User {
        let record = try user.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        return try User(from: savedRecord)
    }
    
    // Fetch user profile by Apple ID
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
    
    // MARK: - Meeting Operations
    
    func saveMeeting(_ meeting: Meeting) async throws -> Meeting {
        let record = meeting.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        
        guard let savedMeeting = Meeting(from: savedRecord) else {
            throw NSError(domain: "Cloudkit", code: -1,
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
            throw NSError(domain: "Cloudkit", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create meeting from saved record"])
        }
        
        return updatedMeeting
    }
    
    func deleteMeeting(_ meetingID: String) async throws {
        let recordID = CKRecord.ID(recordName: meetingID)
        try await publicDatabase.deleteRecord(withID: recordID)
    }
    
}
