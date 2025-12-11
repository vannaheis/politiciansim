//
//  PeaceTermsView.swift
//  PoliticianSim
//
//  Peace negotiation interface after war victory
//

import SwiftUI

struct PeaceTermsView: View {
    @EnvironmentObject var gameManager: GameManager
    let war: War
    @Binding var isPresented: Bool

    var defenderCountry: GlobalCountryState.CountryState? {
        gameManager.globalCountryState.getCountry(code: isPlayerAttacker ? war.defender : war.attacker)
    }

    var isPlayerAttacker: Bool {
        war.attacker == (gameManager.character?.country ?? "USA")
    }

    var isPlayerWinner: Bool {
        (war.outcome == .attackerVictory && isPlayerAttacker) ||
        (war.outcome == .defenderVictory && !isPlayerAttacker)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("WAR CONCLUDED")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("\(war.attacker) vs \(war.defender)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text("Victory")
                        .font(.system(size: 16))
                        .foregroundColor(Constants.Colors.positive)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                Divider()
                    .background(Color.white.opacity(0.2))

                // War Summary
                VStack(spacing: 16) {
                    // Casualties
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CASUALTIES")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text("\(formatNumber(war.casualtiesByCountry[war.attacker] ?? 0)) \(war.attacker)")
                                .font(.system(size: 14))
                                .foregroundColor(.white)

                            Text("\(formatNumber(war.casualtiesByCountry[war.defender] ?? 0)) \(war.defender)")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("WAR COSTS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text(formatMoney(war.costByCountry[war.attacker] ?? 0))
                                .font(.system(size: 14))
                                .foregroundColor(.white)

                            Text(formatMoney(war.costByCountry[war.defender] ?? 0))
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                    }

                    Divider()
                        .background(Color.white.opacity(0.2))

                    // Peace Terms Selection
                    Text("SELECT PEACE TERMS")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(availablePeaceTerms, id: \.self) { term in
                        PeaceTermButton(
                            term: term,
                            defenderCountry: defenderCountry,
                            war: war,
                            isPlayerAttacker: isPlayerAttacker,
                            action: {
                                selectPeaceTerm(term)
                            }
                        )
                    }
                }
                .padding(24)
            }
            .frame(width: 420)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }

    var availablePeaceTerms: [War.PeaceTerm] {
        // All peace terms available to player
        return [.fullConquest, .partialTerritory, .reparations, .statusQuo]
    }

    private func selectPeaceTerm(_ term: War.PeaceTerm) {
        guard let character = gameManager.character else { return }

        // Apply peace terms
        let result = gameManager.warEngine.applyPeaceTerms(
            warId: war.id,
            peaceTerm: term,
            globalCountryState: gameManager.globalCountryState,
            territoryManager: gameManager.territoryManager,
            currentDate: character.currentDate
        )

        if result.success {
            // Apply reputation and approval impacts
            let reputationChange = Int(term.reputationImpact)
            let approvalChange = term.approvalImpact

            gameManager.modifyStat(.reputation, by: reputationChange, reason: "Peace terms: \(term.rawValue)")
            gameManager.modifyApproval(by: approvalChange, reason: "War conclusion")

            // Create reparation agreement if reparations awarded
            if result.reparationAmount > 0 {
                let loserCode = isPlayerAttacker ? war.defender : war.attacker
                let winnerCode = isPlayerAttacker ? war.attacker : war.defender

                let reparation = ReparationAgreement(
                    payerCountry: loserCode,
                    recipientCountry: winnerCode,
                    totalAmount: result.reparationAmount,
                    startDate: character.currentDate,
                    warId: war.id
                )

                gameManager.territoryManager.activeReparations.append(reparation)
            }

            // End war
            gameManager.warEngine.endWar(warId: war.id)
        }

        // Close view
        isPresented = false
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
            return "$\(String(format: "%.1f", value / 1_000_000_000))B"
        } else if value >= 1_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000))M"
        } else {
            return "$\(String(format: "%.0f", value))"
        }
    }
}

// MARK: - Peace Term Button

struct PeaceTermButton: View {
    let term: War.PeaceTerm
    let defenderCountry: GlobalCountryState.CountryState?
    let war: War
    let isPlayerAttacker: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(term.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    if term != .statusQuo {
                        Image(systemName: impactIcon)
                            .font(.system(size: 14))
                            .foregroundColor(impactColor)
                    }
                }

                Text(term.description)
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.leading)

                // Show specific impacts
                VStack(alignment: .leading, spacing: 4) {
                    if let territory = estimatedTerritory {
                        HStack(spacing: 4) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text("Territory: \(territory)")
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                        }
                    }

                    if let reparations = estimatedReparations {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text("Reparations: \(reparations)")
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                        }
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("Approval: \(term.approvalImpact > 0 ? "+" : "")\(Int(term.approvalImpact))")
                            .font(.system(size: 11))
                            .foregroundColor(term.approvalImpact > 0 ? Constants.Colors.positive : Constants.Colors.negative)
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(Color(red: 0.15, green: 0.17, blue: 0.22))
            .cornerRadius(8)
        }
    }

    var estimatedTerritory: String? {
        guard let country = defenderCountry else { return nil }

        let percent = war.territoryConquered ?? term.territoryPercent
        if percent > 0 {
            let sqMiles = country.baseTerritory * percent
            if sqMiles >= 1_000_000 {
                return String(format: "%.1fM sq mi (%.0f%%)", sqMiles / 1_000_000, percent * 100)
            } else {
                return String(format: "%.0fk sq mi (%.0f%%)", sqMiles / 1000, percent * 100)
            }
        }
        return nil
    }

    var estimatedReparations: String? {
        guard let country = defenderCountry else { return nil }

        let amount = term.getReparationAmount(loserGDP: country.currentGDP)
        if amount > 0 {
            let value = Double(truncating: amount as NSNumber)
            if value >= 1_000_000_000 {
                return String(format: "$%.1fB over 10 years", value / 1_000_000_000)
            } else {
                return String(format: "$%.0fM over 10 years", value / 1_000_000)
            }
        }
        return nil
    }

    var impactIcon: String {
        if term.reputationImpact < 0 {
            return "exclamationmark.triangle.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }

    var impactColor: Color {
        if term.reputationImpact < 0 {
            return Constants.Colors.negative
        } else {
            return Constants.Colors.positive
        }
    }
}

#Preview {
    let war = War(
        attacker: "USA",
        defender: "Cuba",
        type: .offensive,
        justification: .territorialDispute,
        attackerStrength: 1_390_000,
        defenderStrength: 50_000,
        startDate: Date()
    )

    return PeaceTermsView(war: war, isPresented: .constant(true))
        .environmentObject(GameManager.shared)
}
