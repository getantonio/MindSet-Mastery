import Foundation
import CoreData

@objc(Playlist)
public class Playlist: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var recordings: Set<Recording>?
    
    // Add computed property for Identifiable conformance
    public var identifier: UUID {
        id ?? UUID()
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }
}

extension Playlist {
    static var defaultPlaylistName: String {
        PlaylistManager.defaultPlaylistName
    }
} 