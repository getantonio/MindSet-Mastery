import Foundation

struct AffirmationCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let keywords: [String]
    let affirmations: [Affirmation]
    
    static let categories: [AffirmationCategory] = [
        .init(id: "confidence", name: "Confidence", keywords: ["confidence", "self-esteem", "doubt", "fear", "shy", "insecure", "worth", "value"], affirmations: loadAffirmations("confidence")),
        .init(id: "emotional-mastery", name: "Emotional Mastery", keywords: ["emotion", "feeling", "anger", "sad", "upset", "mood", "stress", "anxiety", "overwhelm"], affirmations: loadAffirmations("emotional-mastery")),
        .init(id: "focus", name: "Focus", keywords: ["focus", "distraction", "concentrate", "attention", "procrastination", "productivity", "mindful"], affirmations: loadAffirmations("focus")),
        .init(id: "habits", name: "Habits & Discipline", keywords: ["habit", "discipline", "routine", "consistency", "commitment", "structure", "willpower"], affirmations: loadAffirmations("habits")),
        .init(id: "healing", name: "Healing and Recovery", keywords: ["heal", "recovery", "pain", "trauma", "wellness", "health", "restore", "mend"], affirmations: loadAffirmations("healing")),
        .init(id: "self-love", name: "Self-Love", keywords: ["self-love", "self-worth", "self-esteem", "acceptance", "compassion", "inner peace"], affirmations: loadAffirmations("self-love")),
        .init(id: "sleep", name: "Better Sleep", keywords: ["sleep", "rest", "tired", "insomnia", "bed", "night", "dream", "relax", "fatigue"], affirmations: loadAffirmations("sleep")),
        .init(id: "resilience", name: "Resilience", keywords: ["resilient", "strong", "overcome", "challenge", "adversity", "tough", "bounce back", "persevere"], affirmations: loadAffirmations("resilience"))
    ]
    
    static func loadAffirmations(_ category: String) -> [Affirmation] {
        // Load from your affirmations.ts file
        guard let url = Bundle.main.url(forResource: "affirmations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let categoryData = json.first(where: { ($0["id"] as? String) == category }),
              let affirmationsData = categoryData["affirmations"] as? [[String: String]] else {
            return []
        }
        
        return affirmationsData.compactMap { data in
            guard let text = data["text"],
                  let category = data["category"] else { return nil }
            return Affirmation(text: text, category: category)
        }
    }
}

struct Affirmation: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let category: String
    
    // Add variations for different contexts
    func getVariation(for context: AffirmationContext) -> String {
        switch context {
        case .present:
            return text
        case .future:
            return text.replacingOccurrences(of: "I am", with: "I will be")
        case .progressive:
            return text.replacingOccurrences(of: "I am", with: "I am becoming")
        case .gratitude:
            return "I am grateful that " + text.lowercased()
        }
    }
}

enum AffirmationContext {
    case present
    case future
    case progressive
    case gratitude
} 