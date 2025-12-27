//
//  SurrenderConfirmationPopup.swift
//  PoliticianSim
//
//  Surrender confirmation with enemy terms display
//

import SwiftUI

struct SurrenderConfirmationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let war: War
    let playerCountry: String
    let isPlayerAttacker: Bool
    @State private var showingTerms = false
    @Environment(\.dismiss) var dismiss

    var enemyCountry: String {
        isPlayerAttacker ? war.defender : war.attacker
    }

    var enemyTerms: War.PeaceTerm {
        // Enemy always demands harsh terms for surrender
        let attritionDiff = (isPlayerAttacker ? war.defenderAttrition : war.attackerAttrition) -
                           (isPlayerAttacker ? war.attackerAttrition : war.defenderAttrition)

        if attritionDiff > 0.3 {
            // Player is being crushed → full conquest
            return .fullConquest
        } else if attritionDiff > 0.15 {
            // Player is losing badly → partial territory
            return .partialTerritory
        } else {
            // Close war → reparations
            return .reparations
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            if !showingTerms {
                warningView
            } else {
                termsView
            }
        }
    }

    var warningView: some View {
        VStack(spacing: 0) {
            // Warning Header
            VStack(spacing: 16) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Constants.Colors.negative)

                Text("Unconditional Surrender")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)

                Text("Are you certain you wish to surrender?")
                    .font(.system(size: 15))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 24)

            // Consequences
            VStack(spacing: 16) {
                Text("CONSEQUENCES OF SURRENDER")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Constants.Colors.secondaryText)

                VStack(spacing: 12) {
                    SurrenderConsequenceRow(
                        icon: "exclamationmark.triangle.fill",
                        title: "Enemy Dictates Terms",
                        description: "\(enemyCountry) will impose harsh peace conditions"
                    )

                    SurrenderConsequenceRow(
                        icon: "hand.thumbsdown.fill",
                        title: "Massive Approval Loss",
                        description: "-30% approval rating for surrendering"
                    )

                    SurrenderConsequenceRow(
                        icon: "building.2.crop.circle.fill",
                        title: "International Humiliation",
                        description: "-50 reputation for capitulation"
                    )

                    SurrenderConsequenceRow(
                        icon: "map.fill",
                        title: "Potential Territory Loss",
                        description: "Enemy may demand significant territorial concessions"
                    )

                    SurrenderConsequenceRow(
                        icon: "dollarsign.circle.fill",
                        title: "War Reparations",
                        description: "Possible multi-year reparation payments"
                    )
                }
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Warning Message
            Text("This decision cannot be undone and will immediately end the war under enemy terms.")
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.negative)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)

            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.buttonPrimary)
                        .cornerRadius(10)
                }

                Button(action: {
                    withAnimation {
                        showingTerms = true
                    }
                }) {
                    Text("Surrender")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.negative)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .frame(width: 440)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(20)
        .shadow(radius: 30)
    }

    var termsView: some View {
        VStack(spacing: 0) {
            // Terms Header
            VStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Constants.Colors.negative)

                Text("Enemy Peace Terms")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("\(enemyCountry) demands the following")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 28)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Peace Terms
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Constants.Colors.negative)

                    Text(enemyTerms.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(14)
                .background(Constants.Colors.negative.opacity(0.15))
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Terms:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(enemyTerms.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)

                // Specific consequences
                VStack(alignment: .leading, spacing: 10) {
                    if enemyTerms.territoryPercent > 0 {
                        HStack {
                            Image(systemName: "map.fill")
                                .foregroundColor(Constants.Colors.negative)
                            Text("Territory Loss: \(Int(enemyTerms.territoryPercent * 100))% of your nation")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }
                    }

                    HStack {
                        Image(systemName: "hand.thumbsdown.fill")
                        Text("Approval Impact: \(Int(enemyTerms.approvalImpact))%")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }

                    HStack {
                        Image(systemName: "building.2.crop.circle")
                        Text("Reputation Impact: \(Int(enemyTerms.reputationImpact))")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Final Actions
            HStack(spacing: 12) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Refuse & Continue War")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.buttonPrimary)
                        .cornerRadius(10)
                }

                Button(action: {
                    acceptSurrender()
                }) {
                    Text("Accept Terms")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.negative)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .frame(width: 440)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(20)
        .shadow(radius: 30)
    }

    private func acceptSurrender() {
        guard let index = gameManager.warEngine.activeWars.firstIndex(where: { $0.id == war.id }) else {
            return
        }

        var updatedWar = gameManager.warEngine.activeWars[index]

        // Player surrenders → enemy victory with harsh terms
        updatedWar.outcome = isPlayerAttacker ? .defenderVictory : .attackerVictory
        updatedWar.peaceTerm = enemyTerms
        updatedWar.territoryConquered = enemyTerms.territoryPercent

        gameManager.warEngine.activeWars[index] = updatedWar

        // Apply severe penalties for surrender
        if var character = gameManager.character {
            character.approvalRating = max(0, character.approvalRating - 30.0)
            character.reputation = max(-100, character.reputation - 50)
            character.stress = max(0, character.stress - 20)  // At least stress goes down
            gameManager.characterManager.updateCharacter(character)
        }

        dismiss()
    }
}

struct SurrenderConsequenceRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Constants.Colors.negative)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let war = War(
        attacker: "CHN",
        defender: "USA",
        type: .defensive,
        justification: .selfDefense,
        attackerStrength: 2_035_000,
        defenderStrength: 1_400_000,
        startDate: Date().addingTimeInterval(-90 * 24 * 60 * 60)
    )

    return SurrenderConfirmationPopup(war: war, playerCountry: "USA", isPlayerAttacker: false)
        .environmentObject(GameManager.shared)
}
