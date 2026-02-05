//
//  HomepageModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import Foundation
import CloudKit

struct HomepageProject: Identifiable, Hashable {
    let id: CKRecord.ID
    let title: String
    let createdAt: Date

    init(id: CKRecord.ID, title: String, createdAt: Date) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }

    init(record: CKRecord) {
        self.id = record.recordID
        self.title = record[CloudKitSchema.Field.title] as? String ?? ""
        self.createdAt = record[CloudKitSchema.Field.createdAt] as? Date ?? Date()
    }
}


//helloooooooo
