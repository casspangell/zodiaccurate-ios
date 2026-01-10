import SwiftUI

struct ConfirmationOverlay: View {
    let message: String
    let cost: Int?
    let onOK: (() -> Void)?
    let onNevermind: (() -> Void)?
    
    init(message: String, cost: Int? = nil, onOK: (() -> Void)? = nil, onNevermind: (() -> Void)? = nil) {
        self.message = message
        self.cost = cost
        self.onOK = onOK
        self.onNevermind = onNevermind
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 12) {
                    Text(message)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    if let cost = cost {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("\(cost) Stardust")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.yellow)
                        }
                        .padding(.top, 8)
                    }
                }
                
                if onOK != nil || onNevermind != nil {
                    HStack(spacing: 16) {
                        if let onNevermind = onNevermind {
                            Button(action: onNevermind) {
                                Text("Nevermind")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        
                        if let onOK = onOK {
                            Button(action: onOK) {
                                Text("OK")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.orange.opacity(0.8),
                                                Color.pink.opacity(0.8),
                                                Color.purple.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
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
