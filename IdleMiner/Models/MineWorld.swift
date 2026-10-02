import SwiftUI

struct MineWorld: Identifiable, Codable {
    let id: String
    let name: String
    let subtitle: String
    let iconName: String
    let currencyName: String
    let currencySymbol: String
    let requiredDepth: Double
    let requiredPrestige: Int
    let globalMultiplier: Double
    
    // Tema Renkleri
    let primaryColorHex: String
    let secondaryColorHex: String
    let glowColorHex: String
    
    var primaryColor: Color {
        Color(hex: primaryColorHex)
    }
    
    var secondaryColor: Color {
        Color(hex: secondaryColorHex)
    }
    
    var glowColor: Color {
        Color(hex: glowColorHex)
    }
    
    func isUnlocked(currentDepth: Double, prestigeLevel: Int) -> Bool {
        return currentDepth >= requiredDepth || prestigeLevel >= requiredPrestige
    }
    
    static let allWorlds: [MineWorld] = [
        MineWorld(
            id: "world_eldorado",
            name: "El Dorado Vadisi",
            subtitle: "Kadim Altın ve Elmas Toprakları",
            iconName: "mountain.2.fill",
            currencyName: "Altın Külçesi",
            currencySymbol: "circle.circle.fill",
            requiredDepth: 0,
            requiredPrestige: 0,
            globalMultiplier: 1.0,
            primaryColorHex: "#F5C842",
            secondaryColorHex: "#8C5814",
            glowColorHex: "#F7D070"
        ),
        MineWorld(
            id: "world_glacier",
            name: "Buzul Mağaraları",
            subtitle: "Donmuş Safir Kristal Madeni",
            iconName: "snowflake",
            currencyName: "Safir Kristali",
            currencySymbol: "snowflake",
            requiredDepth: 1000,
            requiredPrestige: 1,
            globalMultiplier: 3.0,
            primaryColorHex: "#48CAE4",
            secondaryColorHex: "#023E8A",
            glowColorHex: "#90E0EF"
        ),
        MineWorld(
            id: "world_inferno",
            name: "Magma Çatlağı",
            subtitle: "Kızgın Lav ve Yakut Ocağı",
            iconName: "flame.fill",
            currencyName: "Lav Kor'u",
            currencySymbol: "flame.fill",
            requiredDepth: 5000,
            requiredPrestige: 2,
            globalMultiplier: 6.0,
            primaryColorHex: "#E63946",
            secondaryColorHex: "#590D22",
            glowColorHex: "#FF4D6D"
        ),
        MineWorld(
            id: "world_moon",
            name: "Ay Üssü Alfa",
            subtitle: "Kuantum Enerji Reaktörü",
            iconName: "moon.stars.fill",
            currencyName: "Kuantum Çekirdeği",
            currencySymbol: "atom",
            requiredDepth: 15000,
            requiredPrestige: 3,
            globalMultiplier: 12.0,
            primaryColorHex: "#9D4EDD",
            secondaryColorHex: "#240046",
            glowColorHex: "#C77DFF"
        )
    ]
}

// Hex Renk Desteği
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
