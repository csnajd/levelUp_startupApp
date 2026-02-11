import SwiftUI

@main
struct levelUp_startupAppApp: App {

    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
<<<<<<< HEAD
            NavigationStack {
                HomepageView()  // ✅ Change this temporarily to test
            }
=======
            LogInView() // إذا شاشتك WelcomeView بدليها
                .environmentObject(session)
>>>>>>> main
        }
    }
}
