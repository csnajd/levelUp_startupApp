//
//  ContentView.swift
//  levelUp_startupApp
//

import SwiftUI
import CloudKit

struct UserProgress {
    var currentLevel: Int
    var xp: Int
}

struct ContentView: View {

    @State private var progress = UserProgress(currentLevel: 0, xp: 0)
    @State private var isLoading = true
    @State private var statusText = ""
    @State private var recordID: CKRecord.ID? = nil

    var body: some View {
        VStack(spacing: 14) {

            if isLoading {
                ProgressView("Loading from CloudKit...")
            } else {
                Text("Level \(progress.currentLevel)")
                    .font(.title)

                Text("XP: \(progress.xp)")
                    .font(.headline)

                Button("Gain XP") {
                    progress.xp += 10
                    saveUserProgress()
                }
                .buttonStyle(.borderedProminent)

                if !statusText.isEmpty {
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                }
            }
        }
        .padding()
        .onAppear {
            loadOrCreateUserProgress()
        }
    }

    // MARK: - CloudKit

    private var database: CKDatabase {
        CKContainer.default().privateCloudDatabase
    }

    private func loadOrCreateUserProgress() {
        isLoading = true
        statusText = ""

        let query = CKQuery(recordType: "UserProgress", predicate: NSPredicate(value: true))

        // ✅ Newer API (not deprecated) + completion handler
        database.fetch(withQuery: query, inZoneWith: nil) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (matchResults, _)):

                    // Try to get the first record
                    if let first = matchResults.first,
                       case .success(let record) = first.1 {

                        self.recordID = record.recordID
                        self.apply(record: record)
                        self.statusText = "Loaded from CloudKit ✅"
                        self.isLoading = false
                        return
                    }

                    // No record found -> create one
                    let new = CKRecord(recordType: "UserProgress")
                    new["currentLevel"] = 1 as CKRecordValue
                    new["xp"] = 0 as CKRecordValue
                    new["updatedAt"] = Date() as CKRecordValue

                    self.database.save(new) { saved, error in
                        DispatchQueue.main.async {
                            if let saved {
                                self.recordID = saved.recordID
                                self.apply(record: saved)
                                self.statusText = "Created new record ✅"
                            } else {
                                self.statusText = "Create failed: \(error?.localizedDescription ?? "Unknown error")"
                            }
                            self.isLoading = false
                        }
                    }

                case .failure(let error):
                    self.statusText = "Fetch failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    private func saveUserProgress() {
        statusText = "Saving..."

        let record: CKRecord
        if let recordID {
            // Update existing record using the same recordID
            record = CKRecord(recordType: "UserProgress", recordID: recordID)
        } else {
            record = CKRecord(recordType: "UserProgress")
        }

        record["currentLevel"] = progress.currentLevel as CKRecordValue
        record["xp"] = progress.xp as CKRecordValue
        record["updatedAt"] = Date() as CKRecordValue

        database.save(record) { saved, error in
            DispatchQueue.main.async {
                if let saved {
                    self.recordID = saved.recordID
                    self.statusText = "Saved to CloudKit ✅"
                } else {
                    self.statusText = "Save failed: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }

    private func apply(record: CKRecord) {
        let level = record["currentLevel"] as? Int ?? 1
        let xp = record["xp"] as? Int ?? 0
        self.progress = UserProgress(currentLevel: level, xp: xp)
    }
}

#Preview {
    ContentView()
}
