import Foundation
import CoreData

@objc(Playlist)
public class Playlist: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var recordings: Set<Recording>?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }
}

extension Playlist {
    static var defaultPlaylistName: String {
        PlaylistManager.defaultPlaylistName
    }
} 