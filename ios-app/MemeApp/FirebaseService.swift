//
//  FirebaseService.swift
//  Firebase authentication and Firestore sync
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()

    @Published var isAuthenticated = false
    @Published var currentUser: User?

    private var db: Firestore?
    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        // Check if Firebase is already configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        db = Firestore.firestore()

        // Listen for auth state changes
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.currentUser = user

            // Store user ID in App Group for keyboard access
            if let userId = user?.uid {
                AppGroup.shared.set(userId, forKey: AppGroup.Keys.userId)
            } else {
                AppGroup.shared.removeObject(forKey: AppGroup.Keys.userId)
            }
        }
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    // MARK: - Authentication

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Firestore Sync

    func fetchMemes() async throws -> [Meme] {
        guard let userId = currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let snapshot = try await db?
            .collection("users")
            .document(userId)
            .collection("memes")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        var memes: [Meme] = []

        for document in snapshot?.documents ?? [] {
            let meme = Meme(id: document.documentID, data: document.data())
            memes.append(meme)
        }

        // Cache memes for keyboard access
        cacheMemes(memes)

        return memes
    }

    func toggleFavorite(memeId: String, isFavorite: Bool) async throws {
        guard let userId = currentUser?.uid else { return }

        try await db?
            .collection("users")
            .document(userId)
            .collection("memes")
            .document(memeId)
            .updateData([
                "favorite": isFavorite,
                "updatedAt": FieldValue.serverTimestamp()
            ])
    }

    func deleteMeme(memeId: String) async throws {
        guard let userId = currentUser?.uid else { return }

        try await db?
            .collection("users")
            .document(userId)
            .collection("memes")
            .document(memeId)
            .delete()
    }

    // MARK: - Caching for Keyboard Extension

    private func cacheMemes(_ memes: [Meme]) {
        // Save to UserDefaults for keyboard access
        if let encoded = try? JSONEncoder().encode(memes) {
            AppGroup.shared.set(encoded, forKey: AppGroup.Keys.cachedMemes)
            AppGroup.shared.set(Date(), forKey: AppGroup.Keys.lastSync)
        }

        // Cache images to disk
        for meme in memes {
            if let image = ImageCache.shared.imageFromDataURL(meme.thumbnailUrl) {
                ImageCache.shared.saveImage(image, forKey: meme.id)
            }
        }
    }

    static func loadCachedMemes() -> [Meme] {
        guard let data = AppGroup.shared.data(forKey: AppGroup.Keys.cachedMemes) else {
            return []
        }

        return (try? JSONDecoder().decode([Meme].self, from: data)) ?? []
    }
}
