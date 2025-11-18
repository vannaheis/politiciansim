//
//  TerritoryManager.swift
//  PoliticianSim
//
//  Manages conquered territories, rebellions, and territory administration
//

import Foundation
import Combine

class TerritoryManager: ObservableObject {
    @Published var territories: [Territory] = []
    @Published var activeRebellions: [Rebellion] = []
    @Published var rebellionHistory: [Rebellion] = []

    // MARK: - Territory Acquisition

    func acquireTerritory(
        from war: War,
        defenderCountry: Country,
        currentDate: Date
    ) -> Territory? {
        guard let territoryPercentage = war.territoryConquered, territoryPercentage > 0 else {
            return nil
        }

        // Calculate territory size based on percentage conquered
        let conqueredSize = defenderCountry.territorySize * territoryPercentage
        let conqueredPopulation = Int(Double(defenderCountry.population) * territoryPercentage)

        let territory = Territory(
            name: "\(defenderCountry.name) (Conquered)",
            formerOwner: defenderCountry.code,
            currentOwner: war.attacker,
            size: conqueredSize,
            population: conqueredPopulation,
            conquestDate: currentDate
        )

        territories.append(territory)
        return territory
    }

    // MARK: - Territory Management

    func updateTerritories(days: Int) {
        for i in 0..<territories.count {
            territories[i].updateMorale(days: days)
        }
    }

    func investInTerritory(territoryId: UUID, amount: Decimal) -> Bool {
        guard let index = territories.firstIndex(where: { $0.id == territoryId }) else {
            return false
        }

        territories[index].investInTerritory(amount: amount)
        return true
    }

    func annexTerritory(territoryId: UUID) -> Bool {
        guard let index = territories.firstIndex(where: { $0.id == territoryId }) else {
            return false
        }

        // Can only annex conquered territories
        guard territories[index].type == .conquered else {
            return false
        }

        // Requires morale >= 0.5
        guard territories[index].morale >= 0.5 else {
            return false
        }

        territories[index].annex()
        return true
    }

    func grantAutonomy(territoryId: UUID) -> Bool {
        guard let index = territories.firstIndex(where: { $0.id == territoryId }) else {
            return false
        }

        // Can grant autonomy to conquered or annexed territories
        guard territories[index].type == .conquered || territories[index].type == .annexed else {
            return false
        }

        territories[index].grantAutonomy()
        return true
    }

    // MARK: - Rebellion System

    func checkForRebellions(currentDate: Date) {
        for territory in territories {
            // Skip if already has active rebellion
            if activeRebellions.contains(where: { $0.territory.id == territory.id }) {
                continue
            }

            // Check if rebellion should spawn based on rebellion risk
            let rebellionChance = territory.rebellionRisk
            let roll = Double.random(in: 0.0...1.0)

            if roll < rebellionChance {
                let rebellion = Rebellion(territory: territory, currentDate: currentDate)
                activeRebellions.append(rebellion)
            }
        }
    }

    func suppressRebellion(
        rebellionId: UUID,
        militaryStrength: Int
    ) -> RebellionSuppressionResult {
        guard let index = activeRebellions.firstIndex(where: { $0.id == rebellionId }) else {
            return RebellionSuppressionResult(success: false, casualties: 0, cost: 0)
        }

        let rebellion = activeRebellions[index]

        // Calculate success probability based on strength ratio
        let strengthRatio = Double(militaryStrength) / Double(rebellion.strength)
        let baseSuccessChance = 0.7  // 70% base chance

        // Adjust by strength ratio (0.5x to 2x modifier)
        let successChance = min(0.95, baseSuccessChance * strengthRatio)

        let roll = Double.random(in: 0.0...1.0)
        let success = roll < successChance

        // Calculate casualties (5-15% of rebel strength)
        let casualtyRate = Double.random(in: 0.05...0.15)
        let casualties = Int(Double(rebellion.strength) * casualtyRate)

        // Calculate cost ($100M - $1B based on rebel strength)
        let baseCost: Decimal = 100_000_000
        let cost = baseCost * Decimal(rebellion.strength / 10_000)

        if success {
            // Suppression successful
            activeRebellions[index].outcome = .suppressed
            activeRebellions[index].endDate = Date()

            // Move to history
            let completedRebellion = activeRebellions.remove(at: index)
            rebellionHistory.append(completedRebellion)

            // Reduce territory morale further
            if let territoryIndex = territories.firstIndex(where: { $0.id == rebellion.territory.id }) {
                territories[territoryIndex].morale = max(0.0, territories[territoryIndex].morale - 0.1)
            }
        }

        return RebellionSuppressionResult(
            success: success,
            casualties: casualties,
            cost: cost
        )
    }

    struct RebellionSuppressionResult {
        let success: Bool
        let casualties: Int
        let cost: Decimal
    }

    func grantIndependence(rebellionId: UUID) -> Bool {
        guard let index = activeRebellions.firstIndex(where: { $0.id == rebellionId }) else {
            return false
        }

        activeRebellions[index].outcome = .independence
        activeRebellions[index].endDate = Date()

        // Move to history
        let completedRebellion = activeRebellions.remove(at: index)
        rebellionHistory.append(completedRebellion)

        // Remove territory from control
        if let territoryIndex = territories.firstIndex(where: { $0.id == completedRebellion.territory.id }) {
            territories.remove(at: territoryIndex)
        }

        return true
    }

    func grantAutonomyToRebellion(rebellionId: UUID) -> Bool {
        guard let index = activeRebellions.firstIndex(where: { $0.id == rebellionId }) else {
            return false
        }

        activeRebellions[index].outcome = .autonomy
        activeRebellions[index].endDate = Date()

        // Move to history
        let completedRebellion = activeRebellions.remove(at: index)
        rebellionHistory.append(completedRebellion)

        // Grant autonomy to territory
        if let territoryIndex = territories.firstIndex(where: { $0.id == completedRebellion.territory.id }) {
            territories[territoryIndex].grantAutonomy()
        }

        return true
    }

    // MARK: - Statistics

    func getTotalTerritorySize() -> Double {
        territories.reduce(0.0) { $0 + $1.size }
    }

    func getTotalTerritoryPopulation() -> Int {
        territories.reduce(0) { $0 + $1.population }
    }

    func getAverageMorale() -> Double {
        guard !territories.isEmpty else { return 1.0 }
        let totalMorale = territories.reduce(0.0) { $0 + $1.morale }
        return totalMorale / Double(territories.count)
    }

    func getHighRiskTerritories() -> [Territory] {
        territories.filter { $0.rebellionRisk >= 0.5 }
    }

    func getTerritoryByType(_ type: Territory.TerritoryType) -> [Territory] {
        territories.filter { $0.type == type }
    }

    // MARK: - Daily/Weekly Updates

    func processDaily(currentDate: Date) {
        // Update territory morale (daily decay)
        updateTerritories(days: 1)

        // Check for new rebellions (daily check with low probability)
        let daysSinceLastCheck = 1
        if daysSinceLastCheck >= 30 {  // Check monthly
            checkForRebellions(currentDate: currentDate)
        }
    }

    func processWeekly(currentDate: Date) {
        // Update territory morale (weekly decay)
        updateTerritories(days: 7)

        // Check for new rebellions (weekly check)
        checkForRebellions(currentDate: currentDate)
    }
}
