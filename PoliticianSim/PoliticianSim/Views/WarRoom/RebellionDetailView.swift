//
//  RebellionDetailView.swift
//  PoliticianSim
//
//  Detailed view for managing an active rebellion
//

import SwiftUI

struct RebellionDetailView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    let rebellion: Rebellion
    @State private var showSuppressConfirm = false
    @State private var showGrantAutonomyConfirm = false
    @State private var showGrantIndependenceConfirm = false
    @State private var suppressionResult: String? = nil

    var playerStrength: Int {
        gameManager.character?.militaryStats?.strength ?? 0
    }

    var strengthRatio: Double {
        Double(playerStrength) / Double(max(1, rebellion.strength))
    }

    var threatLevel: (text: String, color: Color) {
        if strengthRatio >= 10.0 {
            return ("Minor Uprising", .yellow)
        } else if strengthRatio >= 5.0 {
            return ("Moderate Threat", .orange)
        } else if strengthRatio >= 2.0 {
            return ("Serious Threat", Constants.Colors.negative)
        } else {
            return ("Critical Threat", Constants.Colors.negative)
        }
    }

    var suppressionChance: Double {
        let baseChance = 0.7
        let adjustedChance = min(0.95, baseChance * strengthRatio)
        return adjustedChance
    }

    var estimatedCasualties: Int {
        Int(Double(rebellion.strength) * 0.10)  // Estimate 10% casualties
    }

    var estimatedCost: Decimal {
        let baseCost: Decimal = 100_000_000
        return baseCost * Decimal(rebellion.strength / 10_000)
    }

    var durationText: String {
        guard let character = gameManager.character else { return "Unknown" }
        let days = Calendar.current.dateComponents([.day], from: rebellion.startDate, to: character.currentDate).day ?? 0
        if days == 0 {
            return "Just started"
        } else if days == 1 {
            return "1 day"
        } else if days < 30 {
            return "\(days) days"
        } else {
            let months = days / 30
            return "\(months) month\(months == 1 ? "" : "s")"
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                StandardBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(threatLevel.color)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ACTIVE REBELLION")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Constants.Colors.secondaryText)

                                    Text(rebellion.territory.name)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                Spacer()
                            }

                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("Duration: \(durationText)")
                                    .font(.system(size: 13))
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                        }
                        .padding(20)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Threat Assessment
                        VStack(alignment: .leading, spacing: 12) {
                            Text("THREAT ASSESSMENT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack {
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 20))
                                    .foregroundColor(threatLevel.color)

                                Text(threatLevel.text)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(threatLevel.color)

                                Spacer()
                            }
                            .padding(12)
                            .background(threatLevel.color.opacity(0.15))
                            .cornerRadius(8)
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Military Comparison
                        VStack(alignment: .leading, spacing: 12) {
                            Text("MILITARY STRENGTH")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Rebel Forces")
                                        .font(.system(size: 13))
                                        .foregroundColor(Constants.Colors.secondaryText)

                                    Text(formatNumber(rebellion.strength))
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Constants.Colors.negative)
                                }

                                Spacer()

                                Image(systemName: "chevron.left.slash.chevron.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Your Forces")
                                        .font(.system(size: 13))
                                        .foregroundColor(Constants.Colors.secondaryText)

                                    Text(formatNumber(playerStrength))
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Constants.Colors.accent)
                                }
                            }

                            // Strength ratio indicator
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Force Ratio: \(String(format: "%.1f", strengthRatio)):1")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)

                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(height: 8)
                                            .cornerRadius(4)

                                        Rectangle()
                                            .fill(strengthRatio >= 2.0 ? Constants.Colors.positive : Constants.Colors.negative)
                                            .frame(width: min(geometry.size.width, geometry.size.width * CGFloat(strengthRatio / 10.0)), height: 8)
                                            .cornerRadius(4)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Territory Information
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TERRITORY DETAILS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            VStack(spacing: 10) {
                                DetailRow(
                                    icon: "person.3.fill",
                                    label: "Population",
                                    value: rebellion.territory.formattedPopulation
                                )

                                DetailRow(
                                    icon: "hand.raised.fill",
                                    label: "Popular Support for Rebels",
                                    value: "\(Int(rebellion.support * 100))%",
                                    valueColor: Constants.Colors.negative
                                )

                                DetailRow(
                                    icon: "heart.fill",
                                    label: "Territory Morale",
                                    value: "\(Int(rebellion.territory.morale * 100))%",
                                    valueColor: rebellion.territory.morale >= 0.5 ? .yellow : Constants.Colors.negative
                                )

                                DetailRow(
                                    icon: "map.fill",
                                    label: "Territory Size",
                                    value: rebellion.territory.formattedSize
                                )
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Suppression Options
                        VStack(alignment: .leading, spacing: 12) {
                            Text("RESPONSE OPTIONS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            // Military Suppression
                            Button(action: {
                                showSuppressConfirm = true
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "shield.lefthalf.filled")
                                            .foregroundColor(Constants.Colors.negative)
                                        Text("Military Suppression")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Image(systemName: "chart.bar.fill")
                                                .font(.system(size: 10))
                                            Text("Success Chance: \(Int(suppressionChance * 100))%")
                                                .font(.system(size: 11))
                                        }
                                        .foregroundColor(Constants.Colors.secondaryText)

                                        HStack {
                                            Image(systemName: "dollarsign.circle.fill")
                                                .font(.system(size: 10))
                                            Text("Estimated Cost: \(formatMoney(estimatedCost))")
                                                .font(.system(size: 11))
                                        }
                                        .foregroundColor(Constants.Colors.secondaryText)

                                        HStack {
                                            Image(systemName: "person.2.slash")
                                                .font(.system(size: 10))
                                            Text("Est. Casualties: ~\(formatNumber(estimatedCasualties))")
                                                .font(.system(size: 11))
                                        }
                                        .foregroundColor(Constants.Colors.secondaryText)

                                        HStack {
                                            Image(systemName: "hand.thumbsdown.fill")
                                                .font(.system(size: 10))
                                            Text("Approval: -10%")
                                                .font(.system(size: 11))
                                        }
                                        .foregroundColor(Constants.Colors.negative)
                                    }
                                }
                                .padding(14)
                                .background(Color(red: 0.2, green: 0.22, blue: 0.27))
                                .cornerRadius(8)
                            }

                            // Grant Autonomy
                            Button(action: {
                                showGrantAutonomyConfirm = true
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.yellow)
                                        Text("Grant Autonomy")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }

                                    Text("Grant self-governance to end the rebellion peacefully. Territory remains under your control but with limited GDP contribution.")
                                        .font(.system(size: 11))
                                        .foregroundColor(Constants.Colors.secondaryText)
                                }
                                .padding(14)
                                .background(Color(red: 0.2, green: 0.22, blue: 0.27))
                                .cornerRadius(8)
                            }

                            // Grant Independence
                            Button(action: {
                                showGrantIndependenceConfirm = true
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "flag.fill")
                                            .foregroundColor(Constants.Colors.positive)
                                        Text("Grant Independence")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Release the territory as an independent nation.")
                                            .font(.system(size: 11))
                                            .foregroundColor(Constants.Colors.secondaryText)

                                        HStack {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 10))
                                            Text("Reputation: +20")
                                                .font(.system(size: 11))
                                        }
                                        .foregroundColor(Constants.Colors.positive)
                                    }
                                }
                                .padding(14)
                                .background(Color(red: 0.2, green: 0.22, blue: 0.27))
                                .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .cornerRadius(12)

                        // Suppression result display
                        if let result = suppressionResult {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: result.contains("Success") ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(result.contains("Success") ? Constants.Colors.positive : Constants.Colors.negative)
                                    Text(result)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(12)
                            .background(Constants.Colors.accent.opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Rebellion Details")
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
        .alert("Suppress Rebellion", isPresented: $showSuppressConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Suppress", role: .destructive) {
                suppressRebellion()
            }
        } message: {
            Text("Deploy military forces to suppress the rebellion?\n\nSuccess Chance: \(Int(suppressionChance * 100))%\nCost: ~\(formatMoney(estimatedCost))\nApproval: -10%\n\nFailure may result in prolonged conflict.")
        }
        .alert("Grant Autonomy", isPresented: $showGrantAutonomyConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Grant Autonomy") {
                grantAutonomy()
            }
        } message: {
            Text("Grant self-governance to this territory to end the rebellion peacefully?\n\nThe territory will become autonomous but remain under your control with reduced GDP contribution.")
        }
        .alert("Grant Independence", isPresented: $showGrantIndependenceConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Grant Independence") {
                grantIndependence()
            }
        } message: {
            Text("Release this territory as an independent nation?\n\nYou will lose all control and GDP contribution, but gain +20 reputation.")
        }
    }

    // MARK: - Actions

    private func suppressRebellion() {
        guard let character = gameManager.character else { return }

        // Apply approval penalty for suppression
        var updatedChar = character
        updatedChar.approvalRating = max(0, updatedChar.approvalRating - 10.0)
        gameManager.characterManager.updateCharacter(updatedChar)

        let result = gameManager.territoryManager.suppressRebellion(
            rebellionId: rebellion.id,
            militaryStrength: playerStrength
        )

        if result.success {
            // Deduct from treasury
            gameManager.treasuryManager.recordReparationPayment(
                amount: -result.cost,
                description: "Rebellion Suppression - \(rebellion.territory.name)",
                date: character.currentDate
            )

            suppressionResult = "Success! Rebellion suppressed. Cost: \(formatMoney(result.cost)), Casualties: \(formatNumber(result.casualties))"

            // Auto-dismiss after showing result
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dismiss()
            }
        } else {
            suppressionResult = "Failed! The rebellion was not suppressed. Morale further declined."
        }
    }

    private func grantAutonomy() {
        let success = gameManager.territoryManager.grantAutonomyToRebellion(rebellionId: rebellion.id)

        if success {
            // Reputation boost
            if var character = gameManager.character {
                character.reputation = min(100, character.reputation + 10)
                gameManager.characterManager.updateCharacter(character)
            }
        }

        dismiss()
    }

    private func grantIndependence() {
        let success = gameManager.territoryManager.grantIndependence(rebellionId: rebellion.id)

        if success {
            // Reputation boost
            if var character = gameManager.character {
                character.reputation = min(100, character.reputation + 20)
                gameManager.characterManager.updateCharacter(character)
            }
        }

        dismiss()
    }

    // MARK: - Helpers

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
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

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.buttonPrimary)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    let territory = Territory(
        name: "Eastern Provinces",
        formerOwner: "CHN",
        currentOwner: "USA",
        size: 3_700_000,
        population: 45_000_000,
        conquestDate: Date().addingTimeInterval(-60 * 24 * 60 * 60)
    )

    let rebellion = Rebellion(territory: territory, currentDate: Date())

    return RebellionDetailView(rebellion: rebellion)
        .environmentObject(GameManager.shared)
}
