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
                    MilitaryBudgetCard(militaryStats: militaryStats)

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

// MARK: - Military Budget Card

struct MilitaryBudgetCard: View {
    @EnvironmentObject var gameManager: GameManager
    let militaryStats: MilitaryStats
    @State private var budgetAmount: Double = 0

    var militaryDepartment: Department? {
        gameManager.budgetManager.currentBudget?.departments.first(where: { $0.category == .military })
    }

    var maxBudget: Double {
        guard let budget = gameManager.budgetManager.currentBudget else { return 1_000_000_000_000 }
        return Double(truncating: (budget.totalRevenue * 0.5) as NSDecimalNumber)
    }

    var stepSize: Double {
        maxBudget / 100.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Military Budget")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            HStack {
                Text("Current:")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text(formatMoney(militaryStats.militaryBudget))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Budget adjustment slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Proposed: \(formatMoney(Decimal(budgetAmount)))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Constants.Colors.buttonPrimary)

                Slider(value: $budgetAmount, in: 0...maxBudget, step: stepSize)
                    .accentColor(Constants.Colors.buttonPrimary)
                    .onChange(of: budgetAmount) { newValue in
                        adjustBudget(newAmount: Decimal(newValue))
                    }
            }

            Text("Adjust military budget in the Budget view to apply changes")
                .font(.system(size: 10))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
        .onAppear {
            budgetAmount = Double(truncating: militaryStats.militaryBudget as NSDecimalNumber)
        }
    }

    private func adjustBudget(newAmount: Decimal) {
        guard var character = gameManager.character else { return }
        guard let departmentId = militaryDepartment?.id else { return }

        let _ = gameManager.budgetManager.adjustDepartmentFunding(
            departmentId: departmentId,
            newAmount: newAmount,
            character: &character
        )
        gameManager.characterManager.updateCharacter(character)
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
