import Foundation
internal import Combine

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

    /// ✅ يسوي Logout
    func signOut() {
        UserDefaults.standard.removeObject(forKey: kUserID)
        appleUserID = nil
        givenName = ""
        familyName = ""
        email = ""
        isSignedIn = false
    }

    /// ✅ مهم: لا تستدعينها إذا تبين التطبيق يفتح دايم على LogIn
    func restoreSessionIfNeeded() {
        if let id = UserDefaults.standard.string(forKey: kUserID) {
            appleUserID = id
            isSignedIn = true
        }
    }
}
