import Foundation
import SwiftUI
import CloudKit

@MainActor
class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var givenName = ""
    @Published var familyName = ""
    @Published var gender: Gender = .preferNotToSay
    @Published var email = ""
    @Published var profileImage: UIImage?
    @Published var isLoading = false
    
    private let cloudKitService = Cloudkit.shared
    
    private init() {
        // Load profile on init
        Task {
            await loadProfile()
        }
    }
    
    func loadProfile() async {
        isLoading = true
        do {
            guard let appleUserID = try await cloudKitService.getCurrentUserID() else {
                isLoading = false
                return
            }
            
            if let user = try await cloudKitService.fetchUserProfile(appleUserID: appleUserID) {
                givenName = user.givenName
                familyName = user.familyName
                gender = user.gender
                email = user.email
                profileImage = user.profileImage
            }
            isLoading = false
        } catch {
            print("Error loading profile: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    var fullName: String {
        if givenName.isEmpty && familyName.isEmpty {
            return "Complete Your Profile"
        }
        return "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
    }
    
    var displayEmail: String {
        email.isEmpty ? "No email set" : email
    }
}