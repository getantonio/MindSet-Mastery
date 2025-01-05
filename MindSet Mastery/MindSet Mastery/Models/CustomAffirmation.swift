import Foundation
import CoreData

@objc(CustomAffirmation)
public class CustomAffirmation: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var text: String
    @NSManaged public var createdAt: Date?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
        text = "New Affirmation"
    }
}

extension CustomAffirmation {
    static var defaultAffirmations: [String] {
        [
            "I am capable of achieving anything I set my mind to",
            "Every day I grow stronger and more confident",
            "I create my own success and happiness"
        ]
    }
} 