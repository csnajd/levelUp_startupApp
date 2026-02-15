//
//  CreateCommunityViewModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 10/02/2026.
//

//
//  CreateCommunityViewModel.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

import Foundation
import CloudKit
internal import Combine

@MainActor
class CreateCommunityViewModel: ObservableObject {
    
    @Published var communityName = ""
    
    @Published var anyoneCanJoin = true
    @Published var inviteOnly = false
    @Published var adminsOnlyPost = true
    @Published var allMembersPost = false
    @Published var adminManaged = true
    @Published var moderatorManaged = false
    @Published var allowFileSharing = true
    @Published var allowComments = false
    
    @Published var inviteCode = ""
    @Published var inviteLink = ""
    
    @Published var isCreating = false
    @Published var communityCreated = false
    @Published var createdCommunity: Community?
    @Published var errorMessage: String?
    
    private let cloudKitService = CloudKitServices.shared
    
    func createCommunitySync() {
        Task {
            await createCommunity()
        }
    }
    
    private func createCommunity() async {
        print("🚀 Starting community creation...")
        isCreating = true
        errorMessage = nil
        
        do {
            print("📝 Getting user ID...")
            guard let userID = try await cloudKitService.getCurrentUserID() else {
                throw NSError(domain: "CreateCommunity", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get user ID"])
            }
            print("✅ User ID: \(userID)")
            
            let code = Community.generateInviteCode()
            print("🔑 Generated invite code: \(code)")
            
            let community = Community(
                name: communityName,
                description: "Community Description",
                creatorID: userID,
                organizationID: "default-org",
                inviteCode: code,
                anyoneCanJoin: anyoneCanJoin,
                inviteOnly: inviteOnly,
                adminsOnlyPost: adminsOnlyPost,
                allMembersPost: allMembersPost,
                adminManaged: adminManaged,
                moderatorManaged: moderatorManaged,
                allowFileSharing: allowFileSharing,
                allowComments: allowComments,
                memberIDs: [userID],
                adminIDs: [userID]
            )
            
            print("💾 Calling saveCommunity...")
            
            // Call saveCommunity directly without timeout wrapper for now
            let savedCommunity = try await cloudKitService.saveCommunity(community)
            
            print("✅ Community saved successfully!")
            
            inviteCode = savedCommunity.inviteCode
            inviteLink = "levelup://join/\(savedCommunity.inviteCode)"
            createdCommunity = savedCommunity
            
            isCreating = false
            communityCreated = true
            print("🎉 Community creation complete!")
            
        } catch let error as NSError {
            print("❌ Error creating community: \(error)")
            print("❌ Error domain: \(error.domain)")
            print("❌ Error code: \(error.code)")
            print("❌ Error description: \(error.localizedDescription)")
            
            if let ckError = error as? CKError {
                print("❌ CloudKit error: \(ckError.errorCode)")
                errorMessage = "CloudKit Error: \(ckError.localizedDescription)"
            } else {
                errorMessage = "Error: \(error.localizedDescription)"
            }
            
            isCreating = false
            communityCreated = false
        }
    }
}
