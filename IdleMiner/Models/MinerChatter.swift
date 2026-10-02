import Foundation

struct MinerRadioMessage: Identifiable {
    let id = UUID()
    let speaker: String
    let message: String
    let iconName: String
    
    static let randomChatters: [MinerRadioMessage] = [
        MinerRadioMessage(speaker: "Ahmet Usta", message: "Patron kazmamın ucu alev alıyor, altın damarı çok zengin!", iconName: "hammer.fill"),
        MinerRadioMessage(speaker: "Vagoncu Mehmet", message: "Vagon tepeleme doldu, külçeleri kasaya taşıyorum!", iconName: "cart.fill"),
        MinerRadioMessage(speaker: "Dinamitçi Ali", message: "Kulakları tıkayın! Birazdan derin galeride büyük bir patlama var!", iconName: "flame.fill"),
        MinerRadioMessage(speaker: "Jeolog Selin", message: "Radar verilerine göre aşağıda devasa bir kristal mağarası var!", iconName: "sparkles"),
        MinerRadioMessage(speaker: "Çırak Hasan", message: "Ustam az önce parmak büyüklüğünde bir elmas buldum!", iconName: "suit.diamond.fill"),
        MinerRadioMessage(speaker: "Fenerci Kemal", message: "Tüneller pırıl pırıl parlıyor, işçiler vızır vızır çalışıyor!", iconName: "lightbulb.fill"),
        MinerRadioMessage(speaker: "Maden Şefi", message: "Günlük rekoru kırdık patron, holding gurur duyacak!", iconName: "trophy.fill")
    ]
}
