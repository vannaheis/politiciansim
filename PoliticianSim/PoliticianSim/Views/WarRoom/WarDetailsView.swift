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
    let warId: UUID
    @State private var showNegotiatePeaceConfirm = false
    @State private var showSurrenderConfirm = false
    @State private var showStrategySelector = false

    init(war: War) {
        self.warId = war.id
    }

    // Get live war data from gameManager
    var war: War? {
        gameManager.warEngine.activeWars.first(where: { $0.id == warId })
    }

    var playerCountry: String {
        gameManager.character?.country ?? "USA"
    }

    var isPlayerAttacker: Bool {
        war?.attacker == playerCountry
    }

    var playerCasualties: Int {
        abs(war?.casualtiesByCountry[playerCountry] ?? 0)
    }

    var enemyCasualties: Int {
        guard let war = war else { return 0 }
        let enemyCountry = isPlayerAttacker ? war.defender : war.attacker
        return abs(war.casualtiesByCountry[enemyCountry] ?? 0)
    }

    var playerCost: Decimal {
        war?.costByCountry[playerCountry] ?? 0
    }

    var playerAttrition: Double {
        guard let war = war else { return 0 }
        return isPlayerAttacker ? war.attackerAttrition : war.defenderAttrition
    }

    var enemyAttrition: Double {
        guard let war = war else { return 0 }
        return isPlayerAttacker ? war.defenderAttrition : war.attackerAttrition
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
        guard let war = war else { return false }
        // Can negotiate if war exhaustion is high or player is winning
        return war.exhaustionLevel == .high ||
               war.exhaustionLevel == .critical ||
               (enemyAttrition > playerAttrition + 0.15)
    }

    var body: some View {
        NavigationView {
            ZStack {
                StandardBackgroundView()

                if let war = war {
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

                        // Current Strategy Section
                        CurrentStrategySection(
                            war: war,
                            currentDate: gameManager.character?.currentDate ?? Date(),
                            onTapChangeStrategy: {
                                showStrategySelector = true
                            }
                        )

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
        .fullScreenCover(isPresented: $showNegotiatePeaceConfirm) {
            if let war = war {
                PeaceNegotiationPopup(
                    war: war,
                    playerCountry: playerCountry,
                    isPlayerAttacker: isPlayerAttacker
                )
                .environmentObject(gameManager)
            }
        }
        .fullScreenCover(isPresented: $showSurrenderConfirm) {
            if let war = war {
                SurrenderConfirmationPopup(
                    war: war,
                    playerCountry: playerCountry,
                    isPlayerAttacker: isPlayerAttacker
                )
                .environmentObject(gameManager)
            }
        }
        .sheet(isPresented: $showStrategySelector) {
            if let war = war {
                StrategySelectionSheet(war: war)
                    .environmentObject(gameManager)
            }
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

// MARK: - Current Strategy Section

struct CurrentStrategySection: View {
    let war: War
    let currentDate: Date
    let onTapChangeStrategy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CURRENT STRATEGY")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Constants.Colors.secondaryText)

            Button(action: onTapChangeStrategy) {
                HStack(spacing: 12) {
                    Image(systemName: war.currentStrategy.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Constants.Colors.buttonPrimary)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(war.currentStrategy.rawValue)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            if war.isTransitioning {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)

                                Text(war.targetStrategy?.rawValue ?? "")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                        }

                        if war.isTransitioning, let target = war.targetStrategy {
                            let progress = war.transitionProgress(currentDate: currentDate)
                            Text("Transitioning... \(Int(progress * 100))% complete")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        } else {
                            Text(war.currentStrategy.description)
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.secondaryText)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
                .padding(16)
                .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                .cornerRadius(12)
            }

            // Transition progress bar (if transitioning)
            if war.isTransitioning {
                let progress = war.transitionProgress(currentDate: currentDate)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Transition Progress")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Spacer()

                        if let days = war.transitionDurationDays {
                            let daysRemaining = days - Int(Double(days) * progress)
                            Text("\(daysRemaining) days remaining")
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                        }
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                                .cornerRadius(3)

                            Rectangle()
                                .fill(.orange)
                                .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22).opacity(0.5))
        .cornerRadius(12)
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
