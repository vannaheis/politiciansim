//
//  PeaceNegotiationPopup.swift
//  PoliticianSim
//
//  Peace negotiation with term selection and enemy response
//

import SwiftUI

struct PeaceNegotiationPopup: View {
    @EnvironmentObject var gameManager: GameManager
    let war: War
    let playerCountry: String
    let isPlayerAttacker: Bool
    @State private var selectedTerm: War.PeaceTerm = .statusQuo
    @State private var showingNegotiationResult = false
    @State private var negotiationAccepted = false
    @Environment(\.dismiss) var dismiss

    var enemyCountry: String {
        isPlayerAttacker ? war.defender : war.attacker
    }

    var playerAttrition: Double {
        isPlayerAttacker ? war.attackerAttrition : war.defenderAttrition
    }

    var enemyAttrition: Double {
        isPlayerAttacker ? war.defenderAttrition : war.attackerAttrition
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            if !showingNegotiationResult {
                termSelectionView
            } else {
                negotiationResultView
            }
        }
    }

    var termSelectionView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Constants.Colors.buttonPrimary)

                Text("Peace Negotiation")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Propose peace terms to \(enemyCountry)")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 20)

            // Current War Status
            VStack(spacing: 12) {
                Text("CURRENT SITUATION")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Attrition")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)
                        Text(String(format: "%.1f%%", playerAttrition * 100))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Enemy Attrition")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)
                        Text(String(format: "%.1f%%", enemyAttrition * 100))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
            .padding(.horizontal, 24)

            // Peace Terms Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("SELECT PEACE TERMS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .padding(.top, 16)

                ForEach([War.PeaceTerm.statusQuo, .reparations, .partialTerritory, .fullConquest], id: \.self) { term in
                    PeaceTermCard(
                        term: term,
                        isSelected: selectedTerm == term,
                        acceptanceLikelihood: calculateAcceptanceLikelihood(for: term)
                    ) {
                        selectedTerm = term
                    }
                }
            }
            .padding(.horizontal, 24)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 16)

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
                        .background(Color(red: 0.25, green: 0.27, blue: 0.32))
                        .cornerRadius(10)
                }

                Button(action: {
                    proposeTerms()
                }) {
                    Text("Propose Terms")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.buttonPrimary)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 420)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(20)
        .shadow(radius: 30)
    }

    var negotiationResultView: some View {
        VStack(spacing: 0) {
            // Result Header
            VStack(spacing: 12) {
                Image(systemName: negotiationAccepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(negotiationAccepted ? Constants.Colors.positive : Constants.Colors.negative)

                Text(negotiationAccepted ? "Peace Accepted" : "Peace Rejected")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)

                Text(negotiationAccepted ? "\(enemyCountry) has accepted your peace proposal" : "\(enemyCountry) has rejected your peace terms")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            if negotiationAccepted {
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 20)

                // Peace Terms Summary
                VStack(spacing: 16) {
                    Text("PEACE TERMS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(Constants.Colors.buttonPrimary)
                            Text(selectedTerm.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text(selectedTerm.description)
                            .font(.system(size: 13))
                            .foregroundColor(Constants.Colors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 24)
            } else {
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 20)

                // Rejection Message
                VStack(spacing: 12) {
                    Text("The war continues...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Your proposed terms were deemed unacceptable. The conflict will continue until one side achieves victory or more favorable terms can be negotiated.")
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)
            }

            // Close Button
            Button(action: {
                if negotiationAccepted {
                    endWar()
                }
                dismiss()
            }) {
                Text(negotiationAccepted ? "Confirm Peace" : "Continue War")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(negotiationAccepted ? Constants.Colors.positive : Constants.Colors.buttonPrimary)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .frame(width: 400)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(20)
        .shadow(radius: 30)
    }

    private func calculateAcceptanceLikelihood(for term: War.PeaceTerm) -> Double {
        let attritionDiff = enemyAttrition - playerAttrition

        switch term {
        case .statusQuo:
            // Always high likelihood
            return max(0.5, 0.8 + (attritionDiff * 0.5))
        case .reparations:
            // Moderate likelihood, increases if player is winning
            return max(0.2, 0.5 + (attritionDiff * 0.8))
        case .partialTerritory:
            // Low likelihood unless player has strong advantage
            return max(0.1, 0.3 + (attritionDiff * 1.2))
        case .fullConquest:
            // Very low likelihood unless overwhelming victory
            return max(0.05, 0.15 + (attritionDiff * 1.5))
        }
    }

    private func proposeTerms() {
        let acceptanceLikelihood = calculateAcceptanceLikelihood(for: selectedTerm)
        let roll = Double.random(in: 0.0...1.0)

        negotiationAccepted = roll < acceptanceLikelihood

        withAnimation {
            showingNegotiationResult = true
        }

        // Apply small approval boost for attempting diplomacy
        if var character = gameManager.character {
            character.approvalRating = min(100, character.approvalRating + 2.0)
            gameManager.characterManager.updateCharacter(character)
        }
    }

    private func endWar() {
        guard let index = gameManager.warEngine.activeWars.firstIndex(where: { $0.id == war.id }) else {
            return
        }

        var updatedWar = gameManager.warEngine.activeWars[index]

        // Set outcome based on terms
        if selectedTerm == .statusQuo {
            updatedWar.outcome = .peaceTreaty
            updatedWar.territoryConquered = 0.0
        } else {
            updatedWar.outcome = isPlayerAttacker ? .attackerVictory : .defenderVictory
            updatedWar.territoryConquered = selectedTerm.territoryPercent
        }

        updatedWar.peaceTerm = selectedTerm
        gameManager.warEngine.activeWars[index] = updatedWar

        // Apply approval bonuses for peace
        if var character = gameManager.character {
            character.approvalRating = min(100, character.approvalRating + 5.0)
            character.stress = max(0, character.stress - 10)
            gameManager.characterManager.updateCharacter(character)
        }
    }
}

struct PeaceTermCard: View {
    let term: War.PeaceTerm
    let isSelected: Bool
    let acceptanceLikelihood: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(term.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Constants.Colors.positive)
                    }
                }

                Text(term.description)
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                // Acceptance Likelihood
                HStack {
                    Text("Acceptance Likelihood:")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Spacer()

                    Text(likelihoodText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(likelihoodColor)
                }
                .padding(.top, 4)
            }
            .padding(12)
            .background(isSelected ? Constants.Colors.buttonPrimary.opacity(0.2) : Color.white.opacity(0.03))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Constants.Colors.buttonPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    var likelihoodText: String {
        if acceptanceLikelihood >= 0.8 {
            return "Very High (\(Int(acceptanceLikelihood * 100))%)"
        } else if acceptanceLikelihood >= 0.6 {
            return "High (\(Int(acceptanceLikelihood * 100))%)"
        } else if acceptanceLikelihood >= 0.4 {
            return "Moderate (\(Int(acceptanceLikelihood * 100))%)"
        } else if acceptanceLikelihood >= 0.2 {
            return "Low (\(Int(acceptanceLikelihood * 100))%)"
        } else {
            return "Very Low (\(Int(acceptanceLikelihood * 100))%)"
        }
    }

    var likelihoodColor: Color {
        if acceptanceLikelihood >= 0.6 {
            return Constants.Colors.positive
        } else if acceptanceLikelihood >= 0.4 {
            return .yellow
        } else {
            return Constants.Colors.negative
        }
    }
}

#Preview {
    let war = War(
        attacker: "USA",
        defender: "CHN",
        type: .offensive,
        justification: .territorialDispute,
        attackerStrength: 1_400_000,
        defenderStrength: 2_035_000,
        startDate: Date().addingTimeInterval(-120 * 24 * 60 * 60)
    )

    return PeaceNegotiationPopup(war: war, playerCountry: "USA", isPlayerAttacker: true)
        .environmentObject(GameManager.shared)
}
