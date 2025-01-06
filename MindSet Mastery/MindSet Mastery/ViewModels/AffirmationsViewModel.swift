import Foundation
import SwiftUI

@MainActor
class AffirmationsViewModel: ObservableObject {
    @Published var currentAffirmations: [String] = []
    @Published var isLoading = false
    
    private var usedAffirmations: [String: Set<String>] = [:]
    
    func initializeAffirmations(for category: BehaviorCategory) {
        print("Initializing affirmations for: \(category.name)")
        print("Available affirmations: \(category.defaultAffirmations.count)")
        
        // Safety check
        guard !category.defaultAffirmations.isEmpty else {
            print("No affirmations available")
            return
        }
        
        // Get three random affirmations
        let shuffled = category.defaultAffirmations.shuffled()
        let initial = Array(shuffled.prefix(3))
        
        // Update on main thread
        DispatchQueue.main.async {
            withAnimation {
                self.currentAffirmations = initial
                self.usedAffirmations[category.id] = Set(initial)
                print("Initialized with \(initial.count) affirmations")
            }
        }
    }
    
    func refreshAffirmations(for category: BehaviorCategory) {
        print("Refreshing affirmations for: \(category.name)")
        
        guard !category.defaultAffirmations.isEmpty else {
            print("No affirmations to refresh")
            return
        }
        
        isLoading = true
        
        // Get unused affirmations
        let used = usedAffirmations[category.id] ?? []
        let available = category.defaultAffirmations.filter { !used.contains($0) }
        
        // Reset if needed
        if available.count < 3 {
            print("Resetting used affirmations")
            usedAffirmations[category.id] = []
            let shuffled = category.defaultAffirmations.shuffled()
            let selected = Array(shuffled.prefix(3))
            
            DispatchQueue.main.async {
                self.currentAffirmations = selected
                self.usedAffirmations[category.id] = Set(selected)
                self.isLoading = false
                print("Refreshed with \(selected.count) new affirmations")
            }
            return
        }
        
        // Select new ones
        let shuffled = available.shuffled()
        let selected = Array(shuffled.prefix(3))
        
        DispatchQueue.main.async {
            self.currentAffirmations = selected
            self.usedAffirmations[category.id]?.formUnion(selected)
            self.isLoading = false
            print("Refreshed with \(selected.count) new affirmations")
        }
    }
} 