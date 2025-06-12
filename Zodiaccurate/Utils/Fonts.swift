import SwiftUI

extension Font {
    static func dmSansSemibold(size: CGFloat) -> Font {
        .custom("DMSans-Semibold", size: size)
    }
    static func dmSansMedium(size: CGFloat) -> Font {
        .custom("DMSans-Medium", size: size)
    }
    static var dmSansSemibold56: Font {
        .custom("DM Sans Semibold", size: 56)
    }
    static var dmSansSemibold16: Font {
        .custom("DM Sans Semibold", size: 16)
    }
    static var dmSansMedium13_4: Font {
        .custom("DM Sans Medium", size: 13.4)
    }
    static var dmSansSemibold56Tracking: Font {
        .custom("DM Sans Semibold", size: 56)
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
}
