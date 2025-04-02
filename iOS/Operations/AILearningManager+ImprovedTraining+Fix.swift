// Proprietary Software License Version 1.0
//
// Copyright (C) 2025 BDG
//
// Backdoor App Signer is proprietary software. You may not use, modify, or distribute it except as expressly permitted under the terms of the Proprietary Software License.

import Foundation
import CoreML
import CreateML
import UIKit

/// Extension with simplified fixes for argument calls in ImprovedTraining
extension AILearningManager {
    
    /// Use this function to check if there's enough data to train a new model
    func checkTrainingRequirements() -> Bool {
        // Check if learning is enabled
        guard isLearningEnabled else {
            return false
        }
        
        // Get counts with proper lock handling
        interactionsLock.lock()
        behaviorsLock.lock()
        patternsLock.lock()
        
        let totalDataPoints = storedInteractions.count + userBehaviors.count + appUsagePatterns.count
        
        interactionsLock.unlock()
        behaviorsLock.unlock()
        patternsLock.unlock()
        
        // Need at least 5 data points
        return totalDataPoints >= 5
    }
    
    /// Handles uploading a trained model with proper error handling
    func handleModelUpload() async -> (success: Bool, message: String) {
        guard let modelURL = getLatestModelURL() else {
            return (false, "No model available to upload")
        }
        
        do {
            // Safe async call with proper await
            let message = try await BackdoorAIClient.shared.uploadModel(at: modelURL)
            return (true, message)
        } catch {
            return (false, error.localizedDescription)
        }
    }
}
