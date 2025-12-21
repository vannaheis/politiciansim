//
//  WarArchiveView.swift
//  PoliticianSim
//
//  Historical war records archive
//

import SwiftUI

struct WarArchiveView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if gameManager.warEngine.warHistory.isEmpty {
                    EmptyArchiveView()
                } else {
                    ForEach(sortedWarHistory) { war in
                        WarArchiveCard(war: war)
                    }
                }
            }
            .padding(24)
        }
        .background(Constants.Colors.background)
    }

    var sortedWarHistory: [War] {
        gameManager.warEngine.warHistory.sorted { (w1, w2) in
            (w1.endDate ?? w1.startDate) > (w2.endDate ?? w2.startDate)
        }
    }
}

// MARK: - Empty State

struct EmptyArchiveView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryText)

            Text("No Historical Wars")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Text("Concluded wars will appear here")
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - War Archive Card

struct WarArchiveCard: View {
    @EnvironmentObject var gameManager: GameManager
    let war: War

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(war.attacker) vs \(war.defender)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text(war.formattedDuration)
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Spacer()

                // Outcome badge
                HStack(spacing: 4) {
                    Image(systemName: war.outcome?.icon ?? "questionmark.circle")
                        .font(.system(size: 12))

                    Text(war.outcome?.rawValue ?? "Unknown")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(outcomeColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(outcomeColor.opacity(0.15))
                .cornerRadius(8)
            }
            .padding(16)

            Divider()
                .background(Color.white.opacity(0.1))

            // War Details
            VStack(spacing: 12) {
                // Casualties
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CASUALTIES")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("\(formatNumber(abs(war.casualtiesByCountry[war.attacker] ?? 0))) \(war.attacker)")
                            .font(.system(size: 13))
                            .foregroundColor(.white)

                        Text("\(formatNumber(abs(war.casualtiesByCountry[war.defender] ?? 0))) \(war.defender)")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("WAR COSTS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text(formatMoney(war.costByCountry[war.attacker] ?? 0))
                            .font(.system(size: 13))
                            .foregroundColor(.white)

                        Text(formatMoney(war.costByCountry[war.defender] ?? 0))
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                }

                // Peace Terms
                if let peaceTerm = war.peaceTerm {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PEACE TERMS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        HStack {
                            Text(peaceTerm.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()
                        }

                        if let territoryPercent = war.territoryConquered, territoryPercent > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                if let loserCountry = getLoserCountry() {
                                    let sqMiles = loserCountry.baseTerritory * territoryPercent
                                    Text("Territory: \(formatTerritory(sqMiles)) (\(String(format: "%.0f%%", territoryPercent * 100)))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                }
                            }
                        }

                        if let reparations = getReparations(), reparations > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("Reparations: \(formatMoney(reparations))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Constants.Colors.cardBackground)
        .cornerRadius(12)
    }

    var outcomeColor: Color {
        guard let outcome = war.outcome else { return Constants.Colors.secondaryText }

        switch outcome {
        case .attackerVictory, .defenderVictory:
            return Constants.Colors.positive
        case .stalemate:
            return .orange
        case .peaceTreaty:
            return .blue
        case .nuclearAnnihilation:
            return Constants.Colors.negative
        }
    }

    func getLoserCountry() -> GlobalCountryState.CountryState? {
        let loserCode = war.outcome == .attackerVictory ? war.defender : war.attacker
        return gameManager.globalCountryState.getCountry(code: loserCode)
    }

    func getReparations() -> Decimal? {
        guard let peaceTerm = war.peaceTerm,
              let loserCountry = getLoserCountry() else { return nil }

        let amount = peaceTerm.getReparationAmount(loserGDP: loserCountry.currentGDP)
        return amount > 0 ? amount : nil
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

    private func formatTerritory(_ sqMiles: Double) -> String {
        if sqMiles >= 1_000_000 {
            return String(format: "%.1fM sq mi", sqMiles / 1_000_000)
        } else {
            return String(format: "%.0fk sq mi", sqMiles / 1_000)
        }
    }
}

#Preview {
    WarArchiveView()
        .environmentObject(GameManager.shared)
}
