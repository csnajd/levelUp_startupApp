//
//  profileViewModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//


import Foundation
import SwiftUI
import PhotosUI
import CloudKit
internal import Combine

@MainActor
class profileViewModel: ObservableObject {
    @Published var givenName = ""
    @Published var familyName = ""
    @Published var gender: Gender = .preferNotToSay
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var profileImage: UIImage?
    @Published var showImagePicker = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var savedSuccessfully = false
    
    private let cloudKitService = Cloudkit.shared
    
    var isSaveButtonEnabled: Bool {
        !givenName.isEmpty && !familyName.isEmpty && !email.isEmpty  // ✅ FIXED - Added email check
    }
    
    func saveProfile() async {
        guard isSaveButtonEnabled else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            guard let appleUserID = try await cloudKitService.getCurrentUserID() else {
                throw NSError(domain: "Profile", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Could not get user ID"])
            }
            
            var user = User(
                givenName: givenName,
                familyName: familyName,
                gender: gender,
                email: email,
                phoneNumber: phoneNumber,  // ✅ Include phone number
                appleUserID: appleUserID
            )
            user.profileImage = profileImage
            
            _ = try await cloudKitService.saveUserProfile(user)
            
            isLoading = false
            savedSuccessfully = true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func loadExistingProfile() async {
        do {
            guard let appleUserID = try await cloudKitService.getCurrentUserID() else {
                return
            }
            
            if let user = try await cloudKitService.fetchUserProfile(appleUserID: appleUserID) {
                givenName = user.givenName
                familyName = user.familyName
                gender = user.gender
                email = user.email
                phoneNumber = user.phoneNumber
                profileImage = user.profileImage
            }
        } catch {
            print("Error loading profile: \(error.localizedDescription)")
        }
    }
}
