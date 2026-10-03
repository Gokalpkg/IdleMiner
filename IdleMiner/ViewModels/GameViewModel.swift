import SwiftUI
import Combine

// MARK: - Uçan Şans Sandığı Modeli
struct LuckyChest: Identifiable {
    let id = UUID()
    var xOffset: CGFloat
    var yOffset: CGFloat
    var durationRemaining: Double = 12.0
}

// MARK: - Beklenmedik Mağara Olayı: Altın Köstebeği Modeli
struct GoldenMole: Identifiable {
    let id = UUID()
    var xOffset: CGFloat
    var yOffset: CGFloat
    var hitsRemaining: Int = 3
    var durationRemaining: Double = 6.0
}

// MARK: - Çevrimdışı Ödül Modeli
struct OfflineReward: Identifiable {
    let id = UUID()
    let elapsedSeconds: Double
    let amount: Double
    
    var formattedDuration: String {
        let totalSeconds = Int(elapsedSeconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours) saat \(minutes) dakika"
        } else if minutes > 0 {
            return "\(minutes) dakika \(seconds) saniye"
        } else {
            return "\(seconds) saniye"
        }
    }
}

// MARK: - Kayıt Veri Modeli
struct GameSaveData: Codable {
    var gold: Double
    var totalGoldMined: Double
    var totalClicks: Int
    var prestigeMultiplier: Double
    var prestigeLevel: Int
    var depth: Double
    var gems: Int
    var lastSavedTimestamp: TimeInterval
    var upgrades: [Upgrade]
    var specialBuffs: [SpecialBuff]
    var quests: [GameQuest]
    var artifacts: [Artifact]?
    var currentWorldId: String?
    var comboProgress: Double?
    var shafts: [MineShaft]?
    var elevatorLevel: Int?
}

@MainActor
final class GameViewModel: ObservableObject {
    // MARK: - Temel Durum Değişkenleri
    @Published var gold: Double = 0
    @Published var clickPower: Double = 1
    @Published var passiveIncome: Double = 0
    @Published var totalGoldMined: Double = 0
    @Published var totalClicks: Int = 0
    
    // MARK: - 3. Mekanik: Dünya Haritası ve Gezegenler
    @Published var currentWorldId: String = "world_eldorado"
    @Published var showWorldMapModal: Bool = false
    
    var currentWorld: MineWorld {
        MineWorld.allWorlds.first(where: { $0.id == currentWorldId }) ?? MineWorld.allWorlds[0]
    }
    
    // MARK: - 4. Mekanik: Telsiz & Madenci Diyalogları
    @Published var activeRadioMessage: MinerRadioMessage? = nil
    private var radioCooldown: Double = 12.0 // Her 12-25 saniyede bir telsiz anonsu
    
    // MARK: - Maden Derinliği ve Cevher Evrimi
    @Published var depth: Double = 0
    
    var currentOreLayer: OreLayer {
        OreLayer.currentLayer(for: depth)
    }
    
    // MARK: - Antik Eserler & Fosil Müzesi
    @Published var artifacts: [Artifact] = Artifact.defaultArtifacts
    @Published var newlyDiscoveredArtifact: Artifact? = nil
    private var passiveDropAccumulator: Double = 0.0
    
    // MARK: - Elmas Para Birimi & Özel Güçlendirmeler
    @Published var gems: Int = 0
    @Published var specialBuffs: [SpecialBuff] = [
        SpecialBuff(
            id: "buff_pickaxe",
            name: "Elmas Kazma Ucu",
            icon: "hammer.circle.fill",
            description: "Kalıcı +%40 Tıklama Gücü",
            gemCost: 15,
            isPurchased: false,
            clickMultiplierBonus: 1.4,
            passiveMultiplierBonus: 1.0
        ),
        SpecialBuff(
            id: "buff_magnet",
            name: "Manyetik Cevher Çekici",
            icon: "bolt.circle.fill",
            description: "Kalıcı +%35 Pasif Maden Geliri",
            gemCost: 18,
            isPurchased: false,
            clickMultiplierBonus: 1.0,
            passiveMultiplierBonus: 1.35
        ),
        SpecialBuff(
            id: "buff_drill_overclock",
            name: "Titanyum Matkap Çarkı",
            icon: "gearshape.2.fill",
            description: "Kalıcı +%35 Tıklama ve +%35 Pasif Gelir",
            gemCost: 28,
            isPurchased: false,
            clickMultiplierBonus: 1.35,
            passiveMultiplierBonus: 1.35
        ),
        SpecialBuff(
            id: "buff_lucky_charm",
            name: "Uğurlu Mağara Tılsımı",
            icon: "sparkles",
            description: "Şans sandıklarının geliş sıklığını ve süresini artırır",
            gemCost: 32,
            isPurchased: false,
            clickMultiplierBonus: 1.15,
            passiveMultiplierBonus: 1.15
        ),
        SpecialBuff(
            id: "buff_prestige_booster",
            name: "Yatırımcı Güveni",
            icon: "crown.fill",
            description: "Tüm kazancı kalıcı olarak %50 artırır",
            gemCost: 45,
            isPurchased: false,
            clickMultiplierBonus: 1.5,
            passiveMultiplierBonus: 1.5
        ),
        SpecialBuff(
            id: "buff_dark_matter",
            name: "Karanlık Madde Reaktörü",
            icon: "flame.circle.fill",
            description: "Kalıcı +%60 Tıklama ve Çılgınlık Modu çarpanı",
            gemCost: 60,
            isPurchased: false,
            clickMultiplierBonus: 1.6,
            passiveMultiplierBonus: 1.2
        ),
        SpecialBuff(
            id: "buff_ancient_resonance",
            name: "Antik Yeraltı Rezonansı",
            icon: "sparkles.rectangle.stack.fill",
            description: "Müze ve maden uyumu: Kalıcı 1.8× Tıklama Gücü",
            gemCost: 75,
            isPurchased: false,
            clickMultiplierBonus: 1.8,
            passiveMultiplierBonus: 1.0
        ),
        SpecialBuff(
            id: "buff_celestial_core",
            name: "Kozmik Maden Çekirdeği",
            icon: "globe.americas.fill",
            description: "Yeraltının kalbi: Kalıcı 1.75× Pasif Gelir ve Tıklama",
            gemCost: 100,
            isPurchased: false,
            clickMultiplierBonus: 1.75,
            passiveMultiplierBonus: 1.75
        )
    ]
    
