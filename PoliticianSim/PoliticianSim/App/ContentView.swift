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
            if gameManager.characterManager.character == nil {
                // Show character creation if no character exists
                CharacterCreationContainerView()
            } else {
                // Show main game based on navigation
                MainGameRouter()
            }
        }
    }
}

// MARK: - Main Game Router

struct MainGameRouter: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showHealthWarning = false
    @State private var showStressWarning = false

    var body: some View {
        ZStack {
            Group {
                switch gameManager.navigationManager.currentView {
                case .home:
                    NewHomeView()
                case .profile:
                    ProfileView()
                case .stats:
                    StatsView()
                case .education:
                    EducationView()
                case .position:
                    PositionView()
                case .settings:
                    SettingsView()
                case .campaigns:
                    CampaignView()
                case .elections:
                    ElectionsView()
                case .policies:
                    PoliciesView()
                case .budget:
                    BudgetView()
                case .treasury:
                    TreasuryView()
                case .laws:
                    LawsView()
                case .governmentStats:
                    GovernmentStatsView()
                case .diplomacy:
                    DiplomacyView()
                case .publicOpinion:
                    PublicOpinionView()
                case .economy:
                    EconomicDataView()
                default:
                    // Placeholder for other views
                    PlaceholderView(viewName: gameManager.navigationManager.currentView.rawValue)
                }
            }

            // Game Over overlay (highest priority)
            if let gameOverData = gameManager.gameState.gameOverData {
                GameOverView(gameOverData: gameOverData)
                    .transition(.opacity)
                    .zIndex(1000)
            }
        }
        .customAlert(
            isPresented: $showHealthWarning,
            title: "Critical Health Warning",
            message: "Your health is dangerously low! If your health reaches zero, you will die. Consider reducing stress and taking care of yourself.",
            primaryButton: "Understood",
            primaryAction: {
                showHealthWarning = false
            }
        )
        .customAlert(
            isPresented: $showStressWarning,
            title: "Extreme Stress Warning",
            message: "You are experiencing extreme stress! This is severely damaging your health and could lead to death. Consider reducing your workload or taking time off.",
            primaryButton: "Understood",
            primaryAction: {
                showStressWarning = false
            }
        )
        .onChange(of: gameManager.gameState.healthWarningShown) { newValue in
            if newValue {
                showHealthWarning = true
            }
        }
        .onChange(of: gameManager.gameState.stressWarningShown) { newValue in
            if newValue {
                showStressWarning = true
            }
        }
    }
}

// MARK: - Placeholder View

struct PlaceholderView: View {
    let viewName: String

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 20) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 60))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(viewName)
                    .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                    .foregroundColor(.white)

                Text("Coming Soon")
                    .font(.system(size: Constants.Typography.bodyTextSize))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager.shared)
}
