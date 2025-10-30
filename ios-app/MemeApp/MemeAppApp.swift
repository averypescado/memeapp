//
//  MemeAppApp.swift
//  Main app entry point
//

import SwiftUI
import FirebaseCore

@main
struct MemeAppApp: App {
    @StateObject private var firebaseService = FirebaseService.shared

    var body: some Scene {
        WindowGroup {
            if firebaseService.isAuthenticated {
                MemeGridView()
                    .environmentObject(firebaseService)
            } else {
                LoginView()
                    .environmentObject(firebaseService)
            }
        }
    }
}
