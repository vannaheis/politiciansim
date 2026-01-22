//
//  RecruitmentView.swift
//  PoliticianSim
//
//  Military recruitment and demobilization management
//

import SwiftUI

struct RecruitmentView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showRecruitConfirm: Int?
    @State private var showDemobilizeConfirm: Int?
    @State private var showExceedsMaxAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let character = gameManager.character,
                   let militaryStats = character.militaryStats {

                    let population = getPopulation(for: character.country)
                    let maxManpower = gameManager.militaryManager.calculateMaxManpower(
                        population: population,
                        militaryStats: militaryStats
                    )

                    // Current Status Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Military Forces")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Active Personnel")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(formatNumber(militaryStats.manpower))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Constants.Colors.positive)
                            }

                            Divider()
                                .background(Constants.Colors.secondaryText.opacity(0.3))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Maximum Capacity")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(formatNumber(maxManpower))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(red: 0.2, green: 0.2, blue: 0.25))
                                    .frame(height: 8)
                                    .cornerRadius(4)

                                let progress = min(1.0, Double(militaryStats.manpower) / Double(maxManpower))
                                Rectangle()
                                    .fill(Constants.Colors.buttonPrimary)
                                    .frame(width: geometry.size.width * progress, height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)

                        HStack {
                            Text("\(String(format: "%.1f%%", Double(militaryStats.manpower) / Double(maxManpower) * 100)) of capacity")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Spacer()

                            Text("10% of population")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                    // Recruitment Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recruit Forces")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        Text("Select percentage of maximum capacity to recruit")
                            .font(.system(size: 13))
                            .foregroundColor(Constants.Colors.secondaryText)

                        // Percentage buttons
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach([10, 20, 30, 50, 75, 100], id: \.self) { percentage in
                                let soldiers = Int(Double(maxManpower) * Double(percentage) / 100.0)
                                let cost = Decimal(soldiers) * militaryStats.recruitmentType.recruitmentCost

                                Button(action: {
                                    showRecruitConfirm = soldiers
                                }) {
                                    VStack(spacing: 4) {
                                        Text("\(percentage)%")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)

                                        Text("\(formatNumber(soldiers))")
                                            .font(.system(size: 12))
                                            .foregroundColor(Constants.Colors.secondaryText)

                                        Text(formatMoney(cost))
                                            .font(.system(size: 11))
                                            .foregroundColor(Constants.Colors.money)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Constants.Colors.buttonPrimary.opacity(0.2))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Constants.Colors.buttonPrimary, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                    // Demobilization Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Demobilize Forces")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        Text("Select percentage of current forces to demobilize")
                            .font(.system(size: 13))
                            .foregroundColor(Constants.Colors.secondaryText)

                        // Percentage buttons
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach([10, 20, 30, 50, 75, 100], id: \.self) { percentage in
                                let soldiers = Int(Double(militaryStats.manpower) * Double(percentage) / 100.0)
                                let severanceCost = militaryStats.recruitmentType == .volunteer ? Decimal(soldiers) * 5_000 : 0
                                let annualSavings = Decimal(soldiers) * militaryStats.recruitmentType.costPerSoldier

                                Button(action: {
                                    showDemobilizeConfirm = soldiers
                                }) {
                                    VStack(spacing: 4) {
                                        Text("\(percentage)%")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)

                                        Text("\(formatNumber(soldiers))")
                                            .font(.system(size: 12))
                                            .foregroundColor(Constants.Colors.secondaryText)

                                        Text("Save \(formatMoney(annualSavings))/yr")
                                            .font(.system(size: 11))
                                            .foregroundColor(Constants.Colors.positive)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Constants.Colors.negative.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Constants.Colors.negative, lineWidth: 1)
                                    )
                                }
                                .disabled(soldiers == 0)
                            }
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
        .alert("Recruit Soldiers", isPresented: Binding(
            get: { showRecruitConfirm != nil },
            set: { if !$0 { showRecruitConfirm = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                showRecruitConfirm = nil
            }
            Button("Confirm") {
                if let soldiers = showRecruitConfirm,
                   var character = gameManager.character,
                   var militaryStats = character.militaryStats {

                    let population = getPopulation(for: character.country)
                    let maxManpower = gameManager.militaryManager.calculateMaxManpower(
                        population: population,
                        militaryStats: militaryStats
                    )

                    // Check if exceeds max
                    if militaryStats.manpower + soldiers > maxManpower {
                        showExceedsMaxAlert = true
                        showRecruitConfirm = nil
                        return
                    }

                    let cost = gameManager.militaryManager.recruit(
                        militaryStats: &militaryStats,
                        soldiers: soldiers
                    )

                    // Allow deficit spending - military can go into debt
                    militaryStats.treasury.cashReserves -= cost
                    character.militaryStats = militaryStats
                    gameManager.characterManager.updateCharacter(character)
                }
                showRecruitConfirm = nil
            }
        } message: {
            if let soldiers = showRecruitConfirm,
               let militaryStats = gameManager.character?.militaryStats {
                let cost = Decimal(soldiers) * militaryStats.recruitmentType.recruitmentCost
                let annualCost = Decimal(soldiers) * militaryStats.recruitmentType.costPerSoldier

                Text("Recruit \(formatNumber(soldiers)) soldiers?\n\nUpfront Cost: \(formatMoney(cost))\nAnnual Personnel Cost: +\(formatMoney(annualCost))\n\nMilitary Cash Reserves: \(formatMoney(militaryStats.treasury.cashReserves))")
            }
        }
        .alert("Demobilize Forces", isPresented: Binding(
            get: { showDemobilizeConfirm != nil },
            set: { if !$0 { showDemobilizeConfirm = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                showDemobilizeConfirm = nil
            }
            Button("Confirm", role: .destructive) {
                if let soldiers = showDemobilizeConfirm,
                   var character = gameManager.character,
                   var militaryStats = character.militaryStats {

                    let severanceCost = gameManager.militaryManager.demobilize(
                        militaryStats: &militaryStats,
                        soldiers: soldiers
                    )

                    militaryStats.treasury.cashReserves -= severanceCost
                    character.militaryStats = militaryStats
                    gameManager.characterManager.updateCharacter(character)
                }
                showDemobilizeConfirm = nil
            }
        } message: {
            if let soldiers = showDemobilizeConfirm,
               let militaryStats = gameManager.character?.militaryStats {
                let severanceCost = militaryStats.recruitmentType == .volunteer ? Decimal(soldiers) * 5_000 : 0
                let annualSavings = Decimal(soldiers) * militaryStats.recruitmentType.costPerSoldier

                Text("Discharge \(formatNumber(soldiers)) soldiers?\n\nSeverance Cost: \(formatMoney(severanceCost))\nAnnual Savings: \(formatMoney(annualSavings))\n\nThis will reduce military strength immediately.")
            }
        }
        .alert("Exceeds Maximum", isPresented: $showExceedsMaxAlert) {
            Button("OK", role: .cancel) {
                showExceedsMaxAlert = false
            }
        } message: {
            if let character = gameManager.character,
               let militaryStats = character.militaryStats {
                let population = getPopulation(for: character.country)
                let maxManpower = gameManager.militaryManager.calculateMaxManpower(
                    population: population,
                    militaryStats: militaryStats
                )

                Text("Cannot recruit more soldiers. You would exceed maximum capacity.\n\nCurrent: \(formatNumber(militaryStats.manpower))\nMax: \(formatNumber(maxManpower))")
            }
        }
        .navigationTitle("Recruitment")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func getPopulation(for countryCode: String) -> Int {
        // For now, only USA is supported
        if countryCode == "USA" {
            return Country.usa.population
        }
        return 330_000_000 // Default to USA population
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
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
        } else if value >= 1_000 {
            return String(format: "$%.1fK", value / 1_000)
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }
}

#Preview {
    RecruitmentView()
        .environmentObject(GameManager.shared)
}
