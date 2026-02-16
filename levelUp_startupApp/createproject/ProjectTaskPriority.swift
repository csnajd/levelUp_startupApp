import Foundation
import CloudKit

// MARK: - Project Task Priority (For CreateProject)

enum ProjectTaskPriority: String, CaseIterable {
    case urgent = "Urgent"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

// MARK: - Project Task Status (For CreateProject)

enum ProjectTaskStatus: String, CaseIterable {
    case todo = "TO do"
    case inProgress = "in progress"
    case done = "Done"
}

// MARK: - Project Task Model

struct ProjectTask: Identifiable {
    var id = UUID()
    var projectID: String
    var name: String
    var priority: ProjectTaskPriority
    var assignedUserIDs: [String]
    var startDate: Date
    var endDate: Date
    var status: ProjectTaskStatus
    var createdAt: Date
    var communityID: String
    
    var record: CKRecord?
    
    init?(from record: CKRecord) {
        guard let projectID = record["projectID"] as? String,
              let name = record["name"] as? String,
              let priorityString = record["priority"] as? String,
              let assignedUserIDs = record["assignedUserIDs"] as? [String],
              let startDate = record["startDate"] as? Date,
              let endDate = record["endDate"] as? Date,
              let statusString = record["status"] as? String,
              let communityID = record["communityID"] as? String else {
            return nil
        }
        
        guard let priority = ProjectTaskPriority(rawValue: priorityString),
              let status = ProjectTaskStatus(rawValue: statusString) else {
            return nil
        }
        
        self.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        self.projectID = projectID
        self.name = name
        self.priority = priority
        self.assignedUserIDs = assignedUserIDs
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.communityID = communityID
        self.record = record
    }
    
    init(id: UUID = UUID(),
         projectID: String,
         name: String,
         priority: ProjectTaskPriority = .medium,
         assignedUserIDs: [String] = [],
         startDate: Date,
         endDate: Date,
         status: ProjectTaskStatus = .todo,
         createdAt: Date = Date(),
         communityID: String) {
        self.id = id
        self.projectID = projectID
        self.name = name
        self.priority = priority
        self.assignedUserIDs = assignedUserIDs
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.createdAt = createdAt
        self.communityID = communityID
    }
    
    func toCKRecord() -> CKRecord {
        let record = self.record ?? CKRecord(recordType: "ProjectTask", recordID: CKRecord.ID(recordName: id.uuidString))
        
        record["projectID"] = projectID as CKRecordValue
        record["name"] = name as CKRecordValue
        record["priority"] = priority.rawValue as CKRecordValue
        record["assignedUserIDs"] = assignedUserIDs as CKRecordValue
        record["startDate"] = startDate as CKRecordValue
        record["endDate"] = endDate as CKRecordValue
        record["status"] = status.rawValue as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        record["communityID"] = communityID as CKRecordValue
        
        return record
    }
}

// MARK: - Task Creation Data (for the creation flow)

struct TaskCreationData {
    var name: String
    var priority: ProjectTaskPriority
    var assignedUserIDs: [String]
    var startDate: Date
    var endDate: Date
}

// MARK: - Team Member (for user selection)

struct TeamMember: Identifiable {
    var id: String
    var email: String?
    var givenName: String?
    var familyName: String?
    
    var displayName: String {
        if let given = givenName, let family = familyName {
            return "\(given) \(family)"
        } else if let given = givenName {
            return given
        } else if let email = email {
            return email
        } else {
            return "User"
        }
    }
    
    var initials: String {
        if let given = givenName, let family = familyName {
            let firstInitial = given.prefix(1)
            let lastInitial = family.prefix(1)
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else if let given = givenName {
            return String(given.prefix(1)).uppercased()
        } else if let email = email {
            return String(email.prefix(1)).uppercased()
        } else {
            return "U"
        }
    }
}
