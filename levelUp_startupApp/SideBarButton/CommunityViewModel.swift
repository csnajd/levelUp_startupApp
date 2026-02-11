//
//  CommunityMember.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 10/02/2026.
//


import Foundation
import SwiftUI
internal import Combine

struct CommunityMember: Identifiable {
    var id: String
    var givenName: String
    var familyName: String
    var jobTitle: String
    var email: String
    var profileImage: UIImage?
    
    var fullName: String {
        "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
    }
}

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var members: [CommunityMember] = []
    @Published var searchText = ""
    @Published var isLoading = false
    
    var filteredMembers: [CommunityMember] {
        if searchText.isEmpty {
            return members
        }
        return members.filter { member in
            member.fullName.lowercased().contains(searchText.lowercased()) ||
            member.jobTitle.lowercased().contains(searchText.lowercased())
        }
    }
    
    func loadMembers() async {
        isLoading = true
        
        // TODO: Replace with actual CloudKit fetch from your friend's CreateCommunity
        // For now, using empty array
        members = []
        
        // When CloudKit is ready, it will look like this:
        // do {
        //     members = try await CloudKitService.shared.fetchCommunityMembers(for: communityID)
        //     isLoading = false
        // } catch {
        //     print("Error loading members: \(error)")
        //     isLoading = false
        // }
        
        // Dummy data for testing (remove later)
        // members = [
        //     CommunityMember(id: "1", givenName: "John", familyName: "Doe", jobTitle: "Developer", email: "john@example.com"),
        //     CommunityMember(id: "2", givenName: "Jane", familyName: "Smith", jobTitle: "Designer", email: "jane@example.com"),
        // ]
        
        isLoading = false
    }
}