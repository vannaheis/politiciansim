//
//  CharacterDetailsView.swift
//  PoliticianSim
//
//  Character name, gender, and background selection
//

import SwiftUI

struct CharacterDetailsView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Create Your Character")
                    .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                    .foregroundColor(.white)

                Text("Define your politician's identity")
                    .font(.system(size: Constants.Typography.bodyTextSize))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 40)

            ScrollView {
                VStack(spacing: 20) {
                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: Constants.Typography.sectionTitleSize, weight: .semibold))
                            .foregroundColor(.white)

                        TextField("Enter your name", text: $viewModel.name)
                            .font(.system(size: Constants.Typography.bodyTextSize))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }

                    // Gender Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender")
                            .font(.system(size: Constants.Typography.sectionTitleSize, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            GenderButton(
                                title: "Male",
                                icon: "person.fill",
                                isSelected: viewModel.gender == .male
                            ) {
                                viewModel.gender = .male
                            }

                            GenderButton(
                                title: "Female",
                                icon: "person.fill",
                                isSelected: viewModel.gender == .female
                            ) {
                                viewModel.gender = .female
                            }

                            GenderButton(
                                title: "Other",
                                icon: "person.fill",
                                isSelected: viewModel.gender == .other
                            ) {
                                viewModel.gender = .other
                            }
                        }
                    }

                    // Background Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Background")
                            .font(.system(size: Constants.Typography.sectionTitleSize, weight: .semibold))
                            .foregroundColor(.white)

                        BackgroundCard(
                            title: "Working Class",
                            description: "Born into a hardworking family. You understand the struggles of everyday people.",
                            benefits: "Charisma +5, Reputation +5",
                            isSelected: viewModel.background == .workingClass
                        ) {
                            viewModel.background = .workingClass
                        }

                        BackgroundCard(
                            title: "Middle Class",
                            description: "Grew up in a stable, comfortable environment with access to good education.",
                            benefits: "Balanced attributes",
                            isSelected: viewModel.background == .middleClass
                        ) {
                            viewModel.background = .middleClass
                        }

                        BackgroundCard(
                            title: "Upper Class",
                            description: "Born into wealth and privilege. You have connections and resources.",
                            benefits: "Intelligence +5, Diplomacy +5",
                            isSelected: viewModel.background == .upperClass
                        ) {
                            viewModel.background = .upperClass
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

                PrimaryButton(title: "Continue", icon: "arrow.right") {
                    if viewModel.canProceedFromDetails {
                        viewModel.nextStep()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Supporting Views

struct GenderButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)

                Text(title)
                    .font(.system(size: Constants.Typography.captionSize, weight: .medium))
                    .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Constants.Colors.buttonPrimary : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected ? Constants.Colors.buttonPrimary : Color.white.opacity(0.2),
                                lineWidth: 2
                            )
                    )
            )
        }
    }
}

struct BackgroundCard: View {
    let title: String
    let description: String
    let benefits: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: Constants.Typography.sectionTitleSize, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Constants.Colors.positive)
                    }
                }

                Text(description)
                    .font(.system(size: Constants.Typography.bodyTextSize))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.positive)

                    Text(benefits)
                        .font(.system(size: Constants.Typography.captionSize, weight: .medium))
                        .foregroundColor(Constants.Colors.positive)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Constants.Colors.buttonPrimary.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Constants.Colors.buttonPrimary : Color.white.opacity(0.2),
                                lineWidth: 2
                            )
                    )
            )
        }
    }
}

#Preview {
    ZStack {
        StandardBackgroundView()
        CharacterDetailsView(viewModel: CharacterCreationViewModel())
    }
}
