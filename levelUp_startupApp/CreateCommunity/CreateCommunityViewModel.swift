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
    
    private let cloudKitService = CloudKitService.shared
    
    func createCommunitySync() {
        Task {
            await createCommunity()
        }
    }
    
    private func createCommunity() async {
        isCreating = true
        errorMessage = nil
        
        do {
            guard let userID = try await cloudKitService.getCurrentUserID() else {
                throw NSError(domain: "CreateCommunity", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get user ID"])
            }
            
            let code = Community.generateInviteCode()
            
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
            
            let savedCommunity = try await cloudKitService.saveCommunity(community)
            
            inviteCode = savedCommunity.inviteCode
            inviteLink = "levelup://join/\(savedCommunity.inviteCode)"
            createdCommunity = savedCommunity
            
            isCreating = false
            communityCreated = true
            
        } catch {
            errorMessage = error.localizedDescription
            isCreating = false
        }
    }
}
