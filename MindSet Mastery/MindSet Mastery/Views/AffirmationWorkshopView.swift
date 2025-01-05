import SwiftUI
import CoreData

struct AffirmationWorkshopView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var newAffirmation = ""
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomAffirmation.createdAt, ascending: false)]
    ) private var customAffirmations: FetchedResults<CustomAffirmation>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Input section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create New Affirmation")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    TextEditor(text: $newAffirmation)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(white: 0.15))
                        .cornerRadius(8)
                    
                    Button(action: saveAffirmation) {
                        Text("Add Affirmation")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .disabled(newAffirmation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                
                // Custom affirmations list
                List {
                    ForEach(customAffirmations) { affirmation in
                        Text(affirmation.text)
                            .foregroundColor(.white)
                    }
                    .onDelete(perform: deleteAffirmations)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Affirmation Workshop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveAffirmation() {
        let affirmation = CustomAffirmation(context: viewContext)
        affirmation.id = UUID()
        affirmation.text = newAffirmation
        affirmation.createdAt = Date()
        
        try? viewContext.save()
        newAffirmation = ""
    }
    
    private func deleteAffirmations(offsets: IndexSet) {
        offsets.forEach { index in
            viewContext.delete(customAffirmations[index])
        }
        try? viewContext.save()
    }
} 