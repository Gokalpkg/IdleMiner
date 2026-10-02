import SwiftUI

// MARK: - Maden Şaftı (Kat) Modeli
struct MineShaft: Identifiable, Codable {
    let id: Int
    let name: String
    let depthRequirement: Double
    let unlockCost: Double
    var isUnlocked: Bool
    var level: Int
    var baseIncome: Double
    let icon: String
    let colorName: String
    
    // Kat seviye atlama maliyeti
    var upgradeCost: Double {
        let base = max(unlockCost * 0.4, 50.0)
        return base * pow(1.22, Double(max(0, level - 1)))
    }
    
    // Katın ham saniyelik geliri
    var currentIncomePerSec: Double {
        guard isUnlocked && level > 0 else { return 0 }
        return baseIncome * Double(level) * pow(1.12, Double(max(0, level - 1)))
    }
    
    // Varsayılan 8 Maden Katı
    static let defaultShafts: [MineShaft] = [
        MineShaft(
            id: 1,
            name: "Kat 1: Yüzey Taş Ocağı",
            depthRequirement: 0,
            unlockCost: 0,
            isUnlocked: true,
            level: 1,
            baseIncome: 2.0,
            icon: "mountain.2.fill",
            colorName: "gray"
        ),
        MineShaft(
            id: 2,
            name: "Kat 2: Kömür Damarı",
            depthRequirement: 40,
            unlockCost: 250,
            isUnlocked: false,
            level: 0,
            baseIncome: 8.0,
            icon: "circle.grid.cross.fill",
            colorName: "black"
        ),
        MineShaft(
            id: 3,
            name: "Kat 3: Bakır Şaftı",
            depthRequirement: 120,
            unlockCost: 1500,
            isUnlocked: false,
            level: 0,
            baseIncome: 28.0,
            icon: "shield.fill",
            colorName: "orange"
        ),
        MineShaft(
            id: 4,
            name: "Kat 4: Demir Galerisi",
            depthRequirement: 300,
            unlockCost: 8000,
            isUnlocked: false,
            level: 0,
            baseIncome: 95.0,
            icon: "hammer.circle.fill",
            colorName: "blue"
        ),
        MineShaft(
            id: 5,
            name: "Kat 5: Altın Damarı",
            depthRequirement: 650,
            unlockCost: 35000,
            isUnlocked: false,
            level: 0,
            baseIncome: 320.0,
            icon: "star.fill",
            colorName: "yellow"
        ),
        MineShaft(
            id: 6,
            name: "Kat 6: Zümrüt & Kristal",
            depthRequirement: 1200,
            unlockCost: 150000,
            isUnlocked: false,
            level: 0,
            baseIncome: 1100.0,
            icon: "sparkles",
            colorName: "green"
        ),
        MineShaft(
            id: 7,
            name: "Kat 7: Derin Elmas Mağarası",
            depthRequirement: 2500,
            unlockCost: 750000,
            isUnlocked: false,
            level: 0,
            baseIncome: 4200.0,
            icon: "suit.diamond.fill",
            colorName: "cyan"
        ),
        MineShaft(
            id: 8,
            name: "Kat 8: Magma & Obsidyen Çekirdeği",
            depthRequirement: 5000,
            unlockCost: 3500000,
            isUnlocked: false,
            level: 0,
            baseIncome: 18000.0,
            icon: "flame.fill",
            colorName: "red"
        )
    ]
}
