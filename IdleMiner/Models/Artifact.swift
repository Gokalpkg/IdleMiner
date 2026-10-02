import SwiftUI

// MARK: - 1. Rarity (Nadirlik Derecesi)
enum Rarity: String, Codable, CaseIterable {
    case common
    case rare
    case epic
    case legendary
    
    var title: String {
        switch self {
        case .common: return "Sıradan"
        case .rare: return "Nadir"
        case .epic: return "Epik"
        case .legendary: return "Efsanevi"
        }
    }
    
    var dropChance: Double {
        switch self {
        case .common: return 0.05
        case .rare: return 0.015
        case .epic: return 0.004
        case .legendary: return 0.0005
        }
    }
    
    var color: Color {
        switch self {
        case .common: return Color(red: 0.35, green: 0.85, blue: 0.45)
        case .rare: return Color(red: 0.25, green: 0.65, blue: 1.0)
        case .epic: return Color(red: 0.72, green: 0.35, blue: 0.98)
        case .legendary: return Color(red: 1.0, green: 0.82, blue: 0.20)
        }
    }
    
    var glowColor: Color {
        switch self {
        case .common: return Color.green.opacity(0.5)
        case .rare: return Color.blue.opacity(0.6)
        case .epic: return Color.purple.opacity(0.7)
        case .legendary: return Color.yellow.opacity(0.85)
        }
    }
}

// MARK: - 2. BonusType (Pasif Güçlendirme Türü)
enum BonusType: Codable, Equatable {
    case passiveIncomeBoost(Double)
    case clickPowerBoost(Double)
    case rareDropRateBoost(Double)
    
    var description: String {
        switch self {
        case .passiveIncomeBoost(let value):
            return "+%\(Int(value * 100)) Pasif Maden Geliri"
        case .clickPowerBoost(let value):
            return "+%\(Int(value * 100)) Tıklama Kazancı"
        case .rareDropRateBoost(let value):
            return "+%\(Int(value * 100)) Eser Bulma Şansı"
        }
    }
    
    var badgeIcon: String {
        switch self {
        case .passiveIncomeBoost: return "bolt.fill"
        case .clickPowerBoost: return "hammer.fill"
        case .rareDropRateBoost: return "sparkles"
        }
    }
}

// MARK: - 3. ArtifactSet (Müze Set & Sinerji Modeli)
struct ArtifactSet: Identifiable, Codable {
    let id: String
    let name: String
    let iconName: String
    let description: String
    let requiredArtifactNames: [String]
    let setBonusText: String
    let globalMultiplierBonus: Double // Örn: 0.25 (+%25 Tüm Gezegen Kazancı)
    
    static let allSets: [ArtifactSet] = [
        ArtifactSet(
            id: "set_dino",
            name: "Dinozor Çağı Seti",
            iconName: "tortoise.fill",
            description: "Milyonlarca yıllık tarih öncesi fosiller bir arada.",
            requiredArtifactNames: ["T-Rex Kafatası", "Fosil Diş"],
            setBonusText: "+%25 Kalıcı Tüm Gezegen Kazancı 🏆",
            globalMultiplierBonus: 0.25
        ),
        ArtifactSet(
            id: "set_relics",
            name: "Kadim Madenciler Seti",
            iconName: "wand.and.rays",
            description: "İlk kaşiflerin ve mitolojik ustaların yadigarları.",
            requiredArtifactNames: ["Antik Madenci Pusulası", "Kararmış Altın Kazma"],
            setBonusText: "+%30 Tıklama & Pasif Çarpanı 🏆",
            globalMultiplierBonus: 0.30
        ),
        ArtifactSet(
            id: "set_cosmic",
            name: "Kozmik Sırlar Seti",
            iconName: "atom",
            description: "Evrenin derinliklerinden gelen gizemli enerji kaynakları.",
            requiredArtifactNames: ["Parlayan Rün Taşı", "Meteorit Parçası"],
            setBonusText: "+%50 Kalıcı Maden Geliri & Çılgınlık Gücü 🏆",
            globalMultiplierBonus: 0.50
        )
    ]
}

// MARK: - 4. Artifact (Eser Modeli)
struct Artifact: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let iconName: String
    let rarity: Rarity
    var isUnlocked: Bool
    let bonusType: BonusType
    let loreDescription: String
    var setId: String? = nil
    
    var perkText: String {
        bonusType.description
    }
    
    static let defaultArtifacts: [Artifact] = [
        Artifact(
            name: "Antik Madenci Pusulası",
            iconName: "safari.fill",
            rarity: .common,
            isUnlocked: false,
            bonusType: .passiveIncomeBoost(0.10),
            loreDescription: "Eski çağ madencilerinin karanlık dehlizlerde yön ve damar tayini için pirinçten dövdüğü pusula.",
            setId: "set_relics"
        ),
        Artifact(
            name: "Fosil Diş",
            iconName: "mouth.fill",
            rarity: .common,
            isUnlocked: false,
            bonusType: .clickPowerBoost(0.15),
            loreDescription: "Milyonlarca yıllık sert tortul kayalarda sıkışıp taşlaşmış sivri bir yırtıcı dişi.",
            setId: "set_dino"
        ),
        Artifact(
            name: "T-Rex Kafatası",
            iconName: "tortoise.fill",
            rarity: .rare,
            isUnlocked: false,
            bonusType: .rareDropRateBoost(0.05),
            loreDescription: "Kömür yataklarının alt katmanlarında neredeyse hiç hasar almadan korunmuş devasa kemik kalıntısı.",
            setId: "set_dino"
        ),
        Artifact(
            name: "Parlayan Rün Taşı",
            iconName: "sparkle",
            rarity: .rare,
            isUnlocked: false,
            bonusType: .passiveIncomeBoost(0.25),
            loreDescription: "Üzerine işlenen kadim simyacı sembolleri geceleri mor bir ışıltı yayarak madeni aydınlatır.",
            setId: "set_cosmic"
        ),
        Artifact(
            name: "Kararmış Altın Kazma",
            iconName: "wand.and.rays",
            rarity: .epic,
            isUnlocked: false,
            bonusType: .clickPowerBoost(0.40),
            loreDescription: "Zamanla yüzeyi karararak sertleşmiş, vurduğu her taştan saf cevher çıkaran mitolojik bir kazma ucu.",
            setId: "set_relics"
        ),
        Artifact(
            name: "Meteorit Parçası",
            iconName: "atom",
            rarity: .legendary,
            isUnlocked: false,
            bonusType: .passiveIncomeBoost(0.60),
            loreDescription: "Yeryüzü henüz oluşurken çarpan ve çekirdeğinde dünyada bilinmeyen kozmik güçler barındıran göktaşı.",
            setId: "set_cosmic"
        )
    ]
}
