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
    @Published var activeReparations: [ReparationAgreement] = []
    @Published var completedReparations: [ReparationAgreement] = []

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

    func checkForRebellions(currentDate: Date) -> [Rebellion] {
        var newRebellions: [Rebellion] = []

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
                newRebellions.append(rebellion)
            }
        }

        return newRebellions
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

    func processWeekly(currentDate: Date) -> [Rebellion] {
        // Update territory morale (weekly decay)
        updateTerritories(days: 7)

        // Check for new rebellions (weekly check)
        let newRebellions = checkForRebellions(currentDate: currentDate)
        return newRebellions
    }

    // MARK: - Annual Territory Growth

    func processAnnualTerritoryGrowth(currentDate: Date) -> [TerritoryGrowthNotification] {
        var notifications: [TerritoryGrowthNotification] = []

        for i in 0..<territories.count {
            let territory = territories[i]
            let previousMultiplier = territory.gdpContributionMultiplier

            // Territory automatically ages one year
            // The gdpContributionMultiplier is recalculated based on yearsSinceConquest

            let newMultiplier = territory.gdpContributionMultiplier

            // Notify if territory reached 90% integration
            if previousMultiplier < 0.90 && newMultiplier >= 0.90 {
                notifications.append(TerritoryGrowthNotification(
                    territoryName: territory.name,
                    newMultiplier: newMultiplier,
                    reachedFullIntegration: true
                ))
            }
        }

        return notifications
    }

    struct TerritoryGrowthNotification {
        let territoryName: String
        let newMultiplier: Double
        let reachedFullIntegration: Bool
    }

    // MARK: - Annual Reparations Processing

    func processAnnualReparations(playerCountryCode: String, currentDate: Date) -> Decimal {
        var totalReceived: Decimal = 0
        var completedIndices: [Int] = []

        for i in 0..<activeReparations.count {
            var agreement = activeReparations[i]

            // Process payment
            agreement.yearsPaid += 1

            // Track if player is recipient
            if agreement.recipientCountry == playerCountryCode {
                totalReceived += agreement.yearlyPayment
            }

            // Check if complete
            if agreement.isComplete {
                completedIndices.append(i)
                completedReparations.append(agreement)
            } else {
                activeReparations[i] = agreement
            }
        }

        // Remove completed reparations (reverse order to maintain indices)
        for index in completedIndices.reversed() {
            activeReparations.remove(at: index)
        }

        return totalReceived
    }

    func getTotalAnnualReparationsOwed(payerCountryCode: String) -> Decimal {
        var total: Decimal = 0
        for agreement in activeReparations where agreement.payerCountry == payerCountryCode {
            total += agreement.yearlyPayment
        }
        return total
    }

    func getTotalAnnualReparationsReceived(recipientCountryCode: String) -> Decimal {
        var total: Decimal = 0
        for agreement in activeReparations where agreement.recipientCountry == recipientCountryCode {
            total += agreement.yearlyPayment
        }
        return total
    }

    // MARK: - GDP Contribution Calculations

    func getTotalConqueredGDPContribution(playerCountry: String, globalCountryState: GlobalCountryState, currentDate: Date) -> Double {
        var totalGDP: Double = 0

        for territory in territories where territory.currentOwner == playerCountry {
            // Get the base GDP for this territory from global state
            if let formerCountry = globalCountryState.getCountry(code: territory.formerOwner) {
                let territoryPercentOfFormerCountry = territory.size / formerCountry.baseTerritory
                let baseGDPForTerritory = formerCountry.currentGDP * territoryPercentOfFormerCountry

                // Apply GDP contribution multiplier based on years since conquest (using game time)
                totalGDP += baseGDPForTerritory * territory.gdpContributionMultiplier(currentDate: currentDate)
            }
        }

        return totalGDP
    }
}
