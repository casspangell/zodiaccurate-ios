import SwiftUI

struct PrimaryGradientButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .poppinsMediumButton(size: 17)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .textCase(.uppercase)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// Preview
struct PrimaryGradientButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryGradientButton(title: "Sign In", action: {})
            .padding()
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
} 