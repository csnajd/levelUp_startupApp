import Foundation
import CloudKit

// ✅ FIX Bug 3: Added MeetingStatus so cancelled meetings stay visible instead of being deleted
enum MeetingStatus: String {
    case scheduled = "scheduled"
    case cancelled = "cancelled"
}

struct Meeting: Identifiable {
    var id = UUID()
    var name: String
    var projectID: String
    var projectName: String
    var attendeeIDs: [String]
    var dateTime: Date
    var platform: String
    var link: String
    var communityID: String
    var createdAt: Date
    // ✅ FIX Bug 3: New status field, defaults to scheduled
    var status: MeetingStatus = .scheduled

    var attendeeCount: Int { attendeeIDs.count }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: dateTime)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: dateTime)
    }

    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy | hh:mm a"
        return formatter.string(from: dateTime)
    }

    var isToday: Bool { Calendar.current.isDateInToday(dateTime) }
    var isUpcoming: Bool { dateTime > Date() }
    // ✅ FIX Bug 3: Convenience computed var for UI
    var isCancelled: Bool { status == .cancelled }
}

// MARK: - CloudKit Conversion
extension Meeting {
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let projectID = record["projectID"] as? String,
              let projectName = record["projectName"] as? String,
              let dateTime = record["dateTime"] as? Date,
              let platform = record["platform"] as? String,
              let link = record["link"] as? String,
              let communityID = record["communityID"] as? String,
              let createdAt = record["createdAt"] as? Date else {
            return nil
        }

        self.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        self.name = name
        self.projectID = projectID
        self.projectName = projectName
        self.attendeeIDs = record["attendeeIDs"] as? [String] ?? []
        self.dateTime = dateTime
        self.platform = platform
        self.link = link
        self.communityID = communityID
        self.createdAt = createdAt
        // ✅ FIX Bug 3: Read status from CloudKit, fall back to scheduled for old records
        let statusRaw = record["status"] as? String ?? "scheduled"
        self.status = MeetingStatus(rawValue: statusRaw) ?? .scheduled
    }

    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: "meeting", recordID: recordID)

        record["name"] = name as CKRecordValue
        record["projectID"] = projectID as CKRecordValue
        record["projectName"] = projectName as CKRecordValue
        record["attendeeIDs"] = attendeeIDs as CKRecordValue
        record["dateTime"] = dateTime as CKRecordValue
        record["platform"] = platform as CKRecordValue
        record["link"] = link as CKRecordValue
        record["communityID"] = communityID as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        // ✅ FIX Bug 3: Save status to CloudKit
        record["status"] = status.rawValue as CKRecordValue

        return record
    }
}
