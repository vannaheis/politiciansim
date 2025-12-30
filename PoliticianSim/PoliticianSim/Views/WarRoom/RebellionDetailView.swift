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

                        // Response Options
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
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(Constants.Colors.secondaryText)
                                    }

                                    Text("Deploy military forces to suppress the rebellion. This will start a civil war.")
                                        .font(.system(size: 12))
                                        .foregroundColor(Constants.Colors.secondaryText)

                                    HStack(spacing: 16) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "dollarsign.circle.fill")
                                                .font(.system(size: 10))
                                            Text("~\(formatMoney(estimatedCost))")
                                                .font(.system(size: 11))
                                        }
                                        .foregroundColor(Constants.Colors.secondaryText)

                                        HStack(spacing: 4) {
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
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(Constants.Colors.secondaryText)
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
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(Constants.Colors.secondaryText)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Release the territory as an independent nation.")
                                            .font(.system(size: 11))
                                            .foregroundColor(Constants.Colors.secondaryText)

                                        HStack(spacing: 4) {
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
                    }
                    .padding(20)
                }

                // Custom Confirmation Popups
                if showSuppressConfirm {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showSuppressConfirm = false
                        }

                    SuppressRebellionConfirmationPopup(
                        rebellion: rebellion,
                        playerStrength: playerStrength,
                        onConfirm: {
                            suppressRebellion()
                            showSuppressConfirm = false
                        },
                        onCancel: {
                            showSuppressConfirm = false
                        }
                    )
                }

                if showGrantAutonomyConfirm {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showGrantAutonomyConfirm = false
                        }

                    GrantAutonomyConfirmationPopup(
                        rebellion: rebellion,
                        onConfirm: {
                            grantAutonomy()
                            showGrantAutonomyConfirm = false
                        },
                        onCancel: {
                            showGrantAutonomyConfirm = false
                        }
                    )
                }

                if showGrantIndependenceConfirm {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showGrantIndependenceConfirm = false
                        }

                    GrantIndependenceConfirmationPopup(
                        rebellion: rebellion,
                        onConfirm: {
                            grantIndependence()
                            showGrantIndependenceConfirm = false
                        },
                        onCancel: {
                            showGrantIndependenceConfirm = false
                        }
                    )
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
    }

    // MARK: - Actions

    private func suppressRebellion() {
        guard let character = gameManager.character else { return }

        // Apply approval penalty for suppression
        var updatedChar = character
        updatedChar.approvalRating = max(0, updatedChar.approvalRating - 10.0)
        gameManager.characterManager.updateCharacter(updatedChar)

        // Start a civil war instead of immediate resolution
        let war = gameManager.warEngine.declareWar(
            attacker: character.country,
            defender: "\(rebellion.territory.formerOwner)_REBELS",  // Virtual rebel faction
            type: .civil,
            justification: .rebellion,
            attackerStrength: playerStrength,
            defenderStrength: rebellion.strength,
            currentDate: character.currentDate
        )

        if let _ = war {
            // War started successfully - the rebellion is now represented as a civil war
            print("✅ Rebellion suppression started as civil war")
        }

        dismiss()
    }

    private func grantAutonomy() {
        let success = gameManager.territoryManager.grantAutonomyToRebellion(
            rebellionId: rebellion.id,
            globalCountryState: gameManager.globalCountryState
        )

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
        let success = gameManager.territoryManager.grantIndependence(
            rebellionId: rebellion.id,
            globalCountryState: gameManager.globalCountryState
        )

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

// MARK: - Confirmation Popups

struct SuppressRebellionConfirmationPopup: View {
    let rebellion: Rebellion
    let playerStrength: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var strengthRatio: Double {
        Double(playerStrength) / Double(max(1, rebellion.strength))
    }

    var successChance: Int {
        let baseChance = 0.7
        let adjustedChance = min(0.95, baseChance * strengthRatio)
        return Int(adjustedChance * 100)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 48))
                    .foregroundColor(Constants.Colors.negative)

                Text("Suppress Rebellion")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Deploy military forces to suppress the rebellion in \(rebellion.territory.name)")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Consequences
            VStack(alignment: .leading, spacing: 16) {
                Text("CONSEQUENCES")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Constants.Colors.secondaryText)

                VStack(alignment: .leading, spacing: 12) {
                    RebellionConsequenceRow(
                        icon: "exclamationmark.triangle.fill",
                        text: "This will start a civil war",
                        color: Constants.Colors.negative
                    )

                    RebellionConsequenceRow(
                        icon: "chart.bar.fill",
                        text: "Est. victory chance: ~\(successChance)%",
                        color: successChance >= 70 ? Constants.Colors.positive : .orange
                    )

                    RebellionConsequenceRow(
                        icon: "hand.thumbsdown.fill",
                        text: "Approval rating: -10%",
                        color: Constants.Colors.negative
                    )

                    RebellionConsequenceRow(
                        icon: "person.2.slash",
                        text: "Significant casualties expected",
                        color: Constants.Colors.secondaryText
                    )

                    RebellionConsequenceRow(
                        icon: "dollarsign.circle.fill",
                        text: "Ongoing war costs",
                        color: Constants.Colors.secondaryText
                    )
                }
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Actions
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.25, green: 0.27, blue: 0.32))
                        .cornerRadius(8)
                }

                Button(action: onConfirm) {
                    Text("Begin Suppression")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.negative)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 420)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct GrantAutonomyConfirmationPopup: View {
    let rebellion: Rebellion
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)

                Text("Grant Autonomy")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Grant self-governance to \(rebellion.territory.name)")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Effects
            VStack(alignment: .leading, spacing: 16) {
                Text("EFFECTS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Constants.Colors.secondaryText)

                VStack(alignment: .leading, spacing: 12) {
                    RebellionConsequenceRow(
                        icon: "checkmark.circle.fill",
                        text: "Rebellion ends peacefully",
                        color: Constants.Colors.positive
                    )

                    RebellionConsequenceRow(
                        icon: "star.fill",
                        text: "Reputation: +10",
                        color: Constants.Colors.positive
                    )

                    RebellionConsequenceRow(
                        icon: "chart.line.downtrend.xyaxis",
                        text: "Reduced GDP contribution",
                        color: .orange
                    )

                    RebellionConsequenceRow(
                        icon: "building.2.fill",
                        text: "Territory becomes autonomous",
                        color: Constants.Colors.secondaryText
                    )
                }
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Actions
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.25, green: 0.27, blue: 0.32))
                        .cornerRadius(8)
                }

                Button(action: onConfirm) {
                    Text("Grant Autonomy")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.yellow)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 420)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct GrantIndependenceConfirmationPopup: View {
    let rebellion: Rebellion
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Constants.Colors.positive)

                Text("Grant Independence")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Release \(rebellion.territory.name) as an independent nation")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Effects
            VStack(alignment: .leading, spacing: 16) {
                Text("EFFECTS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Constants.Colors.secondaryText)

                VStack(alignment: .leading, spacing: 12) {
                    RebellionConsequenceRow(
                        icon: "checkmark.circle.fill",
                        text: "Rebellion ends immediately",
                        color: Constants.Colors.positive
                    )

                    RebellionConsequenceRow(
                        icon: "star.fill",
                        text: "Reputation: +20",
                        color: Constants.Colors.positive
                    )

                    RebellionConsequenceRow(
                        icon: "xmark.circle.fill",
                        text: "Lose all territory control",
                        color: Constants.Colors.negative
                    )

                    RebellionConsequenceRow(
                        icon: "chart.line.downtrend.xyaxis",
                        text: "Lose all GDP contribution",
                        color: Constants.Colors.negative
                    )
                }
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Actions
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.25, green: 0.27, blue: 0.32))
                        .cornerRadius(8)
                }

                Button(action: onConfirm) {
                    Text("Grant Independence")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.positive)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 420)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct RebellionConsequenceRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white)

            Spacer()
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
