import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var howMany: Int
    @Binding var startTime: Date
    @Binding var endTime: Date
    @ObservedObject var notificationService: NotificationService
    @State private var showingAlert = false
    @State private var alertType: AlertType = .success
    @State private var isLoading = false
    @StateObject private var quoteViewModel = QuoteViewModel()
    var quotes: [QuoteService.Quote]

    enum AlertType {
        case success, error, permission, disabled
        
        var title: String {
            switch self {
            case .success: return "Notifications Updated!"
            case .error: return "Invalid Time Range"
            case .permission: return "Permission Required"
            case .disabled: return "Notifications Disabled"
            }
        }
        
        var message: String {
            switch self {
            case .success: return "Your motivational quotes will be delivered at the scheduled times daily."
            case .error: return "End time must be after start time."
            case .permission: return "Please enable notifications in Settings to receive motivational quotes."
            case .disabled: return "All notifications have been cancelled."
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
               
                Text("Notifications")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("How many")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                if howMany > 1 {
                                    howMany -= 1
                                }
                            }) {
                                Image(systemName: "minus.square")
                                    .padding()
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("\(howMany)X")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(minWidth: 30)
                            
                            Button(action: {
                                if howMany < 15 {
                                    howMany += 1
                                }
                            }) {
                                Image(systemName: "plus.square")
                                    .padding()
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("SystemGrayLight"))
                    
                    HStack {
                        DatePicker("Start at:", selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("SystemGrayLight"))
                    
                    HStack {
                        DatePicker("End at:", selection: $endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("SystemGrayLight"))
                    
                    if !isValidTimeRange {
                        HStack {
                            Text("End time must be after start time")
                                .foregroundColor(.red)
                                .font(.caption)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        scheduleNotifications()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                    .padding(.trailing, 8)
                            }
                            
                            Text("Update Notifications")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidTimeRange ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                    .disabled(!isValidTimeRange || isLoading)
                    
                    Button {
                        disableNotifications()
                    } label: {
                        Text("Disable All Notifications")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.primary)
                            .cornerRadius(20)
                    }
                    .disabled(isLoading)
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
                if alertType == .permission {
                    Button("Open Settings") {
                        openSettings()
                    }
                    Button("Cancel", role: .cancel) { }
                } else {
                    Button("OK", role: .cancel) { }
                }
            } message: {
                Text(alertType.message)
            }
            .onAppear {
                loadQuotesIfNeeded()
            }
        }
    }
    
    private var isValidTimeRange: Bool {
        return Calendar.current.compare(startTime, to: endTime, toGranularity: .minute) == .orderedAscending
    }
    
    private func loadQuotesIfNeeded() {
        if quoteViewModel.quotes.isEmpty {
            quoteViewModel.loadQuotes()
        }
    }
    
    private func scheduleNotifications() {
        guard !isLoading else { return }
        isLoading = true
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    Task {
                        await self.performScheduling()
                    }
                    
                case .denied:
                    self.isLoading = false
                    self.alertType = .permission
                    self.showingAlert = true
                    
                case .notDetermined:
                    self.requestPermissionAndSchedule()
                    
                @unknown default:
                    self.isLoading = false
                    self.alertType = .permission
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func requestPermissionAndSchedule() {
        notificationService.requestNotificationPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    Task {
                        await self.performScheduling()
                    }
                } else {
                    self.isLoading = false
                    self.alertType = .permission
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func performScheduling() async {
        let quotesToUse = quoteViewModel.quotes.isEmpty ? quotes : quoteViewModel.quotes
        
        await notificationService.scheduleAllNotificationsWithPagination(
            from: startTime,
            to: endTime,
            count: howMany
        )
        
        await MainActor.run {
            saveSettings()
            isLoading = false
            alertType = .success
            showingAlert = true
        }
    }
    
    private func disableNotifications() {
        isLoading = true
        
        Task {
            await notificationService.clearAllNotifications()
            
            await MainActor.run {
                isLoading = false
                alertType = .disabled
                showingAlert = true
            }
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(howMany, forKey: "howMany")
        UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "startTime")
        UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "endTime")
        UserDefaults.standard.synchronize()
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    @Previewable @State var howManyPreview = 3
    @Previewable @State var startTimePreview = Date()
    @Previewable @State var endTimePreview = Calendar.current.date(byAdding: .hour, value: 6, to: Date()) ?? Date()
    let notificationServicePreview = NotificationService()
    
    NotificationSettingsView(
        howMany: $howManyPreview,
        startTime: $startTimePreview,
        endTime: $endTimePreview,
        notificationService: notificationServicePreview,
        quotes: [QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")]
    )
}
