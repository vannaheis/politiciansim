//
//  TerritoryManagementView.swift
//  PoliticianSim
//
//  Territory and rebellion management
//

import SwiftUI

struct TerritoryManagementView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if gameManager.territoryManager.territories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "map")
                            .font(.system(size: 50))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("No Conquered Territories")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Win wars to acquire new territories")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(gameManager.territoryManager.territories) { territory in
                        TerritoryCard(territory: territory)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

struct TerritoryCard: View {
    let territory: Territory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: territory.type.icon)
                    .foregroundColor(Constants.Colors.buttonPrimary)

                Text(territory.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Population")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(territory.formattedPopulation)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Morale")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(territory.moraleStatus)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(moraleColor(territory.morale))
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }

    private func moraleColor(_ morale: Double) -> Color {
        if morale >= 0.7 {
            return Constants.Colors.positive
        } else if morale >= 0.4 {
            return .yellow
        } else {
            return Constants.Colors.negative
        }
    }
}

#Preview {
    TerritoryManagementView()
        .environmentObject(GameManager.shared)
}
