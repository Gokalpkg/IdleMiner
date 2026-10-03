import SwiftUI

struct MuseumView: View {
    let artifacts: [Artifact]
    var onDismiss: (() -> Void)? = nil
    var hasOwnScroll: Bool = false
    
    private var unlockedCount: Int {
        artifacts.filter { $0.isUnlocked }.count
    }
    
    private var progressFraction: Double {
        guard !artifacts.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(artifacts.count)
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        if hasOwnScroll {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.10)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    museumTopBar
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        contentStack
                            .padding(.bottom, 32)
                    }
                }
            }
        } else {
            contentStack
        }
    }
    
    private var contentStack: some View {
        VStack(spacing: 14) {
            // MARK: - Koleksiyon İlerleme & İstatistik Kartı
            museumHeaderCard
            
            // MARK: - Müze Set Sinerjileri & Kupa Rozetleri
            museumSetsSection
            
            // MARK: - 2 Sütunlu Eser Vitrini (LazyVGrid)
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(artifacts) { artifact in
                    ArtifactPedestalCard(artifact: artifact)
                }
            }
        }
    }
    
    // MARK: - Üst Bar
    private var museumTopBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20))
                    Text("Antik Eserler Müzesi")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                }
                Text("Derinliklerden çıkarılan gizemli yadigarlar")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
        }
    }
    
    // MARK: - Müze İstatistik / Kadife Kaide Başlık Kartı
    private var museumHeaderCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Koleksiyon Tamamlanma")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(unlockedCount)")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.yellow)
                        Text("/ \(artifacts.count) Eser")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Nadirlik Dağılım Hapları
                HStack(spacing: 6) {
                    ForEach(Rarity.allCases, id: \.self) { rarity in
                        let count = artifacts.filter { $0.rarity == rarity && $0.isUnlocked }.count
                        HStack(spacing: 3) {
                            Circle()
                                .fill(rarity.color)
                                .frame(width: 7, height: 7)
                            Text("\(count)")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(rarity.color.opacity(0.18))
                        .clipShape(Capsule())
                    }
                }
            }
            
            // Lüks Altın İlerleme Çubuğu
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * CGFloat(progressFraction), 8), height: 8)
                        .shadow(color: .yellow.opacity(0.5), radius: 4)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.14, green: 0.13, blue: 0.20), Color(red: 0.10, green: 0.09, blue: 0.14)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Müze Set Sinerjileri Bölümü (Synergy)
    private var museumSetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                Text("Set Sinerjileri & Kupa Rozetleri")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 10) {
                ForEach(ArtifactSet.allSets) { artifactSet in
                    ArtifactSetCardView(artifactSet: artifactSet, artifacts: artifacts)
                }
            }
        }
    }
}

// MARK: - Eser Vitrin Kartı (Silüet & Işıltı Mekaniği)
struct ArtifactPedestalCard: View {
    let artifact: Artifact
    
