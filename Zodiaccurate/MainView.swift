import SwiftUI

struct MainView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background layers - ensure full screen coverage
                BackgroundView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack {
                    Text("Welcome to Zodiaccurate")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("You are logged in as: \(authManager.user?.email ?? "")")
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button(action: {
                        try? authManager.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Background View (same as onboarding)
private struct BackgroundView: View {
    var body: some View {
        ZStack {
            // Cosmic background
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "1A0B2E"), location: 0.0),
                    .init(color: Color(hex: "0F051A"), location: 0.7),
                    .init(color: Color.black, location: 1.0)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)

            // Vignette overlay
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.black.opacity(0.0), location: 0.6),
                    .init(color: Color.black.opacity(0.7), location: 1.0)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)
            .blendMode(.multiply)
            .allowsHitTesting(false)

            // Celestial bodies
            GeometryReader { geo in
                CelestialSystemBackground()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .position(x: geo.size.width / 5, y: geo.size.height / 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)

            // Orange overlay
            Color.backgroundPrimary.opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthenticationManager())
} 