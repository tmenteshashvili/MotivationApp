import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Received URL: \(url.absoluteString)")
        
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("Handling URL: \(url.absoluteString)")
        return true
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkAuthStatus()
        return true
    }
}

private func checkAuthStatus() {
    let defaults = UserDefaults.standard
    if let token = defaults.string(forKey: "JWT"), !token.isEmpty {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .userAuthenticated, object: nil)
        }
    }
}


extension Notification.Name {
    static let userAuthenticated = Notification.Name("userAuthenticated")
}
