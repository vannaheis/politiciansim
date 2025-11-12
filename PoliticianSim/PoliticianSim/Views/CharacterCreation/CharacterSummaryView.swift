//
//  CharacterSummaryView.swift
//  PoliticianSim
//
//  Final review before creating character
//

import SwiftUI

struct CharacterSummaryView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Confirm Your Character")
                    .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                    .foregroundColor(.white)

                Text("Review your politician before starting")
                    .font(.system(size: Constants.Typography.bodyTextSize))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 40)

            ScrollView {
                VStack(spacing: 20) {
                    // Basic Info Card
                    InfoCard(title: "Basic Information") {
                        VStack(alignment: .leading, spacing: 12) {
                            SummaryRow(label: "Name", value: viewModel.name)
                            SummaryRow(label: "Gender", value: viewModel.gender.rawValue.capitalized)
                            SummaryRow(label: "Country", value: viewModel.selectedCountry)
                            SummaryRow(label: "Background", value: viewModel.background.rawValue.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).capitalized)
                        }
                    }

                    // Starting Position Info
                    InfoCard(title: "Your Journey Begins") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("You will start as a citizen with political ambitions. Your journey to the presidency begins now.")
                                .font(.system(size: Constants.Typography.bodyTextSize))
                                .foregroundColor(Constants.Colors.secondaryText)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 8) {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(Constants.Colors.political)
                                Text("Starting Age: 18")
                                    .font(.system(size: Constants.Typography.bodyTextSize, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 4)

                            Text("Your attributes will be revealed as your political career unfolds.")
                                .font(.system(size: Constants.Typography.captionSize))
                                .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
                                .italic()
                                .padding(.top, 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Navigation Buttons
            HStack(spacing: 12) {
                SecondaryButton(title: "Back", icon: "arrow.left") {
                    viewModel.previousStep()
                }

                PrimaryButton(title: "Start Journey", icon: "flag.fill") {
                    onComplete()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Supporting Views

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: Constants.Typography.bodyTextSize, weight: .medium))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: Constants.Typography.bodyTextSize, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ZStack {
        StandardBackgroundView()
        CharacterSummaryView(
            viewModel: {
                let vm = CharacterCreationViewModel()
                vm.name = "John Smith"
                vm.gender = .male
                vm.selectedCountry = "USA"
                vm.background = .middleClass
                vm.generateAttributes()
                return vm
            }(),
            onComplete: {
                print("Character created!")
            }
        )
    }
}
