//
//  MemeGridView.swift
//  Main meme browsing screen
//

import SwiftUI

struct MemeGridView: View {
    @EnvironmentObject var firebaseService: FirebaseService

    @State private var memes: [Meme] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var errorMessage: String?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var filteredMemes: [Meme] {
        var filtered = memes

        if showFavoritesOnly {
            filtered = filtered.filter { $0.favorite }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter { meme in
                meme.tags.contains { $0.lowercased().contains(searchText.lowercased()) } ||
                meme.sourceUrl.lowercased().contains(searchText.lowercased())
            }
        }

        return filtered
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search and filter
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search memes...", text: $searchText)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                // Filter button
                Toggle(isOn: $showFavoritesOnly) {
                    Label("Favorites Only", systemImage: "star.fill")
                }
                .padding(.horizontal)

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }

                // Memes grid
                if isLoading {
                    Spacer()
                    ProgressView("Loading memes...")
                    Spacer()
                } else if filteredMemes.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No memes yet!")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text("Save memes from Chrome to see them here")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(filteredMemes) { meme in
                                MemeCell(meme: meme) {
                                    await toggleFavorite(meme)
                                } onDelete: {
                                    await deleteMeme(meme)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Memes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: loadMemes) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        try? firebaseService.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .onAppear {
                loadMemes()
            }
        }
    }

    private func loadMemes() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedMemes = try await firebaseService.fetchMemes()
                await MainActor.run {
                    memes = fetchedMemes
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func toggleFavorite(_ meme: Meme) async {
        do {
            try await firebaseService.toggleFavorite(memeId: meme.id, isFavorite: !meme.favorite)

            // Update local state
            await MainActor.run {
                if let index = memes.firstIndex(where: { $0.id == meme.id }) {
                    memes[index].favorite.toggle()
                }
            }
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }

    private func deleteMeme(_ meme: Meme) async {
        do {
            try await firebaseService.deleteMeme(memeId: meme.id)

            // Update local state
            await MainActor.run {
                memes.removeAll { $0.id == meme.id }
            }
        } catch {
            print("Error deleting meme: \(error)")
        }
    }
}

struct MemeCell: View {
    let meme: Meme
    let onToggleFavorite: () async -> Void
    let onDelete: () async -> Void

    @State private var image: UIImage?
    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Meme image
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 110)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 110, height: 110)
                    .cornerRadius(8)
                    .overlay(
                        ProgressView()
                    )
            }

            // Favorite button
            Button(action: {
                Task {
                    await onToggleFavorite()
                }
            }) {
                Image(systemName: meme.favorite ? "star.fill" : "star")
                    .foregroundColor(meme.favorite ? .yellow : .white)
                    .padding(6)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(4)
        }
        .contextMenu {
            Button(role: .destructive, action: {
                showDeleteConfirmation = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog("Delete this meme?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await onDelete()
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        // Try loading from cache first
        if let cachedImage = ImageCache.shared.loadImage(forKey: meme.id) {
            image = cachedImage
            return
        }

        // Load from data URL
        if let decodedImage = ImageCache.shared.imageFromDataURL(meme.thumbnailUrl) {
            image = decodedImage
            ImageCache.shared.saveImage(decodedImage, forKey: meme.id)
        }
    }
}

#Preview {
    MemeGridView()
        .environmentObject(FirebaseService.shared)
}
