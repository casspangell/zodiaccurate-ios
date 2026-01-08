import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var notificationManager = NotificationManager()
    
    // SwiftData query to fetch User
    @Query private var users: [User]
    
    // Computed property to get the current user
    private var currentUser: User? {
        return users.first
    }
    
    // Settings state
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = true
    @AppStorage("dailyHoroscopeEnabled") private var dailyHoroscopeEnabled = false
    
    // UI State
    @State private var showingEditProfile = false
    @State private var showingSecretsDebug = false
    
    init() {
        // Initialize managers

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
                                    ZodiacProfileBadgeForSettings(zodiacSign: currentUser?.zodiacSign ?? "")
                                        .frame(width: 80, height: 80)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(currentUser?.firstName.isEmpty == true ? "User" : (currentUser?.firstName ?? "User"))
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text(currentUser?.zodiacSign.isEmpty == true ? "Unknown" : (currentUser?.zodiacSign ?? "Unknown"))
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
                                        if let url = URL(string: "https://zodiaccurate.com/contact-page") {
                                            UIApplication.shared.open(url)
                                        }
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
                // Sync notification state
                notificationsEnabled = notificationManager.isNotificationsEnabled
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(onProfileSaved: {
                    // Profile data will automatically update via SwiftData @Query
                })
            }
            .sheet(isPresented: $showingSecretsDebug) {
                APIConfigDebugView()
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
    @Query private var users: [User]
    
    // Focus states for text fields
    @FocusState private var isFirstNameFocused: Bool
    
    // Highlight states for text fields
    @State private var highlightFirstNameField = false
    
    // Loading and error states
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Local state for editing
    @State private var editingFirstName: String = ""
    @State private var editingBirthDate: Date = Date()
    @State private var editingBirthTime: Date = Date()
    
    // Computed property to get the current user
    private var currentUser: User? {
        return users.first
    }
    
    // Helper function to create a User from editing state
    private func createUserFromEditingState() -> User {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        let birthDateString = dateFormatter.string(from: editingBirthDate)
        let birthTimeString = timeFormatter.string(from: editingBirthTime)
        
        return User(
            firstName: editingFirstName,
            birthDate: birthDateString,
            birthTime: birthTimeString,
            zodiacSign: determineZodiacSign(from: birthDateString)
        )
    }
    
    // Helper function to load user data into editing state
    private func loadUserDataIntoEditingState() {
        guard let user = currentUser else { return }
        
        editingFirstName = user.firstName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if let birthDate = dateFormatter.date(from: user.birthDate) {
            editingBirthDate = birthDate
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        if let birthTime = timeFormatter.date(from: user.birthTime) {
            editingBirthTime = birthTime
        }
    }
    
    // Callback for when profile is saved
    let onProfileSaved: (() -> Void)?
    
    init(onProfileSaved: (() -> Void)? = nil) {
        self.onProfileSaved = onProfileSaved
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
                                        text: $editingFirstName,
                                        placeholder: "Enter your first name",
                                        isFocused: $isFirstNameFocused,
                                        onSubmit: {},
                                        highlightInputField: $highlightFirstNameField
                                    )
                                }
                                
                                // Birth Date Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    DatePickerView(
                                        selectedDate: $editingBirthDate,
                                        onDateSelected: { date in
                                            editingBirthDate = date
                                        },
                                        showSubmitButton: false
                                    )
                                }
                                
                                // Birth Time Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    TimePickerView(
                                        selectedTime: $editingBirthTime,
                                        onTimeSelected: { time in
                                            editingBirthTime = time
                                        },
                                        onUnknownTime: {
                                            // Handle unknown time
                                            editingBirthTime = Date()
                                        },
                                        showSubmitButton: false
                                    )
                                }
                            }
                        }
                        
                        // Actions Section
                        SettingsSection(title: "") {
                            VStack(spacing: 12) {
                                // Save Changes Button using PrimaryGradientButton
                                PrimaryGradientButton(
                                    title: isSaving ? "Saving..." : "Save Changes",
                                    action: {
                                        isSaving = true
                                        
                                        // Save profile changes to SwiftData
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            do {
                                                if let user = currentUser {
                                                    // Update existing user data
                                                    let updatedUser = createUserFromEditingState()
                                                    user.firstName = updatedUser.firstName
                                                    user.birthDate = updatedUser.birthDate
                                                    user.birthTime = updatedUser.birthTime
                                                    user.zodiacSign = updatedUser.zodiacSign
                                                    
                                                    // Save to SwiftData
                                                    try modelContext.save()
                                                    
                                                    print("✅ User profile updated successfully")
                                                } else {
                                                    // Create new user if none exists
                                                    let newUser = createUserFromEditingState()
                                                    modelContext.insert(newUser)
                                                    try modelContext.save()
                                                    
                                                    print("✅ New user created successfully")
                                                }
                                                
                                                // Call the callback to refresh the main settings view
                                                onProfileSaved?()
                                                
                                                // Show loading for 3 seconds before dismissing
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                                    isSaving = false
                                                    dismiss()
                                                }
                                            } catch {
                                                // Handle error
                                                isSaving = false
                                                errorMessage = "Failed to save profile changes. Please try again."
                                                showError = true
                                            }
                                        }
                                    }
                                )
                                .disabled(isSaving)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal)
                }
            }
            .overlay(
                // Loading overlay
                Group {
                    if isSaving {
                        ZStack {
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 20) {
                                ZodiacLoadingSpinner(size: .large)
                            }
                        }
                    }
                }
            )
            .overlay(
                Group {
                    if showError {
                        ZodiacAlertView(
                            title: "Error",
                            message: errorMessage,
                            primaryButtonTitle: "OK",
                            primaryButtonAction: {
                                showError = false
                            }
                        )
                    }
                }
            )
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
                // Load current user data into editing state
                loadUserDataIntoEditingState()
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

