import Foundation
import CoreData

class Playlist: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var createdAt: Date
    @NSManaged public var recordings: Set<Recording>
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
        name = "New Playlist"
        recordings = Set<Recording>()
    }
    
    static var defaultName: String {
        "My Affirmations"
    }
}

extension Playlist {
    static func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }
}

// Add Hashable conformance
extension Playlist {
    override public var hash: Int {
        id.hashValue
    }
    
    public static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}

// Helper methods for CoreData
extension NSManagedObjectContext {
    func getOrCreateDefaultPlaylist() -> Playlist? {
        let request = Playlist.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", Playlist.defaultName)
        
        do {
            let results = try fetch(request)
            if let playlist = results.first {
                return playlist
            }
            
            // Create default playlist if it doesn't exist
            let playlist = Playlist(context: self)
            playlist.id = UUID()
            playlist.name = Playlist.defaultName
            playlist.createdAt = Date()
            playlist.recordings = Set<Recording>()
            try save()
            
            return playlist
        } catch {
            print("Error fetching/creating default playlist: \(error)")
            return nil
        }
    }
} 