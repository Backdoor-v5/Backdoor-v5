// Proprietary Software License Version 1.0
//
// Copyright (C) 2025 BDG
//
// Backdoor App Signer is proprietary software. You may not use, modify, or distribute it except as expressly permitted under the terms of the Proprietary Software License.

import UIKit

// Extension to help with using UIColors in Lottie animations
extension UIColor {
    // Data structure to represent Lottie color value without importing Lottie package
    struct LottieColorValue {
        let r: Double
        let g: Double
        let b: Double
        let a: Double
    }
    
    // Convert UIColor to Lottie Color value
    var lottieColorValue: LottieColorValue {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Get RGBA components
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Return Lottie color value in expected format
        return LottieColorValue(r: Double(red), g: Double(green), b: Double(blue), a: Double(alpha))
    }
}
