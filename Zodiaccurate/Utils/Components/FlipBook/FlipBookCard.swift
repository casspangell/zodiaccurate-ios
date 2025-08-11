import SwiftUI

struct FlipBookCard: View {
    let horoscope: Horoscope?
    let isLoading: Bool
    let onCardTap: (() -> Void)?
    @StateObject private var audioManager = AudioManager.shared
    
    init(horoscope: Horoscope?, isLoading: Bool = false, onCardTap: (() -> Void)? = nil) {
        self.horoscope = horoscope
        self.isLoading = isLoading
        self.onCardTap = onCardTap
    }
    
    // Convenience initializer for backward compatibility
    init(title: String, content: String, onCardTap: (() -> Void)? = nil) {
        self.horoscope = Horoscope(title: title, message: content, key: "temp")
        self.isLoading = false
        self.onCardTap = onCardTap
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if isLoading {
                // Loading state with spinner
                VStack {
                    Spacer()
                    ZodiacLoadingSpinner(size: .large)
                        .frame(width: 80, height: 80)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.bubbleMist.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
            } else if let horoscope = horoscope {
                // Content state
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    Text(horoscope.title)
                        .font(.dmSansSemibold(size: 24))
                        .foregroundColor(.whiteCustom)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    // Content
                    Text(horoscope.message)
                        .font(.dmSansMedium(size: 16))
                        .foregroundColor(.whiteCustom.opacity(0.8))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
//                        .fill(Color.bubbleMist.opacity(0.8))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 16)
//                                .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
//                        )
                )
                .shadow(color: Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Audio Playback Button in upper right corner
                if audioManager.hasAudio(for: horoscope) {
                    AudioControlButton(
                        isPlaying: audioManager.isPlaying && audioManager.currentAudioKey == horoscope.key,
                        onToggle: {
                            audioManager.toggleAudio(for: horoscope)
                        },
                        size: 44
                    )
                    .padding(.top, 12)
                    .padding(.trailing, 12)
                    .zIndex(1)
                }
            } else {
                // Empty state (shouldn't happen with proper usage)
                VStack {
                    Spacer()
                    Text("No content available")
                        .font(.dmSansMedium(size: 16))
                        .foregroundColor(.whiteCustom.opacity(0.6))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.bubbleMist.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            // Post notification to move FlipBook to top
            NotificationCenter.default.post(name: .flipBookMoveToTop, object: nil)
            onCardTap?()
        }
    }
}



#Preview {
    VStack(spacing: 20) {
        // Loading state
        FlipBookCard(horoscope: nil, isLoading: true)
            .frame(height: 300)
            .padding()
        
        // Loaded state
        FlipBookCard(
            horoscope: Horoscope(
                title: "Parenting",
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas venenatis eros ut pretium tincidunt. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Sed vitae ex vitae nisi varius venenatis. Praesent commodo urna at nisi finibus varius. Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec vehicula sapien vitae massa tincidunt efficitur. Duis vestibulum mauris ac lectus tincidunt, in volutpat lorem efficitur. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                key: "preview"
            ),
            isLoading: false,
            onCardTap: {
                print("Card tapped - would move FlipBook to top")
            }
        )
        .frame(height: 300)
        .padding()
    }
    .background(Color.backgroundPrimary)
}
