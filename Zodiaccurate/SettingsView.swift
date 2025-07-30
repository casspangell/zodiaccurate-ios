import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var onboardingDataAccess: OnboardingDataAccess
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var userProfileManager: UserProfileManager
    
    // Settings state
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = true
    @AppStorage("dailyHoroscopeEnabled") private var dailyHoroscopeEnabled = false
    
    // UI State
    @State private var showingEditProfile = false
    @State private var showingHelp = false
    @State private var showingSecretsDebug = false
    
    init() {
        // Initialize with a temporary context - will be updated in onAppear
        let tempContext = ModelContext(try! ModelContainer(for: UserDataModel.self))
        self._onboardingDataAccess = StateObject(wrappedValue: OnboardingDataAccess(modelContext: tempContext))
        self._userProfileManager = StateObject(wrappedValue: UserProfileManager(modelContext: tempContext))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                SubBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        SettingsSection(title: "Profile") {
                            VStack(spacing: 16) {
                                // Profile Card
                                HStack(spacing: 16) {
                                    ZodiacProfileBadge()
                                        .frame(width: 80, height: 80)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(userProfileManager.firstName.isEmpty ? "User" : userProfileManager.firstName)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text(userProfileManager.zodiacSign.isEmpty ? "Unknown" : userProfileManager.zodiacSign)
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
                                    icon: "hand.tap",
                                    title: "Haptic Feedback",
                                    subtitle: "Feel the cosmic vibrations",
                                    isOn: $hapticFeedbackEnabled
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
                                        if let url = URL(string: "https://zodiaccurate.com/terms-and-conditions") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "hand.raised",
                                    title: "Privacy Policy",
                                    subtitle: "Read our privacy policy",
                                    action: {
                                        if let url = URL(string: "https://zodiaccurate.com/privacy-policy") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                            }
                        }
                        
                        // Development Section (only show in debug builds)
                        #if DEBUG
                        SettingsSection(title: "Development") {
                            VStack(spacing: 12) {
                                SettingsRow(
                                    icon: "key.fill",
                                    title: "Secrets Manager",
                                    subtitle: "Debug API keys and secrets",
                                    action: {
                                        showingSecretsDebug = true
                                    }
                                )
                            }
                        }
                        #endif
                        
                        // Sign Out Section
                        SettingsSection(title: "Account Actions") {
                            VStack(spacing: 12) {
                                // Sign Out Button styled like SettingsToggleRow
                                Button(action: {
                                    // Preserve all UserDefaults data - only sign out from Firebase
                                    try? authManager.signOut()
                                    dismiss()
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.red)
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Log Out")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Text("Your local data will be preserved")
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
            .toolbarBackground(Color.backgroundSecondary, for: .navigationBar)
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
                userProfileManager.updateModelContext(modelContext)
                // Sync notification state
                notificationsEnabled = notificationManager.isNotificationsEnabled
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingHelp) {
                HelpSupportView()
            }
            .sheet(isPresented: $showingSecretsDebug) {
                ConfigDebugView()
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
    @Environment(\.modelContext) private var modelContext
    @StateObject private var userProfileManager: UserProfileManager
    
    // Focus states for text fields
    @FocusState private var isFirstNameFocused: Bool
    
    // Highlight states for text fields
    @State private var highlightFirstNameField = false
    
    init() {
        let tempContext = ModelContext(try! ModelContainer(for: UserDataModel.self))
        self._userProfileManager = StateObject(wrappedValue: UserProfileManager(modelContext: tempContext))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                SubBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Profile Information Section
                        SettingsSection(title: "Profile Information") {
                            VStack(spacing: 16) {
                                // First Name Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("First Name")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    SingleLineTextField(
                                        text: Binding(
                                            get: { userProfileManager.firstName },
                                            set: { userProfileManager.updateFirstName($0) }
                                        ),
                                        placeholder: "Enter your first name",
                                        isFocused: $isFirstNameFocused,
                                        onSubmit: {},
                                        highlightInputField: $highlightFirstNameField
                                    )
                                }
                                
                                // Birth Date Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    InteractivePickerView(
                                        step: ConversationStep(
                                            message: "Select your birth date",
                                            inputType: "date",
                                            placeholder: "Your birth date",
                                            dataKey: "birthDate"
                                        ),
                                        selectedDate: Binding(
                                            get: { 
                                                let formatter = DateFormatter()
                                                formatter.dateStyle = .medium
                                                return formatter.date(from: userProfileManager.birthDate) ?? Date()
                                            },
                                            set: { userProfileManager.updateBirthDate($0) }
                                        ),
                                        selectedTime: Binding(
                                            get: { 
                                                let formatter = DateFormatter()
                                                formatter.timeStyle = .short
                                                return formatter.date(from: userProfileManager.birthTime) ?? Date()
                                            },
                                            set: { userProfileManager.updateBirthTime($0) }
                                        ),
                                        onDateSelected: { date in
                                            userProfileManager.updateBirthDate(date)
                                        },
                                        onTimeSelected: { time in
                                            userProfileManager.updateBirthTime(time)
                                        },
                                        onUnknownTime: {
                                            // Handle unknown time if needed
                                        }
                                    )
                                }
                                
                                // Birth Time Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    InteractivePickerView(
                                        step: ConversationStep(
                                            message: "Select your birth time",
                                            inputType: "time",
                                            placeholder: "Birth time (if known)",
                                            dataKey: "birthTime"
                                        ),
                                        selectedDate: Binding(
                                            get: { 
                                                let formatter = DateFormatter()
                                                formatter.dateStyle = .medium
                                                return formatter.date(from: userProfileManager.birthDate) ?? Date()
                                            },
                                            set: { userProfileManager.updateBirthDate($0) }
                                        ),
                                        selectedTime: Binding(
                                            get: { 
                                                let formatter = DateFormatter()
                                                formatter.timeStyle = .short
                                                return formatter.date(from: userProfileManager.birthTime) ?? Date()
                                            },
                                            set: { userProfileManager.updateBirthTime($0) }
                                        ),
                                        onDateSelected: { date in
                                            userProfileManager.updateBirthDate(date)
                                        },
                                        onTimeSelected: { time in
                                            userProfileManager.updateBirthTime(time)
                                        },
                                        onUnknownTime: {
                                            // Handle unknown time
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Actions Section
                        SettingsSection(title: "Actions") {
                            VStack(spacing: 12) {
                                // Save Changes Button styled like SettingsRow
                                Button(action: {
                                    userProfileManager.saveChanges()
                                    dismiss()
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.green)
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Save Changes")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Text("Update your profile information")
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
                                
                                // Reset to Default Button styled like SettingsRow
                                Button(action: {
                                    userProfileManager.resetToOnboardingData()
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.orange)
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Reset to Default")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Text("Restore original profile data")
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
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.backgroundSecondary, for: .navigationBar)
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
                userProfileManager.updateModelContext(modelContext)
            }
        }
    }
    
    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Settings Input Field
struct SettingsInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .focused($isTextFieldFocused)
                .onTapGesture {
                    isTextFieldFocused = true
                }
        }
        .onTapGesture {
            isTextFieldFocused = true
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
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "hand.raised")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Privacy Policy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("View our complete privacy policy on our website")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        if let url = URL(string: "https://zodiaccurate.com/privacy-policy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "safari")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("Open Privacy Policy")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
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
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Terms of Service")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("View our complete terms and conditions on our website")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        if let url = URL(string: "https://zodiaccurate.com/terms-and-conditions") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "safari")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("Open Terms of Service")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
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
            .keyboardAdaptive()
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