    // MARK: - Görev & Başarım Sistemi (Kıymetli ve Motive Edici Elmas Ödülleri)
    @Published var quests: [GameQuest] = [
        GameQuest(id: "q_clicks_300", title: "İlk Kazma Vuruşları", description: "300 kez madene tıkla", targetValue: 300, type: .clicks, gemReward: 2),
        GameQuest(id: "q_depth_250", title: "Bakır Damarına Ulaş", description: "250 metre derinliğe in", targetValue: 250, type: .depth, gemReward: 2),
        GameQuest(id: "q_gold_100k", title: "Küçük Maden Sahibi", description: "Toplam 100.000 Altın topla", targetValue: 100000, type: .totalGold, gemReward: 3),
        GameQuest(id: "q_clicks_1000", title: "Yorulmak Bilmeyen Kol", description: "1.000 kez madene tıkla", targetValue: 1000, type: .clicks, gemReward: 3),
        GameQuest(id: "q_shafts_2", title: "Şaft Genişletme", description: "En az 2 maden şaftının kilidini aç", targetValue: 2, type: .shafts, gemReward: 3),
        GameQuest(id: "q_depth_750", title: "Demir Çağı", description: "750 metre derinliğe in", targetValue: 750, type: .depth, gemReward: 4),
        GameQuest(id: "q_gold_1m", title: "Altın Zengini", description: "Toplam 1.000.000 Altın madenciliği yap", targetValue: 1000000, type: .totalGold, gemReward: 4),
        GameQuest(id: "q_clicks_3000", title: "Usta Madenci", description: "3.000 kez madene tıkla", targetValue: 3000, type: .clicks, gemReward: 5),
        GameQuest(id: "q_shafts_3", title: "Büyük Şantiye", description: "En az 3 maden şaftının kilidini aç", targetValue: 3, type: .shafts, gemReward: 5),
        GameQuest(id: "q_artifact_1", title: "İlk Antika Kaşifi", description: "Müzede 1 antik eseri tamamen birleştir", targetValue: 1, type: .artifacts, gemReward: 5),
        GameQuest(id: "q_depth_2000", title: "Karanlık Çukurlar", description: "2.000 metre derinliğe ulaş", targetValue: 2000, type: .depth, gemReward: 6),
        GameQuest(id: "q_gold_10m", title: "Maden Baronu", description: "Toplam 10.000.000 Altın madenciliği yap", targetValue: 10000000, type: .totalGold, gemReward: 7),
        GameQuest(id: "q_prestige_1", title: "Büyük Holding", description: "İlk maden devrini (Rebirth) gerçekleştir", targetValue: 1, type: .prestige, gemReward: 8),
        GameQuest(id: "q_clicks_10000", title: "Efsanevi Kazıcı", description: "10.000 kez madene tıkla", targetValue: 10000, type: .clicks, gemReward: 8),
        GameQuest(id: "q_artifacts_3", title: "Büyük Koleksiyoner", description: "Müzede 3 antik eseri tamamen tamamla", targetValue: 3, type: .artifacts, gemReward: 10)
    ]
    
    // MARK: - Uçan Şans Sandığı & Çılgınlık Modu (Frenzy) & Alevli Kombo Barı
    @Published var luckyChest: LuckyChest?
    @Published var isFrenzyActive: Bool = false
    @Published var frenzyTimeRemaining: Double = 0.0
    @Published var bannerNotification: String?
    private var chestSpawnCooldown: Double = 50.0 // Daha dengeli sandık süresi
    
    // Alevli Kombo Barı (Her seri tıkta artar, tıklanmadıkça yavaşça söner)
    @Published var comboProgress: Double = 0.0 // 0.0 - 1.0 aralığı
    private var comboDecayTimer: Double = 0.0
    
    // MARK: - Cevher Çatlama Mekaniği (Ore Cracking)
    @Published var oreCrackRatio: Double = 0.0 // 0.0: pürüzsüz, 1.0: sonuna kadar çatlamış
    @Published var didOreShatter: Bool = false
    private var crackResetWorkItem: DispatchWorkItem?
    
    // MARK: - Beklenmedik Mağara Olayı: Altın Köstebeği
    @Published var goldenMole: GoldenMole?
    private var moleSpawnCooldown: Double = 55.0 // Nadir çıksın (~55-80s)
    
    // MARK: - Gizemli Gezgin Tüccar (Kara Borsa - 2 Dakika Süre & Nadir Geliş)
    @Published var isMerchantActive: Bool = false
    @Published var merchantTimeRemaining: Double = 120.0 // 2 dakika (120 saniye)
    @Published var merchantOffers: [MerchantOffer] = []
    @Published var showMerchantModal: Bool = false
    private var merchantCooldown: Double = 180.0 // Nadir geliş: 180 - 300 saniye (3 - 5 dakika)
    @Published var merchantMidasTimeRemaining: Double = 0.0 // 3x tık gücü
    @Published var merchantTurboTimeRemaining: Double = 0.0 // 2.5x hız & pasif
    
