import SwiftUI
import SwiftData

struct MainZodiacView: View {
    
    var body: some View {
        ZStack {
            VerticleAuroraBackgroundView()
            HoroscopeLoadingView()
        }
    }
}

#Preview {
    MainZodiacView()
}
