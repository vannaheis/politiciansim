//
//  TechnologyResearchView.swift
//  PoliticianSim
//
//  Technology research management
//

import SwiftUI

struct TechnologyResearchView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showStartResearchConfirm: TechCategory?
    @State private var showCompleteResearchConfirm: UUID?
    @State private var showCancelResearchConfirm: UUID?
    @State private var showInsufficientFundsAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let character = gameManager.character,
                   let militaryStats = character.militaryStats {

                    // Active Research Section
                    if !gameManager.militaryManager.activeResearch.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Research")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            ForEach(gameManager.militaryManager.activeResearch) { research in
                                ActiveResearchCard(
                                    research: research,
                                    onComplete: {
                                        showCompleteResearchConfirm = research.id
                                    },
                                    onCancel: {
                                        showCancelResearchConfirm = research.id
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    // Available Technologies Section
                    Text("Available Technologies")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    ForEach(TechCategory.allCases, id: \.self) { category in
                        TechnologyCard(
                            category: category,
                            currentLevel: militaryStats.technologyLevels[category] ?? 1,
                            canResearch: gameManager.militaryManager.canResearch(
                                category: category,
                                militaryStats: militaryStats
                            ),
                            onStartResearch: {
                                showStartResearchConfirm = category
                            }
                        )
                    }
                } else {
                    Text("No military data available")
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .alert("Start Research", isPresented: Binding(
            get: { showStartResearchConfirm != nil },
            set: { if !$0 { showStartResearchConfirm = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                showStartResearchConfirm = nil
            }
            Button("Start") {
                if let category = showStartResearchConfirm,
                   var character = gameManager.character,
                   var militaryStats = character.militaryStats {
                    let currentLevel = militaryStats.technologyLevels[category] ?? 1
                    let cost = calculateResearchCost(currentLevel: currentLevel)

                    if militaryStats.treasury.cashReserves >= cost {
                        if let research = gameManager.militaryManager.startResearch(
                            category: category,
                            militaryStats: militaryStats,
                            currentDate: character.currentDate
                        ) {
                            militaryStats.treasury.cashReserves -= research.cost
                            character.militaryStats = militaryStats
                            gameManager.characterManager.updateCharacter(character)
                        }
                    } else {
                        showInsufficientFundsAlert = true
                    }
                }
                showStartResearchConfirm = nil
            }
        } message: {
            if let category = showStartResearchConfirm,
               let militaryStats = gameManager.character?.militaryStats {
                let currentLevel = militaryStats.technologyLevels[category] ?? 1
                let cost = calculateResearchCost(currentLevel: currentLevel)
                let days = calculateResearchDays(targetLevel: currentLevel + 1)

                Text("Research \(category.rawValue) to Level \(currentLevel + 1)?\n\nCost: \(formatMoney(cost))\nTime: \(days) days\n\nMilitary Cash Reserves: \(formatMoney(militaryStats.treasury.cashReserves))")
            }
        }
        .alert("Complete Research", isPresented: Binding(
            get: { showCompleteResearchConfirm != nil },
            set: { if !$0 { showCompleteResearchConfirm = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                showCompleteResearchConfirm = nil
            }
            Button("Complete") {
                if let researchId = showCompleteResearchConfirm,
                   var character = gameManager.character,
                   var militaryStats = character.militaryStats {
                    _ = gameManager.militaryManager.completeResearch(
                        researchId: researchId,
                        militaryStats: &militaryStats
                    )
                    character.militaryStats = militaryStats
                    gameManager.characterManager.updateCharacter(character)
                }
                showCompleteResearchConfirm = nil
            }
        } message: {
            Text("Complete this research and upgrade the technology level?")
        }
        .alert("Cancel Research", isPresented: Binding(
            get: { showCancelResearchConfirm != nil },
            set: { if !$0 { showCancelResearchConfirm = nil } }
        )) {
            Button("No", role: .cancel) {
                showCancelResearchConfirm = nil
            }
            Button("Yes, Cancel", role: .destructive) {
                if let researchId = showCancelResearchConfirm,
                   var character = gameManager.character,
                   var militaryStats = character.militaryStats {
                    let refund = gameManager.militaryManager.cancelResearch(researchId: researchId)
                    militaryStats.treasury.cashReserves += refund
                    character.militaryStats = militaryStats
                    gameManager.characterManager.updateCharacter(character)
                }
                showCancelResearchConfirm = nil
            }
        } message: {
            Text("Cancel this research? You will receive a 50% refund.")
        }
        .alert("Insufficient Funds", isPresented: $showInsufficientFundsAlert) {
            Button("OK", role: .cancel) {
                showInsufficientFundsAlert = false
            }
        } message: {
            if let militaryStats = gameManager.character?.militaryStats {
                Text("The military treasury does not have sufficient funds for this research.\n\nAvailable: \(formatMoney(militaryStats.treasury.cashReserves))")
            }
        }
    }

    private func calculateResearchCost(currentLevel: Int) -> Decimal {
        let baseCost: Decimal = 5_000_000_000
        return baseCost * Decimal(pow(Double(currentLevel + 1), 1.5))
    }

    private func calculateResearchDays(targetLevel: Int) -> Int {
        return 90 + (targetLevel * 30)
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

// MARK: - Active Research Card

struct ActiveResearchCard: View {
    let research: TechnologyResearch
    let onComplete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: research.category.icon)
                    .foregroundColor(Constants.Colors.buttonPrimary)

                Text(research.category.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text("Level \(research.targetLevel)")
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Spacer()

                    Text("\(Int(research.progress * 100))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(red: 0.2, green: 0.2, blue: 0.25))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(Constants.Colors.buttonPrimary)
                            .frame(width: geometry.size.width * research.progress, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(research.daysRemaining) days remaining")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Spacer()
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                if research.isComplete {
                    Button(action: onComplete) {
                        Text("Complete Research")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Constants.Colors.positive)
                            .cornerRadius(8)
                    }
                } else {
                    Button(action: onCancel) {
                        Text("Cancel (50% refund)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Constants.Colors.negative)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Constants.Colors.negative, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }
}

// MARK: - Technology Card

struct TechnologyCard: View {
    let category: TechCategory
    let currentLevel: Int
    let canResearch: Bool
    let onStartResearch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(Constants.Colors.buttonPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text(category.description)
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .lineLimit(2)
                }

                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Level")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("\(currentLevel) / 10")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Strength Multiplier")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(String(format: "%.0f%%", category.strengthMultiplier * 100))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.positive)
                }
            }

            if currentLevel < 10 {
                Divider()
                    .background(Constants.Colors.secondaryText.opacity(0.3))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Next Level (\(currentLevel + 1))")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    HStack {
                        Text("Cost:")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Spacer()

                        Text(formatResearchCost(currentLevel: currentLevel))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("Time:")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Spacer()

                        Text("\(calculateResearchDays(targetLevel: currentLevel + 1)) days")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    if canResearch {
                        Button(action: onStartResearch) {
                            Text("Start Research")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Constants.Colors.buttonPrimary)
                                .cornerRadius(8)
                        }
                    } else {
                        Text("Already researching this technology")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                }
            } else {
                Text("✓ Max Level Reached")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Constants.Colors.positive)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }

    private func formatResearchCost(currentLevel: Int) -> String {
        let baseCost: Decimal = 5_000_000_000
        let cost = baseCost * Decimal(pow(Double(currentLevel + 1), 1.5))

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0

        let value = Double(truncating: cost as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return formatter.string(from: cost as NSNumber) ?? "$0"
        }
    }

    private func calculateResearchDays(targetLevel: Int) -> Int {
        return 90 + (targetLevel * 30)
    }
}

#Preview {
    TechnologyResearchView()
        .environmentObject(GameManager.shared)
}
