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
}
