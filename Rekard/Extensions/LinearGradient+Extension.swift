import SwiftUI

extension LinearGradient {
    static let appBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0xDD / 255, green: 0xCB / 255, blue: 0xB3 / 255), // Top - #DDCBB3
            Color(red: 0xFF / 255, green: 0xFF / 255, blue: 0xEA / 255)  // Bottom - #FFFFEA
        ]),
        startPoint: .bottom,
        endPoint: .top
    )
}
