import Foundation

enum BigNumberFormatter {
    private static let units = [
        "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td"
    ]
    
    /// Sayıları 1.5K, 2.3M, 10.4B gibi okunabilir formatlara dönüştürür.
    static func format(_ value: Double) -> String {
        guard value.isFinite && !value.isNaN else { return "0" }
        if value < 0 { return "0" }
        if value < 1000 {
            if value == floor(value) {
                return String(format: "%.0f", value)
            } else {
                return String(format: "%.1f", value)
            }
        }
        
        var val = value
        var unitIndex = 0
        
        while val >= 1000 && unitIndex < units.count - 1 {
            val /= 1000
            unitIndex += 1
        }
        
        if val >= 100 {
            return String(format: "%.0f%@", val, units[unitIndex])
        } else if val >= 10 {
            return String(format: "%.1f%@", val, units[unitIndex])
        } else {
            return String(format: "%.2f%@", val, units[unitIndex])
        }
    }
}
