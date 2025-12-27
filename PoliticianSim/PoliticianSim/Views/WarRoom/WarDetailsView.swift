//
//  WarDetailsView.swift
//  PoliticianSim
//
//  Detailed view of an active war with management options
//

import SwiftUI

struct WarDetailsView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    let war: War
    @State private var showNegotiatePeaceConfirm = false
    @State private var showSurrenderConfirm = false
    @State private var selectedStrategy: War.WarStrategy

    init(war: War) {
        self.war = war
        _selectedStrategy = State(initialValue: war.currentStrategy)
    }

    var playerCountry: String {
        gameManager.character?.country ?? "USA"
    }

    var isPlayerAttacker: Bool {
        war.attacker == playerCountry
    }

    var playerCasualties: Int {
        abs(war.casualtiesByCountry[playerCountry] ?? 0)
    }

    var enemyCasualties: Int {
        let enemyCountry = isPlayerAttacker ? war.defender : war.attacker
        return abs(war.casualtiesByCountry[enemyCountry] ?? 0)
    }

    var playerCost: Decimal {
        war.costByCountry[playerCountry] ?? 0
    }

    var playerAttrition: Double {
        isPlayerAttacker ? war.attackerAttrition : war.defenderAttrition
    }

    var enemyAttrition: Double {
        isPlayerAttacker ? war.defenderAttrition : war.attackerAttrition
    }

    var battleStatus: String {
        let attritionDiff = enemyAttrition - playerAttrition
        if abs(attritionDiff) < 0.05 {
            return "Stalemate"
        } else if attritionDiff > 0.20 {
            return "Decisive Advantage"
        } else if attritionDiff > 0.10 {
            return "Strong Advantage"
        } else if attritionDiff > 0 {
            return "Slight Advantage"
        } else if attritionDiff > -0.10 {
            return "Slight Disadvantage"
        } else if attritionDiff > -0.20 {
            return "Losing Ground"
        } else {
            return "Critical Situation"
        }
    }

    var battleStatusColor: Color {
        let attritionDiff = enemyAttrition - playerAttrition
        if attritionDiff > 0.10 {
            return Constants.Colors.positive
        } else if attritionDiff > 0 {
            return .yellow
        } else if attritionDiff > -0.10 {
            return .orange
        } else {
            return Constants.Colors.negative
        }
    }

    var canNegotiatePeace: Bool {
        // Can negotiate if war exhaustion is high or player is winning
        return war.exhaustionLevel == .high ||
               war.exhaustionLevel == .critical ||
               (enemyAttrition > playerAttrition + 0.15)
    }

    var body: some View {
        NavigationView {
            ZStack {
                StandardBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // War Header
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: war.type.icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(Constants.Colors.buttonPrimary)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(war.formattedDuration)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text("Duration")
                                        .font(.system(size: 12))
                                        .foregroundColor(Constants.Colors.secondaryText)
                                }
                            }

                            Text("\(war.attacker) vs \(war.defender)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(war.justification.rawValue)
                                .font(.system(size: 14))
                                .foregroundColor(Constants.Colors.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(20)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Battle Status
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BATTLE STATUS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack {
                                Text(battleStatus)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(battleStatusColor)

                                Spacer()

                                Image(systemName: battleStatusIcon)
                                    .font(.system(size: 24))
                                    .foregroundColor(battleStatusColor)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // War Exhaustion
                        WarExhaustionCard(war: war)

                        // Casualties
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CASUALTIES")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Forces")
                                        .font(.system(size: 13))
                                        .foregroundColor(Constants.Colors.secondaryText)

                                    Text(formatNumber(playerCasualties))
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Constants.Colors.negative)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Enemy Forces")
                                        .font(.system(size: 13))
                                        .foregroundColor(Constants.Colors.secondaryText)

                                    Text(formatNumber(enemyCasualties))
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Attrition & Cost
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("YOUR ATTRITION")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text(String(format: "%.1f%%", playerAttrition * 100))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Constants.Colors.negative)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                            .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("WAR COST")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text(formatMoney(playerCost))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Constants.Colors.negative)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                            .cornerRadius(10)
                        }

                        // War Strategy (placeholder for future)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CURRENT STRATEGY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack {
                                Image(systemName: war.currentStrategy.icon)
                                    .foregroundColor(Constants.Colors.buttonPrimary)

                                Text(war.currentStrategy.rawValue)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()
                            }
                            .padding(12)
                            .background(Color(red: 0.2, green: 0.22, blue: 0.27))
                            .cornerRadius(8)
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Action Buttons
                        VStack(spacing: 12) {
                            // Negotiate Peace
                            if canNegotiatePeace {
                                Button(action: {
                                    showNegotiatePeaceConfirm = true
                                }) {
                                    HStack {
                                        Image(systemName: "hand.raised.fill")
                                        Text("Negotiate Peace")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Constants.Colors.buttonPrimary)
                                    .cornerRadius(10)
                                }
                            } else {
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "hand.raised.slash")
                                            .foregroundColor(Constants.Colors.secondaryText)
                                        Text("Peace Negotiations Unavailable")
                                            .font(.system(size: 14))
                                            .foregroundColor(Constants.Colors.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                                    .cornerRadius(10)

                                    Text("Available when: War Exhaustion is High/Critical OR you have decisive advantage")
                                        .font(.system(size: 11))
                                        .foregroundColor(Constants.Colors.secondaryText)
                                        .multilineTextAlignment(.center)
                                }
                            }

                            // Surrender (always available but has consequences)
                            Button(action: {
                                showSurrenderConfirm = true
                            }) {
                                HStack {
                                    Image(systemName: "flag.fill")
                                    Text("Surrender")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Constants.Colors.negative)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("War Details")
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
        .alert("Negotiate Peace", isPresented: $showNegotiatePeaceConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Negotiate", role: .destructive) {
                negotiatePeace()
            }
        } message: {
            Text("Attempt to negotiate a peace settlement. The outcome depends on the current battle situation. This will end the war but may require concessions.\n\nContinue?")
        }
        .alert("Surrender", isPresented: $showSurrenderConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Surrender", role: .destructive) {
                surrender()
            }
        } message: {
            Text("Unconditional surrender will end the war immediately but with severe consequences:\n\n• Enemy chooses peace terms\n• Massive reputation loss\n• Severe approval penalty\n• Potential territory loss\n\nAre you sure?")
        }
    }

    var battleStatusIcon: String {
        let attritionDiff = enemyAttrition - playerAttrition
        if attritionDiff > 0.10 {
            return "arrow.up.circle.fill"
        } else if attritionDiff > 0 {
            return "equal.circle.fill"
        } else {
            return "arrow.down.circle.fill"
        }
    }

    private func negotiatePeace() {
        guard let index = gameManager.warEngine.activeWars.firstIndex(where: { $0.id == war.id }) else {
            return
        }

        var updatedWar = gameManager.warEngine.activeWars[index]

        // Determine outcome based on attrition difference
        let attritionDiff = enemyAttrition - playerAttrition

        if attritionDiff > 0.15 {
            // Player is winning decisively → peace on favorable terms
            updatedWar.resolveWar(outcome: isPlayerAttacker ? .attackerVictory : .defenderVictory)
        } else if attritionDiff > 0 {
            // Player has slight advantage → status quo ante bellum
            updatedWar.outcome = .peaceTreaty
            updatedWar.territoryConquered = 0.0
        } else if attritionDiff > -0.15 {
            // Relatively even → status quo
            updatedWar.outcome = .stalemate
            updatedWar.territoryConquered = 0.0
        } else {
            // Player is losing → unfavorable peace
            updatedWar.resolveWar(outcome: isPlayerAttacker ? .defenderVictory : .attackerVictory)
        }

        gameManager.warEngine.activeWars[index] = updatedWar

        // Apply small approval boost for ending war diplomatically
        if var character = gameManager.character {
            character.approvalRating = min(100, character.approvalRating + 5.0)
            character.stress = max(0, character.stress - 10)
            gameManager.characterManager.updateCharacter(character)
        }

        dismiss()
    }

    private func surrender() {
        guard let index = gameManager.warEngine.activeWars.firstIndex(where: { $0.id == war.id }) else {
            return
        }

        var updatedWar = gameManager.warEngine.activeWars[index]

        // Player surrenders → enemy victory
        updatedWar.resolveWar(outcome: isPlayerAttacker ? .defenderVictory : .attackerVictory)

        // Set higher territory conquered for surrender
        updatedWar.territoryConquered = 0.35  // Maximum territory loss

        gameManager.warEngine.activeWars[index] = updatedWar

        dismiss()
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return String(format: "$%.0f", value)
        }
    }
}

