import Foundation
import Combine

@MainActor
final class AppSession: ObservableObject {

    @Published var isSignedIn: Bool = false
    @Published var appleUserID: String?
    @Published var givenName: String = ""
    @Published var familyName: String = ""
    @Published var email: String = ""

    private let kUserID = "appleUserID"

    func saveUserID(_ id: String) {
        UserDefaults.standard.set(id, forKey: kUserID)
        appleUserID = id
        isSignedIn = true
    }
}
