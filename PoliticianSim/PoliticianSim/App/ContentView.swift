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

    var body: some View {
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
            case .laws:
                LawsView()
            case .diplomacy:
                DiplomacyView()
            case .publicOpinion:
                PublicOpinionView()
            default:
                // Placeholder for other views
                PlaceholderView(viewName: gameManager.navigationManager.currentView.rawValue)
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
