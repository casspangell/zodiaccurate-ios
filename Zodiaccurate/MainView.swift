import SwiftUI

struct MainView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Reuse the cosmic background
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
                .ignoresSafeArea()
                
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

#Preview {
    MainView()
        .environmentObject(AuthenticationManager())
} 