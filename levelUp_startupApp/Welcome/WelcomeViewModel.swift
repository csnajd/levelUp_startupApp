import Foundation
import CloudKit
internal import Combine

@MainActor
class WelcomeViewModel: ObservableObject {
    @Published var userCommunities: [Community] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let cloudKitService = CloudKitService.shared  // ✅ Changed variable name to cloudKitService
    
    init() {
        Task {
            await fetchUserCommunities()
        }
    }
    
    func fetchUserCommunities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            userCommunities = try await cloudKitService.fetchUserCommunities()  // ✅ Now this matches
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false  // ✅ Fixed typo: was "fals"
        }
    }
}
