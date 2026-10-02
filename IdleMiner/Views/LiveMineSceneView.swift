import SwiftUI

struct LiveMineSceneView: View {
    let passiveIncome: Double
    let minerLevel: Int
    let cartLevel: Int
    let dynamiteLevel: Int
    let steamDrillLevel: Int
    let isFrenzyActive: Bool
    var isTurboActive: Bool = false
    var isMerchantPresent: Bool = false
    var onWorkerTapped: ((String) -> Void)? = nil
    var onMerchantTapped: (() -> Void)? = nil
    
    // Animasyon durumları
    @State private var cartXOffset: CGFloat = -150
    @State private var pickaxeSwingAngle: Double = -35
    @State private var jackhammerJitter: CGFloat = 0
    @State private var lanternSwayAngle: Double = -6
    @State private var lanternFlicker: Double = 0.9
    @State private var isSparkVisible: Bool = false
    
    // Easter Egg zıplama animasyon durumları
    @State private var leftWorkerJump: CGFloat = 0
    @State private var rightWorkerJump: CGFloat = 0
    @State private var foremanJump: CGFloat = 0
    @State private var drillWorkerJump: CGFloat = 0
    
    // Zıplama altın bildirim balonu
    @State private var easterEggText: String? = nil
    @State private var easterEggOffset: CGFloat = 0
    
    // MARK: - Madenci Düşünce Baloncukları (8 Cümle)
    private static let minerThoughts: [String] = [
        "Altın kokusu alıyorum! ⛏️",
        "Bugün mesai erken biter mi?",
        "Çay molası ne zaman? ☕",
        "Bu damar çok zengin çıktı!",
        "Kazmayı yeni biledim, canavar!",
        "Daha derine inmeliyiz! 🚀",
        "Bir parıltı gördüm sanki... ✨",
        "Tulum yine kömür oldu yahu!"
    ]
    
    @State private var leftThoughtIndex: Int = 0
    @State private var rightThoughtIndex: Int = 4
    @State private var showLeftBubble: Bool = false
    @State private var showRightBubble: Bool = false
    @State private var bubbleTimer: Timer? = nil
    
    // MARK: - Seviye Kontrolleri (Görsel Kadro Büyümesi)
    /// Seviye 10+: Vagon yerine mini buharlı lokomotif
    private var isSteamLocomotive: Bool {
        cartLevel >= 10
    }
    
    /// Seviye 25+: Ortada şantiye şefi / dinamitçi belirir
    private var hasForemanOrDynamite: Bool {
        dynamiteLevel >= 1 || minerLevel >= 25
    }
    
    /// Buharlı Matkap / Hilti Ustası (steamDrillLevel >= 1 veya minerLevel >= 15)
    private var hasJackhammerWorker: Bool {
        steamDrillLevel >= 1 || minerLevel >= 15
    }
    
    // Hız hesaplamaları
    private var cartSpeedDuration: Double {
        let baseSpeed = 4.0
        let speedBoost = Double(cartLevel) * 0.12
        var duration = max(baseSpeed - speedBoost, 1.2)
        if isFrenzyActive { duration /= 2.5 }
        if isTurboActive { duration /= 2.0 }
        return max(duration, 0.4)
    }
    
    private var minerSwingSpeed: Double {
        let baseSpeed = 0.8
        let speedBoost = Double(minerLevel) * 0.03
        var duration = max(baseSpeed - speedBoost, 0.18)
        if isFrenzyActive { duration /= 3.0 }
        if isTurboActive { duration /= 2.0 }
        return max(duration, 0.08)
    }
    
