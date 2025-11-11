//
//  ChoiceButton.swift
//  PoliticianSim
//
//  Event choice selection button
//

import SwiftUI

struct ChoiceButton: View {
    let title: String
    let description: String
    let impact: String?
    let action: () -> Void

    init(
        title: String,
        description: String,
        impact: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.impact = impact
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: Constants.Typography.sectionTitleSize, weight: .bold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: Constants.Typography.bodyTextSize))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                if let impact = impact {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.charisma)

                        Text(impact)
                            .font(.system(size: Constants.Typography.captionSize, weight: .medium))
                            .foregroundColor(Constants.Colors.charisma)
                    }
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ChoiceButton(
            title: "Accept the Endorsement",
            description: "Publicly accept the endorsement from the controversial figure to gain their supporters.",
            impact: "Approval +10%, Reputation -5"
        ) {
            print("Choice 1 selected")
        }

        ChoiceButton(
            title: "Decline Politely",
            description: "Thank them for their support but decline the public endorsement to maintain your image.",
            impact: "Reputation +3"
        ) {
            print("Choice 2 selected")
        }

        ChoiceButton(
            title: "Ignore the Situation",
            description: "Say nothing and let the news cycle move on without comment."
        ) {
            print("Choice 3 selected")
        }
    }
    .padding()
    .background(Constants.Colors.background)
}
