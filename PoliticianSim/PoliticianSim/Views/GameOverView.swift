//
//  GameOverView.swift
//  PoliticianSim
//
//  Game over screen displayed when character dies
//

import SwiftUI

struct GameOverView: View {
    let gameOverData: GameOverData
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Death icon
                Image(systemName: gameOverData.deathCause.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding(.top, 40)

                // Title
                Text("Game Over")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                // Death cause
                Text(gameOverData.deathCause.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Constants.Colors.negative)

                // Character info card
                VStack(alignment: .leading, spacing: 16) {
                    // Character name and message
                    VStack(alignment: .leading, spacing: 8) {
                        Text(gameOverData.characterName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(gameOverData.deathCause.message)
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.secondaryText)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()
                        .background(Color.white.opacity(0.2))

                    // Stats
                    HStack(spacing: 40) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Age at Death")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)
                            Text("\(gameOverData.age)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Final Role")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)
                            Text(gameOverData.role)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Constants.Colors.accent)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: 350)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )

                Spacer()

                // Restart button
                Button(action: {
                    gameManager.newGame()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Start New Game")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 300)
                    .padding(.vertical, 16)
                    .background(Constants.Colors.political)
                    .cornerRadius(12)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    GameOverView(
        gameOverData: GameOverData(
            deathCause: .stress,
            age: 45,
            role: "US President",
            characterName: "John Smith"
        )
    )
    .environmentObject(GameManager.shared)
}
