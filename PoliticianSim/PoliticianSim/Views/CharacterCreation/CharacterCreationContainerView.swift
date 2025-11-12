//
//  CharacterCreationContainerView.swift
//  PoliticianSim
//
//  Container managing character creation flow
//

import SwiftUI

struct CharacterCreationContainerView: View {
    @StateObject private var viewModel = CharacterCreationViewModel()
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            // Current step view
            Group {
                switch viewModel.currentStep {
                case .country:
                    CountrySelectionView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))

                case .details:
                    CharacterDetailsView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))

                case .summary:
                    CharacterSummaryView(viewModel: viewModel) {
                        createCharacter()
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)

            // Progress Indicator at top
            VStack {
                ProgressIndicator(currentStep: viewModel.currentStep)
                    .padding(.top, 8)
                    .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private func createCharacter() {
        print("DEBUG: createCharacter() called")
        let character = viewModel.createCharacter()
        print("DEBUG: Character created - Name: \(character.name)")
        gameManager.characterManager.character = character
        print("DEBUG: Character set in manager")
        gameManager.statManager.initializeHistory(for: character)
        print("DEBUG: Stats initialized")
        gameManager.navigationManager.navigateTo(.home)
        print("DEBUG: Navigation to home completed")
    }
}

// MARK: - Progress Indicator

struct ProgressIndicator: View {
    let currentStep: CharacterCreationViewModel.CharacterCreationStep

    var body: some View {
        HStack(spacing: 8) {
            StepDot(isActive: currentStep == .country, isCompleted: stepIndex >= 1)
            ConnectorLine(isActive: stepIndex >= 1)
            StepDot(isActive: currentStep == .details, isCompleted: stepIndex >= 2)
            ConnectorLine(isActive: stepIndex >= 2)
            StepDot(isActive: currentStep == .summary, isCompleted: false)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.5))
        )
    }

    var stepIndex: Int {
        switch currentStep {
        case .country: return 0
        case .details: return 1
        case .summary: return 2
        }
    }
}

struct StepDot: View {
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: 12, height: 12)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }

    var fillColor: Color {
        if isActive {
            return Constants.Colors.buttonPrimary
        } else if isCompleted {
            return Constants.Colors.positive
        } else {
            return Color.white.opacity(0.3)
        }
    }
}

struct ConnectorLine: View {
    let isActive: Bool

    var body: some View {
        Rectangle()
            .fill(isActive ? Constants.Colors.positive : Color.white.opacity(0.3))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    CharacterCreationContainerView()
        .environmentObject(GameManager.shared)
}
