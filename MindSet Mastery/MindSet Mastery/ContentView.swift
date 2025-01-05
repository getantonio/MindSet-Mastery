//
//  ContentView.swift
//  MindSet Mastery
//
//  Created by Antonio Colomba on 12/28/24.
//

import SwiftUI
import AVFoundation
import CoreData
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedCategory: BehaviorCategory?
    @State private var isRecording = false
    @State private var showPlaylist = false
    @StateObject private var affirmationsVM = AffirmationsViewModel()
    @StateObject private var audioManager = AudioManager()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showMicrophoneAlert = false
    @State private var rotationAngle = 0.0
    @StateObject private var audioPlayerVM = AudioPlayerViewModel.shared
    @State private var currentAffirmationIndex = 0
    @State private var affirmationTimer: Timer?
    @State private var titleIndex = 0
    
    var currentTitle: String {
        guard let category = selectedCategory else {
            return "SELECT CATEGORY"
        }
        
        switch titleIndex {
        case 0:
            return category.name
        case 1:
            return category.defaultAffirmations[0]
        case 2:
            return category.defaultAffirmations[1]
        case 3:
            return category.defaultAffirmations[2]
        default:
            return category.name
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(white: 0.1).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 8) {  // Reduced from 10 to 8
                // Title Box
                VStack(spacing: 8) {
                    Text("Transform Your Mindset")
                        .font(.title.bold())
                        .foregroundColor(.green)
                    Text("Record and loop affirmations to rewire your thoughts")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)  // Reduced padding
                .frame(maxWidth: 500)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.15))
                )
                .padding(.top, 4)  // Reduced from 8
                .padding(.bottom, 8)  // Reduced from 10
                
                // Recording Window
                ZStack {
                    Color.black
                    
                    VStack(spacing: 20) {
                        // Rotating Title
                        Text(currentTitle)
                            .font(.headline)
                            .foregroundColor(.green)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .shadow(color: .green.opacity(0.5), radius: 2)
                        
                        // Spinning wheels with different rotation directions
                        HStack(spacing: 40) {
                            // Left hypnotic wheel (counter-clockwise)
                            HypnoticWheelView(isActive: isRecording, audioLevel: audioManager.audioLevel, rotateClockwise: false)
                                .frame(width: 100, height: 100)
                            
                            // Right hypnotic wheel (clockwise)
                            HypnoticWheelView(isActive: isRecording, audioLevel: audioManager.audioLevel, rotateClockwise: true)
                                .frame(width: 100, height: 100)
                        }
                        
                        // Record Button with glow
                        Button(action: {
                            isRecording.toggle()
                            handleRecordingStateChanged(isRecording)
                        }) {
                            Text("REC")
                                .font(.system(.headline, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(isRecording ? Color.red : Color.gray.opacity(0.3))
                                .cornerRadius(8)
                                .shadow(color: isRecording ? .red.opacity(0.5) : .green.opacity(0.3), radius: 4)
                        }
                        .disabled(selectedCategory == nil)
                    }
                    .padding()
                }
                .frame(height: 300)
                .cornerRadius(12)
                .shadow(color: .green.opacity(0.3), radius: 10)
                .padding(.horizontal)
                .padding(.vertical, 10)  // Reduced padding
                .onAppear {
                    startTitleRotation()
                }
                
                // Category Selection Menu
                Menu {
                    ForEach(BehaviorCategory.categories) { category in
                        Button(category.name) {
                            selectedCategory = category
                            titleIndex = 0
                            if !category.isCustom {
                                affirmationsVM.refreshAffirmations(for: category)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(selectedCategory?.name ?? "Select")
                        Image(systemName: "chevron.down.circle.fill")
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(width: menuWidth)
                    .background(Color(white: 0.15))  // Slightly lighter than background
                    .cornerRadius(8)
                }
                
                // Affirmations Section
                if let category = selectedCategory {
                    if category.isCustom {
                        // Custom Affirmation Workshop
                        VStack(spacing: 10) {
                            AffirmationBuilderView()
                                .frame(maxHeight: 200)
                        }
                        .padding(.horizontal)
                    } else {
                        // Regular Affirmations List
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(category.defaultAffirmations, id: \.self) { affirmation in
                                    Text(affirmation)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(white: 0.15))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                Spacer()
                
                // Playlist Button
                Button(action: { showPlaylist = true }) {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text("Playlist")  // Changed from "My Playlists"
                    }
                    .foregroundColor(.green)
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(8)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPlaylist) {
            PlaylistManagerView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(audioPlayerVM)
        }
    }
    
    private func startTitleRotation() {
        affirmationTimer?.invalidate()
        affirmationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            if selectedCategory != nil {
                titleIndex = (titleIndex + 1) % 4
            }
        }
    }
    
    private var recordingTips: some View {
        VStack(spacing: 8) {
            Text("Recording Tips")
                .font(.headline)
            Text("Speak clearly and confidently")
            Text("Record your affirmation")
            Text("Take a deep breath before speaking")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func affirmationsSection(for category: BehaviorCategory) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Affirmations")
                .font(.title2.bold())
            
            if affirmationsVM.currentAffirmations.isEmpty {
                ForEach(category.defaultAffirmations, id: \.self) { affirmation in
                    AffirmationCard(text: affirmation)
                }
            } else {
                ForEach(affirmationsVM.currentAffirmations, id: \.self) { affirmation in
                    AffirmationCard(text: affirmation)
                }
            }
            
            refreshButton
        }
    }
    
    private var refreshButton: some View {
        HStack {
            Spacer()
            Button(action: {
                if let category = selectedCategory {
                    affirmationsVM.refreshAffirmations(for: category)
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .frame(width: 66, height: 25)
            .background(Color(.darkGray))
            .cornerRadius(8)
            .disabled(affirmationsVM.isLoading)
            .overlay {
                if affirmationsVM.isLoading {
                    ProgressView()
                }
            }
            Spacer()
        }
    }
    
    private func saveRecording(url: URL, category: BehaviorCategory) {
        print("Saving recording at path: \(url.path)")
        
        // Get or create playlist for this category
        let playlistName = category.name
        let playlist = getOrCreatePlaylist(named: playlistName)
        
        // Get next recording number for this category
        let recordingNumber = getNextRecordingNumber(for: category, in: playlist)
        
        let recording = Recording(context: viewContext)
        recording.id = UUID()
        recording.title = "Affirmation \(recordingNumber) - \(category.name)"
        recording.categoryName = category.name
        recording.filePath = url.path
        recording.createdAt = Date()
        recording.duration = 0
        recording.playlist = playlist
        
        do {
            try viewContext.save()
            print("Successfully saved recording to playlist: \(playlist.name ?? "Unknown")")
        } catch {
            print("Error saving recording: \(error)")
            viewContext.rollback()
        }
    }
    
    private func getOrCreatePlaylist(named name: String) -> Playlist {
        // Try to find existing playlist
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        if let existingPlaylist = try? viewContext.fetch(request).first {
            return existingPlaylist
        }
        
        // Create new playlist if none exists
        let playlist = Playlist(context: viewContext)
        playlist.id = UUID()
        playlist.name = name
        playlist.createdAt = Date()
        playlist.recordings = Set<Recording>()
        
        return playlist
    }
    
    private func getNextRecordingNumber(for category: BehaviorCategory, in playlist: Playlist) -> Int {
        guard let recordings = playlist.recordings else { return 1 }
        
        // Find highest number in existing recordings
        let pattern = "Affirmation (\\d+) - \(category.name)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let numbers = recordings.compactMap { recording -> Int? in
            guard let title = recording.title,
                  let match = regex?.firstMatch(
                    in: title,
                    options: [],
                    range: NSRange(title.startIndex..., in: title)
                  ),
                  let range = Range(match.range(at: 1), in: title) else {
                return nil
            }
            return Int(title[range])
        }
        
        return (numbers.max() ?? 0) + 1
    }
    
    private var menuWidth: CGFloat {
        let longestCategory = BehaviorCategory.categories
            .map { $0.name.count }
            .max() ?? 0
        return CGFloat(longestCategory) * 10 + 60 // 10 points per character plus padding
    }
    
    private func handleRecordingStateChanged(_ isRecording: Bool) {
        if isRecording {
            guard let category = selectedCategory else {
                self.isRecording = false
                return
            }
            
            // Request microphone permission if needed
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Starting recording for category: \(category.name)")
                        self.audioManager.startRecording(for: category)
                    } else {
                        self.showMicrophoneAlert = true
                        self.isRecording = false
                    }
                }
            }
        } else if let url = audioManager.stopRecording() {
            print("Stopped recording, saving...")
            saveRecording(url: url, category: selectedCategory!)
        }
    }
}

struct AffirmationCard: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
