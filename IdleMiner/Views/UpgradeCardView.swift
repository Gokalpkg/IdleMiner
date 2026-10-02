import SwiftUI

struct UpgradeCardView: View {
    let upgrade: Upgrade
    let currentGold: Double
    let onBuy: () -> Void
    
    private var canAfford: Bool {
        currentGold >= upgrade.cost
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // İkon
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: upgrade.type == .clickPower ?
                                [Color.orange.opacity(0.85), Color.red.opacity(0.85)] :
                                [Color.blue.opacity(0.85), Color.purple.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: upgrade.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            
            // Bilgi Bölümü
            VStack(alignment: .leading, spacing: 4) {
                // İsim ve Seviye Rozeti
                HStack(spacing: 6) {
                    Text(upgrade.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("Lv. \(upgrade.level)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundColor(.yellow)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.yellow.opacity(0.4), lineWidth: 0.8))
                }
                
                // Açıklama Metni (Tamamı okunabilir, kırpılmaz)
                Text(upgrade.description)
                    .font(.system(size: 11.5))
                    .foregroundColor(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
                
                // İstatistik Detayı (Mevcut Katkı & Sonraki Seviye Artışı)
                HStack(spacing: 5) {
                    let unit = upgrade.type == .clickPower ? "/vuruş" : "/sn"
                    let color = upgrade.type == .clickPower ? Color.orange : Color.cyan
                    
                    Text("Mevcut: +\(BigNumberFormatter.format(upgrade.totalEffect))\(unit)")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(color)
                    
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Text("+\(BigNumberFormatter.format(upgrade.nextLevelEffect))\(unit)")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer(minLength: 4)
            
            // Satın Al Butonu
            Button(action: {
                AudioManager.shared.triggerImpact(style: .medium)
                onBuy()
            }) {
                VStack(spacing: 2) {
                    HStack(spacing: 3) {
                        Image(systemName: "circle.circle.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(canAfford ? .yellow : .white.opacity(0.6))
                        
                        Text(BigNumberFormatter.format(upgrade.cost))
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(canAfford ? .black : .white.opacity(0.6))
                    }
                    
                    Text("Geliştir")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(canAfford ? Color.black.opacity(0.75) : Color.white.opacity(0.4))
                }
                .frame(minWidth: 70)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    canAfford ?
                    LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .top, endPoint: .bottom) :
                    LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.08)], startPoint: .top, endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: canAfford ? Color.yellow.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
            }
            .disabled(!canAfford)
            .opacity(canAfford ? 1.0 : 0.65)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.14, green: 0.14, blue: 0.18).opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(canAfford ? Color.yellow.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
