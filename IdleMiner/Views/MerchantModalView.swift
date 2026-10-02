import SwiftUI

struct MerchantModalView: View {
    @ObservedObject var viewModel: GameViewModel
    let onClose: () -> Void
    
    // Süre formatı (mm:ss)
    private var formattedTimeRemaining: String {
        let totalSeconds = max(0, Int(viewModel.merchantTimeRemaining))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // Karartılmış arka plan
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            VStack(spacing: 16) {
                // MARK: - Başlık ve Kalan Süre
                headerSection
                
                // MARK: - Tüccar Fısıltısı & Atmosfer
                merchantAtmosphereBanner
                
                // MARK: - Aktif İksir/Buff Göstergeleri (Varsa)
                if viewModel.merchantMidasTimeRemaining > 0 || viewModel.merchantTurboTimeRemaining > 0 {
                    activeBuffsRow
                }
                
                // MARK: - Teklif Listesi (3 Eşsiz Eşya)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(viewModel.merchantOffers) { offer in
                            offerCard(offer: offer)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Alt Kapat Butonu
                Button(action: onClose) {
                    Text("Pazardan Ayrıl")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.16, green: 0.10, blue: 0.22),
                                Color(red: 0.08, green: 0.07, blue: 0.12),
                                Color.black
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.6),
                                        Color.yellow.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.purple.opacity(0.35), radius: 24, x: 0, y: 8)
            )
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Üst Başlık Bölümü
    private var headerSection: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 36, height: 36)
                    
                    Text("🧙‍♂️")
                        .font(.system(size: 22))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Gizemli Gezgin Tüccar")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Kara Borsa & Yeraltı Malları")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.purple.opacity(0.85))
                }
            }
            
            Spacer()
            
            // Canlı Geri Sayım Rozeti
            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 11, weight: .bold))
                Text(formattedTimeRemaining)
                    .font(.system(size: 13, weight: .black, design: .monospaced))
            }
            .foregroundColor(.yellow)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.yellow.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.yellow.opacity(0.4), lineWidth: 1))
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 4)
        }
    }
    
    // MARK: - Atmosfer Balonu
    private var merchantAtmosphereBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "quote.opening")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.purple)
            
            Text("Derin mağaraların karanlığından fısıltılar getirdim... Bu eşyaları yüzeydeki tezgahlarda bulamazsın madenci.")
                .font(.system(size: 12, weight: .medium, design: .serif))
                .foregroundColor(.white.opacity(0.85))
                .italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.purple.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    // MARK: - Aktif Buff Göstergesi
    private var activeBuffsRow: some View {
        HStack(spacing: 8) {
            if viewModel.merchantMidasTimeRemaining > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                    Text("Midas 3×: \(Int(viewModel.merchantMidasTimeRemaining))s")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.2))
                .clipShape(Capsule())
            }
            
            if viewModel.merchantTurboTimeRemaining > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("Turbo Hız: \(Int(viewModel.merchantTurboTimeRemaining))s")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.cyan)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.cyan.opacity(0.2))
                .clipShape(Capsule())
            }
            
            Spacer()
        }
    }
    
    // MARK: - Teklif Kartı
    private func offerCard(offer: MerchantOffer) -> some View {
        let canAfford: Bool = {
            switch offer.currency {
            case .gold:
                return viewModel.gold >= offer.cost
            case .gems:
                return Double(viewModel.gems) >= offer.cost
            }
        }()
        
        return HStack(spacing: 12) {
            // İkon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        offer.isPurchased ? Color.gray.opacity(0.2) : Color.purple.opacity(0.25)
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: offer.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(offer.isPurchased ? .gray : (offer.currency == .gems ? .cyan : .yellow))
            }
            
            // Bilgiler
            VStack(alignment: .leading, spacing: 3) {
                Text(offer.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(offer.isPurchased ? .gray : .white)
                
                Text(offer.description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(offer.isPurchased ? .gray.opacity(0.7) : .white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer(minLength: 4)
            
            // Satın Alma Butonu
            if offer.isPurchased {
                Text("ALINDI ✓")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Button(action: {
                    viewModel.purchaseMerchantOffer(offer: offer)
                }) {
                    VStack(spacing: 2) {
                        Text("Satın Al")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                        
                        HStack(spacing: 2) {
                            if offer.currency == .gems {
                                Image(systemName: "suit.diamond.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.cyan)
                                Text("\(Int(offer.cost))")
                                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            } else {
                                Image(systemName: "circle.circle.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.yellow)
                                Text(BigNumberFormatter.format(offer.cost))
                                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            }
                        }
                    }
                    .foregroundColor(canAfford ? .black : .white.opacity(0.4))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        canAfford ?
                        LinearGradient(
                            colors: offer.currency == .gems ? [Color.cyan, Color.blue] : [Color.yellow, Color.orange],
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: canAfford ? (offer.currency == .gems ? Color.cyan.opacity(0.4) : Color.orange.opacity(0.4)) : .clear, radius: 4)
                }
                .disabled(!canAfford)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(offer.isPurchased ? 0.02 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            offer.isPurchased ? Color.white.opacity(0.04) : Color.purple.opacity(0.25),
                            lineWidth: 1
                        )
                )
        )
    }
}