// MARK: - API Configuration Debug View

@MainActor
struct APIConfigDebugView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                SubBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("🔧 API Configuration")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(APIConfig.configStatus.description)
                                .font(.subheadline)
                                .foregroundColor(APIConfig.configStatus.color)
                        }
                        .padding(.top)
                        
                        // Status Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Configuration Status")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                StatusRow(
                                    title: "OpenAI API Key",
                                    isConfigured: APIConfig.isAPIKeyConfigured
                                )
                                
                                StatusRow(
                                    title: "Firebase URL",
                                    isConfigured: !APIConfig.firebaseURL.contains("YOUR_FIREBASE_URL_HERE")
                                )
                                
                                StatusRow(
                                    title: "Firebase API Key",
                                    isConfigured: !APIConfig.firebaseAPIKey.contains("YOUR_FIREBASE_API_KEY_HERE")
                                )
                                
                                StatusRow(
                                    title: "Firebase Password",
                                    isConfigured: !APIConfig.firebasePassword.contains("YOUR_FIREBASE_PASSWORD_HERE")
                                )
                                
                                StatusRow(
                                    title: "Stripe API Key",
                                    isConfigured: APIConfig.isStripeConfigured
                                )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Actions
                        VStack(spacing: 12) {
                            Button(action: {
                                APIConfig.checkConfigStatus()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Refresh Status")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Debug Report
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Debug Report")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                Text(getConfigReport())
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    private func getConfigReport() -> String {
        var report = "🔧 CONFIGURATION REPORT\n"
        report += "======================\n\n"
        
        // OpenAI
        let openAIStatus = APIConfig.isAPIKeyConfigured ? "✅" : "❌"
        report += "\(openAIStatus) OpenAI API Key: \(openAIStatus == "✅" ? "Configured" : "Missing")\n"
        report += "   Base URL: \(APIConfig.openAIBaseURL)\n"
        report += "   Model: \(APIConfig.defaultModel)\n"
        report += "   Temperature: \(APIConfig.defaultTemperature)\n"
        report += "   Max Tokens: \(APIConfig.maxTokens)\n\n"
        
        // Firebase
        let firebaseStatus = APIConfig.isFirebaseConfigured ? "✅" : "❌"
        report += "\(firebaseStatus) Firebase Configuration: \(firebaseStatus == "✅" ? "Configured" : "Missing")\n"
        report += "   URL: \(APIConfig.firebaseURL)\n"
        report += "   API Key: \(APIConfig.firebaseAPIKey.contains("YOUR_") ? "Missing" : "Configured")\n"
        report += "   Password: \(APIConfig.firebasePassword.contains("YOUR_") ? "Missing" : "Configured")\n\n"
        
        // Stripe
        let stripeStatus = APIConfig.isStripeConfigured ? "✅" : "❌"
        report += "\(stripeStatus) Stripe Configuration: \(stripeStatus == "✅" ? "Configured" : "Missing")\n"
        report += "   API Key: \(APIConfig.stripeAPIKey.contains("YOUR_") ? "Missing" : "Configured")\n\n"
        
        // Overall
        let overallStatus = APIConfig.areAllSecretsConfigured ? "✅" : "❌"
        report += "\(overallStatus) Overall Status: \(overallStatus == "✅" ? "Ready" : "Needs Configuration")\n"
        
        return report
    }
}

// MARK: - Status Row Component

struct StatusRow: View {
    let title: String
    let isConfigured: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isConfigured ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isConfigured ? .green : .red)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(isConfigured ? "Configured" : "Missing")
                .font(.caption)
                .foregroundColor(isConfigured ? .green : .red)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
} 
