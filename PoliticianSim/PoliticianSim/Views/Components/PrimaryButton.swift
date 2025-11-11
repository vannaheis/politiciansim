//
//  PrimaryButton.swift
//  PoliticianSim
//
//  Main action button component
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: Constants.Typography.buttonTextSize, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Constants.Colors.buttonPrimary)
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Start Campaign", icon: "flag.fill") {
            print("Campaign started")
        }

        PrimaryButton(title: "Continue") {
            print("Continue pressed")
        }

        PrimaryButton(title: "Create Character", icon: "person.fill") {
            print("Create character")
        }
    }
    .padding()
    .background(Constants.Colors.background)
}