    var body: some View {
        ZStack {
            // Tünel Arka Planı ve Kirişleri
            tunnelBackground
            
            // Ray Hattı
            railTracks
                .offset(y: 30)
            
            // Hareketli Araç (Vagon veya Seviye 10+ Mini Buharlı Lokomotif)
            Group {
                if isSteamLocomotive {
                    animatedSteamLocomotive
                } else {
                    animatedMineCart
                }
            }
            .offset(x: cartXOffset, y: isSteamLocomotive ? 11 : 16)
            
            // Madenci Kadrosu (Dinamik Büyüyen Kadro)
            HStack(alignment: .bottom, spacing: 0) {
                // 1. Sol Madenci (Kazmacı)
                VStack(spacing: 3) {
                    if showLeftBubble && AudioManager.shared.isWorkerThoughtsEnabled {
                        thoughtBubble(text: Self.minerThoughts[leftThoughtIndex], isLeft: true)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.6).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else {
                        Color.clear.frame(height: 22)
                    }
                    
                    animatedMiner(isLeft: true)
                        .offset(y: leftWorkerJump)
                        .onTapGesture {
                            triggerJump(worker: 1, name: "Kazmacı Kazım")
                        }
                }
                .padding(.leading, 8)
                
                Spacer()
                
                // 2. Şantiye Şefi / Dinamitçi (Seviye 25+ veya Dinamitçi Yükseltmesi)
                if hasForemanOrDynamite {
                    foremanOrDynamiteWorker
                        .offset(y: 8 + foremanJump)
                        .onTapGesture {
                            triggerJump(worker: 2, name: "Şantiye Şefi Rıza")
                        }
                        .transition(.scale.combined(with: .opacity))
                    
                    Spacer()
                }
                
                // 3. Hilti / Buharlı Kırıcı Kullanan Madenci (Seviye 15+ veya Buharlı Matkap)
                if hasJackhammerWorker {
                    jackhammerWorker
                        .offset(y: 8 + drillWorkerJump)
                        .onTapGesture {
                            triggerJump(worker: 3, name: "Hiltici Usta")
                        }
                        .transition(.scale.combined(with: .opacity))
                    
                    Spacer()
                }
                
                // 4. Sağ Madenci (Kazmacı)
                VStack(spacing: 3) {
                    if showRightBubble && AudioManager.shared.isWorkerThoughtsEnabled {
                        thoughtBubble(text: Self.minerThoughts[rightThoughtIndex], isLeft: false)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.6).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else {
                        Color.clear.frame(height: 22)
                    }
                    
                    animatedMiner(isLeft: false)
                        .offset(y: rightWorkerJump)
                        .onTapGesture {
                            triggerJump(worker: 4, name: "Kıdemli Veli")
                        }
                }
                .padding(.trailing, 8)
            }
            .offset(y: 4)
            
            // Easter Egg Uçuşan Altın Yazısı
            if let text = easterEggText {
                Text(text)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange, radius: 4)
                    .offset(y: -30 + easterEggOffset)
                    .transition(.opacity)
            }
            
            // Asılı Sallanan Madenci Fenerleri
            HStack {
                hangingLantern
                    .padding(.leading, 18)
                Spacer()
                hangingLantern
                    .padding(.trailing, 18)
            }
            .offset(y: -24)
            
            // MARK: - Gizemli Gezgin Tüccar Figürü (Mağara Kapısında Belirir)
            if isMerchantPresent {
                HStack {
                    Spacer()
                    Button(action: {
                        onMerchantTapped?()
                    }) {
                        VStack(spacing: 1) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color.purple.opacity(0.85), Color.purple.opacity(0.2), Color.clear],
                                            center: .center,
                                            startRadius: 2,
                                            endRadius: 18
                                        )
                                    )
                                    .frame(width: 34, height: 34)
                                
                                Text("🧙‍♂️")
                                    .font(.system(size: 20))
                                    .shadow(color: .purple, radius: 5)
                            }
                            
