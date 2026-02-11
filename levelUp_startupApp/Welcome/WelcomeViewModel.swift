//
//  WelcomeViewModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 10/02/2026.
//



import Foundation
import CloudKit
internal import Combine


import Foundation
import CloudKit

@MainActor
class WelcomeViewModel: ObservableObject {
    @Published var userCommunities: [Community] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let cloudKitService = CloudKitServices.shared
    
    init() {
        Task {
            await fetchUserCommunities()
        }
    }
    
    func fetchUserCommunities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            userCommunities = try await cloudKitService.fetchUserCommunities()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
