//
//  manModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import Foundation
import CloudKit

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
    
    var attendeeCount: Int {
        return attendeeIDs.count
    }
    
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
    
    var isToday: Bool {
        Calendar.current.isDateInToday(dateTime)
    }
    
    var isUpcoming: Bool {
        dateTime > Date()
    }
}

// Empty state for new communities
class MeetingData {
    static var emptyMeetings: [Meeting] = []
    
    // Dummy data for testing
    static var dummyMeetings: [Meeting] = [
        Meeting(
            name: "Startup Sync Meeting",
            projectID: "project1",
            projectName: "The line project",
            attendeeIDs: ["user1", "user2", "user3", "user4", "user5"],
            dateTime: Date(),
            platform: "Zoom",
            link: "https://zoom.us/j/123456789",
            communityID: "community1",
            createdAt: Date()
        ),
        Meeting(
            name: "Weekly Meeting",
            projectID: "project2",
            projectName: "Counting project",
            attendeeIDs: Array(repeating: "user", count: 12),
            dateTime: Date(),
            platform: "Webex",
            link: "https://webex.com/meeting123",
            communityID: "community1",
            createdAt: Date()
        ),
        Meeting(
            name: "QNA Meeting",
            projectID: "project1",
            projectName: "The line project",
            attendeeIDs: ["user1", "user2", "user3", "user4", "user5"],
            dateTime: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            platform: "Webex",
            link: "https://webex.com/qna",
            communityID: "community1",
            createdAt: Date()
        )
    ]
}

// MARK: - CloudKit Conversion
extension Meeting {
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let projectID = record["projectID"] as? String,
              let projectName = record["projectName"] as? String,
              let attendeeIDs = record["attendeeIDs"] as? [String],
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
        self.attendeeIDs = attendeeIDs
        self.dateTime = dateTime
        self.platform = platform
        self.link = link
        self.communityID = communityID
        self.createdAt = createdAt
    }
    
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: "Meeting", recordID: recordID)
        
        record["name"] = name as CKRecordValue
        record["projectID"] = projectID as CKRecordValue
        record["projectName"] = projectName as CKRecordValue
        record["attendeeIDs"] = attendeeIDs as CKRecordValue
        record["dateTime"] = dateTime as CKRecordValue
        record["platform"] = platform as CKRecordValue
        record["link"] = link as CKRecordValue
        record["communityID"] = communityID as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        
        return record
    }
}
