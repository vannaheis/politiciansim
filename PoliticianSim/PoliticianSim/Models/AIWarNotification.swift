    //
//  AIWarNotification.swift
//  PoliticianSim
//
//  Notification for AI war conclusions
//

import Foundation

struct AIWarNotification: Identifiable {
    let id = UUID()
    let war: War
    let winnerName: String
    let loserName: String
    let peaceTerm: War.PeaceTerm
    let territoryTransferred: Double  // Square miles
    let reparationAmount: Decimal

    var title: String {
        "\(winnerName) Defeats \(loserName)"
    }

    var subtitle: String {
        "Global Conflict Concluded"
    }

    var territoryPercent: Double {
        war.territoryConquered ?? 0.0
    }

    var formattedTerritory: String? {
        guard territoryTransferred > 0 else { return nil }

        if territoryTransferred >= 1_000_000 {
            return String(format: "%.1fM sq mi", territoryTransferred / 1_000_000)
        } else {
            return String(format: "%.0fk sq mi", territoryTransferred / 1_000)
        }
    }

    var formattedReparations: String? {
        guard reparationAmount > 0 else { return nil }

        let value = Double(truncating: reparationAmount as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return String(format: "$%.0fk", value / 1000)
        }
    }
}
