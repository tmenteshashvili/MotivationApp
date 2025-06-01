
import SwiftUI

@main
struct MotivationAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var loginVM = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(quotes: [QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")])
                .environmentObject(loginVM)
        }
    }
}
