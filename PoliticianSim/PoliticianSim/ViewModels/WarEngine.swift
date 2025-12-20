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

        // No minimum strength requirement - you can declare war even if you'll lose
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

            // NOTE: Don't automatically move resolved wars to history
            // Let GameManager.checkForWarConclusions() handle peace terms first
            // Wars will be moved to history after peace terms are applied
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

    func applyPeaceTerms(
        warId: UUID,
        peaceTerm: War.PeaceTerm,
        globalCountryState: GlobalCountryState,
        territoryManager: TerritoryManager,
        currentDate: Date
    ) -> PeaceTermResult {
        guard let index = activeWars.firstIndex(where: { $0.id == warId }) else {
            return PeaceTermResult(success: false, territoryTransferred: 0, reparationAmount: 0)
        }

        var war = activeWars[index]
        war.peaceTerm = peaceTerm

        // Determine winner and loser based on outcome
        guard let outcome = war.outcome else {
            return PeaceTermResult(success: false, territoryTransferred: 0, reparationAmount: 0)
        }

        let isAttackerWinner = outcome == .attackerVictory
        let winnerCode = isAttackerWinner ? war.attacker : war.defender
        let loserCode = isAttackerWinner ? war.defender : war.attacker

        var territoryTransferred: Double = 0
        var reparationAmount: Decimal = 0

        // Apply peace terms
        switch peaceTerm {
        case .statusQuo:
            // No territory changes, return to pre-war state
            break

        case .reparations:
            // No territory, only reparations
            if let loserCountry = globalCountryState.getCountry(code: loserCode) {
                reparationAmount = peaceTerm.getReparationAmount(loserGDP: loserCountry.currentGDP)
            }

        case .partialTerritory, .fullConquest:
            // Territory transfer
            let territoryPercent = war.territoryConquered ?? peaceTerm.territoryPercent

            print("[WarEngine] Applying territory transfer:")
            print("  Winner: \(winnerCode), Loser: \(loserCode)")
            print("  Territory %: \(territoryPercent)")

            // Apply territory changes to GlobalCountryState
            globalCountryState.applyWarOutcome(
                attackerCode: winnerCode,
                defenderCode: loserCode,
                territoryPercentConquered: territoryPercent
            )

            // Create conquered Territory object for rebellion tracking
            if let loserCountry = globalCountryState.getCountry(code: loserCode) {
                let conqueredSize = loserCountry.baseTerritory * territoryPercent
                let conqueredPopulation = Int(Double(loserCountry.population) * pow(territoryPercent, 0.7))

                print("  Loser country found: \(loserCountry.name)")
                print("  Base territory: \(loserCountry.baseTerritory)")
                print("  Conquered size: \(conqueredSize)")

                let territory = Territory(
                    name: "\(loserCountry.name) (Conquered)",
                    formerOwner: loserCode,
                    currentOwner: winnerCode,
                    size: conqueredSize,
                    population: conqueredPopulation,
                    conquestDate: currentDate
                )

                territoryManager.territories.append(territory)
                territoryTransferred = conqueredSize
                print("  Territory created and added: \(territory.name)")
                print("  Total territories now: \(territoryManager.territories.count)")
            } else {
                print("  ERROR: Could not find loser country '\(loserCode)'")
            }

            // Also apply reparations if full conquest
            if peaceTerm == .fullConquest, let loserCountry = globalCountryState.getCountry(code: loserCode) {
                reparationAmount = peaceTerm.getReparationAmount(loserGDP: loserCountry.currentGDP)
                print("  Full conquest reparations: \(reparationAmount)")
            }
        }

        // Update war record
        activeWars[index] = war

        return PeaceTermResult(
            success: true,
            territoryTransferred: territoryTransferred,
            reparationAmount: reparationAmount
        )
    }

    struct PeaceTermResult {
        let success: Bool
        let territoryTransferred: Double  // Square miles
        let reparationAmount: Decimal
    }

    func endWar(warId: UUID) {
        guard let index = activeWars.firstIndex(where: { $0.id == warId }) else { return }
        let completedWar = activeWars.remove(at: index)
        warHistory.append(completedWar)
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
