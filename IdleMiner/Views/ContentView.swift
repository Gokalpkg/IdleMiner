import SwiftUI

// Uçuşan sayı animasyonu için model
struct FloatingNumber: Identifiable {
    let id = UUID()
    let value: String
    var offset: CGFloat = 0
    var opacity: Double = 1.0
    let xOffset: CGFloat
    var isCritical: Bool = false
}

enum ActiveTab {
    case upgrades
    case shafts
    case museum
    case gemStore
    case quests
}

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var particleManager = ParticleManager()
    @Environment(\.scenePhase) private var scenePhase
    
    // Animasyon ve Tab Durumları
    @State private var isOrePressed = false
    @State private var floatingNumbers: [FloatingNumber] = []
    @State private var selectedTab: ActiveTab = .upgrades
    @State private var showSettingsModal = false
    
    var body: some View {
        ZStack {
            // Dinamik Arka Plan (Gezegen ve Derinlik Katmanına göre arka plan tonu değişir)
            LinearGradient(
                colors: [
                    viewModel.currentWorld.secondaryColor.opacity(0.85),
                    viewModel.currentOreLayer.secondaryColor.opacity(0.7),
                    Color(red: 0.08, green: 0.09, blue: 0.12),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // MARK: - Üst Oyun Alanı (Bakiye, Canlı Maden, Frenzy Bar, Cevher)
                VStack(spacing: 6) {
                    topBarControls
                        .padding(.top, 4)
                    
                    headerSection
                    
                    LiveMineSceneView(
                        passiveIncome: viewModel.effectivePassiveIncome,
                        minerLevel: viewModel.minerApprenticeLevel,
                        cartLevel: viewModel.mineCartLevel,
                        dynamiteLevel: viewModel.dynamiteExpertLevel,
                        steamDrillLevel: viewModel.steamDrillLevel,
                        isFrenzyActive: viewModel.isFrenzyActive,
                        isTurboActive: viewModel.merchantTurboTimeRemaining > 0,
                        isMerchantPresent: viewModel.isMerchantActive,
                        onWorkerTapped: { name in
                            let bonus = viewModel.triggerWorkerEasterEgg(workerName: name)
                            
                            let randomX = CGFloat.random(in: -30...30)
                            let newNumber = FloatingNumber(
                                value: BigNumberFormatter.format(bonus),
                                offset: 0,
                                opacity: 1.0,
                                xOffset: randomX,
                                isCritical: false
                            )
                            floatingNumbers.append(newNumber)
                            withAnimation(.easeOut(duration: 0.6)) {
                                if let index = floatingNumbers.firstIndex(where: { $0.id == newNumber.id }) {
                                    floatingNumbers[index].offset = -60
                                    floatingNumbers[index].opacity = 0.0
                                }
                            }
                        },
                        onMerchantTapped: {
                            AudioManager.shared.triggerImpact(style: .medium)
                            viewModel.showMerchantModal = true
                        }
                    )
                    
                    // MARK: - Gizemli Gezgin Tüccar Karşılaşması (2 Dakika Canlı)
                    if viewModel.isMerchantActive {
                        merchantEncounterBar
                    }
                    
                    // MARK: - Aktif İksirler Göstergesi
                    if viewModel.merchantMidasTimeRemaining > 0 || viewModel.merchantTurboTimeRemaining > 0 {
                        activePotionsBar
                    }
                    
                    frenzyComboBar
                    
                    Spacer(minLength: 4)
                    
                    oreClickSection
                    
                    Spacer(minLength: 4)
                }
                .padding(.horizontal, 16)
                
                // MARK: - Geliştirme & Yönetim Paneli (Tam Ekran, Kenarlara ve Alt Köşelere Tam Oturan Panel)
                bottomDevelopmentSheet
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea(.keyboard)
            
            // MARK: - Çevrimdışı Gelir Modalı
            if viewModel.showOfflineModal, let reward = viewModel.offlineReward {
                offlineRewardModal(reward: reward)
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
            
            // MARK: - Prestij (Rebirth) Modalı
            if viewModel.showPrestigeModal {
                prestigeModal
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
            
            // MARK: - Antik Eser Keşif Kutlama Penceresi
            if let artifact = viewModel.newlyDiscoveredArtifact {
                ArtifactDiscoveryModal(artifact: artifact, onClaim: {
                    viewModel.claimNewlyDiscoveredArtifact()
                })
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
            
            // MARK: - 3. Mekanik: Dünya Haritası ve Gezegenler Modalı
            if viewModel.showWorldMapModal {
                WorldMapView(
                    currentWorldId: viewModel.currentWorldId,
                    currentDepth: viewModel.depth,
                    prestigeLevel: viewModel.prestigeLevel,
                    onSelectWorld: { world in
                        viewModel.travelToWorld(world)
                    },
                    onClose: {
                        viewModel.showWorldMapModal = false
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
            
            // MARK: - Ayarlar & İstatistikler Modalı
            if showSettingsModal {
                SettingsModalView(viewModel: viewModel, onClose: {
                    showSettingsModal = false
                })
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
            
            // MARK: - Gizemli Gezgin Tüccar Modalı (Kara Borsa)
            if viewModel.showMerchantModal {
                MerchantModalView(viewModel: viewModel, onClose: {
                    viewModel.showMerchantModal = false
                })
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showSettingsModal)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.showMerchantModal)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.showOfflineModal)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.showPrestigeModal)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.showWorldMapModal)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.newlyDiscoveredArtifact != nil)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.activeRadioMessage != nil)
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background, .inactive:
                viewModel.saveGame()
            case .active:
                viewModel.checkOfflineProgress()
            @unknown default:
                break
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Üst Kontrol Çubuğu
    private var topBarControls: some View {
        HStack(spacing: 10) {
            // Ayarlar Butonu (Ses, Titreşim, Madenci Karnesi)
            Button(action: {
                AudioManager.shared.triggerImpact(style: .light)
                showSettingsModal = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.yellow)
                    .padding(8)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.yellow.opacity(0.3), lineWidth: 1))
            }
            
            // Elmas Sayacı
            HStack(spacing: 4) {
                Text("💎")
                    .font(.system(size: 13))
                Text("\(viewModel.gems)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.cyan.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.cyan.opacity(0.3), lineWidth: 1))
            
            // 3. Mekanik: Gezegen / Harita Butonu
            Button(action: {
                AudioManager.shared.triggerImpact(style: .medium)
                viewModel.showWorldMapModal = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(viewModel.currentWorld.primaryColor)
                    Text(viewModel.currentWorld.name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(viewModel.currentWorld.primaryColor.opacity(0.3), lineWidth: 1))
            }
            
            Spacer()
            
            // Prestij (Rebirth) Butonu
            Button(action: {
                AudioManager.shared.triggerImpact(style: .medium)
                viewModel.showPrestigeModal = true
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("\(BigNumberFormatter.format(viewModel.prestigeMultiplier))x")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.8), Color.indigo.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.yellow.opacity(0.4), lineWidth: 1))
            }
        }
    }
    
    // MARK: - Header Görünümü (Dengeli ve Kompakt 2 Satır)
    private var headerSection: some View {
        VStack(spacing: 5) {
            // Üst Satır: Altın Bakiyesi + Derinlik Rozeti
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                        )
                    
                    Text(BigNumberFormatter.format(viewModel.gold))
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: viewModel.gold)
                }
                
                Spacer()
                
                // Derinlik ve Katman Bilgisi
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(viewModel.currentOreLayer.primaryColor)
                    Text("\(Int(viewModel.depth))m")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                    Text("•")
                        .foregroundColor(.gray)
                    Text(viewModel.currentOreLayer.name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(viewModel.currentOreLayer.primaryColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
            }
            
            // Alt Satır: Pasif Gelir ve Tıklama Gücü
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.cyan)
                    Text("+\(BigNumberFormatter.format(viewModel.effectivePassiveIncome))/sn")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.cyan.opacity(0.12))
                .clipShape(Capsule())
                
                HStack(spacing: 4) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("+\(BigNumberFormatter.format(viewModel.effectiveClickPower))/vuruş")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.12))
                .clipShape(Capsule())
                
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.12).opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Gizemli Gezgin Tüccar Karşılaşma Çubuğu (3 Dakika Canlı)
    private var merchantEncounterBar: some View {
        Button(action: {
            AudioManager.shared.triggerImpact(style: .medium)
            viewModel.showMerchantModal = true
        }) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.4))
                        .frame(width: 28, height: 28)
                    Text("🧙‍♂️")
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Gizemli Gezgin Tüccar Geldi!")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Kara borsa tekliflerini incele")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.purple.opacity(0.9))
                }
                
                Spacer()
                
                // Canlı Geri Sayım
                HStack(spacing: 3) {
                    Image(systemName: "timer")
                        .font(.system(size: 9, weight: .bold))
                    let secs = max(0, Int(viewModel.merchantTimeRemaining))
                    Text(String(format: "%02d:%02d", secs / 60, secs % 60))
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.45))
                .clipShape(Capsule())
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.12, blue: 0.32),
                                Color(red: 0.11, green: 0.08, blue: 0.16)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.8), Color.yellow.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.purple.opacity(0.35), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        ))
    }
    
    // MARK: - Aktif İksirler Çubuğu
    private var activePotionsBar: some View {
        HStack(spacing: 8) {
            if viewModel.merchantMidasTimeRemaining > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9, weight: .bold))
                    Text("Midas 3×: \(Int(viewModel.merchantMidasTimeRemaining))s")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.yellow.opacity(0.2))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.yellow.opacity(0.4), lineWidth: 1))
            }
            
            if viewModel.merchantTurboTimeRemaining > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 9, weight: .bold))
                    Text("Turbo Hız 2.5×: \(Int(viewModel.merchantTurboTimeRemaining))s")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                }
                .foregroundColor(.cyan)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.cyan.opacity(0.2))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1))
            }
            
            Spacer()
        }
        .transition(.opacity)
    }
    
    // MARK: - Alevli Kombo Barı (Frenzy Combo Bar)
    private var frenzyComboBar: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.isFrenzyActive ? "flame.fill" : "bolt.fill")
                .font(.system(size: 13, weight: .black))
                .foregroundColor(viewModel.isFrenzyActive ? .red : (viewModel.comboProgress > 0.6 ? .orange : .yellow))
                .scaleEffect(viewModel.isFrenzyActive ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: viewModel.isFrenzyActive)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 7)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: viewModel.isFrenzyActive ?
                                    [.yellow, .red, .purple] :
                                    [.yellow, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: viewModel.isFrenzyActive ?
                                geo.size.width * CGFloat(max(viewModel.frenzyTimeRemaining / 8.0, 0.05)) :
                                max(geo.size.width * CGFloat(viewModel.comboProgress), 6),
                            height: 7
                        )
                        .shadow(color: (viewModel.isFrenzyActive ? Color.red : Color.orange).opacity(0.7), radius: 5)
                }
            }
            .frame(height: 7)
            
            Text(viewModel.isFrenzyActive ? "5X ATEŞ! (\(Int(ceil(viewModel.frenzyTimeRemaining)))s)" : "\(String(format: "%.1f%%", viewModel.comboProgress * 100))")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(viewModel.isFrenzyActive ? .red : .yellow)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            viewModel.isFrenzyActive ?
                            Color.red.opacity(0.5) :
                            (viewModel.comboProgress > 0 ? Color.orange.opacity(0.3) : Color.clear),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Altın Cevheri, Can Barı ve Olaylar Alanı
    private var oreClickSection: some View {
        VStack(spacing: 4) {
            ZStack {
                // Katman ve Çılgınlık Parlama Halkası
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                viewModel.isFrenzyActive ? Color.red.opacity(0.4) : viewModel.currentOreLayer.glowColor,
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 155, height: 155)
                
                // Ana Maden Cevheri Butonu
                Button(action: {
                    handleOreTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        viewModel.currentOreLayer.primaryColor,
                                        viewModel.currentOreLayer.secondaryColor
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 114, height: 114)
                            .shadow(
                                color: viewModel.isFrenzyActive ? Color.red.opacity(0.6) : viewModel.currentOreLayer.glowColor,
                                radius: isOrePressed ? 6 : 14,
                                x: 0,
                                y: 4
                            )
                        
                        VStack(spacing: 2) {
                            Image(systemName: viewModel.currentOreLayer.iconName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Image(systemName: "hammer.circle.fill")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.black.opacity(0.6))
                        }
                        
                        // MARK: - Cevher Çatlak Efekti (Dokundukça Ufak Başlar ve Baya Çatlar)
                        if viewModel.oreCrackRatio > 0.005 {
                            OreCrackingOverlay(crackRatio: viewModel.oreCrackRatio)
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                                .allowsHitTesting(false)
                        }
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                
                // MARK: - 60/120 FPS Kıvılcım & Parçacık Patlaması
                ParticleCanvasView(manager: particleManager)
                    .frame(width: 190, height: 190)
                
                // Uçuşan Sayı Animasyonları (Kritik vuruşta büyük kırmızı ve parlayan sayı)
                ForEach(floatingNumbers) { item in
                    if item.isCritical {
                        VStack(spacing: 0) {
                            Text("KRİTİK! ⚡")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundColor(.yellow)
                                .shadow(color: .red, radius: 4)
                            
                            Text("+\(item.value)")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: [.yellow, .red, Color(red: 1.0, green: 0.15, blue: 0.15)], startPoint: .top, endPoint: .bottom)
                                )
                                .shadow(color: .red.opacity(0.9), radius: 8, x: 0, y: 2)
                        }
                        .scaleEffect(1.2)
                        .offset(x: item.xOffset, y: item.offset)
                        .opacity(item.opacity)
                    } else {
                        Text("+\(item.value)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .white], startPoint: .top, endPoint: .bottom)
                            )
                            .offset(x: item.xOffset, y: item.offset)
                            .opacity(item.opacity)
                    }
                }
                
                // MARK: - Aşama 1: Uçan Şans Sandığı
                if let chest = viewModel.luckyChest {
                    Button(action: {
                        viewModel.openLuckyChest()
                    }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                .frame(width: 50, height: 50)
                                .shadow(color: .yellow.opacity(0.7), radius: 10, x: 0, y: 3)
                            
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.25, green: 0.15, blue: 0.05))
                        }
                    }
                    .offset(x: chest.xOffset, y: chest.yOffset)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.5), value: chest.xOffset)
                }
                
                // MARK: - Beklenmedik Mağara Olayı: Altın Köstebeği (Quick-Time Event)
                if let mole = viewModel.goldenMole {
                    Button(action: {
                        viewModel.tapGoldenMole()
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.yellow.opacity(0.95), Color.orange.opacity(0.7), Color.clear],
                                        center: .center,
                                        startRadius: 4,
                                        endRadius: 28
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(color: .yellow, radius: 8)
                            
                            Image(systemName: "pawprint.circle.fill")
                                .font(.system(size: 38, weight: .black))
                                .foregroundColor(Color(red: 0.28, green: 0.18, blue: 0.05))
                                .background(Circle().fill(Color.yellow))
                            
                            // Kalan Vuruş Canı Rozeti
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("\(mole.hitsRemaining)")
                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Color.red)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.white, lineWidth: 1))
                                }
                                Spacer()
                            }
                            .frame(width: 44, height: 44)
                        }
                    }
                    .offset(x: mole.xOffset, y: mole.yOffset)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.22, dampingFraction: 0.6), value: mole.xOffset)
                    .animation(.spring(response: 0.22, dampingFraction: 0.6), value: mole.yOffset)
                }
            }
            .frame(height: 122)
        }
    }
    
    // MARK: - Geliştirme & Yönetim Paneli
    private var bottomDevelopmentSheet: some View {
        VStack(spacing: 8) {
            // Sekme Seçici (Ekipman, Şaftlar, Müze, Elmas, Görev)
            tabPicker
                .padding(.horizontal, 12)
                .padding(.top, 10)
            
            // Sekme İçeriği (Genişletilmiş Kaydırılabilir Liste)
            tabContentView
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(red: 0.10, green: 0.10, blue: 0.14)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous))
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.7), radius: 12, x: 0, y: -2)
        )
    }
    
    // MARK: - Sekme Seçici
    private var tabPicker: some View {
        HStack(spacing: 3) {
            tabButton(title: "Ekipman", icon: "hammer.fill", tab: .upgrades)
            tabButton(title: "Şaftlar", icon: "arrow.up.and.down.square.fill", tab: .shafts)
            tabButton(title: "Müze", icon: "building.columns.fill", tab: .museum)
            tabButton(title: "Elmas", icon: "sparkles", tab: .gemStore)
            tabButton(title: "Görev", icon: "trophy.fill", tab: .quests)
        }
        .padding(3)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private func tabButton(title: String, icon: String, tab: ActiveTab) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                Text(title)
                    .font(.system(size: 10.5, weight: .bold))
            }
            .foregroundColor(selectedTab == tab ? .black : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                selectedTab == tab ?
                LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
    }
    
    // MARK: - Sekme İçerikleri
    @ViewBuilder
    private var tabContentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 9) {
                switch selectedTab {
                case .upgrades:
                    ForEach(viewModel.upgrades) { upgrade in
                        UpgradeCardView(
                            upgrade: upgrade,
                            currentGold: viewModel.gold,
                            onBuy: {
                                viewModel.buyUpgrade(upgrade)
                            }
                        )
                    }
                case .shafts:
                    MineShaftView(viewModel: viewModel)
                case .museum:
                    MuseumView(artifacts: viewModel.artifacts, hasOwnScroll: false)
                case .gemStore:
                    ForEach(viewModel.specialBuffs) { buff in
                        BuffCardView(
                            buff: buff,
                            currentGems: viewModel.gems,
                            onBuy: {
                                viewModel.buySpecialBuff(buff)
                            }
                        )
                    }
                case .quests:
                    ForEach(viewModel.quests) { quest in
                        QuestCardView(
                            quest: quest,
                            currentClicks: viewModel.totalClicks,
                            currentDepth: viewModel.depth,
                            totalGold: viewModel.totalGoldMined,
                            prestigeLevel: viewModel.prestigeLevel,
                            unlockedArtifactsCount: viewModel.artifacts.filter { $0.isUnlocked }.count,
                            shaftsCount: viewModel.shafts.filter { $0.isUnlocked }.count,
                            onClaim: {
                                viewModel.claimQuestReward(quest)
                            }
                        )
                    }
                }
            }
            .padding(.bottom, 38)
        }
    }
    
    // MARK: - Çevrimdışı Pop-up
    private func offlineRewardModal(reward: OfflineReward) -> some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                        .frame(width: 70, height: 70)
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.15, blue: 0.05))
                }
                
                VStack(spacing: 4) {
                    Text("Tekrar Hoş Geldin Madenci! ⛏️")
                        .font(.system(size: 19, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Sen yokken maden işçilerin aralıksız çalıştı:")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Geçen Süre:").font(.system(size: 13)).foregroundColor(.gray)
                        Spacer()
                        Text(reward.formattedDuration).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    }
                    Divider().background(Color.white.opacity(0.1))
                    HStack {
                        Text("Kazanılan Altın:").font(.system(size: 13)).foregroundColor(.gray)
                        Spacer()
                        Text("+\(BigNumberFormatter.format(reward.amount)) 🪙")
                            .font(.system(size: 19, weight: .black))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                Button(action: {
                    AudioManager.shared.triggerImpact(style: .heavy)
                    viewModel.claimOfflineReward()
                }) {
                    Text("Altınları Topla! 🪙")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.14, green: 0.15, blue: 0.19))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.yellow.opacity(0.3), lineWidth: 1.5))
            )
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Prestij (Rebirth) Modalı
    private var prestigeModal: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom))
                        .frame(width: 74, height: 74)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.yellow)
                }
                
                VStack(spacing: 4) {
                    Text("Madeni Devret (Rebirth)")
                        .font(.system(size: 21, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Tüm altınların ve kadron sıfırlanır, ANCAK kalıcı olarak tüm kazancın 2 KATINA çıkar ve +10 Elmas kazanırsın!")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 10) {
                    HStack {
                        Text("Gereken Altın:").font(.system(size: 13)).foregroundColor(.gray)
                        Spacer()
                        Text("\(BigNumberFormatter.format(viewModel.prestigeCost)) 🪙")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(viewModel.canPrestige ? .green : .red)
                    }
                    Divider().background(Color.white.opacity(0.1))
                    HStack {
                        Text("Kazanç Çarpanı:").font(.system(size: 13)).foregroundColor(.gray)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(BigNumberFormatter.format(viewModel.prestigeMultiplier))x").foregroundColor(.gray)
                            Image(systemName: "arrow.right").font(.system(size: 10)).foregroundColor(.yellow)
                            Text("\(BigNumberFormatter.format(viewModel.prestigeMultiplier * 2))x")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                VStack(spacing: 8) {
                    Button(action: {
                        viewModel.performPrestige()
                    }) {
                        Text(viewModel.canPrestige ? "Madeni Devret & 2x Başla! 🚀" : "Yetersiz Altın")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(viewModel.canPrestige ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                viewModel.canPrestige ?
                                LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!viewModel.canPrestige)
                    
                    Button(action: {
                        viewModel.showPrestigeModal = false
                    }) {
                        Text("Vazgeç").font(.system(size: 13, weight: .semibold)).foregroundColor(.gray).padding(.vertical, 4)
                    }
                }
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.13, green: 0.13, blue: 0.18))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.purple.opacity(0.4), lineWidth: 1.5))
            )
            .padding(.horizontal, 28)
        }
    }
    
    // MARK: - Tıklama ve Animasyon Mantığı (Kritik Vuruş & Parçalanma - Ekran Sallanması Yok, Sadece Haptik)
    private func handleOreTap() {
        let strike = viewModel.mineGold()
        
        // 1. Durum: Cevher Parçalandı (Ore HP = 0)
        if strike.didShatterOre {
            // Dev Altın Patlaması: 55 Parçacık!
            particleManager.emitBurst(
                count: 55,
                primaryColor: .yellow,
                secondaryColor: .orange
            )
            
            // Büyük Parçalanma Uçuşan Yazısı
            let shatterNumber = FloatingNumber(
                value: "💥 CEVHER PARÇALANDI! +\(BigNumberFormatter.format(strike.amountEarned))",
                offset: 0,
                opacity: 1.0,
                xOffset: 0,
                isCritical: true
            )
            floatingNumbers.append(shatterNumber)
            
            withAnimation(.easeOut(duration: 1.2)) {
                if let index = floatingNumbers.firstIndex(where: { $0.id == shatterNumber.id }) {
                    floatingNumbers[index].offset = -140
                    floatingNumbers[index].opacity = 0.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                floatingNumbers.removeAll { $0.id == shatterNumber.id }
            }
            return
        }
        
        // 60/120 FPS Kıvılcım & Altın Parçacık Patlaması (Kritik vuruşta 32, normalde 16 parçacık)
        particleManager.emitBurst(
            count: strike.isCritical ? 32 : 16,
            primaryColor: strike.isCritical ? .red : viewModel.currentOreLayer.primaryColor,
            secondaryColor: strike.isCritical ? .yellow : viewModel.currentOreLayer.secondaryColor
        )
        
        // 10x Değerinde Altın Sayısı Gösterimi
        let clickValString = BigNumberFormatter.format(strike.amountEarned)
        let randomX = CGFloat.random(in: -50...50)
        let newNumber = FloatingNumber(
            value: clickValString,
            offset: 0,
            opacity: 1.0,
            xOffset: randomX,
            isCritical: strike.isCritical
        )
        floatingNumbers.append(newNumber)
        
        withAnimation(.easeOut(duration: strike.isCritical ? 0.95 : 0.75)) {
            if let index = floatingNumbers.firstIndex(where: { $0.id == newNumber.id }) {
                floatingNumbers[index].offset = strike.isCritical ? -120 : -90
                floatingNumbers[index].opacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (strike.isCritical ? 1.0 : 0.8)) {
            floatingNumbers.removeAll { $0.id == newNumber.id }
        }
    }
}

// MARK: - Cevher Çatlama Efekti (GPU Destekli Detaylı Canvas Çizimi)
struct OreCrackingOverlay: View {
    let crackRatio: Double // 0.0 to 1.0
    
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w / 2
            let cy = h / 2
            
            // 1. Ana Çatlak Kolu (Sol Üst)
            var p1 = Path()
            p1.move(to: CGPoint(x: cx, y: cy))
            p1.addLine(to: CGPoint(x: cx - w * 0.10 * min(crackRatio * 2.5, 1.0), y: cy - h * 0.14 * min(crackRatio * 2.5, 1.0)))
            if crackRatio > 0.15 {
                p1.addLine(to: CGPoint(x: cx - w * 0.22, y: cy - h * 0.20))
                p1.addLine(to: CGPoint(x: cx - w * 0.35, y: cy - h * 0.34))
            }
            if crackRatio > 0.40 {
                p1.addLine(to: CGPoint(x: cx - w * 0.44, y: cy - h * 0.42))
                // Yan kırık
                p1.move(to: CGPoint(x: cx - w * 0.22, y: cy - h * 0.20))
                p1.addLine(to: CGPoint(x: cx - w * 0.34, y: cy - h * 0.12))
                p1.addLine(to: CGPoint(x: cx - w * 0.46, y: cy - h * 0.16))
            }
            if crackRatio > 0.70 {
                p1.move(to: CGPoint(x: cx - w * 0.35, y: cy - h * 0.34))
                p1.addLine(to: CGPoint(x: cx - w * 0.26, y: cy - h * 0.45))
            }
            
            // 2. Ana Çatlak Kolu (Sağ Üst)
            var p2 = Path()
            p2.move(to: CGPoint(x: cx, y: cy))
            p2.addLine(to: CGPoint(x: cx + w * 0.12 * min(crackRatio * 2.5, 1.0), y: cy - h * 0.12 * min(crackRatio * 2.5, 1.0)))
            if crackRatio > 0.20 {
                p2.addLine(to: CGPoint(x: cx + w * 0.26, y: cy - h * 0.22))
                p2.addLine(to: CGPoint(x: cx + w * 0.38, y: cy - h * 0.36))
            }
            if crackRatio > 0.45 {
                p2.addLine(to: CGPoint(x: cx + w * 0.46, y: cy - h * 0.42))
                // Yan kırık
                p2.move(to: CGPoint(x: cx + w * 0.26, y: cy - h * 0.22))
                p2.addLine(to: CGPoint(x: cx + w * 0.36, y: cy - h * 0.10))
                p2.addLine(to: CGPoint(x: cx + w * 0.47, y: cy - h * 0.06))
            }
            if crackRatio > 0.75 {
                p2.move(to: CGPoint(x: cx + w * 0.38, y: cy - h * 0.36))
                p2.addLine(to: CGPoint(x: cx + w * 0.48, y: cy - h * 0.26))
            }
            
            // 3. Ana Çatlak Kolu (Sağ Alt)
            var p3 = Path()
            p3.move(to: CGPoint(x: cx, y: cy))
            p3.addLine(to: CGPoint(x: cx + w * 0.10 * min(crackRatio * 2.5, 1.0), y: cy + h * 0.14 * min(crackRatio * 2.5, 1.0)))
            if crackRatio > 0.25 {
                p3.addLine(to: CGPoint(x: cx + w * 0.24, y: cy + h * 0.26))
                p3.addLine(to: CGPoint(x: cx + w * 0.38, y: cy + h * 0.40))
            }
            if crackRatio > 0.50 {
                p3.addLine(to: CGPoint(x: cx + w * 0.45, y: cy + h * 0.44))
                // Yan kırık
                p3.move(to: CGPoint(x: cx + w * 0.24, y: cy + h * 0.26))
                p3.addLine(to: CGPoint(x: cx + w * 0.38, y: cy + h * 0.16))
                p3.addLine(to: CGPoint(x: cx + w * 0.48, y: cy + h * 0.18))
            }
            if crackRatio > 0.80 {
                p3.move(to: CGPoint(x: cx + w * 0.38, y: cy + h * 0.40))
                p3.addLine(to: CGPoint(x: cx + w * 0.28, y: cy + h * 0.47))
            }
            
            // 4. Ana Çatlak Kolu (Sol Alt)
            var p4 = Path()
            p4.move(to: CGPoint(x: cx, y: cy))
            p4.addLine(to: CGPoint(x: cx - w * 0.12 * min(crackRatio * 2.5, 1.0), y: cy + h * 0.12 * min(crackRatio * 2.5, 1.0)))
            if crackRatio > 0.28 {
                p4.addLine(to: CGPoint(x: cx - w * 0.24, y: cy + h * 0.28))
                p4.addLine(to: CGPoint(x: cx - w * 0.38, y: cy + h * 0.40))
            }
            if crackRatio > 0.55 {
                p4.addLine(to: CGPoint(x: cx - w * 0.45, y: cy + h * 0.45))
                // Yan kırık
                p4.move(to: CGPoint(x: cx - w * 0.24, y: cy + h * 0.28))
                p4.addLine(to: CGPoint(x: cx - w * 0.36, y: cy + h * 0.20))
                p4.addLine(to: CGPoint(x: cx - w * 0.47, y: cy + h * 0.24))
            }
            if crackRatio > 0.82 {
                p4.move(to: CGPoint(x: cx - w * 0.38, y: cy + h * 0.40))
                p4.addLine(to: CGPoint(x: cx - w * 0.46, y: cy + h * 0.34))
            }
            
            // 5. Örümcek Ağı / Çapraz Kırık Köprüleri (Baya Çatlama Aşaması)
            var pBridges = Path()
            if crackRatio > 0.40 {
                // Üst Köprü (Sol Üst ile Sağ Üst arası)
                pBridges.move(to: CGPoint(x: cx - w * 0.22, y: cy - h * 0.20))
                pBridges.addLine(to: CGPoint(x: cx, y: cy - h * 0.30))
                pBridges.addLine(to: CGPoint(x: cx + w * 0.26, y: cy - h * 0.22))
            }
            if crackRatio > 0.60 {
                // Sağ Köprü (Sağ Üst ile Sağ Alt arası)
                pBridges.move(to: CGPoint(x: cx + w * 0.36, y: cy - h * 0.10))
                pBridges.addLine(to: CGPoint(x: cx + w * 0.40, y: cy))
                pBridges.addLine(to: CGPoint(x: cx + w * 0.38, y: cy + h * 0.16))
            }
            if crackRatio > 0.72 {
                // Alt Köprü (Sağ Alt ile Sol Alt arası)
                pBridges.move(to: CGPoint(x: cx + w * 0.24, y: cy + h * 0.26))
                pBridges.addLine(to: CGPoint(x: cx, y: cy + h * 0.34))
                pBridges.addLine(to: CGPoint(x: cx - w * 0.24, y: cy + h * 0.28))
            }
            if crackRatio > 0.82 {
                // Sol Köprü (Sol Alt ile Sol Üst arası)
                pBridges.move(to: CGPoint(x: cx - w * 0.36, y: cy + h * 0.20))
                pBridges.addLine(to: CGPoint(x: cx - w * 0.42, y: cy))
                pBridges.addLine(to: CGPoint(x: cx - w * 0.34, y: cy - h * 0.12))
            }
            if crackRatio > 0.90 {
                // Merkez Parçalanma Çemberi (En son evre)
                pBridges.addEllipse(in: CGRect(x: cx - w * 0.18, y: cy - h * 0.18, width: w * 0.36, height: h * 0.36))
            }
            
            var combined = Path()
            combined.addPath(p1)
            combined.addPath(p2)
            combined.addPath(p3)
            combined.addPath(p4)
            combined.addPath(pBridges)
            
            let lineWidth = CGFloat(1.2 + crackRatio * 2.6)
            
            // Dış derin çatlak çizgisi (karanlık yarık)
            context.stroke(
                combined,
                with: .color(Color(red: 0.05, green: 0.03, blue: 0.02).opacity(min(1.0, 0.4 + crackRatio * 0.6))),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
            
            // İç parlama (enerji sızması)
            if crackRatio > 0.25 {
                let innerGlowWidth = CGFloat(0.8 + (crackRatio - 0.25) * 1.8)
                context.stroke(
                    combined,
                    with: .color(Color.yellow.opacity(min(0.95, (crackRatio - 0.20) * 1.3))),
                    style: StrokeStyle(lineWidth: innerGlowWidth, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}

// Buton Yaylanma Efekti
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
