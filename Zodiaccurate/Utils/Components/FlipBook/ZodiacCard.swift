import SwiftUI

struct ZodiacCard: View {
    let title: String
    let content: String
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text(title)
                    .font(.dmSansSemibold(size: 24))
                    .foregroundColor(.whiteCustom)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Content
                Text(content)
                    .font(.dmSansMedium(size: 16))
                    .foregroundColor(.whiteCustom.opacity(0.8))
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
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
            
            // Audio Playback Button in upper right corner
            CircleIconButton(
                systemName: "speaker.wave.2",
                accessibilityLabel: "Play audio"
            ) {
                // Audio playback action will be implemented here
            }
            .padding(.top, 12)
            .padding(.trailing, 12)
            .zIndex(1)
        }
    }
}



#Preview {
    ZStack {
        ZodiacCard(
            title: "Parenting",
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas venenatis eros ut pretium tincidunt. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Sed vitae ex vitae nisi varius venenatis. Praesent commodo urna at nisi finibus varius. Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec vehicula sapien vitae massa tincidunt efficitur. Duis vestibulum mauris ac lectus tincidunt, in volutpat lorem efficitur. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        )
        .padding()
    }
}
