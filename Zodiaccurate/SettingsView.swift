import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var onboardingDataAccess: OnboardingDataAccess
    @StateObject private var notificationManager = NotificationManager()
    
    // Settings state
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = true
    @AppStorage("dailyHoroscopeEnabled") private var dailyHoroscopeEnabled = false
    
    // UI State
    @State private var showingEditProfile = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingHelp = false
    
    init() {
        // Initialize with a temporary context - will be updated in onAppear
        self._onboardingDataAccess = StateObject(wrappedValue: OnboardingDataAccess(modelContext: ModelContext(try! ModelContainer(for: UserDataModel.self))))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                MainCelestialBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Text("Settings")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Customize your cosmic experience")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Profile Section
                        SettingsSection(title: "Profile") {
                            VStack(spacing: 16) {
                                // Profile Card
                                HStack(spacing: 16) {
                                    ZodiacProfileBadge()
                                        .frame(width: 80, height: 80)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(OnboardingDataAccess.firstName)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text(OnboardingDataAccess.zodiacSign)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text("Member since \(getFormattedDate())")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                
                                // Edit Profile Button
                                Button(action: {
                                    showingEditProfile = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Edit Profile")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Preferences Section
                        SettingsSection(title: "Preferences") {
                            VStack(spacing: 12) {
                                SettingsToggleRow(
                                    icon: "bell",
                                    title: "Notifications",
                                    subtitle: "Receive cosmic insights and updates",
                                    isOn: $notificationsEnabled
                                )
                                .onChange(of: notificationsEnabled) { oldValue, newValue in
                                    if newValue {
                                        notificationManager.requestNotificationPermission()
                                    } else {
                                        notificationManager.cancelAllNotifications()
                                    }
                                }
                                
                                SettingsToggleRow(
                                    icon: "star",
                                    title: "Daily Horoscope",
                                    subtitle: "Get your daily cosmic forecast",
                                    isOn: $dailyHoroscopeEnabled
                                )
                                .onChange(of: dailyHoroscopeEnabled) { oldValue, newValue in
                                    if newValue && notificationsEnabled {
                                        notificationManager.scheduleDailyHoroscope()
                                    } else {
                                        notificationManager.cancelAllNotifications()
                                    }
                                }
                                
                                SettingsToggleRow(
                                    icon: "moon",
                                    title: "Dark Mode",
                                    subtitle: "Switch to dark cosmic theme",
                                    isOn: $darkModeEnabled
                                )
                                
                                SettingsToggleRow(
                                    icon: "hand.tap",
                                    title: "Haptic Feedback",
                                    subtitle: "Feel the cosmic vibrations",
                                    isOn: $hapticFeedbackEnabled
                                )
                                
                                SettingsToggleRow(
                                    icon: "arrow.clockwise",
                                    title: "Auto Save",
                                    subtitle: "Automatically save your progress",
                                    isOn: $autoSaveEnabled
                                )
                            }
                        }
                        
                        // Account Section
                        SettingsSection(title: "Account") {
                            VStack(spacing: 12) {
                                SettingsRow(
                                    icon: "person.circle",
                                    title: "Account Information",
                                    subtitle: "View and manage your account",
                                    action: {
                                        // TODO: Navigate to account info
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "lock",
                                    title: "Privacy & Security",
                                    subtitle: "Manage your privacy settings",
                                    action: {
                                        // TODO: Navigate to privacy settings
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "questionmark.circle",
                                    title: "Help & Support",
                                    subtitle: "Get help and contact support",
                                    action: {
                                        showingHelp = true
                                    }
                                )
                            }
                        }
                        
                        // About Section
                        SettingsSection(title: "About") {
                            VStack(spacing: 12) {
                                SettingsRow(
                                    icon: "info.circle",
                                    title: "App Version",
                                    subtitle: "Version 1.0.0",
                                    action: nil
                                )
                                
                                SettingsRow(
                                    icon: "doc.text",
                                    title: "Terms of Service",
                                    subtitle: "Read our terms and conditions",
                                    action: {
                                        showingTermsOfService = true
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "hand.raised",
                                    title: "Privacy Policy",
                                    subtitle: "Read our privacy policy",
                                    action: {
                                        showingPrivacyPolicy = true
                                    }
                                )
                            }
                        }
                        
                        // Sign Out Section
                        SettingsSection(title: "Account Actions") {
                            VStack(spacing: 12) {
                                // Sign Out Button styled like SettingsToggleRow
                                Button(action: {
                                    // Clear onboarding data on sign out
                                    OnboardingDataAccess.clearOnboardingData()
                                    try? authManager.signOut()
                                    dismiss()
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.red)
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Sign Out")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Text("Sign out and clear local data")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(.vertical, 4)
                                }
                                
                                // Delete Account Button styled like SettingsToggleRow
                                Button(action: {
                                    // TODO: Implement delete account functionality
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.red.opacity(0.8))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Delete Account")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Text("Permanently delete your account")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                onboardingDataAccess.updateModelContext(modelContext)
                // Sync notification state
                notificationsEnabled = notificationManager.isNotificationsEnabled
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showingHelp) {
                HelpSupportView()
            }
        }
    }
    
    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = OnboardingDataAccess.firstName
    @State private var birthDate = OnboardingDataAccess.birthDate
    @State private var birthTime = OnboardingDataAccess.birthTime
    
    var body: some View {
        NavigationView {
            ZStack {
                MainCelestialBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Edit Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        SettingsInputField(
                            title: "First Name",
                            text: $firstName,
                            placeholder: "Enter your first name"
                        )
                        
                        SettingsInputField(
                            title: "Birth Date",
                            text: $birthDate,
                            placeholder: "MM/DD/YYYY"
                        )
                        
                        SettingsInputField(
                            title: "Birth Time",
                            text: $birthTime,
                            placeholder: "HH:MM AM/PM (optional)"
                        )
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    
                    Spacer()
                    
                    Button(action: {
                        // TODO: Save profile changes
                        dismiss()
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Settings Input Field
struct SettingsInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
        }
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                MainCelestialBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy Policy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        Text("Last updated: June 27, 2025")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information.")
                                .foregroundColor(.white)
                            
                            Text("Information We Collect")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            
                            Text("• Personal information (name, birth date, birth time)\n• Zodiac sign and astrological data\n• App usage and preferences\n• Device information")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("How We Use Your Information")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            
                            Text("• Provide personalized horoscope readings\n• Improve app functionality\n• Send notifications (with your permission)\n• Analyze app performance")
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                MainCelestialBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Terms of Service")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        Text("Last updated: June 27, 2025")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("By using Zodiaccurate, you agree to these terms and conditions.")
                                .foregroundColor(.white)
                            
                            Text("Acceptance of Terms")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            
                            Text("By accessing and using this app, you accept and agree to be bound by the terms and provision of this agreement.")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Use License")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            
                            Text("Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only.")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Disclaimer")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            
                            Text("The horoscope readings and astrological content are for entertainment purposes only and should not be considered as professional advice.")
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Help & Support View
struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                MainCelestialBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Help & Support")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            HelpSection(title: "Getting Started") {
                                HelpItem(title: "How to set up your profile", action: {})
                                HelpItem(title: "Understanding your zodiac sign", action: {})
                                HelpItem(title: "Customizing your experience", action: {})
                            }
                            
                            HelpSection(title: "Features") {
                                HelpItem(title: "Daily horoscope readings", action: {})
                                HelpItem(title: "Notification settings", action: {})
                                HelpItem(title: "Profile management", action: {})
                            }
                            
                            HelpSection(title: "Contact Us") {
                                HelpItem(title: "Email support", action: {})
                                HelpItem(title: "Report a bug", action: {})
                                HelpItem(title: "Feature request", action: {})
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Help Section
struct HelpSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            content
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
        }
    }
}

// MARK: - Help Item
struct HelpItem: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Settings Section Component
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            content
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
        }
    }
}

// MARK: - Settings Toggle Row Component
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.vertical, 4)
        }
        .disabled(action == nil)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
} 