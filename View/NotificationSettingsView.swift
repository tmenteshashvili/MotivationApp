

import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var howMany: Int
    @Binding var startTime: Date
    @Binding var endTime: Date
    @ObservedObject var notificationService: NotificationService
    @State private var showingAlert = false
    @State private var alertType: AlertType = .success
    
    enum AlertType {
        case success, error, permission
        
        var title: String {
            switch self {
            case .success: return "Notifications Scheduled!"
            case .error: return "Error"
            case .permission: return "Notifications Permission Required"
            }
        }
        
        var message: String {
            switch self {
            case .success: return "Your motivational quotes will be delivered at the specified times."
            case .error: return "Start time must be before end time."
            case .permission: return "Please enable notifications in Settings to receive motivational quotes."
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
               
                Text("Notifications")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .padding(.horizontal)

                
                VStack {
                    
                    HStack {
                        Text("How many")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                if howMany != 1 {
                                    howMany -= 1
                                }
                            }, label: {
                                Image(systemName: "minus.square")
                                    .padding()
                                    .foregroundColor(.secondary)
                            })
                            
                            Text("\(howMany)X")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                            
                            
                            Button(action: {
                                if howMany != 15 {
                                    howMany += 1
                                }
                            }, label: {
                                Image(systemName: "plus.square")
                                    .padding()
                                    .foregroundColor(.secondary)
                                
                            })
                        }
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 380).background(Color("SystemGrayLight"))
                    
                    HStack {
                        DatePicker("Start at:", selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                        
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 380).background(Color("SystemGrayLight"))
                    
                    HStack {
                        DatePicker("End at:", selection: $endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                        
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 380).background(Color("SystemGrayLight"))
                    Spacer()
                    
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        scheduleNotifications()
                    } label: {
                        Text("Schedule")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    
                    Button {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        showingAlert = true
                        alertType = .success
                    } label: {
                        Text("Disable")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding()
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
               
            }
            .alert(alertType.title, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertType.message)
            }
        }
    }
    
    private func scheduleNotifications() {
        if Calendar.current.compare(startTime, to: endTime, toGranularity: .minute) != .orderedAscending {
            alertType = .error
            showingAlert = true
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    let quotes = [Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")]
                    notificationService.scheduleAllNotifications(from: startTime, to: endTime, count: howMany, quotes: quotes)
                    
                    UserDefaults.standard.set(howMany, forKey: "howMany")
                    UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "startTime")
                    UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "endTime")
                    
                    alertType = .success
                    showingAlert = true
                    
                case .denied, .notDetermined:
                    alertType = .permission
                    showingAlert = true
                    
                default:
                    break
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var howManyPreview = 3
    @Previewable @State var startTimePreview = Date()
    @Previewable @State var endTimePreview = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let notificationServicePreview = NotificationService()
    
    NotificationSettingsView(howMany:  $howManyPreview, startTime: $startTimePreview, endTime: $endTimePreview, notificationService: notificationServicePreview)
}
