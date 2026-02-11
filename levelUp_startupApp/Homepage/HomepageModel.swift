//
//  HomepageModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import Foundation

struct Project: Identifiable {
    var id = UUID()
    var name: String
    var memberIDs: [String]
    var isBlocked: Bool
    var blockReason: String?
    var createdAt: Date
    var communityID: String
    
    var memberCount: Int {
        return memberIDs.count
    }
}

class ProjectData {
    // ✅ Default: Empty state
    static var emptyProjects: [Project] = []
    
    // ✅ For testing only - you can manually switch to this if you want to see dummy data
    static var dummyProjects: [Project] = [
        Project(
            name: "New Company App",
            memberIDs: ["user1", "user2", "user3", "user4"],
            isBlocked: false,
            blockReason: nil,
            createdAt: Date(),
            communityID: "community1"
        ),
        Project(
            name: "Design UI/UX",
            memberIDs: ["user1", "user2"],
            isBlocked: true,
            blockReason: "Waiting for design approval",
            createdAt: Date(),
            communityID: "community1"
        ),
        Project(
            name: "Backend Development",
            memberIDs: ["user3", "user4", "user5"],
            isBlocked: true,
            blockReason: "API documentation incomplete",
            createdAt: Date(),
            communityID: "community1"
        ),
        Project(
            name: "Marketing Campaign",
            memberIDs: ["user2"],
            isBlocked: true,
            blockReason: "Budget approval pending",
            createdAt: Date(),
            communityID: "community1"
        ),
        Project(
            name: "QA Testing",
            memberIDs: ["user1", "user3"],
            isBlocked: true,
            blockReason: "Development not complete",
            createdAt: Date(),
            communityID: "community1"
        )
    ]
}
