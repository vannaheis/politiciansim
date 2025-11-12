//
//  HomeView.swift
//  PoliticianSim
//
//  Main game hub view
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top section with date and time controls
                VStack(spacing: 16) {
                    // Date display
                    if let character = gameManager.character {
                        DateDisplayView(
                            currentDate: character.currentDate,
                            age: character.age
                        )
                    }

                    // Time controls
                    TimeControlBar(
                        onSkipDay: {
                            gameManager.skipDay()
                        },
                        onSkipWeek: {
                            gameManager.skipWeek()
                        }
                    )
                }
                .padding(.top, 8)

                // Main content
                ScrollView {
                    VStack(spacing: 20) {
                        if let character = gameManager.character {
                            // Character overview card
                            CharacterOverviewCard(character: character)

                            // Quick stats
                            QuickStatsView(character: character)

                            // Position info (if any)
                            if character.currentPosition != nil {
                                InfoCard(title: "Current Position") {
                                    Text("Position details coming soon")
                                        .foregroundColor(Constants.Colors.secondaryText)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }

                Spacer()
            }

            // Bottom navigation bar
            VStack {
                Spacer()
                NavigationBar(currentView: $gameManager.navigationManager.currentView)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject({
            let gm = GameManager.shared
            gm.createTestCharacter()
            return gm
        }())
}
