import SwiftUI

extension Font {
    static func dmSansSemibold(size: CGFloat) -> Font {
        .custom("DMSans-Semibold", size: size)
    }
    static func dmSansMedium(size: CGFloat) -> Font {
        .custom("DMSans-Medium", size: size)
    }
    static var dmSansSemibold56: Font {
        .custom("DMSans-Semibold", size: 56)
    }
    static var dmSansSemibold16: Font {
        .custom("DMSans-Semibold", size: 16)
    }
    static var dmSansMedium13_4: Font {
        .custom("DMSans-Medium", size: 13.4)
    }
    static var dmSansSemibold56Tracking: Font {
        .custom("DMSans-Semibold", size: 56)
    }
    static func poppinsMedium(size: CGFloat) -> Font {
        .custom("Poppins-Medium", size: size)
    }
}

extension View {
    func dmSansSemiboldTracking(size: CGFloat) -> some View {
        self.font(.dmSansSemibold(size: size))
            .tracking(size * -0.04)
    }
    func dmSansSemibold56Tracking() -> some View {
        self.font(.dmSansSemibold56)
            .tracking(56 * -0.04)
    }
    func poppinsMediumTracking() -> some View {
        self.font(.poppinsMedium(size: 56))
            .tracking(56 * 1.1)
    }
    func poppinsMediumButton(size: CGFloat = 12.27, letterSpacing: CGFloat = 1.1, lineHeight: CGFloat = 24.5) -> some View {
        self.font(.poppinsMedium(size: size))
            .kerning(letterSpacing)
            .lineSpacing(lineHeight - size)
    }
}
