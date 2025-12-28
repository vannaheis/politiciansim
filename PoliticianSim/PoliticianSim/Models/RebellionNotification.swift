//
//  RebellionNotification.swift
//  PoliticianSim
//
//  Notification when a rebellion starts in a conquered territory
//

import Foundation

struct RebellionNotification: Identifiable {
    let id = UUID()
    let rebellion: Rebellion
    let playerMilitaryStrength: Int

    var title: String {
        "Rebellion Erupts!"
    }

    var subtitle: String {
        "\(rebellion.territory.name) rebels against your rule"
    }

    var strengthRatio: Double {
        Double(playerMilitaryStrength) / Double(max(1, rebellion.strength))
    }

    var threatLevel: String {
        if strengthRatio >= 10.0 {
            return "Minor Uprising"
        } else if strengthRatio >= 5.0 {
            return "Moderate Threat"
        } else if strengthRatio >= 2.0 {
            return "Serious Threat"
        } else {
            return "Critical Threat"
        }
    }

    var threatColor: (red: Double, green: Double, blue: Double) {
        if strengthRatio >= 10.0 {
            return (1.0, 0.8, 0.0)  // Yellow
        } else if strengthRatio >= 5.0 {
            return (1.0, 0.5, 0.0)  // Orange
        } else if strengthRatio >= 2.0 {
            return (1.0, 0.3, 0.3)  // Red
        } else {
            return (0.8, 0.0, 0.0)  // Dark Red
        }
    }

    var formattedRebelStrength: String {
        formatStrength(rebellion.strength)
    }

    var formattedPlayerStrength: String {
        formatStrength(playerMilitaryStrength)
    }

    private func formatStrength(_ strength: Int) -> String {
        if strength >= 1_000_000 {
            return String(format: "%.1fM", Double(strength) / 1_000_000.0)
        } else if strength >= 1_000 {
            return String(format: "%.0fk", Double(strength) / 1_000.0)
        } else {
            return "\(strength)"
        }
    }
}
