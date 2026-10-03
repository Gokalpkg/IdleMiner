import Foundation

enum QuestType: String, Codable {
    case clicks
    case depth
    case totalGold
    case prestige
    case artifacts
    case shafts
}

struct GameQuest: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let targetValue: Double
    let type: QuestType
    let gemReward: Int
    var isClaimed: Bool = false
    
    func progress(
        currentClicks: Int,
        currentDepth: Double,
        totalGold: Double,
        prestigeLevel: Int,
        unlockedArtifactsCount: Int = 0,
        shaftsCount: Int = 0
    ) -> Double {
        switch type {
        case .clicks:
            return min(Double(currentClicks) / targetValue, 1.0)
        case .depth:
            return min(currentDepth / targetValue, 1.0)
        case .totalGold:
            return min(totalGold / targetValue, 1.0)
        case .prestige:
            return min(Double(prestigeLevel) / targetValue, 1.0)
        case .artifacts:
            return min(Double(unlockedArtifactsCount) / targetValue, 1.0)
        case .shafts:
            return min(Double(shaftsCount) / targetValue, 1.0)
        }
    }
    
    func isCompleted(
        currentClicks: Int,
        currentDepth: Double,
        totalGold: Double,
        prestigeLevel: Int,
        unlockedArtifactsCount: Int = 0,
        shaftsCount: Int = 0
    ) -> Bool {
        return progress(
            currentClicks: currentClicks,
            currentDepth: currentDepth,
            totalGold: totalGold,
            prestigeLevel: prestigeLevel,
            unlockedArtifactsCount: unlockedArtifactsCount,
            shaftsCount: shaftsCount
        ) >= 1.0
    }
}
