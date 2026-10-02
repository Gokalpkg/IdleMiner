import Foundation

struct SpecialBuff: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let gemCost: Int
    var isPurchased: Bool = false
    let clickMultiplierBonus: Double // Örn: 1.5x
    let passiveMultiplierBonus: Double // Örn: 1.5x
}
