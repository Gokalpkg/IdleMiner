import SwiftUI

struct OreLayer {
    let name: String
    let depthRequired: Double
    let primaryColor: Color
    let secondaryColor: Color
    let glowColor: Color
    let iconName: String
    let bonusMultiplier: Double
    
    static let allLayers: [OreLayer] = [
        OreLayer(
            name: "Taş & Kömür",
            depthRequired: 0,
            primaryColor: Color(red: 0.35, green: 0.35, blue: 0.38),
            secondaryColor: Color(red: 0.18, green: 0.18, blue: 0.20),
            glowColor: Color.white.opacity(0.15),
            iconName: "mountain.2.fill",
            bonusMultiplier: 1.0
        ),
        OreLayer(
            name: "Bakır Katmanı",
            depthRequired: 150,
            primaryColor: Color(red: 0.85, green: 0.45, blue: 0.25),
            secondaryColor: Color(red: 0.55, green: 0.25, blue: 0.10),
            glowColor: Color.orange.opacity(0.3),
            iconName: "shield.fill",
            bonusMultiplier: 1.2
        ),
        OreLayer(
            name: "Demir Katmanı",
            depthRequired: 500,
            primaryColor: Color(red: 0.70, green: 0.75, blue: 0.85),
            secondaryColor: Color(red: 0.35, green: 0.40, blue: 0.50),
            glowColor: Color.cyan.opacity(0.3),
            iconName: "hammer.fill",
            bonusMultiplier: 1.5
        ),
        OreLayer(
            name: "Saf Altın Damarı",
            depthRequired: 1500,
            primaryColor: Color(red: 0.98, green: 0.80, blue: 0.20),
            secondaryColor: Color(red: 0.80, green: 0.50, blue: 0.05),
            glowColor: Color.yellow.opacity(0.5),
            iconName: "sparkles",
            bonusMultiplier: 2.0
        ),
        OreLayer(
            name: "Zümrüt Mağarası",
            depthRequired: 5000,
            primaryColor: Color(red: 0.20, green: 0.85, blue: 0.45),
            secondaryColor: Color(red: 0.05, green: 0.50, blue: 0.25),
            glowColor: Color.green.opacity(0.5),
            iconName: "leaf.fill",
            bonusMultiplier: 3.0
        ),
        OreLayer(
            name: "Elmas Çekirdeği",
            depthRequired: 15000,
            primaryColor: Color(red: 0.30, green: 0.85, blue: 0.98),
            secondaryColor: Color(red: 0.10, green: 0.45, blue: 0.80),
            glowColor: Color.cyan.opacity(0.6),
            iconName: "suit.diamond.fill",
            bonusMultiplier: 5.0
        ),
        OreLayer(
            name: "Kozmik Kristal",
            depthRequired: 50000,
            primaryColor: Color(red: 0.80, green: 0.35, blue: 0.95),
            secondaryColor: Color(red: 0.45, green: 0.10, blue: 0.70),
            glowColor: Color.purple.opacity(0.7),
            iconName: "atom",
            bonusMultiplier: 10.0
        )
    ]
    
    static func currentLayer(for depth: Double) -> OreLayer {
        return allLayers.last(where: { depth >= $0.depthRequired }) ?? allLayers[0]
    }
    
    static func nextLayer(for depth: Double) -> OreLayer? {
        return allLayers.first(where: { depth < $0.depthRequired })
    }
}