    var body: some View {
        VStack(spacing: 10) {
            // MARK: - Kaide / Fanus Alanı
            ZStack {
                // Kaide Zemin Dokusu
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: artifact.isUnlocked ?
                                [artifact.rarity.color.opacity(0.25), Color(red: 0.08, green: 0.08, blue: 0.12)] :
                                [Color.black.opacity(0.6), Color(red: 0.06, green: 0.06, blue: 0.09)],
                            center: .center,
                            startRadius: 8,
                            endRadius: 55
                        )
                    )
                    .frame(height: 90)
                
                if artifact.isUnlocked {
                    // AÇILMIŞ ESER: Canlı renkler, neon ışıltı ve parıltı
                    Image(systemName: artifact.iconName)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [artifact.rarity.color, .white, artifact.rarity.color.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: artifact.rarity.glowColor, radius: 12, x: 0, y: 2)
                } else if artifact.collectedFragments > 0 {
                    // PARÇALI ESER (Kısmen Toplanmış: Örn 1/3 veya 2/3)
                    ZStack {
                        Image(systemName: artifact.iconName)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(artifact.rarity.color.opacity(0.35))
                        
                        VStack {
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "puzzlepiece.extension.fill")
                                    .font(.system(size: 10, weight: .black))
                                Text("\(artifact.collectedFragments)/\(artifact.totalFragments)")
                                    .font(.system(size: 10, weight: .black, design: .rounded))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(artifact.rarity.color)
                            .clipShape(Capsule())
                            .shadow(color: artifact.rarity.glowColor, radius: 4)
                        }
                        .padding(.bottom, 6)
                    }
                } else {
                    // KİLİTLİ ESER (0 Parça): TAMAMEN SİYAH SİLÜET
                    ZStack {
                        Image(systemName: artifact.iconName)
                            .renderingMode(.template)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color.black.opacity(0.92))
                            .shadow(color: artifact.rarity.color.opacity(0.25), radius: 5)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundColor(artifact.rarity.color)
                                    .padding(6)
                                    .background(Color.black.opacity(0.8))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(artifact.rarity.color.opacity(0.6), lineWidth: 1)
                                    )
                                    .shadow(color: artifact.rarity.color.opacity(0.4), radius: 4)
                            }
                        }
                        .padding(6)
                    }
                }
            }
            .frame(height: 90)
            
            // MARK: - Parça İlerleme Çubuğu (Segmentli)
            HStack(spacing: 3) {
                ForEach(0..<artifact.totalFragments, id: \.self) { idx in
                    Capsule()
                        .fill(
                            idx < artifact.collectedFragments ?
                            (artifact.isUnlocked ? Color.green : artifact.rarity.color) :
                            Color.white.opacity(0.12)
                        )
                        .frame(height: 3.5)
                }
            }
            .padding(.horizontal, 8)
            
            // MARK: - İsim ve Nadirlik Rozeti
            VStack(spacing: 4) {
                // Nadirlik Başlığı (Her iki durumda da görünür)
                HStack(spacing: 4) {
                    Circle()
                        .fill(artifact.rarity.color)
                        .frame(width: 5, height: 5)
                    Text(artifact.rarity.title.uppercased())
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(artifact.rarity.color)
                    
                    if artifact.totalFragments > 1 {
                        Text("• \(artifact.collectedFragments)/\(artifact.totalFragments)")
                            .font(.system(size: 9, weight: .heavy, design: .monospaced))
                            .foregroundColor(artifact.isUnlocked ? .green : (artifact.collectedFragments > 0 ? artifact.rarity.color : .gray))
                    }
                }
                
                // İsim: Açılmış veya kısmen bulunmuşsa isim görünür, hiç bulunmamışsa "???"
                Text((artifact.isUnlocked || artifact.collectedFragments > 0) ? artifact.name : "???")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(artifact.isUnlocked ? .white : (artifact.collectedFragments > 0 ? .white.opacity(0.85) : .gray.opacity(0.8)))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 32)
                
                // Pasif Bonus (Açılınca aktif, parçalıyken kilitli)
                HStack(spacing: 4) {
                    Image(systemName: artifact.isUnlocked ? artifact.bonusType.badgeIcon : "lock.fill")
                        .font(.system(size: 8))
                    Text(artifact.isUnlocked ? artifact.bonusType.description : "\(artifact.bonusType.description) (Kilitli)")
                        .font(.system(size: 9.5, weight: .bold))
                }
                .foregroundColor(artifact.isUnlocked ? .green : .gray)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (artifact.isUnlocked ? Color.green.opacity(0.15) : Color.white.opacity(0.06))
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke((artifact.isUnlocked ? Color.green.opacity(0.3) : Color.white.opacity(0.1)), lineWidth: 0.8)
                )
            }
            
            // Açılmışsa kısa hikaye
            if artifact.isUnlocked {
                Text(artifact.loreDescription)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 4)
            } else if artifact.collectedFragments > 0 {
                Text("Tamamlamak için \(artifact.totalFragments - artifact.collectedFragments) parça daha gerekiyor.")
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundColor(artifact.rarity.color.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.12, green: 0.12, blue: 0.16), Color(red: 0.08, green: 0.08, blue: 0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            artifact.isUnlocked ?
                            artifact.rarity.color.opacity(0.45) :
                            artifact.rarity.color.opacity(0.15),
                            lineWidth: artifact.isUnlocked ? 1.5 : 1.0
                        )
                )
                .shadow(color: artifact.isUnlocked ? artifact.rarity.glowColor.opacity(0.25) : .clear, radius: 8)
        )
    }
}

