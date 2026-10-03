import Foundation
import AudioToolbox
import UIKit

final class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "setting_sound_enabled")
        }
    }
    
    @Published var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: "setting_haptics_enabled")
        }
    }
    
    @Published var isWorkerThoughtsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isWorkerThoughtsEnabled, forKey: "setting_thoughts_enabled")
        }
    }
    
    // Önceden ısıtılmış (pre-warmed) haptik jeneratörleri - anlık ve net tepki verir
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "setting_sound_enabled") as? Bool ?? true
        self.isHapticsEnabled = UserDefaults.standard.object(forKey: "setting_haptics_enabled") as? Bool ?? true
        self.isWorkerThoughtsEnabled = UserDefaults.standard.object(forKey: "setting_thoughts_enabled") as? Bool ?? true
        
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationGenerator.prepare()
    }
    
    // MARK: - Cevher Türüne Göre Değişen SFX
    /// Taş katmanında tok ses, Altın katmanında metalik çınlama, Elmas/Kristal katmanında cam kırılması tonu.
    func playOreHitSound(for layerName: String) {
        guard isSoundEnabled else { return }
        
        if layerName.contains("Elmas") || layerName.contains("Kristal") || layerName.contains("Zümrüt") {
            AudioServicesPlaySystemSound(1057) // Parlak zil/kristal tonu
        } else if layerName.contains("Altın") || layerName.contains("Bakır") || layerName.contains("Demir") {
            AudioServicesPlaySystemSound(1052) // Metalik tok vuruş
        } else {
            AudioServicesPlaySystemSound(1052) // Tok vuruş tonu
        }
    }
    
    /// Kritik Vuruş SFX (Büyük darbe)
    func playCriticalHitSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1022) // Yüksek etki ve yankılı vuruş
    }
    
    /// Ekipman satın alma / yükseltme sesi (çınlama)
    func playUpgradeSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1057)
    }
    
    /// Prestij / Eser bulma / Büyük kutlama sesi
    func playCelebrationSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1025)
    }
    
    /// Gizemli Gezgin Tüccar geliş sesi (Mistik çan / gong)
    func playMerchantArrivalSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1033) // Mistik fısıltılı gong / ton
    }
    
    /// Kara borsa eşya alım sesi
    func playMerchantPurchaseSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1054) // Sihirli parıltı tonu
    }
    
    // MARK: - Haptik Geri Bildirim (Yalnızca isHapticsEnabled açıkken çalışır)
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        // Kesin kontrol: ayar kapalıysa ASLA titreşim çalıştırma
        guard isHapticsEnabled else { return }
        
        switch style {
        case .light:
            lightImpact.impactOccurred()
            lightImpact.prepare()
        case .medium:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        case .heavy:
            heavyImpact.impactOccurred()
            heavyImpact.prepare()
        case .rigid:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        case .soft:
            lightImpact.impactOccurred()
            lightImpact.prepare()
        @unknown default:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        }
    }
    
    func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        // Kesin kontrol: ayar kapalıysa ASLA titreşim çalıştırma
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(type)
        notificationGenerator.prepare()
    }
}
