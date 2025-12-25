//
//  DefensiveWarNotification.swift
//  PoliticianSim
//
//  Notification when AI declares war on player
//

import Foundation

struct DefensiveWarNotification: Identifiable {
    let id = UUID()
    let war: War
    let aggressorName: String
    let aggressorStrength: Int
    let playerStrength: Int
    let justification: War.WarJustification

    var title: String {
        "Under Attack!"
    }

    var subtitle: String {
        "\(aggressorName) has declared war"
    }

    var strengthRatio: Double {
        Double(playerStrength) / Double(max(1, aggressorStrength))
    }

    var threatLevel: String {
        if strengthRatio >= 2.0 {
            return "Low Threat"
        } else if strengthRatio >= 1.0 {
            return "Moderate Threat"
        } else if strengthRatio >= 0.5 {
            return "High Threat"
        } else {
            return "Critical Threat"
        }
    }

    var threatColor: (red: Double, green: Double, blue: Double) {
        if strengthRatio >= 2.0 {
            return (0.2, 0.8, 0.2)  // Green
        } else if strengthRatio >= 1.0 {
            return (1.0, 0.8, 0.0)  // Yellow
        } else if strengthRatio >= 0.5 {
            return (1.0, 0.5, 0.0)  // Orange
        } else {
            return (1.0, 0.3, 0.3)  // Red
        }
    }

    var formattedAggressorStrength: String {
        formatStrength(aggressorStrength)
    }

    var formattedPlayerStrength: String {
        formatStrength(playerStrength)
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
