
import SwiftUI

@main
struct MotivationAppApp: App {
    @StateObject private var loginVM = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if loginVM.isAuthenticated {
                    Login()
                } else {
                    Welcome()
                }
            }
            .environmentObject(loginVM)
        }
    }
}
