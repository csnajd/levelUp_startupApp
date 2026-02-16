/*

import Foundation
import CloudKit

struct CloudKitTasksService {

    // إذا عندك Container Identifier حطيه هنا، وإلا خليها nil
    private let containerID: String? = nil
    // مثال:
    // private let containerID: String? = "iCloud.com.najd.levelUp-startupApp"

    private var container: CKContainer {
        if let containerID {
            return CKContainer(identifier: containerID)
        } else {
            return CKContainer.default()
        }
    }

    // تاسكات شخصية لكل مستخدم: privateCloudDatabase (الأبسط)
    private var db: CKDatabase { container.privateCloudDatabase }

    func fetchTasks(ownerUserID: String) async throws -> [AppTask] {
        let predicate = NSPredicate(format: "ownerUserID == %@", ownerUserID)
        let query = CKQuery(recordType: "Task", predicate: predicate)
        

        let (matchResults, _) = try await db.records(matching: query, resultsLimit: 200)

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

    // (اختياري) لإضافة Task بسرعة للتجربة
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

        _ = try await db.save(record)
    }
}
*/
