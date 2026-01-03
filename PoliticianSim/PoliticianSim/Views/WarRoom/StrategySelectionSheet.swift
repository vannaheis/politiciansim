//
//  StrategySelectionSheet.swift
//  PoliticianSim
//
//  Strategy selection sheet for changing war strategy
//

import SwiftUI

struct StrategySelectionSheet: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    let war: War

    var body: some View {
        NavigationView {
            ZStack {
                StandardBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select War Strategy")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("Choose your military approach for this conflict")
                                .font(.system(size: 14))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Strategy options
                        ForEach([War.WarStrategy.aggressive, .balanced, .defensive, .attrition], id: \.self) { strategy in
                            StrategyOptionCard(
                                strategy: strategy,
                                isCurrentStrategy: strategy == war.currentStrategy,
                                isTargetStrategy: strategy == war.targetStrategy,
                                isTransitioning: war.isTransitioning,
                                onSelect: {
                                    selectStrategy(strategy)
                                }
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.buttonPrimary)
                }
            }
        }
    }

    private func selectStrategy(_ strategy: War.WarStrategy) {
        guard let character = gameManager.character else { return }

        let success = gameManager.warEngine.changeStrategy(
            warId: war.id,
            newStrategy: strategy,
            currentDate: character.currentDate
        )

        if success {
            dismiss()
        }
    }
}

struct StrategyOptionCard: View {
    let strategy: War.WarStrategy
    let isCurrentStrategy: Bool
    let isTargetStrategy: Bool
    let isTransitioning: Bool
    let onSelect: () -> Void

    var isDisabled: Bool {
        isCurrentStrategy || isTargetStrategy
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: strategy.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isCurrentStrategy ? Constants.Colors.buttonPrimary : .white)

                    Text(strategy.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    if isCurrentStrategy {
                        Text("ACTIVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.buttonPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Constants.Colors.buttonPrimary.opacity(0.2))
                            .cornerRadius(4)
                    } else if isTargetStrategy {
                        Text("TRANSITIONING")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                }

                Text(strategy.description)
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .lineLimit(3)

                // Strategy stats
                HStack(spacing: 16) {
                    StrategyStatPill(
                        icon: "person.2.slash",
                        label: "Casualties",
                        value: formatMultiplier(strategy.attritionMultiplier)
                    )

                    StrategyStatPill(
                        icon: "clock",
                        label: "Speed",
                        value: formatMultiplier(strategy.speedMultiplier)
                    )

                    StrategyStatPill(
                        icon: "battery.25",
                        label: "Exhaustion",
                        value: formatMultiplier(strategy.exhaustionMultiplier)
                    )
                }
            }
            .padding(16)
            .background(
                isCurrentStrategy
                    ? Constants.Colors.buttonPrimary.opacity(0.15)
                    : Color(red: 0.15, green: 0.17, blue: 0.22)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isCurrentStrategy ? Constants.Colors.buttonPrimary : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .disabled(isDisabled)
        .padding(.horizontal, 20)
    }

    private func formatMultiplier(_ value: Double) -> String {
        if value > 1.0 {
            return "+\(Int((value - 1.0) * 100))%"
        } else if value < 1.0 {
            return "\(Int((value - 1.0) * 100))%"
        } else {
            return "±0%"
        }
    }
}

struct StrategyStatPill: View {
    let icon: String
    let label: String
    let value: String

    var color: Color {
        if value.hasPrefix("+") {
            return Constants.Colors.negative
        } else if value.hasPrefix("-") {
            return Constants.Colors.positive
        } else {
            return Constants.Colors.secondaryText
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Constants.Colors.secondaryText)

            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(red: 0.2, green: 0.22, blue: 0.27))
        .cornerRadius(8)
    }
}

#Preview {
    let war = War(
        attacker: "USA",
        defender: "CHN",
        type: .offensive,
        justification: .territorialDispute,
        attackerStrength: 100_000,
        defenderStrength: 80_000,
        startDate: Date()
    )

    return StrategySelectionSheet(war: war)
        .environmentObject(GameManager.shared)
}
