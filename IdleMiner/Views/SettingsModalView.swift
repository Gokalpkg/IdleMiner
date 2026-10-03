import SwiftUI

struct SettingsModalView: View {
    @ObservedObject var viewModel: GameViewModel
    let onClose: () -> Void
    
    @State private var soundEnabled: Bool = AudioManager.shared.isSoundEnabled
    @State private var hapticsEnabled: Bool = AudioManager.shared.isHapticsEnabled
    @State private var thoughtsEnabled: Bool = AudioManager.shared.isWorkerThoughtsEnabled
    @State private var showResetConfirmation: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            VStack(spacing: 18) {
                // MARK: - Başlık
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("Oyun Ayarları & İstatistik")
                            .font(.system(size: 19, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // MARK: - Ses ve Titreşim Seçenekleri
                        VStack(spacing: 12) {
                            toggleRow(
                                title: "Ses Efektleri",
                                subtitle: "Kazma vuruşları ve aksiyon tonları",
                                icon: "speaker.wave.2.fill",
                                color: .orange,
                                isOn: $soundEnabled
                            ) { val in
                                AudioManager.shared.isSoundEnabled = val
                            }
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            toggleRow(
                                title: "Titreşim & Haptik",
                                subtitle: "Kazma ve ödül titreşim geribildirimleri",
                                icon: "iphone.radiowaves.left.and.right",
                                color: .cyan,
                                isOn: $hapticsEnabled
                            ) { val in
                                AudioManager.shared.isHapticsEnabled = val
                                if val {
                                    AudioManager.shared.triggerImpact(style: .medium)
                                }
                            }
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            toggleRow(
                                title: "Madenci Düşünceleri",
                                subtitle: "İşçilerin kafasında beliren baloncuklar",
                                icon: "bubble.left.and.bubble.right.fill",
                                color: .yellow,
                                isOn: $thoughtsEnabled
                            ) { val in
                                AudioManager.shared.isWorkerThoughtsEnabled = val
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        
                        // MARK: - Madenci Karnesi & Canlı İstatistikler (Seçenek 3)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.yellow)
                                Text("MADENCİ KARNESİ (İSTATİSTİKLER)")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundColor(.yellow)
                            }
                            
                            VStack(spacing: 8) {
                                statRow(title: "Toplam Kazılan Altın", value: BigNumberFormatter.format(viewModel.totalGoldMined), icon: "circle.circle.fill", color: .yellow)
                                statRow(title: "Toplam Kazma Vuruşu", value: "\(viewModel.totalClicks)", icon: "hammer.fill", color: .orange)
                                statRow(title: "Ulaşılan En Derin Katman", value: "\(Int(viewModel.depth)) Metre (\(viewModel.currentOreLayer.name))", icon: "arrow.down.circle.fill", color: .green)
                                statRow(title: "Keşfedilen Antik Eser", value: "\(viewModel.artifacts.filter({ $0.isUnlocked }).count) / \(viewModel.artifacts.count) Eser", icon: "building.columns.fill", color: .purple)
                                statRow(title: "Aktif Maden Dünyası", value: viewModel.currentWorld.name, icon: "globe.americas.fill", color: .blue)
                                statRow(title: "Maden Prestij Seviyesi", value: "Seviye \(viewModel.prestigeLevel) (\(Int(viewModel.prestigeMultiplier))x)", icon: "sparkles", color: .cyan)
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        
                        // MARK: - Gezgin Tüccarı Çağır (Hızlı Etkinlik)
                        Button(action: {
                            onClose()
                            viewModel.spawnMerchant()
                        }) {
                            HStack(spacing: 8) {
                                Text("🧙‍♂️")
                                    .font(.system(size: 16))
                                Text("Gizemli Gezgin Tüccarı Çağır")
                                    .font(.system(size: 13, weight: .bold))
                                Spacer()
                                Image(systemName: "sparkles")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.purple)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .background(Color.purple.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                            )
                        }
                        
                        // MARK: - Veri Sıfırlama (Danger Zone)
                        VStack(spacing: 8) {
                            Button(action: {
                                showResetConfirmation = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash.fill")
                                    Text("Tüm Oyunu Sıfırla")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundColor(.red.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.red.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.25), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Versiyon & Geliştirici Bilgisi
                        Text("Idle Miner v1.4.0 • Built with Swift & SwiftUI")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.top, 4)
                    }
                }
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .alert("Tüm İlerleme Sıfırlansın mı?", isPresented: $showResetConfirmation) {
            Button("İptal", role: .cancel) {}
            Button("Evet, Sıfırla", role: .destructive) {
                viewModel.resetAllData()
                onClose()
            }
        } message: {
            Text("Tüm altın, derinlik, satın alınan yükseltmeler ve eserler sıfırlanacaktır. Bu işlem geri alınamaz!")
        }
        .onAppear {
            soundEnabled = AudioManager.shared.isSoundEnabled
            hapticsEnabled = AudioManager.shared.isHapticsEnabled
            thoughtsEnabled = AudioManager.shared.isWorkerThoughtsEnabled
        }
    }
    
    private func toggleRow(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        isOn: Binding<Bool>,
        onChange: @escaping (Bool) -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isOn.wrappedValue },
                set: { newVal in
                    isOn.wrappedValue = newVal
                    onChange(newVal)
                }
            ))
            .labelsHidden()
            .tint(.yellow)
        }
    }
    
    private func statRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.75))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 3)
    }
}