    // MARK: - 10. Mekanik: Dikey Asansör Kuyusu & Maden Şaftları
    @Published var shafts: [MineShaft] = MineShaft.defaultShafts
    @Published var elevatorLevel: Int = 1
    
    // MARK: - Prestij (Rebirth) Değişkenleri
    @Published var prestigeLevel: Int = 0
    @Published var prestigeMultiplier: Double = 1.0
    @Published var showPrestigeModal: Bool = false
    
    var prestigeCost: Double {
        return 50000.0 * pow(3.0, Double(prestigeLevel))
    }
    
    var canPrestige: Bool {
        return gold >= prestigeCost
    }
    
    // MARK: - Karşılama Pop-up'ı Durumu
    @Published var offlineReward: OfflineReward?
    @Published var showOfflineModal: Bool = false
    
    // MARK: - Yükseltmeler
    @Published var upgrades: [Upgrade] = [
        Upgrade(
            id: "stone_pickaxe",
            name: "Taş Kazma",
            icon: "hammer.fill",
            description: "Her vuruşta ekstra +1 Altın",
            type: .clickPower,
            level: 0,
            baseCost: 15,
            baseEffect: 1,
            costMultiplier: 1.15
        ),
        Upgrade(
            id: "miner_apprentice",
            name: "Çırak Madenci",
            icon: "person.fill",
            description: "Saniyede +1 pasif Altın üretir",
            type: .passiveIncome,
            level: 0,
            baseCost: 50,
            baseEffect: 1,
            costMultiplier: 1.15
        ),
        Upgrade(
            id: "iron_pickaxe",
            name: "Demir Kazma",
            icon: "bolt.fill",
            description: "Her vuruşta ekstra +5 Altın",
            type: .clickPower,
            level: 0,
            baseCost: 250,
            baseEffect: 5,
            costMultiplier: 1.15
        ),
        Upgrade(
            id: "mine_cart",
            name: "Maden Vagonu",
            icon: "cart.fill",
            description: "Saniyede +8 pasif Altın taşır",
            type: .passiveIncome,
            level: 0,
            baseCost: 1000,
            baseEffect: 8,
            costMultiplier: 1.15
        ),
        Upgrade(
            id: "dynamite_expert",
            name: "Dinamit Uzmanı",
            icon: "flame.fill",
            description: "Saniyede +35 pasif Altın patlatır",
            type: .passiveIncome,
            level: 0,
            baseCost: 5000,
            baseEffect: 35,
            costMultiplier: 1.15
        ),
        Upgrade(
            id: "steam_drill",
            name: "Buharlı Matkap",
            icon: "gearshape.2.fill",
            description: "Saniyede +150 pasif Altın deler",
            type: .passiveIncome,
            level: 0,
            baseCost: 25000,
            baseEffect: 150,
            costMultiplier: 1.15
        )
    ]
    
    // MARK: - Zamanlayıcı (Timer)
    private var timer: AnyCancellable?
    private let tickInterval: Double = 0.1
    private var autoSaveCounter: Int = 0
    private let saveKey = "IdleMiner_SaveData_v4"
    
    init() {
        loadGame()
        recalculateStats()
        checkOfflineProgress()
        startPassiveTimer()
    }
    
    // MARK: - Müze Eser Çarpanları & Set Sinerjileri (Synergy)
    /// Açılmış olan tüm eserlerin ve tamamlanan setlerin bonuslarını toplayıp ana oyundaki üretim formülüne ekler.
    func calculateMuseumMultipliers() -> (clickBoost: Double, passiveBoost: Double, dropRateBoost: Double, setSynergyBoost: Double) {
        var clickBoost: Double = 0.0
        var passiveBoost: Double = 0.0
        var dropRateBoost: Double = 0.0
        var setSynergyBoost: Double = 0.0
        
        for artifact in artifacts where artifact.isUnlocked {
            switch artifact.bonusType {
            case .clickPowerBoost(let value):
                clickBoost += value
            case .passiveIncomeBoost(let value):
                passiveBoost += value
            case .rareDropRateBoost(let value):
                dropRateBoost += value
            }
        }
        
        // Tamamlanan Set Bonusları (Örn: Dinozor Çağı Seti: T-Rex + Fosil Diş -> +%25 Kalıcı Tüm Gezegen Kazancı)
        for aSet in ArtifactSet.allSets {
            let isComplete = aSet.requiredArtifactNames.allSatisfy { name in
                artifacts.contains { $0.name == name && $0.isUnlocked }
            }
            if isComplete {
                setSynergyBoost += aSet.globalMultiplierBonus
            }
        }
        
        return (clickBoost: clickBoost, passiveBoost: passiveBoost, dropRateBoost: dropRateBoost, setSynergyBoost: setSynergyBoost)
    }
    
    // Toplam çarpanlar (Katman Çarpanı * Gezegen Çarpanı * Prestij Çarpanı * Çılgınlık Modu * Elmas Buffları * Müze Eserleri & Set Sinerjileri)
    var effectiveClickPower: Double {
        var multiplier = prestigeMultiplier * currentOreLayer.bonusMultiplier * currentWorld.globalMultiplier
        if isFrenzyActive { multiplier *= 5.0 } // Çılgınlık Modu 5x kazanç
        if merchantMidasTimeRemaining > 0 { multiplier *= 3.0 } // Midas İksiri 3x kazanç
        
        for buff in specialBuffs where buff.isPurchased {
            multiplier *= buff.clickMultiplierBonus
        }
        
        // Müze Tıklama Bonusu & Set Sinerjisi
        let museum = calculateMuseumMultipliers()
        multiplier *= (1.0 + museum.clickBoost + museum.setSynergyBoost)
        
        return clickPower * multiplier
    }
    
