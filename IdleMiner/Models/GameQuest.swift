import Foundation

enum QuestType: String, Codable {
    case clicks
    case depth
    case totalGold
    case prestige
}

struct GameQuest: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let targetValue: Double
    let type: QuestType
    let gemReward: Int
    var isClaimed: Bool = false
    
    func progress(currentClicks: Int, currentDepth: Double, totalGold: Double, prestigeLevel: Int) -> Double {
        switch type {
        case .clicks:
            return min(Double(currentClicks) / targetValue, 1.0)
        case .depth:
            return min(currentDepth / targetValue, 1.0)
        case .totalGold:
            return min(totalGold / targetValue, 1.0)
        case .prestige:
            return min(Double(prestigeLevel) / targetValue, 1.0)
        }
    }
    
    func isCompleted(currentClicks: Int, currentDepth: Double, totalGold: Double, prestigeLevel: Int) -> Bool {
        return progress(currentClicks: currentClicks, currentDepth: currentDepth, totalGold: totalGold, prestigeLevel: prestigeLevel) >= 1.0
    }
}
