import SwiftUI

struct MineShaftView: View {
    @ObservedObject var viewModel: GameViewModel
    
    // Asansör makara animasyonu
    @State private var pulleyRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // MARK: - 1. Asansör Kontrol Kulesi (Elevator Master Card)
            elevatorMasterCard
            
            // MARK: - 2. Maden Katları Listesi (1 - 8)
            ForEach(viewModel.shafts) { shaft in
                shaftFloorCard(shaft: shaft)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                pulleyRotation = 360
            }
        }
    }
    
    // MARK: - Asansör Ana Kontrol Kartı
    private var elevatorMasterCard: some View {
        let elevatorMultiplier = 1.0 + Double(viewModel.elevatorLevel - 1) * 0.25
        let canUpgrade = viewModel.canUpgradeElevator
        
        return VStack(spacing: 10) {
            HStack(spacing: 12) {
                // Dönen Asansör Makarası & Kabin İkonu
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "gearshape.2.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(pulleyRotation))
                    
                    Image(systemName: "arrow.up.and.down")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("DİKEY ASANSÖR KUYUSU")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Lv. \(viewModel.elevatorLevel)")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow)
                            .clipShape(Capsule())
                    }
                    
                    Text("Tüm maden katlarının cevherini yüzeye taşır")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 10) {
                        HStack(spacing: 3) {
                            Text("Taşıma Çarpanı:")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Text(String(format: "%.2fx", elevatorMultiplier))
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        
                        HStack(spacing: 3) {
                            Text("Şaft Geliri:")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Text("+\(BigNumberFormatter.format(viewModel.shaftPassiveIncome))/sn")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer(minLength: 2)
            }
            
            // Asansör Güçlendirme Butonu
            Button(action: {
                viewModel.upgradeElevator()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Asansör Makaralarını Güçlendir (+%25)")
                            .font(.system(size: 11, weight: .bold))
                        Text("Tüm katların üretim aktarımını artırır")
                            .font(.system(size: 9))
                            .opacity(0.8)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "circle.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text(BigNumberFormatter.format(viewModel.elevatorUpgradeCost))
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                    }
                }
                .foregroundColor(canUpgrade ? .black : .white.opacity(0.4))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    canUpgrade ?
                    LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom) :
                    LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .disabled(!canUpgrade)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.14, green: 0.12, blue: 0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Maden Katı Kartı
    private func shaftFloorCard(shaft: MineShaft) -> some View {
        let isDepthReached = viewModel.depth >= shaft.depthRequirement
        let canUnlock = isDepthReached && viewModel.gold >= shaft.unlockCost
        let canUpgrade = shaft.isUnlocked && viewModel.gold >= shaft.upgradeCost
        let cardColor = colorForShaft(shaft.colorName)
        
        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                // Kat Derinlik & İkon Kutusu
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(cardColor.opacity(shaft.isUnlocked ? 0.25 : 0.08))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: shaft.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(shaft.isUnlocked ? cardColor : .gray)
                }
                
                // Kat Bilgileri
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(shaft.name)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(shaft.isUnlocked ? .white : .gray)
                        
                        if shaft.isUnlocked {
                            Text("Lv. \(shaft.level)")
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1.5)
                                .background(cardColor.opacity(0.7))
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 8))
                            Text("\(Int(shaft.depthRequirement))m")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.gray)
                        
                        if shaft.isUnlocked {
                            HStack(spacing: 2) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 8))
                                Text("+\(BigNumberFormatter.format(shaft.currentIncomePerSec))/sn")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .foregroundColor(.green)
                            }
                        } else {
                            Text(isDepthReached ? "Kazıya Hazır" : "Gereken Derinlik: \(Int(shaft.depthRequirement))m")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(isDepthReached ? .yellow : .red.opacity(0.8))
                        }
                    }
                }
                
                Spacer(minLength: 4)
                
                // Sağ Aksiyon Butonu (Açma veya Yükseltme)
                if shaft.isUnlocked {
                    Button(action: {
                        viewModel.upgradeShaft(id: shaft.id)
                    }) {
                        VStack(spacing: 2) {
                            Text("Geliştir")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                            
                            HStack(spacing: 2) {
                                Image(systemName: "circle.circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.yellow)
                                Text(BigNumberFormatter.format(shaft.upgradeCost))
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            }
                        }
                        .foregroundColor(canUpgrade ? .black : .white.opacity(0.4))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            canUpgrade ?
                            LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .disabled(!canUpgrade)
                } else {
                    Button(action: {
                        viewModel.unlockShaft(id: shaft.id)
                    }) {
                        VStack(spacing: 2) {
                            Text("Katı Kaz")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                            
                            HStack(spacing: 2) {
                                Image(systemName: "circle.circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.yellow)
                                Text(BigNumberFormatter.format(shaft.unlockCost))
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            }
                        }
                        .foregroundColor(canUnlock ? .black : .white.opacity(0.4))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            canUnlock ?
                            LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .disabled(!canUnlock)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(shaft.isUnlocked ? 0.05 : 0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            shaft.isUnlocked ? cardColor.opacity(0.3) : Color.white.opacity(0.05),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // Renk Yardımcısı
    private func colorForShaft(_ name: String) -> Color {
        switch name {
        case "gray": return .gray
        case "black": return Color(white: 0.6)
        case "orange": return .orange
        case "blue": return .blue
        case "yellow": return .yellow
        case "green": return .green
        case "cyan": return .cyan
        case "red": return .red
        default: return .yellow
        }
    }
}
