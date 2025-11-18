//
//  MilitaryOverviewView.swift
//  PoliticianSim
//
//  Military overview and statistics
//

import SwiftUI

struct MilitaryOverviewView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let character = gameManager.character,
                   let militaryStats = character.militaryStats {

                    // Military Strength Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Military Strength")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Strength")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(militaryStats.strength)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Constants.Colors.positive)
                            }

                            Divider()
                                .background(Constants.Colors.secondaryText.opacity(0.3))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Manpower")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(militaryStats.manpower)")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                    // Recruitment Type Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recruitment")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        HStack {
                            Text(militaryStats.recruitmentType.rawValue)
                                .font(.system(size: 15))
                                .foregroundColor(.white)

                            Spacer()

                            Text("Cost: \(formatMoney(militaryStats.recruitmentType.costPerSoldier))/soldier")
                                .font(.system(size: 13))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                    // Military Budget Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Military Budget")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        Text(formatMoney(militaryStats.militaryBudget))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Constants.Colors.positive)
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                    // Nuclear Arsenal Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nuclear Arsenal")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        if militaryStats.nuclearArsenal.isNuclearPower {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Warheads:")
                                        .foregroundColor(Constants.Colors.secondaryText)
                                    Spacer()
                                    Text("\(militaryStats.nuclearArsenal.warheadCount)")
                                        .foregroundColor(.white)
                                }

                                HStack {
                                    Text("ICBMs:")
                                        .foregroundColor(Constants.Colors.secondaryText)
                                    Spacer()
                                    Text("\(militaryStats.nuclearArsenal.icbmCount)")
                                        .foregroundColor(.white)
                                }

                                if militaryStats.nuclearArsenal.hasFirstStrikeCapability {
                                    Text("✓ First Strike Capable")
                                        .font(.system(size: 13))
                                        .foregroundColor(Constants.Colors.positive)
                                }

                                if militaryStats.nuclearArsenal.hasSecondStrikeCapability {
                                    Text("✓ Second Strike Capable (MAD)")
                                        .font(.system(size: 13))
                                        .foregroundColor(Constants.Colors.positive)
                                }
                            }
                        } else {
                            Text("No nuclear weapons")
                                .font(.system(size: 14))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                } else {
                    Text("No military data available")
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
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
    MilitaryOverviewView()
        .environmentObject(GameManager.shared)
}
