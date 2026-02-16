import Foundation
import CloudKit
internal import Combine

@MainActor
final class manViewModel: ObservableObject {
    @Published var meetings: [Meeting] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var communityID: String = ""
    
    private let cloudKitService = CloudKitService.shared
    
    init() {
        // Initial setup
    }
    
    func loadMeetings() async {
        guard !communityID.isEmpty else {
            print("⚠️ No community ID set")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            meetings = try await cloudKitService.fetchCommunityMeetings(communityID: communityID)
            isLoading = false
            print("✅ Loaded \(meetings.count) meetings")
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            meetings = []
            print("❌ Error loading meetings: \(error)")
        }
    }
    
    func addMeeting(_ meeting: Meeting) {
        meetings.append(meeting)
        
        Task {
            do {
                let savedMeeting = try await cloudKitService.saveMeeting(meeting)
                
                if let index = meetings.firstIndex(where: { $0.id == meeting.id }) {
                    meetings[index] = savedMeeting
                }
                
                print("✅ Meeting saved: \(meeting.name)")
            } catch {
                meetings.removeAll { $0.id == meeting.id }
                errorMessage = error.localizedDescription
                print("❌ Error saving meeting: \(error)")
            }
        }
    }
    
    func updateMeeting(_ meeting: Meeting) {
        guard let index = meetings.firstIndex(where: { $0.id == meeting.id }) else {
            print("⚠️ Meeting not found")
            return
        }
        
        meetings[index] = meeting
        
        Task {
            do {
                let updatedMeeting = try await cloudKitService.updateMeeting(meeting)
                meetings[index] = updatedMeeting
                print("✅ Meeting updated: \(meeting.name)")
            } catch {
                await loadMeetings()
                errorMessage = error.localizedDescription
                print("❌ Error updating meeting: \(error)")
            }
        }
    }
    
    func deleteMeeting(_ meetingID: String) {
        let removedMeeting = meetings.first { $0.id.uuidString == meetingID }
        meetings.removeAll { $0.id.uuidString == meetingID }
        
        Task {
            do {
                try await cloudKitService.deleteMeeting(meetingID)
                print("✅ Meeting deleted")
            } catch {
                if let meeting = removedMeeting {
                    meetings.append(meeting)
                }
                errorMessage = error.localizedDescription
                print("❌ Error deleting meeting: \(error)")
            }
        }
    }
    
    func setCommunity(_ id: String) {
        self.communityID = id
        Task {
            await loadMeetings()
        }
    }
    
    var todayMeetings: [Meeting] {
        meetings.filter { $0.isToday }.sorted { $0.dateTime < $1.dateTime }
    }
    
    var upcomingMeetings: [Meeting] {
        meetings.filter { $0.isUpcoming && !$0.isToday }.sorted { $0.dateTime < $1.dateTime }
    }
    
    var hasTodayMeetings: Bool {
        !todayMeetings.isEmpty
    }
    
    var hasUpcomingMeetings: Bool {
        !upcomingMeetings.isEmpty
    }
}
