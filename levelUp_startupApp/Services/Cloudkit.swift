<<<<<<< HEAD
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
=======
import Foundation
import CloudKit

final class CloudKitService {

    private let container: CKContainer
    private let database: CKDatabase

    // usePublicDB = true عشان iCloud Storage Full عندك (Public ما يتوقف بسبب مساحة حسابك)
    init(containerID: String? = nil, usePublicDB: Bool = true) {
        if let id = containerID {
            self.container = CKContainer(identifier: id)
        } else {
            self.container = CKContainer.default()
        }
        self.database = usePublicDB ? container.publicCloudDatabase : container.privateCloudDatabase
    }

    // Upsert by recordName = appleUserID
    func upsertUserProfile(
        appleUserID: String,
        email: String?,
        givenName: String?,
        familyName: String?
    ) async throws {

        let recordID = CKRecord.ID(recordName: appleUserID)

        let record: CKRecord
        do {
            record = try await database.record(for: recordID)
        } catch let error as CKError {
            if error.code == .unknownItem {
                record = CKRecord(recordType: "UserProfile", recordID: recordID)
                record["createdAt"] = Date() as CKRecordValue
                record["appleUserID"] = appleUserID as CKRecordValue
            } else {
                throw error
            }
        }

        if let email, !email.isEmpty { record["email"] = email as CKRecordValue }
        if let givenName, !givenName.isEmpty { record["givenName"] = givenName as CKRecordValue }
        if let familyName, !familyName.isEmpty { record["familyName"] = familyName as CKRecordValue }

        record["lastLogin"] = Date() as CKRecordValue

        let saved = try await database.save(record)
        print("✅ CloudKit saved:", saved.recordType, saved.recordID.recordName)
    }

    func fetchUserProfile(appleUserID: String) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: appleUserID)
        let fetched = try await database.record(for: recordID)
        print("✅ CloudKit fetched:", fetched.recordType, fetched.recordID.recordName)
        return fetched
>>>>>>> main
    }
}
