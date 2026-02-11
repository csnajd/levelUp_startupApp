//
//  manViewModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import Foundation
internal import Combine

@MainActor
class manViewModel: ObservableObject {
    @Published var meetings: [Meeting] = []
    @Published var isLoading = false
    
    init() {
        loadMeetings()
    }
    
    func loadMeetings() {
        // Start with empty meetings for new communities
        meetings = MeetingData.emptyMeetings
        
        // TODO: Replace with CloudKit fetch
        // isLoading = true
        // Task {
        //     do {
        //         meetings = try await CloudKitService.shared.fetchMeetings(for: communityID)
        //         isLoading = false
        //     } catch {
        //         print("Error loading meetings: \(error)")
        //         isLoading = false
        //     }
        // }
    }
    
    func addMeeting(_ meeting: Meeting) {
        meetings.append(meeting)
        // TODO: Save to CloudKit
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
