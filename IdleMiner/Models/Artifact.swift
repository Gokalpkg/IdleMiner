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
    
    // Dengeli düşme olasılıkları (Efsaneviler çok daha nadir)
    var dropChance: Double {
        switch self {
        case .common: return 0.012     // %1.2
        case .rare: return 0.004       // %0.4
        case .epic: return 0.0012      // %0.12
        case .legendary: return 0.0003 // %0.03
        }
    }
    
    var defaultFragments: Int {
        switch self {
        case .legendary: return 3 // Efsaneviler 3 parçadan oluşur
        case .epic: return 2      // Epikler 2 parça
        case .rare: return 2      // Nadirler 2 parça
        case .common: return 1    // Sıradanlar 1 parça
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
            return "+%\(Int(round(value * 100))) Pasif Maden Geliri"
        case .clickPowerBoost(let value):
            return "+%\(Int(round(value * 100))) Tıklama Kazancı"
        case .rareDropRateBoost(let value):
            return "+%\(Int(round(value * 100))) Eser Bulma Şansı"
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
    let globalMultiplierBonus: Double
    
    static let allSets: [ArtifactSet] = [
        ArtifactSet(
            id: "set_dino",
            name: "Dinozor Çağı Seti",
            iconName: "tortoise.fill",
            description: "Milyonlarca yıllık tarih öncesi fosiller bir arada.",
            requiredArtifactNames: ["T-Rex Kafatası", "Fosil Diş"],
            setBonusText: "+%8 Kalıcı Tüm Gezegen Kazancı 🏆",
            globalMultiplierBonus: 0.08
        ),
        ArtifactSet(
            id: "set_relics",
            name: "Kadim Madenciler Seti",
            iconName: "wand.and.rays",
            description: "İlk kaşiflerin ve mitolojik ustaların yadigarları.",
            requiredArtifactNames: ["Antik Madenci Pusulası", "Kararmış Altın Kazma"],
            setBonusText: "+%10 Tıklama & Pasif Çarpanı 🏆",
            globalMultiplierBonus: 0.10
        ),
        ArtifactSet(
            id: "set_cosmic",
            name: "Kozmik Sırlar Seti",
            iconName: "atom",
            description: "Evrenin derinliklerinden gelen gizemli enerji kaynakları.",
            requiredArtifactNames: ["Parlayan Rün Taşı", "Meteorit Parçası"],
            setBonusText: "+%12 Kalıcı Maden Geliri 🏆",
            globalMultiplierBonus: 0.12
        )
    ]
}

// MARK: - 4. Artifact (Eser Modeli - Parçalı Sistem)
struct Artifact: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let iconName: String
    let rarity: Rarity
    var isUnlocked: Bool
    let bonusType: BonusType
    let loreDescription: String
    var setId: String? = nil
    var totalFragments: Int
    var collectedFragments: Int
    
    var perkText: String {
        bonusType.description
    }
    
    var isComplete: Bool {
        collectedFragments >= totalFragments
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, iconName, rarity, isUnlocked, bonusType, loreDescription, setId, totalFragments, collectedFragments
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        rarity: Rarity,
        isUnlocked: Bool = false,
        bonusType: BonusType,
        loreDescription: String,
        setId: String? = nil,
        totalFragments: Int? = nil,
        collectedFragments: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.rarity = rarity
        self.bonusType = bonusType
        self.loreDescription = loreDescription
        self.setId = setId
        
        let required = totalFragments ?? rarity.defaultFragments
        self.totalFragments = required
        self.collectedFragments = isUnlocked ? required : collectedFragments
        self.isUnlocked = self.collectedFragments >= self.totalFragments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.iconName = try container.decode(String.self, forKey: .iconName)
        self.rarity = try container.decode(Rarity.self, forKey: .rarity)
        let unlocked = try container.decodeIfPresent(Bool.self, forKey: .isUnlocked) ?? false
        self.bonusType = try container.decode(BonusType.self, forKey: .bonusType)
        self.loreDescription = try container.decode(String.self, forKey: .loreDescription)
        self.setId = try container.decodeIfPresent(String.self, forKey: .setId)
        
        let defaultFrag = self.rarity.defaultFragments
        self.totalFragments = try container.decodeIfPresent(Int.self, forKey: .totalFragments) ?? defaultFrag
        
        if let savedCollected = try container.decodeIfPresent(Int.self, forKey: .collectedFragments) {
            self.collectedFragments = savedCollected
            self.isUnlocked = self.collectedFragments >= self.totalFragments
        } else {
            self.collectedFragments = unlocked ? self.totalFragments : 0
            self.isUnlocked = unlocked
        }
    }
    
    static let defaultArtifacts: [Artifact] = [
        Artifact(
            name: "Antik Madenci Pusulası",
            iconName: "safari.fill",
            rarity: .common,
            isUnlocked: false,
            bonusType: .passiveIncomeBoost(0.03), // +%3 Pasif (Dengeli)
            loreDescription: "Eski çağ madencilerinin karanlık dehlizlerde yön ve damar tayini için pirinçten dövdüğü pusula.",
            setId: "set_relics",
            totalFragments: 1
        ),
        Artifact(
            name: "Fosil Diş",
            iconName: "mouth.fill",
            rarity: .common,
            isUnlocked: false,
            bonusType: .clickPowerBoost(0.04), // +%4 Tıklama (Dengeli)
            loreDescription: "Milyonlarca yıllık sert tortul kayalarda sıkışıp taşlaşmış sivri bir yırtıcı dişi.",
            setId: "set_dino",
            totalFragments: 1
        ),
        Artifact(
            name: "T-Rex Kafatası",
            iconName: "tortoise.fill",
            rarity: .rare,
            isUnlocked: false,
            bonusType: .rareDropRateBoost(0.02), // +%2 Eser Bulma Şansı
            loreDescription: "Kömür yataklarının alt katmanlarında neredeyse hiç hasar almadan korunmuş devasa kemik kalıntısı.",
            setId: "set_dino",
            totalFragments: 2 // 2 Parça
        ),
        Artifact(
            name: "Parlayan Rün Taşı",
            iconName: "sparkle",
            rarity: .rare,
            isUnlocked: false,
            bonusType: .passiveIncomeBoost(0.06), // +%6 Pasif (Dengeli)
            loreDescription: "Üzerine işlenen kadim simyacı sembolleri geceleri mor bir ışıltı yayarak madeni aydınlatır.",
            setId: "set_cosmic",
            totalFragments: 2 // 2 Parça
        ),
        Artifact(
            name: "Kararmış Altın Kazma",
            iconName: "wand.and.rays",
            rarity: .epic,
            isUnlocked: false,
            bonusType: .clickPowerBoost(0.10), // +%10 Tıklama (Dengeli)
            loreDescription: "Zamanla yüzeyi karararak sertleşmiş, vurduğu her taştan saf cevher çıkaran mitolojik bir kazma ucu.",
            setId: "set_relics",
            totalFragments: 2 // 2 Parça
        ),
        Artifact(
            name: "Meteorit Parçası",
            iconName: "atom",
            rarity: .legendary,
            isUnlocked: false,
            bonusType: .passiveIncomeBoost(0.15), // +%15 Pasif (Dengeli ve efsanevi)
            loreDescription: "Yeryüzü henüz oluşurken çarpan ve çekirdeğinde dünyada bilinmeyen kozmik güçler barındıran göktaşı.",
            setId: "set_cosmic",
            totalFragments: 3 // 3 Parça (Üçü toplanınca aktif!)
        )
    ]
}
