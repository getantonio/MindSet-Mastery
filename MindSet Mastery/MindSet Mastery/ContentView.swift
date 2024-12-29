//
//  ContentView.swift
//  MindSet Mastery
//
//  Created by Antonio Colomba on 12/28/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedCategory: BehaviorCategory?
    @State private var isRecording = false
    @State private var hue: Double = 0.5
    @StateObject private var affirmationsVM = AffirmationsViewModel()
    @StateObject private var audioManager = AudioManager()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showMicrophoneAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Title Box
                VStack(spacing: 8) {
                    Text("Transform Your Mindset")
                        .font(.title.bold())
                        .foregroundColor(Color(hue: hue, saturation: 1, brightness: 1))
                        .shadow(color: Color(hue: hue, saturation: 1, brightness: 1).opacity(0.3), radius: 2)
                    Text("Record daily affirmations to rewire your thoughts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: 500) // Match recorder width
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.windowBackgroundColor))
                        .shadow(radius: 2)
                )
                .padding(.top)
                .padding(.bottom, 32) // Add gap under title box
                
                // Main content with fixed width
                VStack(spacing: 24) {
                    // Recorder Section
                    RecorderView(
                        isRecording: $isRecording,
                        selectedCategory: $selectedCategory,
                        hue: $hue
                    ) { isRecording in
                        if isRecording {
                            guard let category = selectedCategory else {
                                self.isRecording = false
                                return
                            }
                            print("Starting recording for category: \(category.name)")
                            audioManager.startRecording(for: category)
                        } else if let url = audioManager.stopRecording() {
                            print("Stopped recording, saving...")
                            saveRecording(url: url, category: selectedCategory!)
                        }
                    }
                    .padding(.bottom, 16)
                    
                    // Category Selection
                    Menu {
                        ForEach(BehaviorCategory.categories) { category in
                            Button(category.name) {
                                selectedCategory = category
                                affirmationsVM.refreshAffirmations(for: category)
                            }
                        }
                    } label: {
                        Label(
                            selectedCategory?.name ?? "Select",
                            systemImage: "chevron.down.circle.fill"
                        )
                        .font(.headline)
                        .foregroundColor(Color(hue: hue, saturation: 1, brightness: 1))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(.windowBackgroundColor))
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 16)
                    .frame(width: menuWidth)  // Use dynamic width
                    
                    if let category = selectedCategory {
                        ScrollView {
                            VStack(spacing: 24) {
                                affirmationsSection(for: category)
                            }
                            .padding()
                        }
                    }
                }
                .frame(maxWidth: 600)  // Maximum width for the entire content
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("")  // Remove navigation title
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: PlaylistView().environment(\.managedObjectContext, viewContext)) {
                        Image(systemName: "music.note.list")
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowMicrophoneAccessAlert"))) { _ in
            showMicrophoneAlert = true
        }
        .alert("Microphone Access Required", isPresented: $showMicrophoneAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                    NSWorkspace.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable microphone access in System Settings to record affirmations.")
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
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .frame(width: 66, height: 25) // 15% taller
            .background(Color(.windowBackgroundColor))
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
        print("Creating recording for: \(category.name)")
        
        // Get or create default playlist
        guard let playlist = viewContext.getOrCreateDefaultPlaylist() else {
            print("Failed to get/create default playlist")
            return
        }
        
        let recording = Recording(context: viewContext)
        recording.id = UUID()
        recording.title = "Affirmation - \(category.name)"
        recording.categoryName = category.name
        recording.filePath = url.path
        recording.createdAt = Date()
        recording.duration = 0
        
        // Add to default playlist
        recording.playlist = playlist
        
        do {
            try viewContext.save()
            print("Successfully saved recording to playlist: \(Playlist.defaultName)")
        } catch {
            print("Error saving recording: \(error)")
            viewContext.rollback()
        }
    }
    
    private var menuWidth: CGFloat {
        let longestCategory = BehaviorCategory.categories
            .map { $0.name.count }
            .max() ?? 0
        return CGFloat(longestCategory) * 10 + 60 // 10 points per character plus padding
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
