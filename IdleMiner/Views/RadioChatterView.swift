import SwiftUI

struct RadioChatterView: View {
    let message: MinerRadioMessage
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 28, height: 28)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(message.speaker)
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.yellow)
                
                Text(message.message)
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(white: 0.12).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
        )
    }
}
