import Foundation
import CoreData

class Recording: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var categoryName: String
    @NSManaged public var filePath: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var duration: Double
    @NSManaged public var playlist: Playlist?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
        duration = 0
    }
}

extension Recording {
    static func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }
} 