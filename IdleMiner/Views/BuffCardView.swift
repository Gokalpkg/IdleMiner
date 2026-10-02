import SwiftUI

struct BuffCardView: View {
    let buff: SpecialBuff
    let currentGems: Int
    let onBuy: () -> Void
    
    private var canAfford: Bool {
        currentGems >= buff.gemCost
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: buff.isPurchased ?
                                [Color.green.opacity(0.8), Color.teal.opacity(0.8)] :
                                [Color.cyan.opacity(0.8), Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: buff.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(buff.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Text(buff.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            if buff.isPurchased {
                Text("Sahip Olundu")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Capsule())
            } else {
                Button(action: onBuy) {
                    HStack(spacing: 4) {
                        Text("💎")
                            .font(.system(size: 12))
                        Text("\(buff.gemCost)")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        canAfford ?
                        LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .disabled(!canAfford)
                .opacity(canAfford ? 1.0 : 0.6)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.15).opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(buff.isPurchased ? Color.green.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
