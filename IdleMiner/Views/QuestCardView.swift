import SwiftUI

struct QuestCardView: View {
    let quest: GameQuest
    let currentClicks: Int
    let currentDepth: Double
    let totalGold: Double
    let prestigeLevel: Int
    let onClaim: () -> Void
    
    private var progress: Double {
        quest.progress(currentClicks: currentClicks, currentDepth: currentDepth, totalGold: totalGold, prestigeLevel: prestigeLevel)
    }
    
    private var isCompleted: Bool {
        quest.isCompleted(currentClicks: currentClicks, currentDepth: currentDepth, totalGold: totalGold, prestigeLevel: prestigeLevel)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(quest.isClaimed ? Color.green.opacity(0.2) : Color.yellow.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: quest.isClaimed ? "checkmark.seal.fill" : "trophy.fill")
                        .font(.system(size: 18))
                        .foregroundColor(quest.isClaimed ? .green : .yellow)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(quest.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(quest.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if quest.isClaimed {
                    Text("Alındı")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                } else if isCompleted {
                    Button(action: onClaim) {
                        HStack(spacing: 4) {
                            Text("💎")
                            Text("+\(quest.gemReward)")
                                .font(.system(size: 13, weight: .black))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: .green.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                } else {
                    HStack(spacing: 3) {
                        Text("💎")
                            .font(.system(size: 11))
                        Text("\(quest.gemReward)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
                }
            }
            
            // İlerleme Çubuğu
            if !quest.isClaimed {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 5)
                        
                        Capsule()
                            .fill(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * CGFloat(progress), height: 5)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(white: 0.14).opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isCompleted && !quest.isClaimed ? Color.yellow.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
