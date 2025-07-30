import SwiftUI

struct ConfirmationOverlay: View {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                
                Text(message)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .background(Color.backgroundSecondary.opacity(0.9))
            .cornerRadius(20)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()
        
        ConfirmationOverlay(
            message: "Your changes have been saved successfully"
        )
    }
} 
