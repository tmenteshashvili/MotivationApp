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
    

    func createArrayOfTimes(from startTime: Date, to endTime: Date, count: Int) -> [Date] {
        var arrayOfTimes: [Date] = []
        
        let timeInterval = endTime.timeIntervalSince(startTime)
        let lengthOfChunk = timeInterval / Double(count)
        
        var currentTime = startTime
        for _ in 0..<count {
            currentTime = currentTime.addingTimeInterval(lengthOfChunk)
            arrayOfTimes.append(currentTime)
        }
        
        return arrayOfTimes
    }
    

    func scheduleAllNotifications(from startTime: Date, to endTime: Date, count: Int, quotes: [Quote]) {
        let arrayOfTimes = createArrayOfTimes(from: startTime, to: endTime, count: count)
        
        for (index, time) in arrayOfTimes.enumerated() {
            let quote = quotes[index % quotes.count]
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
}
