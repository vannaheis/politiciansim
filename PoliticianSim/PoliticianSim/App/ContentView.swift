//
//  ContentView.swift
//  PoliticianSim
//
//  Created on 11/11/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Politician Sim")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                Text("From Birth to the Presidency")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                Spacer()

                // Temporary test content
                if let character = gameManager.character {
                    VStack(spacing: 12) {
                        Text("Character: \(character.name)")
                            .foregroundColor(.white)

                        Text("Age: \(character.age)")
                            .foregroundColor(.gray)

                        Text("Charisma: \(character.charisma)/100")
                            .foregroundColor(.blue)
                    }
                } else {
                    Button(action: {
                        gameManager.createTestCharacter()
                    }) {
                        Text("Create Character")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }

                Spacer()

                Text("Phase 1: Foundation")
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
