//
//  WarDefeatNotification.swift
//  PoliticianSim
//
//  Notification for player war defeats
//

import Foundation

struct WarDefeatNotification: Identifiable {
    let id = UUID()
    let war: War
    let enemyName: String
    let peaceTerm: War.PeaceTerm
    let territoryLost: Double  // Square miles
    let reparationAmount: Decimal
    let reputationLoss: Int
    let approvalLoss: Double
    let stressGain: Int

    var title: String {
        "War Defeat"
    }

    var subtitle: String {
        "Lost to \(enemyName)"
    }

    var formattedTerritory: String? {
        guard territoryLost > 0 else { return nil }

        if territoryLost >= 1_000_000 {
            return String(format: "%.1fM sq mi", territoryLost / 1_000_000)
        } else {
            return String(format: "%.0fk sq mi", territoryLost / 1_000)
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