    // Maden Şaftları ve Asansör Toplam Pasif Geliri
    var shaftPassiveIncome: Double {
        let baseTotal = shafts.filter { $0.isUnlocked }.reduce(0.0) { $0 + $1.currentIncomePerSec }
        let elevatorMultiplier = 1.0 + Double(elevatorLevel - 1) * 0.25
        return baseTotal * elevatorMultiplier
    }
    
    var effectivePassiveIncome: Double {
        var multiplier = prestigeMultiplier * currentOreLayer.bonusMultiplier * currentWorld.globalMultiplier
        if isFrenzyActive { multiplier *= 5.0 } // Çılgınlık Modu 5x kazanç
        if merchantTurboTimeRemaining > 0 { multiplier *= 2.5 } // Turbo Şurup 2.5x kazanç
        
        for buff in specialBuffs where buff.isPurchased {
            multiplier *= buff.passiveMultiplierBonus
        }
        
        // Müze Pasif Gelir Bonusu & Set Sinerjisi
        let museum = calculateMuseumMultipliers()
        multiplier *= (1.0 + museum.passiveBoost + museum.setSynergyBoost)
        
        return (passiveIncome + shaftPassiveIncome) * multiplier
    }
    
    var minerApprenticeLevel: Int {
        upgrades.first(where: { $0.id == "miner_apprentice" })?.level ?? 0
    }
    
    var mineCartLevel: Int {
        upgrades.first(where: { $0.id == "mine_cart" })?.level ?? 0
    }
    
    var dynamiteExpertLevel: Int {
        upgrades.first(where: { $0.id == "dynamite_expert" })?.level ?? 0
    }
    
    var steamDrillLevel: Int {
        upgrades.first(where: { $0.id == "steam_drill" })?.level ?? 0
    }
    
    // MARK: - İşçiye Dokunma (Easter Egg)
    func triggerWorkerEasterEgg(workerName: String) -> Double {
        let bonus = max(effectiveClickPower * 0.5, 10.0)
        gold += bonus
        totalGoldMined += bonus
        
        AudioManager.shared.triggerImpact(style: .medium)
        AudioManager.shared.playUpgradeSound()
        showBanner("🎉 \(workerName) zıpladı! +\(BigNumberFormatter.format(bonus)) Altın!")
        return bonus
    }
    
    // MARK: - Gezegen / Maden Seyahati
    func travelToWorld(_ world: MineWorld) {
        currentWorldId = world.id
        showWorldMapModal = false
        showBanner("🚀 \(world.name) Madenine İniş Yapıldı! (\(Int(world.globalMultiplier))x)")
        AudioManager.shared.playCelebrationSound()
        AudioManager.shared.triggerNotification(type: .success)
        saveGame()
    }
    
    // MARK: - Eser ve Parça Düşme (Drop) Mantığı
    /// Oyuncu madene tıkladığında veya saniyelik pasif kazanç sağlandığında arka planda çalışır.
    /// Eser parçalarının düşmesi çok nadir, heyecan verici ve kıymetli bir andır.
    func checkArtifactDrop(isPassive: Bool = false) {
        // Zaten ekranda bekleyen keşif modalı varsa yeni bir tane tetikleme
        guard newlyDiscoveredArtifact == nil else { return }
        
        let incompleteIndices = artifacts.indices.filter { !artifacts[$0].isUnlocked }
        guard !incompleteIndices.isEmpty else { return }
        
        // Eserlerden gelen ek drop oranı bonusu (Örn: +%2 -> rareDropRateBoost)
        let museum = calculateMuseumMultipliers()
        let dropRateMultiplier = 1.0 + museum.dropRateBoost
        
        // Pasif kazanç kontrolünde tıklamaya göre daha seyrek şans (tıklamada %0.08, pasifte %0.02 temel şans)
        let baseDropRollChance = isPassive ? 0.0002 : 0.0008
        let finalDropChance = baseDropRollChance * dropRateMultiplier
        
        guard Double.random(in: 0.0...1.0) < finalDropChance else { return }
        
        // Şans başarılı oldu, şimdi tamamlanmamış eserler arasından ağırlıklı seçim yap:
        // Ağırlıklar: Common: 60, Rare: 25, Epic: 12, Legendary: 3
        var weightedPool: [Int] = []
        for index in incompleteIndices {
            let weight: Int
            switch artifacts[index].rarity {
            case .common: weight = 60
            case .rare: weight = 25
            case .epic: weight = 12
            case .legendary: weight = 3
            }
            weightedPool.append(contentsOf: Array(repeating: index, count: weight))
        }
        
        guard let chosenIndex = weightedPool.randomElement() else { return }
        
        // Parça Düştü!
        artifacts[chosenIndex].collectedFragments += 1
        if artifacts[chosenIndex].collectedFragments >= artifacts[chosenIndex].totalFragments {
            artifacts[chosenIndex].isUnlocked = true
            AudioManager.shared.playCelebrationSound()
            AudioManager.shared.triggerNotification(type: .success)
        } else {
            AudioManager.shared.playUpgradeSound()
            AudioManager.shared.triggerNotification(type: .warning)
        }
        
        newlyDiscoveredArtifact = artifacts[chosenIndex]
        saveGame()
    }
    
    // MARK: - Vuruş Sonucu Modeli
    struct StrikeResult {
        let isCritical: Bool
        let amountEarned: Double
        let didShatterOre: Bool
    }
    
