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
                case .warRoom:
                    WarRoomView()
                case .warArchive:
                    WarArchiveView()
                default:
                    // Placeholder for other views
                    PlaceholderView(viewName: gameManager.navigationManager.currentView.rawValue)
                }
            }

            // War Update Popup (shows sequential popups)
            if let firstUpdate = gameManager.pendingWarUpdates.first {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(900)
                    .onTapGesture {
                        // Dismiss popup when tapping outside
                        if !gameManager.pendingWarUpdates.isEmpty {
                            gameManager.pendingWarUpdates.removeFirst()
                        }
                    }

                WarUpdatePopup(update: firstUpdate)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(901)
            }

            // Defensive War Notification (AI declares war on player)
            if let defensiveWarNotification = gameManager.pendingDefensiveWarNotification {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(903)

                DefensiveWarNotificationPopup(notification: defensiveWarNotification)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(904)
            }

            // War Defeat Notification
            if let defeatNotification = gameManager.pendingWarDefeatNotification {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(905)

                WarDefeatNotificationPopup(notification: defeatNotification)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(906)
            }

            // AI War Notification (shows sequential notifications)
            if let firstNotification = gameManager.pendingAIWarNotifications.first {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(910)

                AIWarNotificationPopup(notification: firstNotification)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(911)
            }

            // War Exhaustion Warning
            if let exhaustionWarning = gameManager.pendingExhaustionWarning {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(920)

                WarExhaustionWarningPopup(warning: exhaustionWarning)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(921)
            }

            // Peace Terms Selection (war victory)
            if let war = gameManager.pendingPeaceTerms {
                PeaceTermsView(
                    war: war,
                    isPresented: Binding(
                        get: { gameManager.pendingPeaceTerms != nil },
                        set: { if !$0 { gameManager.pendingPeaceTerms = nil } }
                    )
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(950)
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
