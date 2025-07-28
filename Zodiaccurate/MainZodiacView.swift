import SwiftUI
import SwiftData

struct MainZodiacView: View {
    
    var body: some View {
        ZStack {
            VerticleAuroraBackgroundView()
            
            VStack {
                Text("Zodiaccurate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Main View")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

#Preview {
    MainZodiacView()
}
