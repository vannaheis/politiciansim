//
//  TerritoryManagementView.swift
//  PoliticianSim
//
//  Territory and rebellion management
//

import SwiftUI

struct TerritoryManagementView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedSection: TerritorySection = .rankings

    enum TerritorySection {
        case rankings
        case conquered
        case reparations
    }

    var body: some View {
        VStack(spacing: 0) {
            // Section selector
            TerritoryTabSelector(selectedSection: $selectedSection)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // Section content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedSection {
                    case .rankings:
                        GlobalRankingsView()
                    case .conquered:
                        ConqueredTerritoriesView()
                    case .reparations:
                        ReparationsView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Tab Selector

struct TerritoryTabSelector: View {
    @Binding var selectedSection: TerritoryManagementView.TerritorySection

    var body: some View {
        HStack(spacing: 8) {
            TerritoryTabButton(
                title: "Rankings",
                isSelected: selectedSection == .rankings
            ) {
                selectedSection = .rankings
            }

            TerritoryTabButton(
                title: "Conquered",
                isSelected: selectedSection == .conquered
            ) {
                selectedSection = .conquered
            }

            TerritoryTabButton(
                title: "Reparations",
                isSelected: selectedSection == .reparations
            ) {
                selectedSection = .reparations
            }
        }
    }
}

struct TerritoryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Constants.Colors.buttonPrimary : Constants.Colors.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isSelected
                        ? Constants.Colors.buttonPrimary.opacity(0.15)
                        : Color.clear
                )
                .cornerRadius(8)
        }
    }
}

// MARK: - Global Rankings View

struct GlobalRankingsView: View {
    @EnvironmentObject var gameManager: GameManager

    var rankedCountries: [GlobalCountryState.CountryState] {
        gameManager.globalCountryState.getRankedByTerritory()
    }

    var playerCountryCode: String {
        gameManager.character?.country ?? "USA"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GLOBAL TERRITORY RANKINGS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)
                .padding(.top, 4)

            ForEach(Array(rankedCountries.enumerated()), id: \.element.id) { index, country in
                CountryRankingRow(
                    rank: index + 1,
                    country: country,
                    isPlayerCountry: country.code == playerCountryCode
                )
            }
        }
    }
}

struct CountryRankingRow: View {
    let rank: Int
    let country: GlobalCountryState.CountryState
    let isPlayerCountry: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(rankColor)
                .frame(width: 30, alignment: .leading)

            // Country name
            Text(country.name)
                .font(.system(size: 14, weight: isPlayerCountry ? .bold : .regular))
                .foregroundColor(isPlayerCountry ? Constants.Colors.buttonPrimary : .white)

            Spacer()

            // Territory size
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatTerritory(country.totalTerritory))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                if country.territoryChangePercent != 0 {
                    Text(formatTerritoryChange(country.territoryChangePercent))
                        .font(.system(size: 11))
                        .foregroundColor(country.territoryChangePercent > 0 ? Constants.Colors.positive : Constants.Colors.negative)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(isPlayerCountry ? Constants.Colors.buttonPrimary.opacity(0.1) : Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(8)
    }

    var rankColor: Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0)  // Gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75)  // Silver
        case 3: return Color(red: 0.80, green: 0.50, blue: 0.20)  // Bronze
        default: return Constants.Colors.secondaryText
        }
    }

    private func formatTerritory(_ sqMiles: Double) -> String {
        if sqMiles >= 1_000_000 {
            return String(format: "%.1fM sq mi", sqMiles / 1_000_000)
        } else {
            return String(format: "%.0fk sq mi", sqMiles / 1000)
        }
    }

    private func formatTerritoryChange(_ percent: Double) -> String {
        let sign = percent > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", percent * 100))%"
    }
}

// MARK: - Conquered Territories View

struct ConqueredTerritoriesView: View {
    @EnvironmentObject var gameManager: GameManager

    var playerTerritories: [Territory] {
        let playerCode = gameManager.character?.country ?? "USA"
        return gameManager.territoryManager.territories.filter { $0.currentOwner == playerCode }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if playerTerritories.isEmpty {
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
                .padding(.top, 40)
            } else {
                Text("YOUR CONQUERED TERRITORIES")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .padding(.top, 4)

                ForEach(playerTerritories) { territory in
                    TerritoryCard(territory: territory)
                }
            }
        }
    }
}

// MARK: - Reparations View

struct ReparationsView: View {
    @EnvironmentObject var gameManager: GameManager

    var playerCountryCode: String {
        gameManager.character?.country ?? "USA"
    }

    var incomingReparations: [ReparationAgreement] {
        gameManager.territoryManager.activeReparations.filter { $0.recipientCountry == playerCountryCode }
    }

    var outgoingReparations: [ReparationAgreement] {
        gameManager.territoryManager.activeReparations.filter { $0.payerCountry == playerCountryCode }
    }

    var totalIncoming: Decimal {
        gameManager.territoryManager.getTotalAnnualReparationsReceived(recipientCountryCode: playerCountryCode)
    }

    var totalOutgoing: Decimal {
        gameManager.territoryManager.getTotalAnnualReparationsOwed(payerCountryCode: playerCountryCode)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Summary
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ANNUAL INCOMING")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(formatMoney(totalIncoming))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Constants.Colors.positive)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("ANNUAL OUTGOING")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(formatMoney(totalOutgoing))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Constants.Colors.negative)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                .cornerRadius(8)
            }

            // Incoming reparations
            if !incomingReparations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("RECEIVING FROM")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    ForEach(incomingReparations) { agreement in
                        ReparationRow(agreement: agreement, isIncoming: true)
                    }
                }
            }

            // Outgoing reparations
            if !outgoingReparations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PAYING TO")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    ForEach(outgoingReparations) { agreement in
                        ReparationRow(agreement: agreement, isIncoming: false)
                    }
                }
            }

            // Empty state
            if incomingReparations.isEmpty && outgoingReparations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 50))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("No Active Reparations")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Win wars and demand reparations to receive payments")
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            }
        }
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value > 0 {
            return String(format: "$%.0fk", value / 1000)
        } else {
            return "$0"
        }
    }
}

struct ReparationRow: View {
    @EnvironmentObject var gameManager: GameManager
    let agreement: ReparationAgreement
    let isIncoming: Bool

    var countryName: String {
        let code = isIncoming ? agreement.payerCountry : agreement.recipientCountry
        return gameManager.globalCountryState.getCountry(code: code)?.name ?? code
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(countryName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text("\(agreement.yearsPaid) of \(agreement.totalYears) years paid")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatMoney(agreement.yearlyPayment))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isIncoming ? Constants.Colors.positive : Constants.Colors.negative)

                Text("per year")
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
        }
        .padding(12)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(8)
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return String(format: "$%.0fk", value / 1000)
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
