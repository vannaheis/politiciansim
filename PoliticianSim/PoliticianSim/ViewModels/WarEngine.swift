//
//  WarEngine.swift
//  PoliticianSim
//
//  War simulation and management engine
//

import Foundation
import Combine

class WarEngine: ObservableObject {
    @Published var activeWars: [War] = []
    @Published var warHistory: [War] = []

    // MARK: - War Declaration

    func canDeclareWar(playerCountry: String, targetCountry: String, militaryStats: MilitaryStats) -> Bool {
        // Can't declare war on yourself
        guard playerCountry != targetCountry else { return false }

        // Can't have too many simultaneous wars (max 3)
        guard activeWars.count < 3 else { return false }

        // Must have minimum military strength (100,000)
        guard militaryStats.strength >= 100_000 else { return false }

        return true
    }

    func declareWar(
        attacker: String,
        defender: String,
        type: War.WarType,
        justification: War.WarJustification,
        attackerStrength: Int,
        defenderStrength: Int,
        currentDate: Date
    ) -> War? {
        let war = War(
            attacker: attacker,
            defender: defender,
            type: type,
            justification: justification,
            attackerStrength: attackerStrength,
            defenderStrength: defenderStrength,
            startDate: currentDate
        )

        activeWars.append(war)
        return war
    }

    // MARK: - War Simulation

    func simulateDay() {
        for i in 0..<activeWars.count {
            activeWars[i].simulateDay()

            // Move to history if resolved
            if !activeWars[i].isActive {
                let completedWar = activeWars.remove(at: i)
                warHistory.append(completedWar)
                break  // Only process one completion per day
            }
        }
    }

    func changeStrategy(warId: UUID, to strategy: War.WarStrategy) {
        guard let index = activeWars.firstIndex(where: { $0.id == warId }) else { return }
        activeWars[index].changeStrategy(to: strategy)
    }

    // MARK: - Peace Negotiation

    func negotiatePeace(warId: UUID, outcome: War.WarOutcome) -> Bool {
        guard let index = activeWars.firstIndex(where: { $0.id == warId }) else {
            return false
        }

        activeWars[index].resolveWar(outcome: outcome)

        // Move to history
        let completedWar = activeWars.remove(at: index)
        warHistory.append(completedWar)

        return true
    }

    // MARK: - Nuclear Strike

    func launchNuclearStrike(
        warId: UUID,
        attackerNukes: NuclearArsenal,
        defenderNukes: NuclearArsenal
    ) -> NuclearStrikeResult {
        guard let index = activeWars.firstIndex(where: { $0.id == warId }) else {
            return NuclearStrikeResult(success: false, retaliation: false, casualties: 0)
        }

        // Check if attacker has capability
        guard attackerNukes.warheadCount > 0, attackerNukes.hasFirstStrikeCapability else {
            return NuclearStrikeResult(success: false, retaliation: false, casualties: 0)
        }

        // Launch strike
        let casualties = Int.random(in: 500_000...5_000_000)  // 500k-5M casualties

        // Check for retaliation (MAD)
        let retaliation = defenderNukes.warheadCount > 0 && defenderNukes.hasSecondStrikeCapability

        if retaliation {
            // Mutual Assured Destruction
            activeWars[index].resolveWar(outcome: .nuclearAnnihilation)

            // Move to history
            let completedWar = activeWars.remove(at: index)
            warHistory.append(completedWar)

            return NuclearStrikeResult(
                success: true,
                retaliation: true,
                casualties: casualties * 2  // Both sides annihilated
            )
        } else {
            // Successful first strike, automatic victory
            activeWars[index].resolveWar(outcome: .attackerVictory)

            // Move to history
            let completedWar = activeWars.remove(at: index)
            warHistory.append(completedWar)

            return NuclearStrikeResult(
                success: true,
                retaliation: false,
                casualties: casualties
            )
        }
    }

    struct NuclearStrikeResult {
        let success: Bool
        let retaliation: Bool  // MAD triggered
        let casualties: Int
    }

    // MARK: - War Stats

    func getTotalCasualties(for country: String) -> Int {
        var total = 0

        for war in activeWars {
            total += war.casualtiesByCountry[country] ?? 0
        }

        for war in warHistory {
            total += war.casualtiesByCountry[country] ?? 0
        }

        return total
    }

    func getTotalWarCost(for country: String) -> Decimal {
        var total: Decimal = 0

        for war in activeWars {
            total += war.costByCountry[country] ?? 0
        }

        for war in warHistory {
            total += war.costByCountry[country] ?? 0
        }

        return total
    }

    func getVictories(for country: String) -> Int {
        var victories = 0

        for war in warHistory {
            if war.outcome == .attackerVictory && war.attacker == country {
                victories += 1
            } else if war.outcome == .defenderVictory && war.defender == country {
                victories += 1
            }
        }

        return victories
    }

    func getDefeats(for country: String) -> Int {
        var defeats = 0

        for war in warHistory {
            if war.outcome == .attackerVictory && war.defender == country {
                defeats += 1
            } else if war.outcome == .defenderVictory && war.attacker == country {
                defeats += 1
            }
        }

        return defeats
    }
}
