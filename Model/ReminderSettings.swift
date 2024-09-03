

import SwiftUI


class ReminderSettings: ObservableObject {
    @Published var counter: Int
    @Published var startTime: Date
    @Published var endTime: Date
    
    init() {
        
        let savedCounter = UserDefaults.standard.integer(forKey: "counter")
        self.counter = savedCounter == 0 ? 10 : savedCounter  
        
        self.startTime = UserDefaults.standard.object(forKey: "startTime") as? Date ??
            Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        
        self.endTime = UserDefaults.standard.object(forKey: "endTime") as? Date ??
            Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    }
}
