import Foundation
import CloudKit
import SwiftUI
internal import Combine

@MainActor
class CreateCommunityViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var communityName = ""
    @Published var whoCanJoinIndex = 0
    @Published var whoCanPostIndex = 0
    @Published var whoCanManageIndex = 0
    @Published var allowFileSharing = true
    @Published var allowComments = false
    @Published var generatedInviteCode: String?
    @Published var createdCommunityID: String?
    @Published var shouldNavigateToHomepage = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var createdSuccessfully = false
    
    private let cloudKitService = CloudKitService.shared
    
    func nextStep() {
        if currentStep < 2 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func createCommunity() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let userID = try await cloudKitService.getCurrentUserID() else {
                throw NSError(domain: "CreateCommunity", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Could not get user ID"])
            }
            
            let community = Community(
                name: communityName,
                description: "",
                creatorID: userID,
                organizationID: "",
                anyoneCanJoin: whoCanJoinIndex == 0,
                inviteOnly: whoCanJoinIndex == 1,
                adminsOnlyPost: whoCanPostIndex == 0,
                allMembersPost: whoCanPostIndex == 1,
                adminManaged: whoCanManageIndex == 0,
                moderatorManaged: whoCanManageIndex == 1,
                allowFileSharing: allowFileSharing,
                allowComments: allowComments,
                memberIDs: [userID],
                adminIDs: [userID]
            )
            
            let savedCommunity = try await cloudKitService.saveCommunity(community)
            generatedInviteCode = savedCommunity.inviteCode
            createdCommunityID = savedCommunity.id
            
            isLoading = false
            createdSuccessfully = true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func shareInviteLink() {
        guard let inviteCode = generatedInviteCode else { return }
        
        let inviteLink = "levelup://join?code=\(inviteCode)"
        
        let activityVC = UIActivityViewController(
            activityItems: [
                "Join my community on LevelUp! Use invite code: \(inviteCode)\n\nOr click: \(inviteLink)"
            ],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            
            topVC.present(activityVC, animated: true)
        }
    }
}
