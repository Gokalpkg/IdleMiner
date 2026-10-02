import SwiftUI

struct MiningParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double = 1.0
    var isDiamondShard: Bool
}

@MainActor
final class ParticleManager: ObservableObject {
    @Published var particles: [MiningParticle] = []
    
    func emitBurst(at point: CGPoint = .zero, count: Int = 16, primaryColor: Color, secondaryColor: Color) {
        var newParticles: [MiningParticle] = []
        
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 140...340)
            let vx = cos(angle) * speed
            // Hafif yukarı fırlama açısı
            let vy = sin(angle) * speed - CGFloat.random(in: 70...150)
            let size = CGFloat.random(in: 4...9)
            
            let colorChoices: [Color] = [.yellow, .white, primaryColor, secondaryColor, .orange]
            let color = colorChoices.randomElement() ?? .yellow
            let isDiamond = Bool.random()
            
            newParticles.append(
                MiningParticle(
                    x: point.x,
                    y: point.y,
                    vx: vx,
                    vy: vy,
                    size: size,
                    color: color,
                    opacity: 1.0,
                    isDiamondShard: isDiamond
                )
            )
        }
        
        // Aşırı tıklamada performansı korumak için tavan sınır
        if particles.count > 120 {
            particles.removeFirst(particles.count - 120)
        }
        particles.append(contentsOf: newParticles)
    }
    
    func update(dt: Double) {
        guard !particles.isEmpty else { return }
        let gravity: CGFloat = 650.0 // Gerçekçi yerçekimi ivmesi
        
        for i in (0..<particles.count).reversed() {
            particles[i].x += particles[i].vx * CGFloat(dt)
            particles[i].y += particles[i].vy * CGFloat(dt)
            particles[i].vy += gravity * CGFloat(dt)
            particles[i].opacity -= dt * 1.9 // Yaklaşık 0.5 saniyede süzülerek solar
            
            if particles[i].opacity <= 0 {
                particles.remove(at: i)
            }
        }
    }
}

// 60/120 FPS GPU Destekli SwiftUI Canvas Görünümü
struct ParticleCanvasView: View {
    @ObservedObject var manager: ParticleManager
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                for p in manager.particles {
                    let rect = CGRect(
                        x: center.x + p.x - p.size / 2,
                        y: center.y + p.y - p.size / 2,
                        width: p.size,
                        height: p.size
                    )
                    
                    var pContext = context
                    pContext.opacity = p.opacity
                    
                    if p.isDiamondShard {
                        // Elmas/Kristal Kıymığı (Baklava Şeklinde)
                        var path = Path()
                        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
                        path.closeSubpath()
                        pContext.fill(path, with: .color(p.color))
                    } else {
                        // Yuvarlak Altın Kıvılcımı
                        pContext.fill(Path(ellipseIn: rect), with: .color(p.color))
                    }
                }
            }
            .onChange(of: timeline.date) { _ in
                manager.update(dt: 1.0 / 60.0)
            }
        }
        .allowsHitTesting(false)
    }
}
