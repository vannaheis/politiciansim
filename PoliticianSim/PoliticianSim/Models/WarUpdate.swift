//
//  WarUpdate.swift
//  PoliticianSim
//
//  Monthly war progress update data
//

import Foundation

struct WarUpdate: Identifiable {
    let id = UUID()
    let war: War
    let monthNumber: Int  // Which month of the war (1-based)
    let totalWars: Int    // Total active wars (for "1 of 3" display)
    let warIndex: Int     // Index in the list (for "1 of 3" display)

    var title: String {
        "\(war.attacker) vs \(war.defender) (\(warIndex + 1) of \(totalWars))"
    }

    var monthLabel: String {
        "Month \(monthNumber)"
    }

    var attackerCasualties: Int {
        war.casualtiesByCountry[war.attacker] ?? 0
    }

    var defenderCasualties: Int {
        war.casualtiesByCountry[war.defender] ?? 0
    }

    var attackerCost: Decimal {
        war.costByCountry[war.attacker] ?? 0
    }

    var defenderCost: Decimal {
        war.costByCountry[war.defender] ?? 0
    }

    var attackerAttritionPercent: Double {
        war.attackerAttrition * 100
    }

    var defenderAttritionPercent: Double {
        war.defenderAttrition * 100
    }

    var status: String {
        let attritionDiff = war.defenderAttrition - war.attackerAttrition

        if abs(attritionDiff) < 0.05 {
            return "Stalemate"
        } else if attritionDiff > 0.15 {
            return "\(war.attacker) Winning"
        } else if attritionDiff < -0.15 {
            return "\(war.defender) Winning"
        } else {
            return "Close Fight"
        }
    }

    var statusColor: String {
        let attritionDiff = war.defenderAttrition - war.attackerAttrition

        if abs(attritionDiff) < 0.05 {
            return "yellow"
        } else if attritionDiff > 0 {
            return "green"  // Attacker winning
        } else {
            return "red"    // Defender winning
        }
    }
}
