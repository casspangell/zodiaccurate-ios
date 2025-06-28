import SwiftUI

struct SettingsWidgetMenu: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var notificationsEnabled = true
    @State private var appearance: Int = 0 // 0: Auto, 1: Light, 2: Dark
    @State private var animateTiles = false
    @State private var graphData: [Double] = [50, 80, 60, 100, 55, 40, 45]
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: UIBlurEffect.Style.systemUltraThinMaterialDark)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 16) {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.top, 12)
                
                // Large User Badge Widget at the top
                UserBadgeWidget()
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                
                // Prominent Graph Card
                GraphCardView(graphData: graphData)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    // Profile Tile
                    SettingsTile(icon: "person.crop.circle", color: .blue, label: "Profile") {
                        // Edit profile action
                    }
                    // Notifications Tile
                    SettingsTile(icon: "bell.fill", color: .orange, label: "Notifications") {
                        notificationsEnabled.toggle()
                    }
                    // Theme Tile
                    SettingsTile(icon: "moon.fill", color: .purple, label: "Appearance") {
                        // Cycle through appearance modes
                        appearance = (appearance + 1) % 3
                    }
                    // Daily Horoscope Tile
                    SettingsTile(icon: "sparkles", color: .yellow, label: "Horoscope") {
                        // Show daily horoscope
                    }
                    // Streak Tile
                    SettingsTile(icon: "flame.fill", color: .red, label: "Streak") {
                        // Show check-in streak
                    }
                    // Compatibility Tile
                    SettingsTile(icon: "heart.circle.fill", color: .pink, label: "Compatibility") {
                        // Show compatibility
                    }
                    // App Info Tile
                    SettingsTile(icon: "info.circle.fill", color: .teal, label: "App Info") {
                        // Show app info
                    }
                    // Update Credit Card Tile
                    SettingsTile(icon: "creditcard.fill", color: .green, label: "Update Credit Card") {
                        // Show credit card update
                    }
                    // Help Tile
                    SettingsTile(icon: "questionmark.circle.fill", color: .indigo, label: "Help") {
                        // Show help/support
                    }
                    // Sign Out Tile
                    SettingsTile(icon: "arrow.backward.circle.fill", color: .red, label: "Sign Out") {
                        OnboardingDataAccess.clearOnboardingData()
                        try? authManager.signOut()
                        isPresented = false
                    }
                }
                .padding(.horizontal, 8)
                .opacity(animateTiles ? 1 : 0)
                .offset(y: animateTiles ? 0 : 40)
                .animation(.easeOut(duration: 0.6), value: animateTiles)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.indigo.opacity(0.7))
            )
            .padding(.horizontal, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                withAnimation {
                    animateTiles = true
                }
            }
        }
    }
}

// Large User Badge Widget
struct UserBadgeWidget: View {
    var body: some View {
        VStack(spacing: 12) {
            // Large Zodiac Profile Badge
            ZodiacProfileBadge()
                .frame(width: 120, height: 120)
            
            // User Info
            VStack(spacing: 4) {
                Text(OnboardingDataAccess.firstName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(OnboardingDataAccess.zodiacSign.isEmpty ? OnboardingDataAccess.firstName : OnboardingDataAccess.zodiacSign)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Member since \(getFormattedDate())")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.accentGold.opacity(0.5), Color.accentPurple.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
        )
        .shadow(color: Color.accentGold.opacity(0.1), radius: 12, x: 0, y: 6)
        .onAppear {
            logUserProfile()
        }
    }
    
    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
    
    private func logUserProfile() {
        print("🔍 === USER PROFILE DEBUG INFO ===")
        print("👤 First Name: '\(OnboardingDataAccess.firstName)'")
        print("📅 Birth Date: '\(OnboardingDataAccess.birthDate)'")
        print("⏰ Birth Time: '\(OnboardingDataAccess.birthTime)'")
        print("♈ Zodiac Sign: '\(OnboardingDataAccess.zodiacSign)'")
        print("✅ Has Completed Onboarding: \(OnboardingDataAccess.hasCompletedOnboarding)")
        print("📝 Number of Responses: \(OnboardingDataAccess.responses.count)")
        
        if !OnboardingDataAccess.responses.isEmpty {
            print("💬 User Responses:")
            for (index, response) in OnboardingDataAccess.responses.enumerated() {
                print("   \(index + 1). Question: '\(response.0)'")
                print("      Key: '\(response.1)'")
                print("      Answer: '\(response.2)'")
            }
        }
        
        print("🔍 === END USER PROFILE DEBUG ===")
    }
}

struct SettingsTile: View {
    let icon: String
    let color: Color
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 64, height: 64)
                        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(color)
                }
                Text(label)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .frame(width: 120, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Simple animated line graph
struct AnimatedLineGraph: View {
    let data: [Double]
    let animate: Bool
    
    var path: Path {
        var path = Path()
        guard data.count > 1 else { return path }
        let width: CGFloat = 200
        let height: CGFloat = 80
        let stepX = width / CGFloat(data.count - 1)
        let maxY = (data.max() ?? 1)
        let minY = (data.min() ?? 0)
        let rangeY = maxY - minY == 0 ? 1 : maxY - minY
        path.move(to: CGPoint(x: 0, y: height - CGFloat((data[0] - minY) / rangeY) * height))
        for i in 1..<data.count {
            let x = CGFloat(i) * stepX
            let y = height - CGFloat((data[i] - minY) / rangeY) * height
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
    
    var body: some View {
        GeometryReader { geo in
            path
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing), lineWidth: 3)
                .animation(.easeOut(duration: 1), value: animate)
        }
    }
}

struct GraphCardView: View {
    let graphData: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Energy Consumption Statistics")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            LineGraphWithDots(data: graphData)
                .frame(height: 120)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.cyan.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
        )
        .shadow(color: Color.blue.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}

struct LineGraphWithDots: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let maxY = (data.max() ?? 1)
            let minY = (data.min() ?? 0)
            let rangeY = maxY - minY == 0 ? 1 : maxY - minY
            let stepX = width / CGFloat(max(data.count - 1, 1))
            let points = data.enumerated().map { (i, val) in
                CGPoint(x: CGFloat(i) * stepX, y: height - CGFloat((val - minY) / rangeY) * height)
            }
            ZStack {
                // Axes
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: width, y: height))
                }
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                // Line
                Path { path in
                    guard points.count > 1 else { return }
                    path.move(to: points[0])
                    for pt in points.dropFirst() {
                        path.addLine(to: pt)
                    }
                }
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]), startPoint: .leading, endPoint: .trailing), lineWidth: 3)
                // Dots
                ForEach(points.indices, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .position(points[i])
                        .shadow(color: Color.cyan.opacity(0.5), radius: 4, x: 0, y: 2)
                }
            }
        }
    }
} 
