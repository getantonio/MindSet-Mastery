import Foundation
import CoreData

class PlaylistManager {
    static let shared = PlaylistManager()
    static let defaultPlaylistName = "All Recordings"
    
    private init() {}
    
    func createDefaultPlaylist(context: NSManagedObjectContext) -> MindSet_Mastery.Playlist? {
        // Check if default playlist already exists
        let request = MindSet_Mastery.Playlist.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", Self.defaultPlaylistName)
        
        do {
            let results = try context.fetch(request)
            if let existing = results.first {
                print("Found existing default playlist")
                return existing
            }
            
            // Create new default playlist
            let playlist = MindSet_Mastery.Playlist(context: context)
            playlist.id = UUID()
            playlist.name = Self.defaultPlaylistName
            playlist.createdAt = Date()
            playlist.recordings = Set<MindSet_Mastery.Recording>()
            
            try context.save()
            print("Created new default playlist")
            return playlist
            
        } catch {
            print("Error creating default playlist: \(error)")
            return nil
        }
    }
    
    func getDefaultPlaylist(context: NSManagedObjectContext) -> MindSet_Mastery.Playlist? {
        let request = MindSet_Mastery.Playlist.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", Self.defaultPlaylistName)
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching default playlist: \(error)")
            return nil
        }
    }
    
    func getOrCreateCategoryPlaylist(category: BehaviorCategory, context: NSManagedObjectContext) -> Playlist {
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", category.name)
        request.fetchLimit = 1
        
        if let existingPlaylist = try? context.fetch(request).first {
            return existingPlaylist
        }
        
        let playlist = Playlist(context: context)
        playlist.id = UUID()
        playlist.name = category.name
        playlist.createdAt = Date()
        playlist.recordings = Set<Recording>()
        
        try? context.save()
        return playlist
    }
} 