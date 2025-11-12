//
//  AttributeGenerationView.swift
//  PoliticianSim
//
//  Randomized attribute generation with reroll
//

import SwiftUI

struct AttributeGenerationView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Your Attributes")
                    .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                    .foregroundColor(.white)

                Text("Your starting attributes have been randomly generated")
                    .font(.system(size: Constants.Typography.bodyTextSize))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            Spacer()

            // Attributes Display
            VStack(spacing: 16) {
                AttributeRow(
                    iconName: Constants.Icons.Attributes.charisma,
                    iconColor: Constants.Colors.charisma,
                    label: "Charisma",
                    value: viewModel.charisma
                )

                AttributeRow(
                    iconName: Constants.Icons.Attributes.intelligence,
                    iconColor: Constants.Colors.intelligence,
                    label: "Intelligence",
                    value: viewModel.intelligence
                )

                AttributeRow(
                    iconName: Constants.Icons.Attributes.reputation,
                    iconColor: Constants.Colors.reputation,
                    label: "Reputation",
                    value: viewModel.reputation
                )

                AttributeRow(
                    iconName: Constants.Icons.Attributes.luck,
                    iconColor: Constants.Colors.luck,
                    label: "Luck",
                    value: viewModel.luck
                )

                AttributeRow(
                    iconName: Constants.Icons.Attributes.diplomacy,
                    iconColor: Constants.Colors.diplomacyColor,
                    label: "Diplomacy",
                    value: viewModel.diplomacy
                )
            }
            .padding(.horizontal, 20)

            // Average Display
            HStack {
                Text("Average:")
                    .font(.system(size: Constants.Typography.bodyTextSize, weight: .medium))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text("\(averageAttribute)/100")
                    .font(.system(size: Constants.Typography.heroNumberSize, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.05))
            )
            .padding(.horizontal, 20)

            Spacer()

            // Reroll Button
            SecondaryButton(title: "Reroll Attributes", icon: "arrow.clockwise") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.rerollAttributes()
                }
            }
            .padding(.horizontal, 20)

            // Navigation Buttons
            HStack(spacing: 12) {
                SecondaryButton(title: "Back", icon: "arrow.left") {
                    viewModel.previousStep()
                }

                PrimaryButton(title: "Continue", icon: "arrow.right") {
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    var averageAttribute: Int {
        let total = viewModel.charisma + viewModel.intelligence + viewModel.reputation + viewModel.luck + viewModel.diplomacy
        return total / 5
    }
}

// MARK: - Supporting Views

struct AttributeRow: View {
    let iconName: String
    let iconColor: Color
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Label
            Text(label)
                .font(.system(size: Constants.Typography.bodyTextSize, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            // Value with bar
            HStack(spacing: 12) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(iconColor)
                            .frame(width: geometry.size.width * (Double(value) / 100.0), height: 8)
                    }
                }
                .frame(width: 80, height: 8)

                // Numeric value
                Text("\(value)")
                    .font(.system(size: Constants.Typography.heroNumberSize, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    ZStack {
        StandardBackgroundView()
        AttributeGenerationView(viewModel: {
            let vm = CharacterCreationViewModel()
            vm.generateAttributes()
            return vm
        }())
    }
}
