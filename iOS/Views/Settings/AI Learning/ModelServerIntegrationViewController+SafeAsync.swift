// Proprietary Software License Version 1.0
//
// Copyright (C) 2025 BDG
//
// Backdoor App Signer is proprietary software. You may not use, modify, or distribute it except as expressly permitted under the terms of the Proprietary Software License.

import Foundation
import UIKit

/// Extension to ensure proper async/await usage in view controllers
extension ModelServerIntegrationViewController {
    
    /// Safe wrapper for async tasks that ensures proper await usage
    func performAsyncSafely(_ task: @escaping () async -> Void) {
        Task {
            await task()
        }
    }
    
    /// Safe method to check server status with proper async/await handling
    func checkServerStatusSafely() {
        performAsyncSafely { [weak self] in
            do {
                let modelInfo = try await BackdoorAIClient.shared.getLatestModelInfo()
                DispatchQueue.main.async {
                    self?.updateServerStatusUI(status: "Online", message: "Latest model: \(modelInfo.latestModelVersion)", isError: false)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.updateServerStatusUI(status: "Error", message: error.localizedDescription, isError: true)
                }
            }
        }
    }
    
    /// Updates the server status UI using the public method instead of direct label access
    private func updateServerStatusUI(status: String, message: String, isError: Bool) {
        let statusText = "Server status: \(status)\n\(message)"
        updateStatusLabel(text: statusText, isError: isError)
    }
    
    /// Safe wrapper for model uploads using proper async/await
    func uploadModelSafely(completion: @escaping (Bool, String) -> Void) {
        performAsyncSafely { [weak self] in
            guard let self = self else { return }
            
            let result = await AILearningManager.shared.uploadTrainedModelToServer()
            
            DispatchQueue.main.async {
                completion(result.success, result.message)
            }
        }
    }
}
