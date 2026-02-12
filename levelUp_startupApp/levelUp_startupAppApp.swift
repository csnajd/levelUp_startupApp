import SwiftUI

@main
struct levelUp_startupAppApp: App {

    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {


            LogInView() // إذا شاشتك WelcomeView بدليها
                .environmentObject(session)
 
        }
    }
}
