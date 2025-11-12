//
//  CountrySelectionView.swift
//  PoliticianSim
//
//  Country selection screen (USA only in Phase 1)
//

import SwiftUI

struct CountrySelectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Select Your Country")
                    .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                    .foregroundColor(.white)

                Text("Where will your political career begin?")
                    .font(.system(size: Constants.Typography.bodyTextSize))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.top, 40)

            Spacer()

            // USA Card (only option in Phase 1)
            Button(action: {
                viewModel.selectedCountry = "USA"
            }) {
                VStack(spacing: 16) {
                    // Flag emoji
                    Text("🇺🇸")
                        .font(.system(size: 80))

                    VStack(spacing: 8) {
                        Text("United States of America")
                            .font(.system(size: Constants.Typography.sectionTitleSize, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("Population")
                                    .font(.system(size: Constants.Typography.captionSize))
                                    .foregroundColor(Constants.Colors.secondaryText)
                                Text("333M")
                                    .font(.system(size: Constants.Typography.bodyTextSize, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            VStack(spacing: 4) {
                                Text("Government")
                                    .font(.system(size: Constants.Typography.captionSize))
                                    .foregroundColor(Constants.Colors.secondaryText)
                                Text("Federal Republic")
                                    .font(.system(size: Constants.Typography.bodyTextSize, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.selectedCountry == "USA" ? Constants.Colors.buttonPrimary.opacity(0.2) : Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    viewModel.selectedCountry == "USA" ? Constants.Colors.buttonPrimary : Color.white.opacity(0.2),
                                    lineWidth: 2
                                )
                        )
                )
            }
            .padding(.horizontal, 20)

            Spacer()

            // Continue Button
            PrimaryButton(title: "Continue", icon: "arrow.right") {
                if viewModel.canProceedFromCountry {
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .opacity(viewModel.canProceedFromCountry ? 1.0 : 0.5)
            .disabled(!viewModel.canProceedFromCountry)
        }
    }
}

#Preview {
    ZStack {
        StandardBackgroundView()
        CountrySelectionView(viewModel: CharacterCreationViewModel())
    }
}
