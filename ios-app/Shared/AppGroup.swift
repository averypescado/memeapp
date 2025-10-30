//
//  AppGroup.swift
//  Shared configuration for App Groups
//

import Foundation

struct AppGroup {
    // IMPORTANT: Change this to match your App Group ID
    // Format: group.com.yourname.MemeApp
    static let identifier = "group.com.yourname.MemeApp"

    // Shared UserDefaults for passing data between app and keyboard
    static var shared: UserDefaults {
        return UserDefaults(suiteName: identifier)!
    }

    // Keys for storing data
    struct Keys {
        static let cachedMemes = "cachedMemes"
        static let lastSync = "lastSync"
        static let userId = "userId"
    }

    // Get container URL for file storage
    static var containerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
}
