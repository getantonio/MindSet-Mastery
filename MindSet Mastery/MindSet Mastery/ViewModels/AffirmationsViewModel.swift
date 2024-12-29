import Foundation
import SwiftUI

@MainActor
class AffirmationsViewModel: ObservableObject {
    @Published var currentAffirmations: [String] = []
    @Published var isLoading = false
    
    func refreshAffirmations(for category: BehaviorCategory) {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentAffirmations = category.defaultAffirmations.shuffled()
            self.isLoading = false
        }
    }
} 