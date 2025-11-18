//
//  ActiveWarsView.swift
//  PoliticianSim
//
//  Active wars management
//

import SwiftUI

struct ActiveWarsView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if gameManager.warEngine.activeWars.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "flag.slash")
                            .font(.system(size: 50))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("No Active Wars")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Your nation is currently at peace")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(gameManager.warEngine.activeWars) { war in
                        WarCard(war: war)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

struct WarCard: View {
    let war: War

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: war.type.icon)
                    .foregroundColor(Constants.Colors.buttonPrimary)

                Text(war.type.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text(war.formattedDuration)
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Text("\(war.attacker) vs \(war.defender)")
                .font(.system(size: 14))
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Casualties")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("\(war.casualtiesByCountry[war.attacker] ?? 0)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.negative)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Cost")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(formatMoney(war.costByCountry[war.attacker] ?? 0))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.negative)
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0

        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }
}

#Preview {
    ActiveWarsView()
        .environmentObject(GameManager.shared)
}
