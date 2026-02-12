//
//  manViewModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import Foundation
internal import Combine
import CloudKit

@MainActor
class manViewModel: ObservableObject {
    @Published var meetings: [Meeting] = []
    @Published var isLoading = false
    @Published var communityID: String = "" // Set this when community is selected
    
    private let cloudKitService = Cloudkit.shared // ✅ Uses your Cloudkit class
    
    init() {
        loadMeetings()
    }
    
    func loadMeetings() {
        // Start with empty meetings for new communities
        meetings = MeetingData.emptyMeetings
        
        // Uncomment when you have a community selected
        // Task {
        //     await fetchMeetingsFromCloudKit()
        // }
    }
    
    func fetchMeetingsFromCloudKit() async {
        guard !communityID.isEmpty else {
            print("No community ID set")
            return
        }
        
        isLoading = true
        
        do {
            meetings = try await cloudKitService.fetchCommunityMeetings(communityID: communityID)
            isLoading = false
        } catch {
            print("Error loading meetings: \(error)")
            isLoading = false
            meetings = []
        }
    }
    
    func addMeeting(_ meeting: Meeting) {
        meetings.append(meeting)
        
        // Save to CloudKit
        Task {
            do {
                _ = try await cloudKitService.saveMeeting(meeting)
                print("✅ Meeting saved to CloudKit: \(meeting.name)")
            } catch {
                print("❌ Error saving meeting to CloudKit: \(error)")
            }
        }
    }
    
    func updateMeeting(_ meeting: Meeting) {
        guard let index = meetings.firstIndex(where: { $0.id == meeting.id }) else { return }
        meetings[index] = meeting
        
        // Update in CloudKit
        Task {
            do {
                _ = try await cloudKitService.updateMeeting(meeting)
                print("✅ Meeting updated in CloudKit: \(meeting.name)")
            } catch {
                print("❌ Error updating meeting in CloudKit: \(error)")
            }
        }
    }
    
    func deleteMeeting(_ meetingID: String) {
        meetings.removeAll { $0.id.uuidString == meetingID }
        
        // Delete from CloudKit
        Task {
            do {
                try await cloudKitService.deleteMeeting(meetingID)
                print("✅ Meeting deleted from CloudKit")
            } catch {
                print("❌ Error deleting meeting from CloudKit: \(error)")
            }
        }
    }
    
    func setCommunity(_ id: String) {
        self.communityID = id
        Task {
            await fetchMeetingsFromCloudKit()
        }
    }
    
    // MARK: - Computed Properties
    
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
