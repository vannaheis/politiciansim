//
//  TerritoryDetailView.swift
//  PoliticianSim
//
//  Detailed view of a conquered territory with management options
//

import SwiftUI

struct TerritoryDetailView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    let territory: Territory
    let playerCountry: String
    @State private var showInvestConfirm = false
    @State private var showSuppressConfirm = false
    @State private var showGrantAutonomyConfirm = false
    @State private var showGrantIndependenceConfirm = false

    var activeRebellion: Rebellion? {
        gameManager.territoryManager.activeRebellions.first(where: { $0.territory.id == territory.id })
    }

    var territoryGDP: Double {
        if let country = gameManager.globalCountryState.getCountry(code: territory.formerOwner) {
            let territoryPercentOfFormerCountry = territory.size / country.baseTerritory
            let baseGDPForTerritory = country.currentGDP * territoryPercentOfFormerCountry
            return baseGDPForTerritory * territory.gdpContributionMultiplier
        }
        return 0
    }

    var moralStatus: (text: String, color: Color) {
        if territory.morale >= 0.80 {
            return ("Stable & Content", Constants.Colors.positive)
        } else if territory.morale >= 0.60 {
            return ("Stable", .yellow)
        } else if territory.morale >= 0.40 {
            return ("Discontent", .orange)
        } else if territory.morale >= 0.20 {
            return ("Restive", Constants.Colors.negative)
        } else {
            return ("Rebellious", Constants.Colors.negative)
        }
    }

    var rebellionRiskStatus: (text: String, color: Color) {
        if territory.rebellionRisk >= 0.7 {
            return ("Imminent", Constants.Colors.negative)
        } else if territory.rebellionRisk >= 0.4 {
            return ("High", .orange)
        } else if territory.rebellionRisk >= 0.2 {
            return ("Moderate", .yellow)
        } else {
            return ("Low", Constants.Colors.positive)
        }
    }

    var canInvest: Bool {
        guard let treasury = gameManager.treasuryManager.currentTreasury else { return false }
        return treasury.cashOnHand >= 50_000_000_000 && territory.morale < 1.0
    }

    var canSuppressRebellion: Bool {
        return activeRebellion != nil
    }

    var canGrantAutonomy: Bool {
        return territory.type == .conquered && territory.morale < 0.70
    }

    var body: some View {
        NavigationView {
            ZStack {
                StandardBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Territory Header
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(Constants.Colors.buttonPrimary)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(territory.type.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text("Type")
                                        .font(.system(size: 12))
                                        .foregroundColor(Constants.Colors.secondaryText)
                                }
                            }

                            Text(territory.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Conquered from \(territory.formerOwner)")
                                .font(.system(size: 14))
                                .foregroundColor(Constants.Colors.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(20)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Territory Stats
                        VStack(alignment: .leading, spacing: 16) {
                            Text("TERRITORY INFORMATION")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack(spacing: 12) {
                                TerritoryStatCard(
                                    icon: "chart.bar.fill",
                                    label: "GDP Contribution",
                                    value: formatMoney(territoryGDP),
                                    color: Constants.Colors.positive
                                )

                                TerritoryStatCard(
                                    icon: "person.3.fill",
                                    label: "Population",
                                    value: formatNumber(territory.population),
                                    color: Constants.Colors.buttonPrimary
                                )
                            }

                            HStack(spacing: 12) {
                                TerritoryStatCard(
                                    icon: "calendar",
                                    label: "Years Held",
                                    value: "\(territory.yearsSinceConquest)",
                                    color: .white
                                )

                                TerritoryStatCard(
                                    icon: "percent",
                                    label: "Size",
                                    value: String(format: "%.1f%%", territory.size * 100),
                                    color: .white
                                )
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Morale Status
                        VStack(alignment: .leading, spacing: 12) {
                            Text("MORALE STATUS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 18))
                                    .foregroundColor(moralStatus.color)

                                Text(moralStatus.text)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(moralStatus.color)

                                Spacer()

                                Text("\(Int(territory.morale * 100))/100")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            // Morale progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 8)
                                        .cornerRadius(4)

                                    Rectangle()
                                        .fill(moralStatus.color)
                                        .frame(width: geometry.size.width * CGFloat(territory.morale), height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Rebellion Risk
                        VStack(alignment: .leading, spacing: 12) {
                            Text("REBELLION RISK")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(rebellionRiskStatus.color)

                                Text(rebellionRiskStatus.text)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(rebellionRiskStatus.color)

                                Spacer()

                                Text(String(format: "%.0f%%", territory.rebellionRisk * 100))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(rebellionRiskStatus.color)
                            }

                            // Rebellion risk progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 8)
                                        .cornerRadius(4)

                                    Rectangle()
                                        .fill(rebellionRiskStatus.color)
                                        .frame(width: geometry.size.width * CGFloat(territory.rebellionRisk), height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)

                            if let rebellion = activeRebellion {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("ACTIVE REBELLION")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Constants.Colors.negative)

                                    Text("Rebel Strength: \(formatNumber(rebellion.strength))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)

                                    Text("Support: \(String(format: "%.0f%%", rebellion.support * 100))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Constants.Colors.negative.opacity(0.15))
                                .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Management Actions
                        VStack(spacing: 12) {
                            Text("MANAGEMENT ACTIONS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            // Invest in Territory
                            Button(action: {
                                showInvestConfirm = true
                            }) {
                                HStack {
                                    Image(systemName: canInvest ? "dollarsign.circle.fill" : "dollarsign.circle")
                                        .foregroundColor(canInvest ? Constants.Colors.positive : Constants.Colors.secondaryText)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Invest in Territory")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(canInvest ? .white : Constants.Colors.secondaryText)

                                        Text("Cost: $50B • +15 morale")
                                            .font(.system(size: 11))
                                            .foregroundColor(Constants.Colors.secondaryText)
                                    }

                                    Spacer()
                                }
                                .padding(14)
                                .background(canInvest ? Constants.Colors.positive.opacity(0.15) : Color.white.opacity(0.05))
                                .cornerRadius(10)
                            }
                            .disabled(!canInvest)

                            // Suppress Rebellion
                            if canSuppressRebellion {
                                Button(action: {
                                    showSuppressConfirm = true
                                }) {
                                    HStack {
                                        Image(systemName: "shield.fill")
                                            .foregroundColor(Constants.Colors.negative)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Suppress Rebellion")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)

                                            Text("Military action • May harm approval")
                                                .font(.system(size: 11))
                                                .foregroundColor(Constants.Colors.secondaryText)
                                        }

                                        Spacer()
                                    }
                                    .padding(14)
                                    .background(Constants.Colors.negative.opacity(0.15))
                                    .cornerRadius(10)
                                }
                            }

                            // Grant Autonomy
                            Button(action: {
                                showGrantAutonomyConfirm = true
                            }) {
                                HStack {
                                    Image(systemName: canGrantAutonomy ? "hand.raised.fill" : "hand.raised.slash")
                                        .foregroundColor(canGrantAutonomy ? Constants.Colors.buttonPrimary : Constants.Colors.secondaryText)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Grant Autonomy")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(canGrantAutonomy ? .white : Constants.Colors.secondaryText)

                                        Text("Improve relations • Reduce GDP contribution")
                                            .font(.system(size: 11))
                                            .foregroundColor(Constants.Colors.secondaryText)
                                    }

                                    Spacer()
                                }
                                .padding(14)
                                .background(canGrantAutonomy ? Constants.Colors.buttonPrimary.opacity(0.15) : Color.white.opacity(0.05))
                                .cornerRadius(10)
                            }
                            .disabled(!canGrantAutonomy)

                            // Grant Independence
                            Button(action: {
                                showGrantIndependenceConfirm = true
                            }) {
                                HStack {
                                    Image(systemName: "flag.fill")
                                        .foregroundColor(.orange)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Grant Independence")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)

                                        Text("Release territory • +reputation")
                                            .font(.system(size: 11))
                                            .foregroundColor(Constants.Colors.secondaryText)
                                    }

                                    Spacer()
                                }
                                .padding(14)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Territory Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.buttonPrimary)
                }
            }
        }
        .alert("Invest in Territory", isPresented: $showInvestConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Invest $50B") {
                investInTerritory()
            }
        } message: {
            Text("Invest $50 billion to improve infrastructure and living conditions. This will increase morale by 15 points.")
        }
        .alert("Suppress Rebellion", isPresented: $showSuppressConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Suppress", role: .destructive) {
                suppressRebellion()
            }
        } message: {
            Text("Use military force to suppress the rebellion. This may harm your approval rating.")
        }
        .alert("Grant Autonomy", isPresented: $showGrantAutonomyConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Grant Autonomy") {
                grantAutonomy()
            }
        } message: {
            Text("Grant this territory greater self-governance. This will improve morale but reduce GDP contribution by 25%.")
        }
        .alert("Grant Independence", isPresented: $showGrantIndependenceConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Grant Independence") {
                grantIndependence()
            }
        } message: {
            Text("Release this territory as an independent nation. You will gain +20 reputation but lose all GDP contribution.")
        }
    }

    private func investInTerritory() {
        let investmentAmount: Decimal = 50_000_000_000
        let success = gameManager.territoryManager.investInTerritory(
            territoryId: territory.id,
            amount: investmentAmount
        )

        if success, let character = gameManager.character {
            // Deduct from treasury
            gameManager.treasuryManager.recordReparationPayment(
                amount: -investmentAmount,
                description: "Territory Investment - \(territory.name)",
                date: character.currentDate
            )
        }

        dismiss()
    }

    private func suppressRebellion() {
        guard let rebellion = activeRebellion else { return }

        // Apply approval penalty for suppression
        if var character = gameManager.character {
            character.approvalRating = max(0, character.approvalRating - 10.0)
            gameManager.characterManager.updateCharacter(character)
        }

        let result = gameManager.territoryManager.suppressRebellion(
            rebellionId: rebellion.id,
            militaryStrength: 100_000
        )

        if result.success, let character = gameManager.character {
            // Deduct from treasury
            gameManager.treasuryManager.recordReparationPayment(
                amount: -result.cost,
                description: "Rebellion Suppression - \(territory.name)",
                date: character.currentDate
            )
        }

        dismiss()
    }

    private func grantAutonomy() {
        let success = gameManager.territoryManager.grantAutonomy(territoryId: territory.id)

        if success {
            // Reputation boost for granting autonomy
            if var character = gameManager.character {
                character.reputation = min(100, character.reputation + 10)
                gameManager.characterManager.updateCharacter(character)
            }
        }

        dismiss()
    }

    private func grantIndependence() {
        // Remove the territory from control
        if let territoryIndex = gameManager.territoryManager.territories.firstIndex(where: { $0.id == territory.id }) {
            gameManager.territoryManager.territories.remove(at: territoryIndex)

            // Reputation boost for granting independence
            if var character = gameManager.character {
                character.reputation = min(100, character.reputation + 20)
                gameManager.characterManager.updateCharacter(character)
            }
        }

        dismiss()
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatMoney(_ amount: Double) -> String {
        if amount >= 1_000_000_000_000 {
            return String(format: "$%.1fT", amount / 1_000_000_000_000)
        } else if amount >= 1_000_000_000 {
            return String(format: "$%.1fB", amount / 1_000_000_000)
        } else if amount >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
}

// MARK: - Territory Stat Card

struct TerritoryStatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)

                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(red: 0.2, green: 0.22, blue: 0.27))
        .cornerRadius(8)
    }
}

#Preview {
    let territory = Territory(
        name: "Eastern Provinces",
        formerOwner: "CHN",
        currentOwner: "USA",
        size: 3_700_000,
        population: 45_000_000,
        conquestDate: Date().addingTimeInterval(-180 * 24 * 60 * 60)
    )

    TerritoryDetailView(territory: territory, playerCountry: "USA")
        .environmentObject(GameManager.shared)
}