                            Text("TÜCCAR")
                                .font(.system(size: 7, weight: .black, design: .rounded))
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1.5)
                                .background(Color.black.opacity(0.75))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.purple.opacity(0.6), lineWidth: 0.8))
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .offset(x: -8, y: -18)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            startAnimations()
            startThoughtCycle()
        }
        .onDisappear {
            bubbleTimer?.invalidate()
            bubbleTimer = nil
        }
    }
    
    // MARK: - Easter Egg Zıplama & Komik Tepki Tetikleyici
    private func triggerJump(worker: Int, name: String) {
        // Haptik & Ses
        AudioManager.shared.triggerImpact(style: .medium)
        AudioManager.shared.playUpgradeSound()
        
        switch worker {
        case 1:
            withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.3)) { leftWorkerJump = -18 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.6)) { leftWorkerJump = 0 }
            }
        case 2:
            withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.3)) { foremanJump = -18 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.6)) { foremanJump = 0 }
            }
        case 3:
            withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.3)) { drillWorkerJump = -18 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.6)) { drillWorkerJump = 0 }
            }
        default:
            withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.3)) { rightWorkerJump = -18 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.6)) { rightWorkerJump = 0 }
            }
        }
        
        onWorkerTapped?(name)
    }
    
    // MARK: - Düşünce Baloncuğu
    private func thoughtBubble(text: String, isLeft: Bool) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "bubble.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.orange)
                
                Text(text)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(Color(red: 0.12, green: 0.10, blue: 0.08))
                    .lineLimit(1)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3.5)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(white: 0.98))
                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
            )
            
            HStack {
                if isLeft { Spacer().frame(width: 14) } else { Spacer() }
                Circle()
                    .fill(Color(white: 0.95))
                    .frame(width: 4, height: 4)
                if !isLeft { Spacer().frame(width: 14) } else { Spacer() }
            }
        }
    }
    
    // MARK: - Mini Buharlı Lokomotif (Seviye 10+)
    private var animatedSteamLocomotive: some View {
        ZStack {
            // Lokomotif Bacası ve Dumanı
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 5, height: 5)
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 7, height: 7)
                }
                .offset(x: -8, y: -4)
                
                // Baca Borusu
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 6, height: 8)
                    .offset(x: -8)
            }
            .offset(y: -14)
            
            // Lokomotif Gövdesi
            HStack(spacing: 1) {
                // Ön Kazan
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(colors: [Color.red.opacity(0.85), Color.black], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 28, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.yellow, lineWidth: 1)
                    )
                
                // Makinist Kabini
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.25))
                        .frame(width: 22, height: 25)
                    
                    // Kabin Penceresi
                    Rectangle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .offset(y: -4)
                }
            }
            
            // Büyük Metal Tekerlekler
            HStack(spacing: 12) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 11, height: 11)
                        .overlay(Circle().stroke(Color.yellow, lineWidth: 1.5))
                }
            }
            .offset(y: 13)
        }
    }
    
    // MARK: - Standart Vagon
    private var animatedMineCart: some View {
        ZStack {
            HStack(spacing: -3) {
                ForEach(0..<4) { i in
                    Circle()
                        .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 10, height: 10)
                        .offset(y: i % 2 == 0 ? -12 : -10)
                }
            }
            
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color(red: 0.45, green: 0.30, blue: 0.18), Color(red: 0.28, green: 0.18, blue: 0.10)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 44, height: 22)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.6), lineWidth: 1))
            
            HStack(spacing: 20) {
                Circle().fill(Color(white: 0.3)).frame(width: 9, height: 9).overlay(Circle().stroke(Color.black, lineWidth: 1))
                Circle().fill(Color(white: 0.3)).frame(width: 9, height: 9).overlay(Circle().stroke(Color.black, lineWidth: 1))
            }
            .offset(y: 11)
        }
    }
    
    // MARK: - Şantiye Şefi / Dinamitçi (Seviye 25+)
    private var foremanOrDynamiteWorker: some View {
        ZStack {
            VStack(spacing: 1) {
                // Beyaz Mühendis Bareti (Şef Bareti)
                ZStack {
                    Circle()
                        .fill(Color(red: 0.95, green: 0.80, blue: 0.65))
                        .frame(width: 15, height: 15)
                    
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 17, height: 8)
                        .offset(y: -4)
                        .shadow(color: .white.opacity(0.5), radius: 2)
                }
                
                // Turuncu Emniyet Yeleği & Şef Tulumu
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.orange)
                    .frame(width: 14, height: 16)
                    .overlay(
                        VStack(spacing: 3) {
                            Rectangle().fill(Color.yellow).frame(height: 2)
                            Rectangle().fill(Color.yellow).frame(height: 2)
                        }
                    )
            }
            
            // Elinde Telsiz veya Dinamit Fünyesi
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.red)
                .offset(x: 10, y: -2)
        }
    }
    
    // MARK: - Hilti / Pnömatik Kırıcı Kullanan Usta
    private var jackhammerWorker: some View {
        ZStack {
            VStack(spacing: 1) {
                // Kırmızı Koruyucu Baret & Kulaklık
                ZStack {
                    Circle()
                        .fill(Color(red: 0.95, green: 0.80, blue: 0.65))
                        .frame(width: 14, height: 14)
                    
                    Capsule()
                        .fill(Color.red)
                        .frame(width: 16, height: 8)
                        .offset(y: -4)
                }
                
                // Koyu Gri İş Tulumu
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.25, green: 0.25, blue: 0.3))
                    .frame(width: 13, height: 16)
            }
            
            // Titreyen Pnömatik Hilti / Kırıcı Matkap
            VStack(spacing: 0) {
                Image(systemName: "wrench.adjustable.fill")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.yellow)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: 6)
            }
            .rotationEffect(.degrees(25))
            .offset(x: 8, y: 3 + jackhammerJitter)
            
            // Hilti Ucundaki Sürekli Kıvılcım & Toz
            if isSparkVisible {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 4, height: 4)
                    .offset(x: 12, y: 12)
            }
        }
    }
    
    // MARK: - Kazma Sallayan Standart Madenci
    private func animatedMiner(isLeft: Bool) -> some View {
        ZStack {
            VStack(spacing: 2) {
                ZStack {
                    Circle().fill(Color(red: 0.95, green: 0.80, blue: 0.65)).frame(width: 14, height: 14)
                    Capsule().fill(Color.yellow).frame(width: 16, height: 8).offset(y: -4)
                }
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blue.opacity(0.85))
                    .frame(width: 12, height: 16)
            }
            
            Image(systemName: "hammer.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color.orange)
                .rotationEffect(.degrees(isLeft ? pickaxeSwingAngle : -pickaxeSwingAngle))
                .offset(x: isLeft ? 10 : -10, y: -4)
            
            if isSparkVisible {
                Image(systemName: "sparkle")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.yellow)
                    .offset(x: isLeft ? 16 : -16, y: 6)
            }
        }
    }
    
    // MARK: - Tünel Arka Planı
    private var tunnelBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.14, green: 0.12, blue: 0.11), Color(red: 0.08, green: 0.07, blue: 0.07)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            HStack {
                ForEach(0..<6) { _ in
                    Rectangle()
                        .fill(Color(red: 0.35, green: 0.22, blue: 0.12))
                        .frame(width: 8)
                        .overlay(Rectangle().stroke(Color.black.opacity(0.5), lineWidth: 0.5))
                    Spacer()
                }
            }
            .opacity(0.4)
            
            VStack {
                Rectangle()
                    .fill(Color(red: 0.38, green: 0.24, blue: 0.14))
                    .frame(height: 7)
                    .overlay(Rectangle().stroke(Color.black.opacity(0.4), lineWidth: 0.5))
                Spacer()
            }
        }
    }
    
    // MARK: - Maden Rayları
    private var railTracks: some View {
        ZStack {
            VStack(spacing: 6) {
                Rectangle().fill(LinearGradient(colors: [.gray, .white.opacity(0.7), .gray], startPoint: .top, endPoint: .bottom)).frame(height: 2)
                Rectangle().fill(LinearGradient(colors: [.gray, .white.opacity(0.7), .gray], startPoint: .top, endPoint: .bottom)).frame(height: 2)
            }
            
            HStack(spacing: 12) {
                ForEach(0..<25) { _ in
                    Rectangle().fill(Color(red: 0.32, green: 0.20, blue: 0.10)).frame(width: 5, height: 14)
                }
            }
        }
    }
    
    // MARK: - Titrek Fener
    private var hangingLantern: some View {
        ZStack {
            Rectangle().fill(Color.black.opacity(0.6)).frame(width: 1, height: 12).offset(y: -8)
            Circle().fill(RadialGradient(colors: [Color.yellow.opacity(0.5 * lanternFlicker), Color.clear], center: .center, startRadius: 2, endRadius: 22)).frame(width: 36, height: 36)
            RoundedRectangle(cornerRadius: 2).fill(Color.yellow).frame(width: 8, height: 10).overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black, lineWidth: 1))
        }
        .rotationEffect(.degrees(lanternSwayAngle))
    }
    
    // MARK: - Animasyonları Başlatma
    private func startAnimations() {
        withAnimation(.easeInOut(duration: cartSpeedDuration).repeatForever(autoreverses: true)) {
            cartXOffset = 150
        }
        withAnimation(.easeInOut(duration: minerSwingSpeed).repeatForever(autoreverses: true)) {
            pickaxeSwingAngle = 35
        }
        withAnimation(.easeInOut(duration: 0.08).repeatForever(autoreverses: true)) {
            jackhammerJitter = 2.0
        }
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            lanternSwayAngle = 6
        }
        withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
            lanternFlicker = 1.15
        }
        Timer.scheduledTimer(withTimeInterval: minerSwingSpeed, repeats: true) { _ in
            isSparkVisible.toggle()
        }
    }
    
    // MARK: - Düşünce Döngüsü
    private func startThoughtCycle() {
        var cycleStep = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showLeftBubble = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showLeftBubble = false
                }
            }
        }
        
        bubbleTimer = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: true) { _ in
            cycleStep += 1
            let isLeftTurn = cycleStep % 2 == 1
            
            if isLeftTurn {
                leftThoughtIndex = (leftThoughtIndex + 1) % Self.minerThoughts.count
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showLeftBubble = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showLeftBubble = false
                    }
                }
            } else {
                rightThoughtIndex = (rightThoughtIndex + 1) % Self.minerThoughts.count
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showRightBubble = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showRightBubble = false
                    }
                }
            }
        }
    }
}
