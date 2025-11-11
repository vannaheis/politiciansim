//
//  EventCard.swift
//  PoliticianSim
//
//  Event notification display card
//

import SwiftUI

struct EventCard: View {
    let title: String
    let description: String
    let eventType: EventType

    enum EventType {
        case positive
        case negative
        case neutral
        case political

        var color: Color {
            switch self {
            case .positive: return Constants.Colors.positive
            case .negative: return Constants.Colors.negative
            case .neutral: return Constants.Colors.secondaryText
            case .political: return Constants.Colors.political
            }
        }

        var icon: String {
            switch self {
            case .positive: return "checkmark.circle.fill"
            case .negative: return "xmark.circle.fill"
            case .neutral: return "info.circle.fill"
            case .political: return "building.columns.fill"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: eventType.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(eventType.color)

                Text(title)
                    .font(.system(size: Constants.Typography.sectionTitleSize, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }

            Text(description)
                .font(.system(size: Constants.Typography.bodyTextSize))
                .foregroundColor(Constants.Colors.secondaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(eventType.color.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        EventCard(
            title: "Poll Numbers Rising",
            description: "Your approval rating has increased by 5% after your recent speech on healthcare reform.",
            eventType: .positive
        )

        EventCard(
            title: "Scandal Revealed",
            description: "A journalist has uncovered evidence of questionable campaign donations. Your reputation takes a hit.",
            eventType: .negative
        )

        EventCard(
            title: "Election Day Approaches",
            description: "The election is in 30 days. Make sure your campaign is ready.",
            eventType: .political
        )

        EventCard(
            title: "Daily Briefing",
            description: "Review your schedule and upcoming commitments for the week.",
            eventType: .neutral
        )
    }
    .padding()
    .background(Constants.Colors.background)
}
