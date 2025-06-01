import UserNotifications
import SwiftUI

class NotificationService: NSObject, ObservableObject {
    
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(granted)
        }
    }
    
    override init() {
        super.init()
        createQuoteNotificationCategory()
    }
    
    private func createQuoteNotificationCategory() {
        let action = UNNotificationAction(identifier: "Motivation", title: "Motivation", options: .foreground)
        let category = UNNotificationCategory(identifier: "Motivation", actions: [action], intentIdentifiers: [], options: [])
        notificationCenter.setNotificationCategories([category])
    }
    
    func  clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("Cleared all existing notifications")
    }
    
    func createArrayOfTimes(from startTime: Date, to endTime: Date, count: Int) -> [Date] {
        var arrayOfTimes: [Date] = []
        
        if count == 1 {
            arrayOfTimes.append(startTime)
            return arrayOfTimes
        }
        
        let timeInterval = endTime.timeIntervalSince(startTime)
        let lengthOfChunk = timeInterval / Double(count - 1)
        
        arrayOfTimes.append(startTime)
        
        
        for i in 1..<(count - 1) {
            let nextTime = startTime.addingTimeInterval(Double(i) * lengthOfChunk)
            arrayOfTimes.append(nextTime)
        }
        
        arrayOfTimes.append(endTime)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        print("Scheduled notification times:")
        for (index, time) in arrayOfTimes.enumerated() {
            print("Notification \(index + 1): \(formatter.string(from: time))")
        }
        
        return arrayOfTimes
    }
    
    func scheduleAllNotifications(from startTime: Date, to endTime: Date, count: Int, quotes: [QuoteService.Quote]) {
        
        clearAllNotifications()
        
        guard !quotes.isEmpty else {
            print("No quotes available for notifications")
            return
        }
        
        let arrayOfTimes = createArrayOfTimes(from: startTime, to: endTime, count: count)
        
        //        for (index, time) in arrayOfTimes.enumerated() {
        //            let quote = quotes[index % quotes.count]
        //            let hour = Calendar.current.component(.hour, from: time)
        //            let minute = Calendar.current.component(.minute, from: time)
        //
        for i in 0..<count {
            let time = arrayOfTimes[i]
            let quote = quotes[i % quotes.count] // Cycle through quotes if needed
            let hour = Calendar.current.component(.hour, from: time)
            let minute = Calendar.current.component(.minute, from: time)
            
            addNotification(
                title: "Motivation",
                body: "\(quote.content) — \(quote.author)",
                hour: hour,
                minute: minute,
                categoryIdentifier: "Motivation"
            )
        }
        
        listScheduledNotifications()
    }
    
    func addNotification(
        title: String,
        body: String,
        hour: Int,
        minute: Int = 0,
        seconds: Int = 0,
        notificationIdentifier: String? = nil,
        categoryIdentifier: String? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if let categoryIdentifier = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = seconds
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier ?? UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled: \(request.identifier) at \(hour):\(minute)")
            }
        }
    }
    func listScheduledNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            print("\n📅 Currently scheduled notifications: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let hour = trigger.dateComponents.hour ?? 0
                    let minute = trigger.dateComponents.minute ?? 0
                    print("• \(request.identifier): \(hour):\(String(format: "%02d", minute)) - \(request.content.title)")
                }
            }
            print("")
        }
    }
}
