//
//  PoliticianSimApp.swift
//  PoliticianSim
//
//  Created on 11/11/2024.
//

import SwiftUI

@main
struct PoliticianSimApp: App {
    @StateObject private var gameManager = GameManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .preferredColorScheme(.dark) // Force dark mode
        }
    }
}
