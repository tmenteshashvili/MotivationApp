
import SwiftUI

@main
struct MotivationAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var loginVM = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginVM)
        }
    }
}
