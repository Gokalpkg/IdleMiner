import Foundation

// MARK: - Tüccar Para Birimi
enum MerchantCurrency: String, Codable {
    case gold
    case gems
}

// MARK: - Kara Borsa Eşya Türleri
enum MerchantItemType: String, Codable {
    case contrabandDynamite  // 5 dakikalık anlık pasif altın patlaması
    case midasElixir         // 60 sn boyunca 3x Tıklama Gücü
    case turboTonic          // 90 sn boyunca 2.5x Madenci Hızı & Pasif Gelir
    case forbiddenRelic      // Kilitli bir Antik Eseri anında açar (veya 25 Elmas)
    case shadowDiamondBuy    // Altın verip Elmas alma
    case shadowGoldExchange  // Elmas verip devasa Altın serveti alma
}

// MARK: - Tüccar Teklif Modeli
struct MerchantOffer: Identifiable, Codable {
    let id: String
    let itemType: MerchantItemType
    let title: String
    let description: String
    let icon: String
    let currency: MerchantCurrency
    let cost: Double
    var isPurchased: Bool = false
    
    // Rastgele 3 eşsiz teklif oluşturucu
    static func generateOffers(passiveIncome: Double, clickPower: Double, depth: Double) -> [MerchantOffer] {
        var offers: [MerchantOffer] = []
        
        // 1. Kaçak Dinamit Paketi (Altın ile satılır)
        let dynamiteCost = max(300.0, passiveIncome * 120.0 + clickPower * 50.0)
        offers.append(
            MerchantOffer(
                id: "offer_dynamite_\(UUID().uuidString.prefix(6))",
                itemType: .contrabandDynamite,
                title: "Kaçak Dinamit Demeti",
                description: "Mağarayı patlatıp anında 5 dakikalık devasa maden kazancı fışkırtır!",
                icon: "flame.fill",
                currency: .gold,
                cost: dynamiteCost
            )
        )
        
        // 2. İksir (Midas veya Turbo)
        if Bool.random() {
            offers.append(
                MerchantOffer(
                    id: "offer_midas_\(UUID().uuidString.prefix(6))",
                    itemType: .midasElixir,
                    title: "Karanlık Midas İksiri",
                    description: "60 saniye boyunca her maden vuruşun 3× Altın üretir.",
                    icon: "sparkles",
                    currency: .gems,
                    cost: 5
                )
            )
        } else {
            offers.append(
                MerchantOffer(
                    id: "offer_turbo_\(UUID().uuidString.prefix(6))",
                    itemType: .turboTonic,
                    title: "Yeraltı Turbo Şurubu",
                    description: "90 saniye boyunca madenciler ve vagonlar 2.5× daha hızlı çalışır!",
                    icon: "bolt.fill",
                    currency: .gems,
                    cost: 4
                )
            )
        }
        
        // 3. Özel Takas (Antik Eser veya Elmas/Altın Borsası)
        let choice = Int.random(in: 0...2)
        if choice == 0 {
            offers.append(
                MerchantOffer(
                    id: "offer_relic_\(UUID().uuidString.prefix(6))",
                    itemType: .forbiddenRelic,
                    title: "Kayıp Antika Parşömeni",
                    description: "Müzede henüz keşfedilmemiş gizli bir Antik Eseri anında açar.",
                    icon: "scroll.fill",
                    currency: .gems,
                    cost: 12
                )
            )
        } else if choice == 1 {
            let diamondBuyCost = max(800.0, passiveIncome * 200.0 + clickPower * 80.0)
            offers.append(
                MerchantOffer(
                    id: "offer_gems_\(UUID().uuidString.prefix(6))",
                    itemType: .shadowDiamondBuy,
                    title: "Kara Borsa Elmas Paketi",
                    description: "Altın karşılığında gizlice 6 parlak Elmas satın al.",
                    icon: "suit.diamond.fill",
                    currency: .gold,
                    cost: diamondBuyCost
                )
            )
        } else {
            offers.append(
                MerchantOffer(
                    id: "offer_gold_\(UUID().uuidString.prefix(6))",
                    itemType: .shadowGoldExchange,
                    title: "Gölge Hazine Sandığı",
                    description: "4 Elmas vererek anında 10 dakikalık servet dolu altın sandığı al.",
                    icon: "shippingbox.fill",
                    currency: .gems,
                    cost: 4
                )
            )
        }
        
        return offers
    }
}
