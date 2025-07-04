import SwiftUI
import SwiftData

struct StardustEarningAnimationOverlay: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var stardustManager: StardustManager
    
    init() {
        // Initialize with a temporary context - will be updated in onAppear
        self._stardustManager = StateObject(wrappedValue: StardustManager(modelContext: ModelContext(try! ModelContainer(for: StardustBalance.self, StardustTransaction.self))))
    }
    
    var body: some View {
        ZStack {
            // Stardust earning animation
            if stardustManager.showEarningAnimation {
                StardustEarningAnimation(
                    amount: stardustManager.earningAnimationAmount,
                    type: stardustManager.earningAnimationType,
                    isShowing: $stardustManager.showEarningAnimation
                )
            }
        }
        .onAppear {
            // Update the model context
            stardustManager.updateModelContext(modelContext)
        }
    }
}

// Extension to StardustManager to support context updates
extension StardustManager {
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadBalance()
    }
} 