// MARK: - War Exhaustion Card Component

struct WarExhaustionCard: View {
    let war: War

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WAR EXHAUSTION")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Constants.Colors.secondaryText)

            HStack {
                Image(systemName: war.exhaustionLevel.icon)
                    .font(.system(size: 18))
                    .foregroundColor(exhaustionColor)

                Text(war.exhaustionLevel.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(exhaustionColor)

                Spacer()

                Text(war.formattedExhaustion)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(exhaustionColor)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(exhaustionColor)
                        .frame(width: geometry.size.width * CGFloat(war.warExhaustion), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            // Consequences
            if war.exhaustionLevel != .minimal {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly Consequences:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.system(size: 10))
                            Text("\(String(format: "%.1f", war.exhaustionLevel.weeklyApprovalPenalty))% approval")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(Constants.Colors.negative)

                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                            Text("+\(war.exhaustionLevel.weeklyStressIncrease) stress")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(Constants.Colors.negative)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }

    var exhaustionColor: Color {
        switch war.exhaustionLevel.color {
        case "green": return Constants.Colors.positive
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return Constants.Colors.negative
        default: return .white
        }
    }
}

#Preview {
    let war = War(
        attacker: "USA",
        defender: "CHN",
        type: .offensive,
        justification: .territorialDispute,
        attackerStrength: 1_400_000,
        defenderStrength: 2_035_000,
        startDate: Date().addingTimeInterval(-120 * 24 * 60 * 60)
    )

    var warWithProgress = war
    warWithProgress.daysSinceStart = 120
    warWithProgress.updateWarExhaustion()

    return WarDetailsView(war: warWithProgress)
        .environmentObject(GameManager.shared)
}
