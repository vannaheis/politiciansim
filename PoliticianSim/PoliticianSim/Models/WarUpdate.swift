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
        abs(war.casualtiesByCountry[war.attacker] ?? 0)
    }

    var defenderCasualties: Int {
        abs(war.casualtiesByCountry[war.defender] ?? 0)
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

// MARK: - War Exhaustion Warning

struct WarExhaustionWarning: Identifiable {
    let id = UUID()
    let war: War
    let exhaustionLevel: War.ExhaustionLevel
    let playerCountry: String

    var title: String {
        switch exhaustionLevel {
        case .critical:
            return "CRITICAL War Exhaustion"
        case .high:
            return "High War Exhaustion"
        case .moderate:
            return "War Exhaustion Rising"
        default:
            return "War Update"
        }
    }

    var message: String {
        let warName = "\(war.attacker) vs \(war.defender)"
        let duration = war.formattedDuration
        let casualties = abs(war.casualtiesByCountry[playerCountry] ?? 0)

        switch exhaustionLevel {
        case .critical:
            return "The war against \(opponentName) has reached critical exhaustion levels after \(duration). With \(casualties) casualties, public demands for peace are overwhelming. Consider negotiating peace immediately to avoid severe political consequences."
        case .high:
            return "Public support for the war against \(opponentName) is deteriorating after \(duration) of conflict. \(casualties) casualties have taken a toll on morale. Peace negotiations should be considered."
        case .moderate:
            return "The war against \(opponentName) continues into its \(duration) with \(casualties) casualties. Public patience is beginning to wear thin."
        default:
            return "War update for \(warName)."
        }
    }

    var opponentName: String {
        war.attacker == playerCountry ? war.defender : war.attacker
    }

    var icon: String {
        exhaustionLevel.icon
    }

    var iconColor: String {
        exhaustionLevel.color
    }
}
