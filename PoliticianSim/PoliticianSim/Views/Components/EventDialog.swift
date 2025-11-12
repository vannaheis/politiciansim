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

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Blurred background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissal by background tap - force user to make choice
                }

            // Popup card
            ScrollView {
                VStack(spacing: 0) {
                    // Category badge at top
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(categoryColor.opacity(0.2))
                                .frame(width: 36, height: 36)

                            Image(systemName: event.category.iconName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(categoryColor)
                        }

                        Text(event.category.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(categoryColor)
                            .tracking(0.5)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    // Event content
                    VStack(alignment: .leading, spacing: 14) {
                        // Title
                        Text(event.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)

                        // Description
                        Text(event.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Constants.Colors.secondaryText)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        // Divider
                        Rectangle()
                            .fill(categoryColor.opacity(0.3))
                            .frame(height: 1)
                            .padding(.vertical, 8)

                        // Choices section
                        Text("Choose Your Action")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText.opacity(0.8))
                            .textCase(.uppercase)
                            .tracking(0.5)

                        VStack(spacing: 10) {
                            ForEach(event.choices) { choice in
                                EventChoiceButton(choice: choice, categoryColor: categoryColor) {
                                    onChoiceSelected(choice)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .frame(maxWidth: 380, maxHeight: 600)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                categoryColor.opacity(0.4),
                                categoryColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: categoryColor.opacity(0.3), radius: 30, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
            .padding(.vertical, 60)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
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
    let categoryColor: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Choice indicator
                ZStack {
                    Circle()
                        .strokeBorder(categoryColor.opacity(0.5), lineWidth: 2)
                        .frame(width: 20, height: 20)

                    Circle()
                        .fill(categoryColor.opacity(isPressed ? 0.8 : 0.0))
                        .frame(width: 12, height: 12)
                }
                .padding(.top, 2)

                // Choice content
                VStack(alignment: .leading, spacing: 6) {
                    Text(choice.text)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(choice.outcomePreview)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                // Arrow indicator
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(categoryColor.opacity(0.6))
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isPressed
                            ? categoryColor.opacity(0.15)
                            : Color.white.opacity(0.05)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isPressed
                            ? categoryColor.opacity(0.5)
                            : categoryColor.opacity(0.2),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
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
