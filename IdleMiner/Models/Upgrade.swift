import Foundation

enum UpgradeType: String, Codable {
    case clickPower
    case passiveIncome
}

struct Upgrade: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let type: UpgradeType
    var level: Int
    let baseCost: Double
    let baseEffect: Double
    var costMultiplier: Double = 1.15
    
    /// Adım 5 ve 12: Maliyet = Taban Fiyat * 1.15^Seviye
    var cost: Double {
        return (baseCost * pow(costMultiplier, Double(level))).rounded()
    }
    
    /// Mevcut seviyenin sağladığı toplam katkı
    var totalEffect: Double {
        return baseEffect * Double(level)
    }
    
    /// Bir sonraki seviyenin ekleyeceği katkı
    var nextLevelEffect: Double {
        return baseEffect
    }
}
