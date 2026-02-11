//
//  manModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//
import Foundation

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
