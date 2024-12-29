import Foundation

class AffirmationGenerator {
    static let shared = AffirmationGenerator()
    
    private let affirmationTemplates: [String: [String]] = [
        "anxiety": [
            "I am calm and in control",
            "I choose peace over worry",
            "I am safe and secure",
            "My mind is peaceful and quiet",
            "I release all tension and anxiety"
        ],
        "confidence": [
            "I am confident and capable",
            "I believe in my abilities",
            "I am worthy of success",
            "I trust my decisions",
            "I radiate confidence and self-assurance"
        ],
        "motivation": [
            "I am driven and focused",
            "I take action towards my goals",
            "I am unstoppable",
            "I embrace challenges as opportunities",
            "I am passionate and determined"
        ]
        // Add more categories as needed
    ]
    
    func generateAffirmations(for category: BehaviorCategory) -> [String] {
        let templates = affirmationTemplates[category.name.lowercased()] ?? []
        if templates.isEmpty {
            return category.defaultAffirmations
        }
        
        // Randomly select 3 unique affirmations
        return Array(Set(templates)).shuffled().prefix(3).map { $0 }
    }
} 