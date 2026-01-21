//
//  RecruitmentView.swift
//  PoliticianSim
//
//  Military recruitment and mobilization management
//

import SwiftUI

struct RecruitmentView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var recruitmentAmount: String = ""
    @State private var demobilizationAmount: String = ""
    @State private var showRecruitConfirm = false
    @State private var showDemobilizeConfirm = false
    @State private var showChangeMobilizationConfirm: MobilizationLevel?
    @State private var showInsufficientFundsAlert = false
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
                        Text("Current Forces")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Active Duty")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(formatNumber(militaryStats.manpower))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Constants.Colors.positive)
                            }

                            Divider()
                                .background(Constants.Colors.secondaryText.opacity(0.3))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("In Training")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(formatNumber(militaryStats.recruitsInTraining))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.orange)
                            }

                            Divider()
                                .background(Constants.Colors.secondaryText.opacity(0.3))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("\(formatNumber(militaryStats.totalPersonnel))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        Divider().background(Color.white.opacity(0.2))

                        HStack {
                            Text("Maximum Capacity:")
                                .font(.system(size: 13))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Spacer()

                            Text("\(formatNumber(maxManpower))")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(red: 0.2, green: 0.2, blue: 0.25))
                                    .frame(height: 8)
                                    .cornerRadius(4)

                                let progress = min(1.0, Double(militaryStats.totalPersonnel) / Double(maxManpower))
                                Rectangle()
                                    .fill(Constants.Colors.buttonPrimary)
                                    .frame(width: geometry.size.width * progress, height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                    .cornerRadius(12)

                    // Mobilization Level Card
                    MobilizationLevelCard(
                        currentLevel: militaryStats.mobilizationLevel,
                        onChangeMobilization: { level in
                            showChangeMobilizationConfirm = level
                        }
                    )

                    // Training Queue
                    if !militaryStats.trainingQueue.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Training Queue")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            ForEach(militaryStats.trainingQueue) { cohort in
                                TrainingCohortCard(cohort: cohort)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Recruitment Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recruit Soldiers")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        Text(militaryStats.recruitmentType.rawValue)
                            .font(.system(size: 13))
                            .foregroundColor(Constants.Colors.secondaryText)

                        HStack {
                            TextField("Number of soldiers", text: $recruitmentAmount)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color(red: 0.12, green: 0.14, blue: 0.18))
                                .cornerRadius(8)
                                .foregroundColor(.white)

                            Button(action: {
                                if let amount = Int(recruitmentAmount), amount > 0 {
                                    showRecruitConfirm = true
                                }
                            }) {
                                Text("Recruit")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Constants.Colors.buttonPrimary)
                                    .cornerRadius(8)
                            }
                        }

                        if let amount = Int(recruitmentAmount), amount > 0 {
                            let cost = Decimal(amount) * militaryStats.recruitmentType.recruitmentCost
                            Text("Cost: \(formatMoney(cost)) • Training Time: 90 days")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.secondaryText)
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

                        HStack {
                            TextField("Number of soldiers", text: $demobilizationAmount)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color(red: 0.12, green: 0.14, blue: 0.18))
                                .cornerRadius(8)
                                .foregroundColor(.white)

                            Button(action: {
                                if let amount = Int(demobilizationAmount), amount > 0 {
                                    showDemobilizeConfirm = true
                                }
                            }) {
                                Text("Demobilize")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Constants.Colors.negative)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Constants.Colors.negative, lineWidth: 1)
                                    )
                            }
                        }

                        if let amount = Int(demobilizationAmount), amount > 0 {
                            let severanceCost = militaryStats.recruitmentType == .volunteer ? Decimal(amount) * 5_000 : 0
                            let annualSavings = Decimal(amount) * militaryStats.recruitmentType.costPerSoldier

                            Text("Severance: \(formatMoney(severanceCost)) • Annual Savings: \(formatMoney(annualSavings))")
                                .font(.system(size: 12))
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
        .alert("Recruit Soldiers", isPresented: $showRecruitConfirm) {
            Button("Cancel", role: .cancel) {
                showRecruitConfirm = false
            }
            Button("Confirm") {
                if let amount = Int(recruitmentAmount),
                   var character = gameManager.character,
                   var militaryStats = character.militaryStats {

                    let population = getPopulation(for: character.country)
                    let maxManpower = gameManager.militaryManager.calculateMaxManpower(
                        population: population,
                        militaryStats: militaryStats
                    )

                    // Check if exceeds max
                    if militaryStats.totalPersonnel + amount > maxManpower {
                        showExceedsMaxAlert = true
                        showRecruitConfirm = false
                        return
                    }

                    let cost = gameManager.militaryManager.recruit(
                        militaryStats: &militaryStats,
                        soldiers: amount,
                        currentDate: character.currentDate
                    )

                    if militaryStats.treasury.cashReserves >= cost {
                        militaryStats.treasury.cashReserves -= cost
                        character.militaryStats = militaryStats
                        gameManager.characterManager.updateCharacter(character)
                        recruitmentAmount = ""
                    } else {
                        showInsufficientFundsAlert = true
                    }
                }
                showRecruitConfirm = false
            }
        } message: {
            if let amount = Int(recruitmentAmount),
               let militaryStats = gameManager.character?.militaryStats {
                let cost = Decimal(amount) * militaryStats.recruitmentType.recruitmentCost
                Text("Recruit \(formatNumber(amount)) soldiers?\n\nUpfront Cost: \(formatMoney(cost))\nTraining Time: 90 days\n\nMilitary Cash Reserves: \(formatMoney(militaryStats.treasury.cashReserves))")
            }
        }
        .alert("Demobilize Forces", isPresented: $showDemobilizeConfirm) {
            Button("Cancel", role: .cancel) {
                showDemobilizeConfirm = false
            }
            Button("Confirm", role: .destructive) {
                if let amount = Int(demobilizationAmount),
                   var character = gameManager.character,
                   var militaryStats = character.militaryStats {

                    let severanceCost = gameManager.militaryManager.demobilize(
                        militaryStats: &militaryStats,
                        soldiers: amount
                    )

                    militaryStats.treasury.cashReserves -= severanceCost
                    character.militaryStats = militaryStats
                    gameManager.characterManager.updateCharacter(character)
                    demobilizationAmount = ""
                }
                showDemobilizeConfirm = false
            }
        } message: {
            if let amount = Int(demobilizationAmount),
               let militaryStats = gameManager.character?.militaryStats {
                let severanceCost = militaryStats.recruitmentType == .volunteer ? Decimal(amount) * 5_000 : 0
                let annualSavings = Decimal(amount) * militaryStats.recruitmentType.costPerSoldier

                Text("Discharge \(formatNumber(amount)) soldiers?\n\nSeverance Cost: \(formatMoney(severanceCost))\nAnnual Savings: \(formatMoney(annualSavings))\n\nThis will reduce military strength.")
            }
        }
        .alert("Change Mobilization Level", isPresented: Binding(
            get: { showChangeMobilizationConfirm != nil },
            set: { if !$0 { showChangeMobilizationConfirm = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                showChangeMobilizationConfirm = nil
            }
            Button("Confirm") {
                if let level = showChangeMobilizationConfirm,
                   var character = gameManager.character,
                   var militaryStats = character.militaryStats {

                    gameManager.militaryManager.changeMobilizationLevel(
                        militaryStats: &militaryStats,
                        to: level
                    )

                    character.militaryStats = militaryStats
                    gameManager.characterManager.updateCharacter(character)
                }
                showChangeMobilizationConfirm = nil
            }
        } message: {
            if let level = showChangeMobilizationConfirm,
               let character = gameManager.character,
               let militaryStats = character.militaryStats {
                let population = getPopulation(for: character.country)
                let newMaxManpower = Int(Double(population) * level.percentage * militaryStats.recruitmentType.manpowerMultiplier)

                Text("Change to \(level.rawValue)?\n\nNew Max Manpower: \(formatNumber(newMaxManpower))\nApproval Impact: \(String(format: "%.1f%%", level.approvalImpactYearly)) per year\n\n\(level.description)")
            }
        }
        .alert("Insufficient Funds", isPresented: $showInsufficientFundsAlert) {
            Button("OK", role: .cancel) {
                showInsufficientFundsAlert = false
            }
        } message: {
            if let militaryStats = gameManager.character?.militaryStats {
                Text("The military treasury does not have sufficient funds for this recruitment.\n\nAvailable: \(formatMoney(militaryStats.treasury.cashReserves))")
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

                Text("Cannot recruit more soldiers. You are at or near maximum capacity.\n\nCurrent: \(formatNumber(militaryStats.totalPersonnel))\nMax: \(formatNumber(maxManpower))\n\nIncrease mobilization level to recruit more.")
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

// MARK: - Mobilization Level Card

struct MobilizationLevelCard: View {
    let currentLevel: MobilizationLevel
    let onChangeMobilization: (MobilizationLevel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mobilization Level")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            ForEach(MobilizationLevel.allCases, id: \.self) { level in
                Button(action: {
                    if level != currentLevel {
                        onChangeMobilization(level)
                    }
                }) {
                    HStack {
                        Image(systemName: level.icon)
                            .foregroundColor(level == currentLevel ? Constants.Colors.positive : Constants.Colors.buttonPrimary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(level.rawValue)
                                .font(.system(size: 14, weight: level == currentLevel ? .bold : .semibold))
                                .foregroundColor(level == currentLevel ? .white : Constants.Colors.secondaryText)

                            Text("\(String(format: "%.1f%%", level.percentage * 100)) of population")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }

                        Spacer()

                        if level == currentLevel {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Constants.Colors.positive)
                        } else if level.approvalImpactYearly < 0 {
                            Text("\(String(format: "%.0f%%", level.approvalImpactYearly))/yr")
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(12)
                    .background(level == currentLevel ? Color(red: 0.2, green: 0.25, blue: 0.2) : Color(red: 0.12, green: 0.14, blue: 0.18))
                    .cornerRadius(8)
                }
                .disabled(level == currentLevel)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }
}

// MARK: - Training Cohort Card

struct TrainingCohortCard: View {
    let cohort: RecruitmentCohort

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundColor(.orange)

                Text("\(formatNumber(cohort.soldierCount)) soldiers in training")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(cohort.daysRemaining) days")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.25))
                        .frame(height: 6)
                        .cornerRadius(3)

                    let progress = 1.0 - (Double(cohort.daysRemaining) / 90.0)
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(Color(red: 0.12, green: 0.14, blue: 0.18))
        .cornerRadius(8)
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

#Preview {
    RecruitmentView()
        .environmentObject(GameManager.shared)
}
