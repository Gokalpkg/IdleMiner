import SwiftUI

struct WorldMapView: View {
    let currentWorldId: String
    let currentDepth: Double
    let prestigeLevel: Int
    let onSelectWorld: (MineWorld) -> Void
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Başlık
                HStack {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Maden Galaksisi & Harita")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                        Text("Farklı gezegen ve maden ocaklarına seyahat et.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Dünyalar Listesi
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(MineWorld.allWorlds) { world in
                            worldCardView(world: world)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .frame(maxHeight: 520)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.13, blue: 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
        }
    }
    
    private func worldCardView(world: MineWorld) -> some View {
        let isUnlocked = world.isUnlocked(currentDepth: currentDepth, prestigeLevel: prestigeLevel)
        let isSelected = world.id == currentWorldId
        
        return HStack(spacing: 14) {
            // Dünya İkonu
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isUnlocked ? [world.primaryColor, world.secondaryColor] : [Color.gray.opacity(0.3), Color.black.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: isUnlocked ? world.glowColor.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 2)
                
                Image(systemName: isUnlocked ? world.iconName : "lock.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : .gray)
            }
            
            // Bilgiler
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(world.name)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(isUnlocked ? .white : .gray)
                    
                    if isSelected {
                        Text("Aktif")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.yellow)
                            .clipShape(Capsule())
                    }
                }
                
                Text(world.subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 9))
                        Text("\(Int(world.globalMultiplier))x Küresel Çarpan")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(world.primaryColor)
                }
            }
            
            Spacer()
            
            // Seyahat Butonu veya Kilit Durumu
            if isUnlocked {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                } else {
                    Button(action: {
                        AudioManager.shared.triggerImpact(style: .medium)
                        onSelectWorld(world)
                    }) {
                        Text("Seyahat")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(colors: [world.primaryColor, world.glowColor], startPoint: .top, endPoint: .bottom)
                            )
                            .clipShape(Capsule())
                    }
                }
            } else {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Kilitli")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.red)
                    Text("\(Int(world.requiredDepth))m veya Rebirth \(world.requiredPrestige)")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(white: 0.14).opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected ? world.primaryColor.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
