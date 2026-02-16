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
    
    private let cloudKitService = CloudKitService.shared
    
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
        
        // For now empty - will be populated from CloudKit
        members = []
        
        isLoading = false
    }
}
