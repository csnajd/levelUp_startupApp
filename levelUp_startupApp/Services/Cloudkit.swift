//
//  Cloudkit.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 03/02/2026.
//


import Foundation
import CloudKit

final class CloudKitService {
    static let shared = CloudKitService()

    private init() {}

    private let container = CKContainer.default()
    private var db: CKDatabase { container.publicCloudDatabase } // public مثل كودك

    // MARK: - Project

    func fetchProjects(completion: @escaping (Result<[HomepageProject], Error>) -> Void) {
        let query = CKQuery(recordType: CloudKitSchema.RecordType.project,
                            predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: CloudKitSchema.Field.createdAt, ascending: false)]

        db.perform(query, inZoneWith: nil) { records, error in
            if let error {
                completion(.failure(error))
                return
            }

            let items = (records ?? []).map { HomepageProject(record: $0) }
            completion(.success(items))
        }
    }

    func createProject(title: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let record = CKRecord(recordType: CloudKitSchema.RecordType.project)
        record[CloudKitSchema.Field.title] = title as CKRecordValue
        record[CloudKitSchema.Field.createdAt] = Date() as CKRecordValue

        db.save(record) { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func deleteProject(id: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
        db.delete(withRecordID: id) { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
}

// MARK: - CloudKit Schema Names
enum CloudKitSchema {
    enum RecordType {
        static let project = "project"  // انتبهي: نفس اللي في CloudKit Console
    }

    enum Field {
        static let title = "title"
        static let createdAt = "createdAt"
    }
}