    // MARK: - Ana Tıklama Mekaniği, Nadir Kritik Vuruş (%0.8) & SFX & Cevher Canı/Çatlama
    @discardableResult
    func mineGold() -> StrikeResult {
        // Çok Nadir Kritik Vuruş Şansı Kontrolü (%0.8)
        let roll = Double.random(in: 0.0...1.0)
        let isCritical = roll < 0.008
        
        // Kritik vuruş normal sayı yerine 10x altın verir!
        let baseEarned = effectiveClickPower
        let earned = isCritical ? (baseEarned * 10.0) : baseEarned
        
        gold += earned
        totalGoldMined += earned
        totalClicks += 1
        depth += 1.0
        
        // Çatlama İlerlemesi: Bastıkça ufak çatlak oluşur, sonuna gelince öylece kalır, 3 sn sonra geri döner
        crackResetWorkItem?.cancel()
        
        let crackIncrement: Double = isCritical ? 0.045 : 0.022
        withAnimation(.easeOut(duration: 0.12)) {
            self.oreCrackRatio = min(1.0, self.oreCrackRatio + crackIncrement)
        }
        
        let resetItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            withAnimation(.easeInOut(duration: 0.8)) {
                self.oreCrackRatio = 0.0
            }
        }
        crackResetWorkItem = resetItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: resetItem)
        
        let didShatter = false
        
        // Enerji / Kombo Barını Doldur (10-15 dakika gerçek oynanışta dolacak şekilde ayarlandı)
        if !isFrenzyActive {
            // ~2500 vuruş (ortalama 10-15 dakika aktif oynanış)
            let increment = isCritical ? 0.0008 : 0.0004
            comboProgress = min(comboProgress + increment, 1.0)
            
            if comboProgress >= 1.0 {
                isFrenzyActive = true
                frenzyTimeRemaining = 8.0 // Tam 8 saniye sürer ve biter
                comboProgress = 0.0
                showBanner("🔥 ENERJİ DOLDU! 5X ÇILGINLIK MODU AKTİF! (8s)")
                AudioManager.shared.playCelebrationSound()
                AudioManager.shared.triggerNotification(type: .success)
            }
        }
        
        // Eser düşme kontrolü
        checkArtifactDrop(isPassive: false)
        
        // Haptik & Ses:
        if isCritical {
            // Sadece nadir kritik vuruşlarda güçlü haptik titreşim verilir
            AudioManager.shared.triggerImpact(style: .heavy)
            AudioManager.shared.playCriticalHitSound()
        } else {
            // Normal tıklamalarda titreşim yok, sadece ses efekti var (aşırı titreşimi önlemek için)
            AudioManager.shared.playOreHitSound(for: currentOreLayer.name)
        }
        
        return StrikeResult(isCritical: isCritical, amountEarned: earned, didShatterOre: didShatter)
    }
    
    func claimNewlyDiscoveredArtifact() {
        guard let artifact = newlyDiscoveredArtifact else { return }
        newlyDiscoveredArtifact = nil
        
        if artifact.isUnlocked {
            AudioManager.shared.triggerNotification(type: .success)
            AudioManager.shared.playCelebrationSound()
        } else {
            AudioManager.shared.triggerImpact(style: .medium)
            AudioManager.shared.playUpgradeSound()
        }
        saveGame()
    }
    
    // MARK: - Pasif Gelir & Telsiz & Şans Sandığı Döngüsü
    private func startPassiveTimer() {
        timer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // Pasif Gelir
                if self.effectivePassiveIncome > 0 {
                    let earned = self.effectivePassiveIncome * self.tickInterval
                    self.gold += earned
                    self.totalGoldMined += earned
                    self.depth += (self.passiveIncome * 0.05) * self.tickInterval
                    
                    // Saniyelik pasif kazanç sağlandığında eser düşme zar kontrolü (her 1 saniyede bir)
                    self.passiveDropAccumulator += self.tickInterval
                    if self.passiveDropAccumulator >= 1.0 {
                        self.passiveDropAccumulator = 0
                        self.checkArtifactDrop(isPassive: true)
                    }
                }
                
                // Enerji Barı Pasif Katkı (10-15 dakikada dolumu destekler, oyuncunun emeğini silmez)
                if !self.isFrenzyActive && self.comboProgress < 1.0 {
                    self.comboProgress = min(self.comboProgress + (0.00004 * self.tickInterval), 1.0)
                    if self.comboProgress >= 1.0 {
                        self.isFrenzyActive = true
                        self.frenzyTimeRemaining = 8.0 // 8 saniye
                        self.comboProgress = 0.0
                        self.showBanner("🔥 ENERJİ DOLDU! 5X ÇILGINLIK MODU AKTİF! (8s)")
                        AudioManager.shared.playCelebrationSound()
                        AudioManager.shared.triggerNotification(type: .success)
                    }
                }
                
                // Çılgınlık Modu Geri Sayımı
                if self.isFrenzyActive {
                    self.frenzyTimeRemaining -= self.tickInterval
                    if self.frenzyTimeRemaining <= 0 {
                        self.isFrenzyActive = false
                    }
                }
                
                // Tüccar İksir Süreleri
                if self.merchantMidasTimeRemaining > 0 {
                    self.merchantMidasTimeRemaining = max(0, self.merchantMidasTimeRemaining - self.tickInterval)
                }
                if self.merchantTurboTimeRemaining > 0 {
                    self.merchantTurboTimeRemaining = max(0, self.merchantTurboTimeRemaining - self.tickInterval)
                }
                
                // Gizemli Gezgin Tüccar Doğuş & Kalan Süre Döngüsü
                if self.isMerchantActive {
                    self.merchantTimeRemaining -= self.tickInterval
                    if self.merchantTimeRemaining <= 0 {
                        self.isMerchantActive = false
                        self.showMerchantModal = false
                        self.merchantOffers = []
                        self.merchantCooldown = Double.random(in: 180.0...300.0) // 3-5 dakika nadir geliş
                        self.showBanner("Tüccar tünellerin karanlığına karıştı...")
                    }
                } else {
                    self.merchantCooldown -= self.tickInterval
                    if self.merchantCooldown <= 0 {
                        self.spawnMerchant()
                    }
                }
                
                // Uçan Sandık Spawn Kontrolü
                if self.luckyChest == nil {
                    self.chestSpawnCooldown -= self.tickInterval
                    if self.chestSpawnCooldown <= 0 {
                        self.spawnLuckyChest()
                        self.chestSpawnCooldown = Double.random(in: 25.0...40.0)
                    }
                } else {
                    if var chest = self.luckyChest {
                        chest.durationRemaining -= self.tickInterval
                        if chest.durationRemaining <= 0 {
                            self.luckyChest = nil
                        } else {
                            self.luckyChest = chest
                        }
                    }
                }
                
                // Altın Köstebeği Spawn & Geri Sayım Kontrolü
                if self.goldenMole == nil {
                    self.moleSpawnCooldown -= self.tickInterval
                    if self.moleSpawnCooldown <= 0 {
                        self.spawnGoldenMole()
                        self.moleSpawnCooldown = Double.random(in: 45.0...70.0)
                    }
                } else {
                    if var mole = self.goldenMole {
                        mole.durationRemaining -= self.tickInterval
                        if mole.durationRemaining <= 0 {
                            self.goldenMole = nil
                        } else {
                            self.goldenMole = mole
                        }
                    }
                }
                
                // 10 saniyede bir oto-kayıt
                self.autoSaveCounter += 1
                if self.autoSaveCounter >= 100 {
                    self.autoSaveCounter = 0
                    self.saveGame()
                }
            }
    }
    
    func dismissRadioMessage() {
        activeRadioMessage = nil
    }
    
    // MARK: - Altın Köstebeği (Quick-Time Event)
    private func spawnGoldenMole() {
        let randomX = CGFloat.random(in: -110...110)
        let randomY = CGFloat.random(in: -90...130)
        goldenMole = GoldenMole(xOffset: randomX, yOffset: randomY, hitsRemaining: 3, durationRemaining: 6.0)
    }
    
    func tapGoldenMole() {
        guard var mole = goldenMole else { return }
        mole.hitsRemaining -= 1
        
        AudioManager.shared.triggerImpact(style: .medium)
        AudioManager.shared.playCriticalHitSound()
        
        if mole.hitsRemaining <= 0 {
            goldenMole = nil
            gems += 1
            showBanner("🦔 YAKALANDI! Altın Köstebek'ten +1 Elmas!")
            AudioManager.shared.triggerNotification(type: .success)
            AudioManager.shared.playCelebrationSound()
            saveGame()
        } else {
            // Hızlıca kaçıp başka konuma zıplar
            mole.xOffset = CGFloat.random(in: -110...110)
            mole.yOffset = CGFloat.random(in: -90...130)
            goldenMole = mole
        }
    }
    
    // MARK: - Şans Sandığı
    private func spawnLuckyChest() {
        let randomX = CGFloat.random(in: -120...120)
        let randomY = CGFloat.random(in: -80...120)
        luckyChest = LuckyChest(xOffset: randomX, yOffset: randomY, durationRemaining: 12.0)
    }
    
    func openLuckyChest() {
        guard luckyChest != nil else { return }
        luckyChest = nil
        
        let rewardType = Int.random(in: 1...3)
        AudioManager.shared.playCelebrationSound()
        AudioManager.shared.triggerNotification(type: .success)
        
        switch rewardType {
        case 1:
            let frenzyDuration = 25.0
            isFrenzyActive = true
            frenzyTimeRemaining = frenzyDuration
            showBanner("🔥 7X ÇILGINLIK MODU AKTİF! (\(Int(frenzyDuration))s)")
        case 2:
            let bonusGold = max(effectivePassiveIncome * 60, effectiveClickPower * 80, 500)
            gold += bonusGold
            totalGoldMined += bonusGold
            showBanner("💰 ŞANSLI HAZİNE: +\(BigNumberFormatter.format(bonusGold)) Altın!")
        default:
            let gemReward = 1 // Dengeli ve kıymetli: her sandıktan 1 elmas
            gems += gemReward
            showBanner("💎 ŞANSLI KEŞİF: +\(gemReward) Elmas!")
        }
        
        saveGame()
    }
    
    // MARK: - Gizemli Gezgin Tüccar İşlemleri
    func spawnMerchant() {
        isMerchantActive = true
        merchantTimeRemaining = 120.0 // 2 dakika
        merchantOffers = MerchantOffer.generateOffers(
            passiveIncome: effectivePassiveIncome,
            clickPower: effectiveClickPower,
            depth: depth
        )
        merchantCooldown = Double.random(in: 180.0...300.0) // Nadir geliş (3 - 5 dakika)
        AudioManager.shared.playMerchantArrivalSound()
        AudioManager.shared.triggerNotification(type: .warning)
    }
    
    func purchaseMerchantOffer(offer: MerchantOffer) {
        guard !offer.isPurchased else { return }
        
        // Bakiye kontrolü
        switch offer.currency {
        case .gold:
            guard gold >= offer.cost else { return }
            gold -= offer.cost
        case .gems:
            guard Double(gems) >= offer.cost else { return }
            gems -= Int(offer.cost)
        }
        
        // Satın alındı olarak işaretle
        if let idx = merchantOffers.firstIndex(where: { $0.id == offer.id }) {
            merchantOffers[idx].isPurchased = true
        }
        
        // Eşya Etkisini Uygula
        switch offer.itemType {
        case .contrabandDynamite:
            let bonusGold = max(3000.0, (effectivePassiveIncome * 300.0) + (effectiveClickPower * 100.0))
            gold += bonusGold
            totalGoldMined += bonusGold
            AudioManager.shared.playCriticalHitSound()
            AudioManager.shared.triggerImpact(style: .heavy)
            
        case .midasElixir:
            merchantMidasTimeRemaining = 60.0
            AudioManager.shared.playMerchantPurchaseSound()
            AudioManager.shared.triggerImpact(style: .medium)
            
        case .turboTonic:
            merchantTurboTimeRemaining = 90.0
            AudioManager.shared.playMerchantPurchaseSound()
            AudioManager.shared.triggerImpact(style: .medium)
            
        case .forbiddenRelic:
            AudioManager.shared.playMerchantPurchaseSound()
            AudioManager.shared.triggerImpact(style: .heavy)
            if let lockedIndex = artifacts.firstIndex(where: { !$0.isUnlocked }) {
                artifacts[lockedIndex].collectedFragments += 1
                if artifacts[lockedIndex].collectedFragments >= artifacts[lockedIndex].totalFragments {
                    artifacts[lockedIndex].isUnlocked = true
                }
                newlyDiscoveredArtifact = artifacts[lockedIndex]
            } else {
                gems += 20
            }
            
        case .shadowDiamondBuy:
            gems += 3 // Dengelendi: 6 yerine 3 elmas
            AudioManager.shared.playMerchantPurchaseSound()
            AudioManager.shared.triggerImpact(style: .medium)
            
        case .shadowGoldExchange:
            let bonusGold = max(8000.0, (effectivePassiveIncome * 600.0) + (effectiveClickPower * 200.0))
            gold += bonusGold
            totalGoldMined += bonusGold
            AudioManager.shared.playMerchantPurchaseSound()
            AudioManager.shared.triggerImpact(style: .heavy)
        }
        
        saveGame()
    }
    
    // MARK: - Asansör ve Maden Şaftı İşlemleri
    var elevatorUpgradeCost: Double {
        return 500.0 * pow(1.5, Double(max(0, elevatorLevel - 1)))
    }
    
    var canUpgradeElevator: Bool {
        return gold >= elevatorUpgradeCost
    }
    
    func upgradeElevator() {
        guard canUpgradeElevator else { return }
        gold -= elevatorUpgradeCost
        elevatorLevel += 1
        AudioManager.shared.playUpgradeSound()
        AudioManager.shared.triggerImpact(style: .medium)
        saveGame()
    }
    
    func unlockShaft(id: Int) {
        guard let index = shafts.firstIndex(where: { $0.id == id }) else { return }
        guard !shafts[index].isUnlocked else { return }
        guard depth >= shafts[index].depthRequirement else { return }
        guard gold >= shafts[index].unlockCost else { return }
        
        gold -= shafts[index].unlockCost
        shafts[index].isUnlocked = true
        shafts[index].level = 1
        
        // Yeni kata ulaşılınca derinliği artır
        depth = max(depth, shafts[index].depthRequirement + 15.0)
        
        AudioManager.shared.playCelebrationSound()
        AudioManager.shared.triggerNotification(type: .success)
        saveGame()
    }
    
    func upgradeShaft(id: Int) {
        guard let index = shafts.firstIndex(where: { $0.id == id }) else { return }
        guard shafts[index].isUnlocked else { return }
        let cost = shafts[index].upgradeCost
        guard gold >= cost else { return }
        
        gold -= cost
        shafts[index].level += 1
        
        AudioManager.shared.playUpgradeSound()
        AudioManager.shared.triggerImpact(style: .light)
        saveGame()
    }
    
    private func showBanner(_ message: String) {
        // Kullanıcı isteği: Rahatsız edici bildirim balonları tamamen kapatıldı
        return
    }
    
    // MARK: - Elmas Dükkanı
    func buySpecialBuff(_ buff: SpecialBuff) {
        guard let index = specialBuffs.firstIndex(where: { $0.id == buff.id }) else { return }
        guard !specialBuffs[index].isPurchased else { return }
        guard gems >= specialBuffs[index].gemCost else { return }
        
        gems -= specialBuffs[index].gemCost
        specialBuffs[index].isPurchased = true
        recalculateStats()
        saveGame()
        
        AudioManager.shared.playCelebrationSound()
        AudioManager.shared.triggerNotification(type: .success)
    }
    
    // MARK: - Görev Ödülünü Toplama
    func claimQuestReward(_ quest: GameQuest) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        guard !quests[index].isClaimed else { return }
        
        let unlockedArtCount = artifacts.filter { $0.isUnlocked }.count
        let unlockedShaftsCount = shafts.filter { $0.isUnlocked }.count
        
        guard quests[index].isCompleted(
            currentClicks: totalClicks,
            currentDepth: depth,
            totalGold: totalGoldMined,
            prestigeLevel: prestigeLevel,
            unlockedArtifactsCount: unlockedArtCount,
            shaftsCount: unlockedShaftsCount
        ) else { return }
        
        quests[index].isClaimed = true
        gems += quests[index].gemReward
        saveGame()
        
        AudioManager.shared.playCelebrationSound()
        AudioManager.shared.triggerNotification(type: .success)
        showBanner("🏆 Görev Tamamlandı: +\(quests[index].gemReward) Elmas!")
    }
    
    // MARK: - Yükseltme Satın Alma
    func buyUpgrade(_ upgrade: Upgrade) {
        guard let index = upgrades.firstIndex(where: { $0.id == upgrade.id }) else { return }
        let currentCost = upgrades[index].cost
        
        guard gold >= currentCost else { return }
        
        gold -= currentCost
        upgrades[index].level += 1
        recalculateStats()
        saveGame()
        
        AudioManager.shared.playUpgradeSound()
    }
    
    // MARK: - Prestij (Rebirth) Mekaniği
    func performPrestige() {
        guard canPrestige else { return }
        
        gold = 0
        depth = 0
        for i in 0..<upgrades.count {
            upgrades[i].level = 0
        }
        
        prestigeLevel += 1
        prestigeMultiplier = pow(2.0, Double(prestigeLevel))
        gems += 10
        
        recalculateStats()
        saveGame()
        
        showPrestigeModal = false
        AudioManager.shared.playCelebrationSound()
        AudioManager.shared.triggerNotification(type: .success)
        showBanner("🚀 Maden Devredildi! +10 Elmas & 2x Kazanç!")
    }
    
    private func recalculateStats() {
        var newClickPower: Double = 1.0
        var newPassiveIncome: Double = 0.0
        
        for upgrade in upgrades {
            switch upgrade.type {
            case .clickPower:
                newClickPower += upgrade.totalEffect
            case .passiveIncome:
                newPassiveIncome += upgrade.totalEffect
            }
        }
        
        self.clickPower = newClickPower
        self.passiveIncome = newPassiveIncome
    }
    
    // MARK: - Kayıt & Yükleme
    func saveGame() {
        let saveData = GameSaveData(
            gold: gold,
            totalGoldMined: totalGoldMined,
            totalClicks: totalClicks,
            prestigeMultiplier: prestigeMultiplier,
            prestigeLevel: prestigeLevel,
            depth: depth,
            gems: gems,
            lastSavedTimestamp: Date().timeIntervalSince1970,
            upgrades: upgrades,
            specialBuffs: specialBuffs,
            quests: quests,
            artifacts: artifacts,
            currentWorldId: currentWorldId,
            comboProgress: comboProgress,
            shafts: shafts,
            elevatorLevel: elevatorLevel
        )
        
        if let encoded = try? JSONEncoder().encode(saveData) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func loadGame() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode(GameSaveData.self, from: data) else {
            return
        }
        
        self.gold = decoded.gold
        self.totalGoldMined = decoded.totalGoldMined
        self.totalClicks = decoded.totalClicks
        self.prestigeLevel = decoded.prestigeLevel
        self.prestigeMultiplier = max(decoded.prestigeMultiplier, 1.0)
        self.depth = decoded.depth
        self.gems = decoded.gems
        if let worldId = decoded.currentWorldId {
            self.currentWorldId = worldId
        }
        if let savedCombo = decoded.comboProgress {
            self.comboProgress = min(max(savedCombo, 0.0), 1.0)
        }
        if let savedShafts = decoded.shafts {
            self.shafts = savedShafts
        }
        if let savedElevator = decoded.elevatorLevel {
            self.elevatorLevel = savedElevator
        }
        
        for savedUpgrade in decoded.upgrades {
            if let index = self.upgrades.firstIndex(where: { $0.id == savedUpgrade.id }) {
                self.upgrades[index].level = savedUpgrade.level
            }
        }
        for savedBuff in decoded.specialBuffs {
            if let index = self.specialBuffs.firstIndex(where: { $0.id == savedBuff.id }) {
                self.specialBuffs[index].isPurchased = savedBuff.isPurchased
            }
        }
        for savedQuest in decoded.quests {
            if let index = self.quests.firstIndex(where: { $0.id == savedQuest.id }) {
                self.quests[index].isClaimed = savedQuest.isClaimed
            }
        }
        if let savedArtifacts = decoded.artifacts {
            for savedArt in savedArtifacts {
                if let index = self.artifacts.firstIndex(where: { $0.name == savedArt.name }) {
                    self.artifacts[index].totalFragments = savedArt.totalFragments
                    self.artifacts[index].collectedFragments = savedArt.collectedFragments
                    self.artifacts[index].isUnlocked = savedArt.isUnlocked
                }
            }
        }
    }
    
    func checkOfflineProgress() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode(GameSaveData.self, from: data) else {
            return
        }
        
        let now = Date().timeIntervalSince1970
        let elapsedSeconds = now - decoded.lastSavedTimestamp
        
        if elapsedSeconds >= 10 && self.effectivePassiveIncome > 0 {
            let cappedSeconds = min(elapsedSeconds, 86400)
            let earned = cappedSeconds * self.effectivePassiveIncome
            
            if earned > 0 {
                self.offlineReward = OfflineReward(elapsedSeconds: cappedSeconds, amount: earned)
                self.showOfflineModal = true
            }
        }
    }
    
    func claimOfflineReward() {
        guard let reward = offlineReward else { return }
        gold += reward.amount
        totalGoldMined += reward.amount
        offlineReward = nil
        showOfflineModal = false
        saveGame()
        
        AudioManager.shared.playUpgradeSound()
    }
    
    // MARK: - Tüm İlerlemeyi Sıfırla (Settings Menu)
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: saveKey)
        
        gold = 0
        depth = 0
        totalGoldMined = 0
        totalClicks = 0
        prestigeLevel = 0
        prestigeMultiplier = 1.0
        gems = 0
        currentWorldId = "world_eldorado"
        comboProgress = 0.0
        isFrenzyActive = false
        
        for i in 0..<upgrades.count {
            upgrades[i].level = 0
        }
        for i in 0..<specialBuffs.count {
            specialBuffs[i].isPurchased = false
        }
        for i in 0..<quests.count {
            quests[i].isClaimed = false
        }
        for i in 0..<artifacts.count {
            artifacts[i].isUnlocked = false
            artifacts[i].collectedFragments = 0
        }
        
        self.shafts = MineShaft.defaultShafts
        self.elevatorLevel = 1
        
        recalculateStats()
        AudioManager.shared.triggerNotification(type: .warning)
        showBanner("🔄 Tüm veriler sıfırlandı!")
    }
}
