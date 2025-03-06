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
}
