import SwiftUI

struct ArtifactDiscoveryModal: View {
    let artifact: Artifact
    let onClaim: () -> Void
    
    @State private var rotationAngle: Double = 0
    @State private var bounceScale: CGFloat = 0.5
    @State private var sparkleOpacity: Double = 0.3
    @State private var auraRadius: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Karartılmış Sinematik Arka Plan
            Color.black.opacity(0.88)
                .ignoresSafeArea()
            
            VStack(spacing: 22) {
                // MARK: - Dönen Işık Halkası ve Eser İkonu
                ZStack {
                    // Dış Mistik Parıltı Haresi
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    artifact.rarity.color.opacity(0.5),
                                    artifact.rarity.glowColor.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(auraRadius / 20)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Parıltı Yıldızları
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(artifact.rarity.color)
                        .opacity(sparkleOpacity)
                        .rotationEffect(.degrees(-rotationAngle * 0.7))
                    
                    // Kaide Tabanı
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.18, green: 0.18, blue: 0.25), Color(red: 0.08, green: 0.08, blue: 0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(artifact.rarity.color, lineWidth: 2.5)
                        )
                        .shadow(color: artifact.rarity.glowColor, radius: 25, x: 0, y: 5)
                    
                    // Parlayan Eser İkonu
                    Image(systemName: artifact.iconName)
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [artifact.rarity.color, .white, artifact.rarity.color.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: artifact.rarity.glowColor, radius: 15)
                }
                .scaleEffect(bounceScale)
                
                // MARK: - Nadirlik Rozeti ve İsim
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: artifact.isUnlocked ? "sparkle" : "puzzlepiece.extension.fill")
                            .font(.system(size: 11, weight: .black))
                        Text(
                            artifact.isUnlocked ?
                            "\(artifact.rarity.title.uppercased()) ESER BİRLEŞTİRİLDİ!" :
                            "YENİ PARÇA BULUNDU! (\(artifact.collectedFragments)/\(artifact.totalFragments))"
                        )
                        .font(.system(size: 12, weight: .black))
                        .tracking(1.5)
                    }
                    .foregroundColor(artifact.rarity.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(artifact.rarity.color.opacity(0.15))
                    .clipShape(Capsule())
                    
                    Text(artifact.name)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Parça İlerleme Çubukları
                    if artifact.totalFragments > 1 {
                        HStack(spacing: 6) {
                            ForEach(0..<artifact.totalFragments, id: \.self) { idx in
                                Capsule()
                                    .fill(
                                        idx < artifact.collectedFragments ?
                                        (artifact.isUnlocked ? Color.green : artifact.rarity.color) :
                                        Color.white.opacity(0.15)
                                    )
                                    .frame(width: 32, height: 5)
                                    .shadow(color: (idx < artifact.collectedFragments ? artifact.rarity.color.opacity(0.6) : Color.clear), radius: 3)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                // MARK: - Lore Hikayesi ve Pasif Özellik
                VStack(spacing: 12) {
                    Text(artifact.loreDescription)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 6)
                    
                    Divider().background(Color.white.opacity(0.12))
                    
                    if artifact.isUnlocked {
                        HStack(spacing: 8) {
                            Image(systemName: artifact.bonusType.badgeIcon)
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.green)
                            
                            Text("\(artifact.bonusType.description) (Aktif!)")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                    } else {
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                
                                Text("\(artifact.bonusType.description) (Kilitli)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            
                            Text("Özelliğin aktif olması için \(artifact.totalFragments - artifact.collectedFragments) parça daha gerekiyor.")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(artifact.rarity.color.opacity(0.9))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                // MARK: - "Müzeye Ekle" Butonu
                Button(action: {
                    AudioManager.shared.triggerImpact(style: .heavy)
                    onClaim()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: artifact.isUnlocked ? "building.columns.fill" : "puzzlepiece.fill")
                            .font(.system(size: 16))
                        Text(artifact.isUnlocked ? "Müzeye Ekle 🏛️" : "Parçayı Müzeye Ekle 🧩")
                            .font(.system(size: 16, weight: .black))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [artifact.rarity.color, artifact.rarity.color.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: artifact.rarity.color.opacity(0.6), radius: 14, x: 0, y: 5)
                }
            }
            .padding(26)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [artifact.rarity.color, artifact.rarity.color.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .padding(.horizontal, 26)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                bounceScale = 1.0
            }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                sparkleOpacity = 0.9
                auraRadius = 24
            }
        }
    }
}
