import SwiftUI
import SwiftData

struct HoroscopeSplashView: View {
    @State private var showWelcomeMessage = true
    @State private var refreshTrigger = false
    @State private var showConsentAlert = true
    @State private var shouldReverseTagline = false
    @State private var showTapAnywhere = true
    @State private var showLoadingSpinner = true
    
    let onDismiss: (() -> Void)?
    let onConsentDismissed: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil, onConsentDismissed: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
        self.onConsentDismissed = onConsentDismissed
    }
    
    var body: some View {
        ZStack {
            // Consent Alert Overlay (blocks all interaction until accepted)
            if showConsentAlert {
                VisualEffectBlur(blurStyle: .systemMaterialDark)
                    .ignoresSafeArea()
                    .opacity(0.98)
                    .zIndex(100)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: showConsentAlert)
                    .allowsHitTesting(true)
                    .overlay(
                        ConsentAlertView(showConsentAlert: $showConsentAlert)
                    )
            }
            
            // Show tap to continue label only after consent is dismissed
            if !showConsentAlert {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Tagline at 30% from top
                        TaglineView(onReverseAnimation: {
                            // Navigate to main after tagline animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showMain()
                            }
                        }, shouldReverse: $shouldReverseTagline)
                        .animation(.easeInOut(duration: 0.5), value: showConsentAlert)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.3)
                        
                        Spacer()
                        
                        if showLoadingSpinner {
                            VStack(spacing: 20) {
                                ZodiacLoadingSpinner(size: .large)
                            }
                            .padding(.bottom, 80)
                            .transition(.opacity)
                        }
                        
                        if showTapAnywhere {
                            tapToContinueLabel
                                .transition(.opacity)
                        }
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: showConsentAlert)
            }
        }
        // Make the whole screen tappable to continue (except when loading)
        .contentShape(Rectangle())
        .onTapGesture {
//            if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty, showHoroscopeContent {
                withAnimation(.easeOut(duration: 0.3)) {
                    showTapAnywhere = false
                }
            
                shouldReverseTagline = true
            
            withAnimation(.easeOut(duration: 0.3).delay(1.3)) {
                    showLoadingSpinner = false
                }
//            }
        }
        .navigationBarHidden(true)
        .onChange(of: refreshTrigger) { _, _ in
            // This will trigger a view refresh when refreshTrigger changes
        }
        .onChange(of: showConsentAlert) { _, newValue in
            // When consent alert is dismissed (changes from true to false)
            print("HoroscopeSplashView: showConsentAlert changed to \(newValue)")
            if !newValue {
                print("done")
                print("HoroscopeSplashView: Calling onConsentDismissed callback")
                onConsentDismissed?()
            }
        }

    }

    private func showMain() {
        print("Navigating to MainView...")
        // Call the dismiss callback
        onDismiss?()
    }
}
@ViewBuilder
private var tapToContinueLabel: some View {
    HStack {
        Spacer()
        TapAnywhere()
            .frame(maxWidth: .infinity)
        Spacer()
    }
    .padding(.bottom, 50)
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserDataModel.self, configurations: config)
    
    // Create mock user data
    let mockUserData = UserDataModel.createMockUserData()
    
    container.mainContext.insert(mockUserData)
    
    return HoroscopeSplashView()
        .modelContainer(container)
} 