// MARK: - Müze Set Kartı (Kupa Rozeti & Sinerji)
struct ArtifactSetCardView: View {
    let artifactSet: ArtifactSet
    let artifacts: [Artifact]
    
    private var isCompleted: Bool {
        artifactSet.requiredArtifactNames.allSatisfy { name in
            artifacts.first(where: { $0.name == name })?.isUnlocked == true
        }
    }
    
    private var unlockedCount: Int {
        artifactSet.requiredArtifactNames.filter { name in
            artifacts.first(where: { $0.name == name })?.isUnlocked == true
        }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Başlık & Kupa Rozeti Durumu
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.yellow.opacity(0.2) : Color.white.opacity(0.06))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: artifactSet.iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isCompleted ? .yellow : .gray)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(artifactSet.name)
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(artifactSet.description)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Tamamlanma Rozeti (Kupa)
                HStack(spacing: 4) {
                    Image(systemName: isCompleted ? "trophy.fill" : "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text(isCompleted ? "TAMAMLANDI" : "\(unlockedCount)/\(artifactSet.requiredArtifactNames.count)")
                        .font(.system(size: 10, weight: .black))
                }
                .foregroundColor(isCompleted ? .black : .white.opacity(0.8))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(
                    isCompleted ?
                    LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(Capsule())
                .shadow(color: isCompleted ? Color.yellow.opacity(0.4) : .clear, radius: 4)
            }
            
            Divider()
                .background(Color.white.opacity(0.08))
            
            // Gerekli Eserler Listesi (Mini Simgelerle)
            HStack(spacing: 8) {
                ForEach(artifactSet.requiredArtifactNames, id: \.self) { name in
                    let art = artifacts.first(where: { $0.name == name })
                    let unlocked = art?.isUnlocked == true
                    
                    HStack(spacing: 5) {
                        Image(systemName: art?.iconName ?? "questionmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(unlocked ? (art?.rarity.color ?? .yellow) : .gray.opacity(0.5))
                        
                        Text(unlocked ? name : "???")
                            .font(.system(size: 10, weight: unlocked ? .bold : .medium))
                            .foregroundColor(unlocked ? .white : .gray.opacity(0.6))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        unlocked ?
                        (art?.rarity.color.opacity(0.15) ?? Color.white.opacity(0.05)) :
                        Color.black.opacity(0.3)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(unlocked ? (art?.rarity.color.opacity(0.3) ?? Color.clear) : Color.white.opacity(0.05), lineWidth: 1)
                    )
                }
            }
            
            // Sinerji Bonusu Metni
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isCompleted ? .yellow : .orange.opacity(0.8))
                
                Text(artifactSet.setBonusText)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(isCompleted ? .yellow : .orange.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCompleted ? Color.yellow.opacity(0.12) : Color.orange.opacity(0.06))
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: isCompleted ?
                            [Color(red: 0.16, green: 0.14, blue: 0.22), Color(red: 0.11, green: 0.10, blue: 0.16)] :
                            [Color(red: 0.11, green: 0.11, blue: 0.14), Color(red: 0.08, green: 0.08, blue: 0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isCompleted ? Color.yellow.opacity(0.5) : Color.white.opacity(0.06),
                            lineWidth: isCompleted ? 1.5 : 1.0
                        )
                )
                .shadow(color: isCompleted ? Color.yellow.opacity(0.2) : .clear, radius: 8)
        )
    }
}

// MARK: - SwiftUI Canvas Preview
struct MuseumView_Previews: PreviewProvider {
    static var previews: some View {
        var sampleArtifacts = Artifact.defaultArtifacts
        sampleArtifacts[0].isUnlocked = true
        sampleArtifacts[3].isUnlocked = true
        
        return MuseumView(artifacts: sampleArtifacts)
            .preferredColorScheme(.dark)
    }
}
