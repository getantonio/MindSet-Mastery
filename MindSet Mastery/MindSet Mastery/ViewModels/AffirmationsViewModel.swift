import Foundation
import SwiftUI

@MainActor
class AffirmationsViewModel: ObservableObject {
    @Published var currentAffirmations: [String] = []
    @Published var isLoading = false
    
    private var affirmationBank: [String: [String]] = [:]
    
    init() {
        loadAffirmationBank()
    }
    
    private func loadAffirmationBank() {
        guard let url = Bundle.main.url(forResource: "affirmations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode(AffirmationData.self, from: data) else {
            print("Failed to load affirmations")
            return
        }
        
        // Convert to dictionary for quick access
        json.categories.forEach { category in
            affirmationBank[category.id] = category.affirmations.map { $0.text }
        }
    }
    
    func refreshAffirmations(for category: BehaviorCategory) {
        isLoading = true
        
        Task {
            // Get affirmations for this category
            let categoryAffirmations = getAffirmationsForCategory(category.name)
            
            // Ensure we have affirmations
            guard !categoryAffirmations.isEmpty else {
                print("No affirmations found for category: \(category.name)")
                await MainActor.run {
                    self.isLoading = false
                }
                return
            }
            
            // Select 3 random unique affirmations
            var selected: [String] = []
            var available = categoryAffirmations
            
            while selected.count < 3 && !available.isEmpty {
                let randomIndex = Int.random(in: 0..<available.count)
                selected.append(available.remove(at: randomIndex))
            }
            
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
            
            await MainActor.run {
                self.currentAffirmations = selected
                self.isLoading = false
            }
        }
    }
    
    private func getAffirmationsForCategory(_ category: String) -> [String] {
        switch category.lowercased() {
        case "sleep":
            return [
                "I fall asleep easily and naturally",
                "My mind is calm and ready for rest",
                "I drift into peaceful slumber",
                "My body knows how to rest deeply",
                "I welcome refreshing sleep"
            ]
        case "focus":
            return [
                "My concentration is razor sharp",
                "I maintain perfect focus",
                "My mind is clear and directed",
                "I accomplish tasks with ease",
                "Distractions fade away naturally"
            ]
        case "relationship":
            return [
                "I attract healthy relationships",
                "My connections grow stronger daily",
                "I communicate with clarity and love",
                "I deserve fulfilling relationships",
                "I give and receive love freely"
            ]
        case "anxiety":
            return [
                "I choose peace over worry",
                "My mind is naturally calm",
                "I breathe in serenity",
                "I release all anxiety",
                "Peace flows through me"
            ]
        case "gratitude":
            return [
                "I am deeply grateful for my life",
                "I see beauty in every moment",
                "My heart is full of appreciation",
                "I celebrate life's blessings",
                "Gratitude fills my being"
            ]
        case "forgiveness":
            return [
                "I choose to forgive and release",
                "I free myself through forgiveness",
                "I let go of past hurts",
                "Peace replaces resentment",
                "My heart grows through forgiveness"
            ]
        case "motivation":
            return [
                "I am driven to succeed",
                "My energy is limitless",
                "I take inspired action",
                "My motivation grows stronger",
                "I pursue my goals relentlessly"
            ]
        case "addiction":
            return [
                "I choose healthy alternatives",
                "My willpower grows stronger",
                "I break free from old patterns",
                "I embrace positive change",
                "I am in control of my choices"
            ]
        case "depression":
            return [
                "I welcome light into my life",
                "Joy flows through me naturally",
                "I choose happiness each day",
                "My spirit lifts higher",
                "I embrace positive energy"
            ]
        case "stress":
            return [
                "I remain calm under pressure",
                "Peace flows through my body",
                "I handle challenges with ease",
                "Tranquility is my natural state",
                "I choose relaxation over stress"
            ]
        case "fear":
            return [
                "I face challenges courageously",
                "I am stronger than my fears",
                "Confidence replaces doubt",
                "I move forward boldly",
                "I embrace new opportunities"
            ]
        case "anger":
            return [
                "I respond with calmness",
                "Peace guides my actions",
                "I choose understanding over anger",
                "I maintain emotional balance",
                "Serenity flows through me"
            ]
        case "procrastination":
            return [
                "I take action immediately",
                "I complete tasks efficiently",
                "I embrace productive habits",
                "I move forward decisively",
                "I choose action over delay"
            ]
        case "self-doubt":
            return [
                "I trust my inner wisdom",
                "I believe in my abilities",
                "I am confident and capable",
                "I embrace my potential",
                "My self-belief is unshakeable"
            ]
        default:
            return []
        }
    }
    
    private func createVariation(of affirmation: String) -> String {
        let variations = [
            "I am becoming someone who \(affirmation.lowercased())",
            "Each day \(affirmation.lowercased())",
            "I choose to \(affirmation.lowercased())",
            "I naturally \(affirmation.lowercased())"
        ]
        return variations.randomElement() ?? affirmation
    }
}

// Add these structs for JSON decoding
struct AffirmationData: Codable {
    let categories: [CategoryData]
}

struct CategoryData: Codable {
    let id: String
    let name: String
    let affirmations: [AffirmationItem]
}

struct AffirmationItem: Codable {
    let text: String
    let category: String
} 