//
//  ContentView.swift
//  PoliticianSim
//
//  Root view that routes to character creation or main game
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        Group {
            if gameManager.character == nil {
                // Show character creation if no character exists
                CharacterCreationContainerView()
            } else {
                // Show main game
                MainGameView()
            }
        }
    }
}

// MARK: - Main Game View (Placeholder)

struct MainGameView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 20) {
                Text("Politician Sim")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                Text("From Birth to the Presidency")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                Spacer()

                if let character = gameManager.character {
                    VStack(spacing: 12) {
                        Text("Character: \(character.name)")
                            .foregroundColor(.white)

                        Text("Age: \(character.age)")
                            .foregroundColor(.gray)

                        Text("Charisma: \(character.charisma)/100")
                            .foregroundColor(.blue)

                        // Temporary delete button for testing
                        Button("Delete Character") {
                            gameManager.characterManager.character = nil
                        }
                        .padding()
                        .foregroundColor(.red)
                    }
                }

                Spacer()

                Text("Phase 1.4: Character Creation Complete")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager.shared)
}
