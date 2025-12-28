//
//  CivilWarVictoryNotification.swift
//  PoliticianSim
//
//  Notification for player civil war victories (rebellion suppression)
//

import Foundation

struct CivilWarVictoryNotification: Identifiable {
    let id = UUID()
    let war: War
    let territoryName: String
    let territorySize: Double  // Square miles
    let territoryPopulation: Int
    let newMorale: Double  // 0.5 (50%)
    let casualties: Int
    let warCost: Decimal
    let approvalGain: Double

    var title: String {
        "Rebellion Suppressed"
    }

    var subtitle: String {
        "Victory in \(territoryName)"
    }

    var formattedTerritory: String {
        if territorySize >= 1_000_000 {
            return String(format: "%.1fM sq mi", territorySize / 1_000_000)
        } else {
            return String(format: "%.0fk sq mi", territorySize / 1_000)
        }
    }

    var formattedPopulation: String {
        if territoryPopulation >= 1_000_000 {
            return String(format: "%.1fM", Double(territoryPopulation) / 1_000_000)
        } else {
            return String(format: "%.0fk", Double(territoryPopulation) / 1_000)
        }
    }

    var formattedWarCost: String {
        let value = Double(truncating: warCost as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return String(format: "$%.0fk", value / 1000)
        }
    }

    var formattedCasualties: String {
        if casualties >= 1_000_000 {
            return String(format: "%.1fM", Double(casualties) / 1_000_000)
        } else if casualties >= 1_000 {
            return String(format: "%.1fk", Double(casualties) / 1_000)
        } else {
            return "\(casualties)"
        }
    }
}
