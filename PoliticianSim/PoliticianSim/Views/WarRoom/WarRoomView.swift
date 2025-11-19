//
//  WarRoomView.swift
//  PoliticianSim
//
//  War Room main view (President only)
//

import SwiftUI

struct WarRoomView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab: WarRoomTab = .overview

    enum WarRoomTab {
        case overview
        case wars
        case research
        case territories
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameManager.navigationManager.toggleMenu()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("War Room")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Check if President
                if let character = gameManager.character {
                    if character.currentPosition?.level == 5 {
                        // Tab selector
                        WarRoomTabSelector(selectedTab: $selectedTab)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        // Tab content
                        Group {
                            switch selectedTab {
                            case .overview:
                                MilitaryOverviewView()
                            case .wars:
                                ActiveWarsView()
                            case .research:
                                TechnologyResearchView()
                            case .territories:
                                TerritoryManagementView()
                            }
                        }
                        .padding(.top, 16)
                    } else {
                        // Not President
                        VStack(spacing: 16) {
                            Spacer()

                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text("Restricted Access")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            Text("The War Room is only accessible to the President")
                                .font(.system(size: 15))
                                .foregroundColor(Constants.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Spacer()
                        }
                    }
                }

                Spacer()
            }

            // Side menu overlay (must be last for proper z-index)
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
    }
}

// MARK: - Tab Selector

struct WarRoomTabSelector: View {
    @Binding var selectedTab: WarRoomView.WarRoomTab

    var body: some View {
        HStack(spacing: 8) {
            WarRoomTabButton(
                title: "Overview",
                icon: "chart.bar.fill",
                isSelected: selectedTab == .overview
            ) {
                selectedTab = .overview
            }

            WarRoomTabButton(
                title: "Wars",
                icon: "flag.fill",
                isSelected: selectedTab == .wars
            ) {
                selectedTab = .wars
            }

            WarRoomTabButton(
                title: "Research",
                icon: "flame.fill",
                isSelected: selectedTab == .research
            ) {
                selectedTab = .research
            }

            WarRoomTabButton(
                title: "Territories",
                icon: "map.fill",
                isSelected: selectedTab == .territories
            ) {
                selectedTab = .territories
            }
        }
    }
}

struct WarRoomTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Constants.Colors.buttonPrimary : Constants.Colors.secondaryText)

                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Constants.Colors.buttonPrimary : Constants.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? Constants.Colors.buttonPrimary.opacity(0.15)
                    : Color.clear
            )
            .cornerRadius(8)
        }
    }
}

#Preview {
    WarRoomView()
        .environmentObject(GameManager.shared)
}
