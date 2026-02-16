import Foundation
import CloudKit
internal import Combine

@MainActor
class JoinCommunityViewModel: ObservableObject {
    @Published var inviteCode = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var joinedSuccessfully = false
    @Published var joinedCommunity: Community?
    
    private let cloudKitService = CloudKitService.shared
    
    func joinCommunity(inviteCode: String) async {
        guard !inviteCode.isEmpty else {
            errorMessage = "Please enter an invite code"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            guard let community = try await cloudKitService.findCommunityByInviteCode(inviteCode.uppercased()) else {
                throw NSError(domain: "Join", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid invite code"])
            }
            
            guard let userID = try await cloudKitService.getCurrentUserID() else {
                throw NSError(domain: "Join", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Could not get user ID"])
            }
            
            if community.memberIDs.contains(userID) {
                errorMessage = "You are already a member of this community"
                isLoading = false
                return
            }
            
            var updatedCommunity = community
            updatedCommunity.memberIDs.append(userID)
            
            let savedCommunity = try await cloudKitService.updateCommunity(updatedCommunity)
            
            joinedCommunity = savedCommunity
            joinedSuccessfully = true
            isLoading = false
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
