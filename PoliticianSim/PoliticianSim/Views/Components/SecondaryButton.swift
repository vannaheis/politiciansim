//
//  SecondaryButton.swift
//  PoliticianSim
//
//  Secondary action button component
//

import SwiftUI

struct SecondaryButton: View {
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
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton(title: "View Profile", icon: "person.circle") {
            print("Profile viewed")
        }

        SecondaryButton(title: "Cancel") {
            print("Cancelled")
        }

        SecondaryButton(title: "Settings", icon: "gearshape") {
            print("Settings opened")
        }
    }
    .padding()
    .background(Constants.Colors.background)
}
