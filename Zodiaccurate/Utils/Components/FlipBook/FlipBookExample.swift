import SwiftUI

struct FlipBookExample: View {
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("FlipBook with ZodiacCard Example")
                    .font(.dmSansSemibold(size: 24))
                    .foregroundColor(.whiteCustom)
                    .padding(.top, 40)
                
                // Example 1: FlipBook with ZodiacCard content
                FlipBook(pages: [
                    FlipBookPageContent(
                        title: "Daily Horoscope",
                        subtitle: "Discover what the stars have in store for you today",
                        color: Color.accentPurple,
                        zodiacCard: ZodiacCard(
                            title: "Today's Reading",
                            content: "The stars align in your favor today. Mercury's influence brings clarity to your thoughts, while Venus enhances your relationships. Focus on communication and trust your intuition."
                        )
                    ),
                    FlipBookPageContent(
                        title: "Weekly Forecast",
                        subtitle: "Plan your week with cosmic guidance",
                        color: Color.accentBlue,
                        zodiacCard: ZodiacCard(
                            title: "This Week's Energy",
                            content: "A powerful week ahead with Jupiter's expansion energy. New opportunities arise mid-week. Stay open to unexpected connections and trust the universe's timing."
                        )
                    ),
                    FlipBookPageContent(
                        title: "Monthly Insights",
                        subtitle: "Deep dive into your monthly astrological journey",
                        color: Color.accentGold,
                        zodiacCard: ZodiacCard(
                            title: "Monthly Overview",
                            content: "This month brings transformative energy with Pluto's influence. Major life changes are possible. Embrace transformation and trust the process of growth."
                        )
                    )
                ])
                
                Spacer()
                
                // Example 2: Default FlipBook (without ZodiacCard)
                Text("Default FlipBook")
                    .font(.dmSansSemibold(size: 20))
                    .foregroundColor(.whiteCustom)
                
                FlipBook()
            }
            .padding()
        }
    }
}

#Preview {
    FlipBookExample()
}
