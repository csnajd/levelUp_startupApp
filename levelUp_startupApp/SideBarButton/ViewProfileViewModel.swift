//
//  ViewProfileViewModel.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 10/02/2026.
//


import Foundation
import SwiftUI
import PhotosUI
import CloudKit
internal import Combine

@MainActor
class EditProfileViewModel: ObservableObject {  // ✅ RENAMED to EditProfileViewModel
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
        true
    }
    
    func saveProfile() async {
        isLoading = true
        errorMessage = nil
        savedSuccessfully = false
        
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
                phoneNumber: phoneNumber,
                appleUserID: appleUserID
            )
            user.profileImage = profileImage
            
            _ = try await cloudKitService.saveUserProfile(user)
            
            isLoading = false
            savedSuccessfully = true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            savedSuccessfully = false
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
