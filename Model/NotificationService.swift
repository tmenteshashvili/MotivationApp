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
    
    func clearAllNotifications() async {
        await withCheckedContinuation { continuation in
            notificationCenter.removeAllPendingNotificationRequests()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                continuation.resume()
            }
        }
    }
    
    func createArrayOfTimes(from startTime: Date, to endTime: Date, count: Int) -> [Date] {
        var arrayOfTimes: [Date] = []
        
        guard count > 0 else { return arrayOfTimes }
        
        if count == 1 {
            arrayOfTimes.append(startTime)
            return arrayOfTimes
        }
        
        let calendar = Calendar.current
        let startMinutes = calendar.component(.hour, from: startTime) * 60 + calendar.component(.minute, from: startTime)
        let endMinutes = calendar.component(.hour, from: endTime) * 60 + calendar.component(.minute, from: endTime)
        
        let totalMinutes = endMinutes - startMinutes
        let intervalMinutes = totalMinutes / (count - 1)
        
        for i in 0..<count {
            let minutesToAdd = i * intervalMinutes
            let targetMinutes = startMinutes + minutesToAdd
            
            let hour = targetMinutes / 60
            let minute = targetMinutes % 60
            
            var components = calendar.dateComponents([.year, .month, .day], from: startTime)
            components.hour = hour
            components.minute = minute
            components.second = 0
            
            if let notificationTime = calendar.date(from: components) {
                arrayOfTimes.append(notificationTime)
            }
        }
        
        arrayOfTimes = Array(Set(arrayOfTimes)).sorted()
        
        if arrayOfTimes.count < count {
            print("⚠️ Warning: Could only create \(arrayOfTimes.count) unique times instead of \(count)")
        }
        
        return arrayOfTimes
    }
    
    func scheduleAllNotifications(from startTime: Date, to endTime: Date, count: Int, quotes: [QuoteService.Quote]) async {
        
        await clearAllNotifications()
        
        guard !quotes.isEmpty else {
            return
        }
        
        // Step 2: Create unique times
        let arrayOfTimes = createArrayOfTimes(from: startTime, to: endTime, count: count)
        let actualCount = min(count, arrayOfTimes.count)
        
        
        for i in 0..<actualCount {
            let time = arrayOfTimes[i]
            let quote = quotes[i % quotes.count]
            let hour = Calendar.current.component(.hour, from: time)
            let minute = Calendar.current.component(.minute, from: time)
            
            let identifier = "motivation_daily_\(hour)_\(minute)"
            
            await scheduleNotification(
                identifier: identifier,
                title: "Daily Motivation",
                body: "\(quote.content) — \(quote.author)",
                hour: hour,
                minute: minute
            )
            
            print("   ✅ \(hour):\(String(format: "%02d", minute)) - \(quote.author)")
        }
        
        
        await verifyNotifications()
    }
    
    private func scheduleNotification(identifier: String, title: String, body: String, hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "Motivation"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        await withCheckedContinuation { continuation in
            notificationCenter.add(request) { error in
                if let error = error {
                    print("❌ Error scheduling \(identifier): \(error.localizedDescription)")
                } else {
                    print("✅ Scheduled: \(identifier)")
                }
                continuation.resume()
            }
        }
    }
    
    func scheduleAllNotificationsWithPagination(from startTime: Date, to endTime: Date, count: Int) async {
        do {
            let quoteService = QuoteService()
            let quotes = try await quoteService.fetchQuotesForNotifications()
            
            print("📱 Fetched \(quotes.count) quotes for notifications")
            
            // Schedule with fresh quotes
            await scheduleAllNotifications(
                from: startTime,
                to: endTime,
                count: count,
                quotes: quotes
            )
            
            print("✅ Scheduled notifications with paginated quotes")
        } catch {
            print("❌ Error fetching quotes for notifications: \(error)")
            
            let fallbackQuotes = getFallbackQuotes()
            await scheduleAllNotifications(
                from: startTime,
                to: endTime,
                count: count,
                quotes: fallbackQuotes
            )
        }
    }
    
    private func verifyNotifications() async {
        await withCheckedContinuation { continuation in
            notificationCenter.getPendingNotificationRequests { requests in
                
                var timeGroups: [String: Int] = [:]
                
                for request in requests {
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        let hour = trigger.dateComponents.hour ?? 0
                        let minute = trigger.dateComponents.minute ?? 0
                        let timeKey = "\(hour):\(String(format: "%02d", minute))"
                        
                        timeGroups[timeKey, default: 0] += 1
                    }
                }
                
                let duplicates = timeGroups.filter { $0.value > 1 }
                if duplicates.isEmpty {
                    print("   ✅ No duplicate times found!")
                } else {
                    print("   ❌ Duplicate times found:")
                    for (time, count) in duplicates {
                        print("      \(time): \(count) notifications")
                    }
                }
                
                continuation.resume()
            }
        }
    }
    
    private func getFallbackQuotes() -> [QuoteService.Quote] {
        return [
            QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Nelson Mandela", content: "It always seems impossible until it's done."),
            QuoteService.Quote(id: 2, category: "Motivational", type: "text", author: "Walt Disney", content: "The way to get started is to quit talking and begin doing."),
            QuoteService.Quote(id: 3, category: "Motivational", type: "text", author: "Steve Jobs", content: "Your work is going to fill a large part of your life, and the only way to be truly satisfied is to do what you believe is great work."),
            QuoteService.Quote(id: 4, category: "Motivational", type: "text", author: "Maya Angelou", content: "Try to be a rainbow in someone's cloud."),
            QuoteService.Quote(id: 5, category: "Motivational", type: "text", author: "Eleanor Roosevelt", content: "The future belongs to those who believe in the beauty of their dreams.")
        ]
    }
    
    func addNotification(title: String, body: String, hour: Int, minute: Int = 0, seconds: Int = 0, notificationIdentifier: String? = nil, categoryIdentifier: String? = nil) {
    }
    
    func listScheduledNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let hour = trigger.dateComponents.hour ?? 0
                    let minute = trigger.dateComponents.minute ?? 0
                    print("• \(request.identifier): \(hour):\(String(format: "%02d", minute))")
                }
            }
            print("")
        }
    }
}

extension NotificationService {
    func checkForDuplicateNotifications(completion: @escaping ([String]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            var timeGroups: [String: [String]] = [:]
            
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let hour = trigger.dateComponents.hour ?? 0
                    let minute = trigger.dateComponents.minute ?? 0
                    let timeKey = "\(hour):\(String(format: "%02d", minute))"
                    
                    timeGroups[timeKey, default: []].append(request.identifier)
                }
            }
            
            let duplicateTimes = timeGroups.compactMap { (time, identifiers) in
                identifiers.count > 1 ? time : nil
            }
            
            completion(duplicateTimes)
        }
    }
}
