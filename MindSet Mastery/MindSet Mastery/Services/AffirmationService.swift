import Foundation

class AffirmationService: ObservableObject {
    static let shared = AffirmationService()
    
    private let openAIKey: String = "" // Add your OpenAI API key here
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    @Published private(set) var isLoading = false
    
    func generateAffirmations(for category: BehaviorCategory) async throws -> [String] {
        isLoading = true
        defer { isLoading = false }
        
        let prompt = """
        Generate 3 powerful, positive affirmations for someone dealing with \(category.name.lowercased()). 
        The affirmations should be:
        1. Personal and use "I" statements
        2. Present tense
        3. Positive (avoid negative words)
        4. Specific to \(category.name.lowercased())
        5. Emotionally engaging
        
        Format: Return only the 3 affirmations, one per line.
        """
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are an expert in positive psychology and personal development."],
            ["role": "user", "content": prompt]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 150
        ]
        
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        let affirmationsText = response.choices.first?.message.content ?? ""
        return affirmationsText.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
    }
    
    // Fallback affirmations if API is unavailable
    func getFallbackAffirmations(for category: BehaviorCategory) -> [String] {
        category.defaultAffirmations
    }
}

// OpenAI API Response Models
private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
} 