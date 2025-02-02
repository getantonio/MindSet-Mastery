//
//  MindSet_MasteryApp.swift
//  MindSet Mastery
//
//  Created by Antonio Colomba on 12/28/24.
//

import SwiftUI
import AVFoundation

@main
struct MindSet_MasteryApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session:", error)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
