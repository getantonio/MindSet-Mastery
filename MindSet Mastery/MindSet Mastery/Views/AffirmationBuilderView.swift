import SwiftUI
import CoreData

struct AffirmationBuilderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newAffirmation = ""
    @State private var selectedTemplate = 0
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomAffirmation.createdAt, ascending: false)]
    ) private var customAffirmations: FetchedResults<CustomAffirmation>
    
    let templates = [
        "I am [positive trait]",
        "Every day I [positive action]",
        "I choose to [empowering choice]",
        "I deserve [positive outcome]",
        "My [aspect] is [positive state]"
    ]
    
    let examples = [
        "I am confident and capable",
        "Every day I grow stronger",
        "I choose to embrace opportunities",
        "I deserve abundance and joy",
        "My mind is clear and focused"
    ]
    
    let wordSuggestions = [
        "positive trait": ["confident", "strong", "capable", "resilient", "worthy", "powerful"],
        "positive action": ["grow", "improve", "succeed", "thrive", "excel", "progress"],
        "empowering choice": ["embrace change", "take action", "stay focused", "remain positive"],
        "positive outcome": ["success", "happiness", "abundance", "peace", "fulfillment"],
        "aspect": ["mind", "body", "spirit", "energy", "potential"],
        "positive state": ["powerful", "unlimited", "expanding", "flourishing", "thriving"]
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Template Selector
                Menu {
                    ForEach(0..<templates.count, id: \.self) { index in
                        Button(templates[index]) {
                            selectedTemplate = index
                            newAffirmation = templates[index]
                        }
                    }
                } label: {
                    HStack {
                        Text("Template")
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.green)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color(white: 0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Example
                Text(examples[selectedTemplate])
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Word Suggestions
            let currentTemplate = templates[selectedTemplate]
            ForEach(extractPlaceholders(from: currentTemplate), id: \.self) { placeholder in
                if let suggestions = wordSuggestions[placeholder] {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            Text("\(placeholder):")
                                .font(.caption)
                                .foregroundColor(.green)
                            ForEach(suggestions, id: \.self) { word in
                                Button(word) {
                                    insertWord(word, for: placeholder, in: currentTemplate)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(white: 0.2))
                                .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            
            // Input and Save
            HStack {
                TextField("Type your affirmation", text: $newAffirmation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.white)
                
                Button(action: saveAffirmation) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                .disabled(newAffirmation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            // Custom Affirmations List
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(customAffirmations) { affirmation in
                        HStack {
                            Text(affirmation.text)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: { deleteAffirmation(affirmation) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(8)
                        .background(Color(white: 0.15))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(8)
    }
    
    private func extractPlaceholders(from template: String) -> [String] {
        let pattern = "\\[(.*?)\\]"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(template.startIndex..., in: template)
        let matches = regex.matches(in: template, range: range)
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: template) else { return nil }
            return String(template[range])
        }
    }
    
    private func insertWord(_ word: String, for placeholder: String, in template: String) {
        if newAffirmation.isEmpty {
            newAffirmation = template.replacingOccurrences(of: "[\(placeholder)]", with: word)
        } else {
            newAffirmation = newAffirmation.replacingOccurrences(of: "[\(placeholder)]", with: word)
        }
    }
    
    private func deleteAffirmation(_ affirmation: CustomAffirmation) {
        viewContext.delete(affirmation)
        try? viewContext.save()
    }
    
    private func saveAffirmation() {
        let affirmation = CustomAffirmation(context: viewContext)
        affirmation.id = UUID()
        affirmation.text = newAffirmation
        affirmation.createdAt = Date()
        
        try? viewContext.save()
        newAffirmation = ""
    }
} 