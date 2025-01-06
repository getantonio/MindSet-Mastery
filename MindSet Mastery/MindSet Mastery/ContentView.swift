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
    @State private var titleOpacity = 1.0
    @State private var previousTitle = ""
    @State private var backgroundPulse = false
    @StateObject private var themeManager = ThemeManager.shared
    
    var currentTitle: String {
        guard let category = selectedCategory else {
            return "SELECT CATEGORY"
        }
        
        // Safety check for affirmations
        guard !affirmationsVM.currentAffirmations.isEmpty else {
            return category.name
        }
        
        switch titleIndex {
        case 0:
            return category.name
        case 1:
            return affirmationsVM.currentAffirmations[0]
        case 2:
            return affirmationsVM.currentAffirmations[1]
        case 3:
            return affirmationsVM.currentAffirmations[2]
        default:
            return category.name
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Box at the very top
            VStack(spacing: 8) {
                Text("Transform Your Mindset")
                    .font(.title.bold())
                    .foregroundColor(themeManager.textColor)
                    .shadow(color: themeManager.glowColor, radius: 8)
                Text("Record and loop affirmations to rewire your thoughts")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: 500)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.15))
            )
            
            // Rest of the content in a ScrollView
            ScrollView {
                VStack(spacing: 8) {
                    // Recording Window with pulsing background
                    ZStack {
                        // Pure black background
                        Color.black
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.accentColor.opacity(0.2))
                            )
                        
                        GeometryReader { geometry in
                            VStack(spacing: 0) {
                                // Title section (top 30% of space)
                                ZStack {
                                    // Previous Title
                                    Text(previousTitle)
                                        .font(.headline)
                                        .foregroundColor(themeManager.textColor)
                                        .opacity(1 - titleOpacity)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                    
                                    // Current Title
                                    Text(currentTitle)
                                        .font(.headline)
                                        .foregroundColor(themeManager.textColor)
                                        .opacity(titleOpacity)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                }
                                .padding(.horizontal)
                                .scaleEffect(titleScale)
                                .animation(
                                    Animation.easeInOut(duration: 2.5)
                                        .repeatForever(autoreverses: true),
                                    value: isRecording
                                )
                                .frame(height: geometry.size.height * 0.3)
                                
                                Spacer()
                                
                                // Bottom section with wheels and controls
                                VStack(spacing: 0) {  // Changed from 5 to 0
                                    // Spinning wheels
                                    HStack(spacing: 40) {
                                        HypnoticWheelView(
                                            isActive: selectedCategory != nil,
                                            isRecording: isRecording,
                                            audioLevel: audioManager.audioLevel,
                                            rotateClockwise: false
                                        )
                                        .frame(width: 100, height: 100)
                                        
                                        HypnoticWheelView(
                                            isActive: selectedCategory != nil,
                                            isRecording: isRecording,
                                            audioLevel: audioManager.audioLevel,
                                            rotateClockwise: true
                                        )
                                        .frame(width: 100, height: 100)
                                    }
                                    .padding(.bottom, 5)
                                    .padding(.leading, 33)
                                    
                                    // Record controls
                                    VStack(spacing: 5) {
                                        // Discard Button
                                        Button(action: {
                                            isRecording = false
                                            audioManager.discardRecording()
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(.title2))
                                                .foregroundColor(.red.opacity(0.8))
                                        }
                                        .opacity(isRecording ? 1 : 0)
                                        .animation(.easeInOut, value: isRecording)
                                        
                                        // Record Button
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
                                    .frame(height: geometry.size.height * 0.25)
                                    .padding(.bottom, 15)  // Added fixed padding from bottom
                                }
                            }
                            .padding()
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(12)
                    .shadow(color: themeManager.shadowColor, radius: 10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .onAppear {
                        backgroundPulse = true
                        startTitleRotation()
                    }
                    
                    // Category Selection Menu
                    Menu {
                        ForEach(BehaviorCategory.categories) { category in
                            Button(category.name) {
                                print("Selected category: \(category.name)")
                                print("Affirmation count: \(category.defaultAffirmations.count)")
                                
                                // Update category first
                                selectedCategory = category
                                titleIndex = 0
                                
                                // Then initialize affirmations if not custom
                                if !category.isCustom {
                                    DispatchQueue.main.async {
                                        self.affirmationsVM.initializeAffirmations(for: category)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(selectedCategory?.name ?? "Select")
                            Image(systemName: "chevron.down.circle.fill")
                        }
                        .foregroundColor(themeManager.accentColor)
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
                            VStack(spacing: 4) {  // Reduced from 10 to 4
                                ScrollView {
                                    VStack(spacing: 4) {  // Reduced from 10 to 4
                                        if affirmationsVM.currentAffirmations.isEmpty {
                                            Text("Loading affirmations...")
                                                .foregroundColor(.gray)
                                                .padding(.vertical, 8)  // Reduced padding
                                        } else {
                                            ForEach(Array(affirmationsVM.currentAffirmations.enumerated()), id: \.1) { index, affirmation in
                                                Text(affirmation)
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 8)  // Reduced vertical padding
                                                    .padding(.horizontal, 12)  // Reduced horizontal padding
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(Color(white: 0.15))
                                                    .cornerRadius(6)  // Slightly reduced corner radius
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8)  // Reduced outer horizontal padding
                                }
                                .frame(maxHeight: 200)
                                
                                regenerateButton
                                    .padding(.top, 4)  // Reduced padding above button
                            }
                            .padding(.horizontal, 8)  // Reduced outer padding
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            
            // Bottom section with color buttons and playlist
            VStack(spacing: 4) {
                // Color theme selector
                colorThemeSelector
                    .padding(.vertical, 4)
                
                // Playlist Button
                Button(action: {
                    showPlaylist.toggle()
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Playlist")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.2))
                    .cornerRadius(8)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .background(Color(white: 0.1))
        }
        .background(Color(white: 0.1).edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPlaylist) {
            PlaylistManagerView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(audioPlayerVM)
        }
    }
    
    private var titleScale: CGFloat {
        let progress = sin(Date().timeIntervalSince1970)  // Smooth sine wave
        let scale = 0.275  // Range from 0.7 to 1.25
        return 0.975 + (progress * scale)  // Center point at 0.975
    }
    
    private func startTitleRotation() {
        affirmationTimer?.invalidate()
        affirmationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if selectedCategory != nil {
                withAnimation(.easeInOut(duration: 1.0)) {
                    previousTitle = currentTitle
                    titleOpacity = 0
                    titleIndex = (titleIndex + 1) % 4
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            titleOpacity = 1
                        }
                    }
                }
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
        Button(action: {
            if let category = selectedCategory {
                affirmationsVM.refreshAffirmations(for: category)
            }
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)  // Make it square
                .background(Color(.darkGray))
                .clipShape(Circle())           // Make it circular
        }
        .buttonStyle(.plain)
        .disabled(affirmationsVM.isLoading)
        .overlay {
            if affirmationsVM.isLoading {
                ProgressView()
            }
        }
    }
    
    private var regenerateButton: some View {
        Button(action: {
            if let category = selectedCategory {
                affirmationsVM.refreshAffirmations(for: category)
            }
        }) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 120, height: 32)  // Wider and shorter
                .background(Color(white: 0.15))  // Match affirmations background
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(affirmationsVM.isLoading)
        .overlay {
            if affirmationsVM.isLoading {
                ProgressView()
            }
        }
    }
    
    private var colorThemeSelector: some View {
        HStack(spacing: 12) {
            // Green theme
            ColorThemeButton(color: .green, action: {
                withAnimation {
                    themeManager.activeColor = .green
                }
            }, isActive: themeManager.activeColor == .green)
            
            // Red theme
            ColorThemeButton(color: .red, action: {
                withAnimation {
                    themeManager.activeColor = .red
                }
            }, isActive: themeManager.activeColor == .red)
            
            // Blue theme
            ColorThemeButton(color: .blue, action: {
                withAnimation {
                    themeManager.activeColor = .blue
                }
            }, isActive: themeManager.activeColor == .blue)
        }
        .padding(.horizontal)
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

struct ColorThemeButton: View {
    let color: Color
    let action: () -> Void
    let isActive: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(color)
                    .opacity(isActive ? 0.3 : 0.0)
                    .frame(width: 32, height: 32)
                    .blur(radius: 8)
                
                // LED light
                Circle()
                    .fill(color)
                    .opacity(isActive ? 1.0 : 0.3)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .opacity(isActive ? 0.4 : 0.1)
                            .frame(width: 12, height: 12)
                            .blur(radius: 2)
                            .offset(x: -2, y: -2)  // Highlight in top-left
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(isActive ? 0.4 : 0.1), lineWidth: 2)
                    )
                    .shadow(color: color.opacity(isActive ? 0.8 : 0), radius: 6)
            }
        }
    }
}

#Preview {
    ContentView()
}
