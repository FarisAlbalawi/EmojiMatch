import SwiftUI

class Theme {
    // MARK: - Colors
    static let primaryYellow = Color(hex: "fbf031")
    static let secondaryYellow = Color(hex: "FFD700")
    static let primaryPurple = Color(hex: "c292ff")
    static let secondaryPurple = Color(hex: "dac6f3")
    static let background = Color.black
    static let cardBackground = Color.white.opacity(0.05)
    static let cardBorder = Color.white.opacity(0.1)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.6)
    
    // MARK: - Fonts
    static let titleFont =  Font.custom("ArialRoundedMTBold", size: 36)
    static let subtitleFont = Font.custom("ArialRoundedMTBold", size: 18)
    static let buttonFont = Font.custom("ArialRoundedMTBold", size: 18)
    static let timerFont = Font.custom("ArialRoundedMTBold", size: 30)
    static let bestTimeFont = Font.custom("ArialRoundedMTBold", size: 20)
    static let cardValueFont = Font.custom("ArialRoundedMTBold", size: 20)
    static let cardTitleFont = Font.custom("ArialRoundedMTBold", size: 12)
    static let historyTitleFont = Font.custom("ArialRoundedMTBold", size: 16)
    static let historySubtitleFont = Font.custom("ArialRoundedMTBold", size: 12)
    static let historyTimeFont = Font.custom("ArialRoundedMTBold", size: 14)
    static let statsValueFont = Font.custom("ArialRoundedMTBold", size: 24)
    static let statsTitleFont = Font.custom("ArialRoundedMTBold", size: 12)
    static let chartTitleFont = Font.custom("ArialRoundedMTBold", size: 20)
    static let chartLabelFont = Font.custom("ArialRoundedMTBold", size: 12)
    static let tooltipFont = Font.custom("ArialRoundedMTBold", size: 14)
    static let tooltipSubtitleFont = Font.custom("ArialRoundedMTBold", size: 12)
    static let legendFont = Font.custom("ArialRoundedMTBold", size: 11)
    
    // MARK: - Corner Radius
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 16
    static let extraLargeCornerRadius: CGFloat = 20
    
    // MARK: - Spacing
    static let smallSpacing: CGFloat = 4
    static let mediumSpacing: CGFloat = 8
    static let largeSpacing: CGFloat = 12
    static let extraLargeSpacing: CGFloat = 16
    static let hugeSpacing: CGFloat = 20
    static let massiveSpacing: CGFloat = 24
    static let enormousSpacing: CGFloat = 30
    
    // MARK: - Sizes
    static let smallIconSize: CGFloat = 12
    static let mediumIconSize: CGFloat = 16
    static let largeIconSize: CGFloat = 18
    static let extraLargeIconSize: CGFloat = 24
    static let hugeIconSize: CGFloat = 40
    static let massiveIconSize: CGFloat = 60
    
    static let smallButtonHeight: CGFloat = 44
    static let mediumButtonHeight: CGFloat = 50
    static let smallCardHeight: CGFloat = 90
    static let mediumCardHeight: CGFloat = 100
    static let largeCardHeight: CGFloat = 120
} 


extension Font {
    static func roundedBold(size: CGFloat) -> Font {
        .custom("ArialRoundedMTBold", size: size)
    }
}
