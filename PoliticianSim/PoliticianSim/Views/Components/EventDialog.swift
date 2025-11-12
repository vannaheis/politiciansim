//
//  EventDialog.swift
//  PoliticianSim
//
//  Dialog view for displaying events with choices
//

import SwiftUI

struct EventDialog: View {
    let event: Event
    let onChoiceSelected: (Event.Choice) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissal by background tap - force user to make choice
                }

            // Event card
            VStack(spacing: 0) {
                // Header with category icon
                HStack(spacing: 12) {
                    Image(systemName: event.category.iconName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(categoryColor)

                    Text(event.category.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(categoryColor)

                    Spacer()
                }
                .padding(16)
                .background(categoryColor.opacity(0.15))

                // Event content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(event.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        // Description
                        Text(event.description)
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.secondaryText)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()
                            .background(Color.white.opacity(0.2))
                            .padding(.vertical, 4)

                        // Choices
                        Text("Your Options:")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        ForEach(event.choices) { choice in
                            EventChoiceButton(choice: choice) {
                                onChoiceSelected(choice)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .frame(maxWidth: 400)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(categoryColor.opacity(0.3), lineWidth: 2)
            )
            .padding(.horizontal, 24)
        }
    }

    private var categoryColor: Color {
        switch event.category {
        case .earlyLife: return Color.green
        case .education: return Color.blue
        case .political: return Constants.Colors.political
        case .economic: return Color.yellow
        case .international: return Color.cyan
        case .scandal: return Constants.Colors.negative
        case .crisis: return Color.orange
        case .personal: return Color.purple
        }
    }
}

// MARK: - Event Choice Button

struct EventChoiceButton: View {
    let choice: Event.Choice
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(choice.text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Text(choice.outcomePreview)
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Constants.Colors.political.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EventDialog(
        event: Event(
            eventId: "test_001",
            title: "Test Event",
            description: "This is a test event to preview the dialog. You need to make an important decision that will affect your political career.",
            category: .political,
            choices: [
                Event.Choice(
                    text: "Take the risky option",
                    outcomePreview: "High reward but potential backlash",
                    effects: []
                ),
                Event.Choice(
                    text: "Play it safe",
                    outcomePreview: "Minimal impact on your reputation",
                    effects: []
                ),
                Event.Choice(
                    text: "Avoid the situation entirely",
                    outcomePreview: "No change, but miss potential opportunity",
                    effects: []
                )
            ],
            triggers: [],
            ageRange: Event.AgeRange(min: 18, max: 100)
        ),
        onChoiceSelected: { _ in },
        onDismiss: { }
    )
    .background(Constants.Colors.background)
}
