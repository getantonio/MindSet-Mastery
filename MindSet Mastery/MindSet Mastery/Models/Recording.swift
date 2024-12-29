import Foundation
import CoreData

@objc(Recording)
public class Recording: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var filePath: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var duration: Double
    @NSManaged public var playlist: Playlist?
    
    public var identifier: UUID {
        id ?? UUID()
    }
    
    var wrappedTitle: String {
        title ?? "Untitled Recording"
    }
    
    var wrappedCategoryName: String {
        categoryName ?? "Uncategorized"
    }
    
    var wrappedFilePath: String {
        filePath ?? ""
    }
    
    var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }
} 