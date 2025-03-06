
import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var showRemainder = false
    @Published var howMany: Int = UserDefaults.standard.integer(forKey: "howMany")
    @Published var startTime: Date = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "startTime"))
    @Published var endTime: Date = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "endTime"))
    
    init() {
            self.howMany = UserDefaults.standard.integer(forKey: "howMany")
            self.startTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "startTime"))
            self.endTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "endTime"))
        }
        
        func saveNotificationSettings() {
            UserDefaults.standard.set(howMany, forKey: "howMany")
            UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "startTime")
            UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "endTime")
        }
    
}
