import SwiftUI

// Custom Alert View that matches the app's UI scheme
struct ZodiacAlertView: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryButtonAction: () -> Void
    let secondaryButtonTitle: String?
    let secondaryButtonAction: (() -> Void)?
    
    init(title: String, message: String, primaryButtonTitle: String, primaryButtonAction: @escaping () -> Void, secondaryButtonTitle: String? = nil, secondaryButtonAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
    }
    
    var body: some View {
        ZStack {
            // Background blur overlay
            VisualEffectBlur(blurStyle: UIBlurEffect.Style.systemUltraThinMaterialDark)
                .ignoresSafeArea()
                .onTapGesture {
                    secondaryButtonAction?()
                }
            
            // Alert content
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.red.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 52, height: 52)
                        .foregroundColor(.white)
                }
                
                // Title
                Text(title)
                    .font(.dmSansSemibold(size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Message
                Text(message)
                    .font(.dmSansMedium(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Buttons
                VStack(spacing: 12) {
                    // Primary button
                    Button(action: primaryButtonAction) {
                        Text(primaryButtonTitle)
                            .font(.dmSansSemibold(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.red.opacity(0.8),
                                                Color.red.opacity(0.6)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                    
                    // Secondary button (optional)
                    if let secondaryButtonTitle = secondaryButtonTitle, let secondaryButtonAction = secondaryButtonAction {
                        Button(action: secondaryButtonAction) {
                            Text(secondaryButtonTitle)
                                .font(.dmSansMedium(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.9),
                                Color.indigo.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.accentGold.opacity(0.4),
                                        Color.accentPurple.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 24, x: 0, y: 12)
            .padding(.horizontal, 40)
        }
    }
} 
