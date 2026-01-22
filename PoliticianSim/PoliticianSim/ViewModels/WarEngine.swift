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
        currentDate: Date,
        globalCountryState: GlobalCountryState? = nil
    ) -> War? {
        // Mobilize AI countries for war (if globalCountryState provided)
        if let globalState = globalCountryState {
            // Check if attacker is AI country (not player)
            if let _ = globalState.getCountry(code: attacker) {
                globalState.mobilizeCountry(countryCode: attacker)
            }

            // Check if defender is AI country (not player)
            if let _ = globalState.getCountry(code: defender) {
                globalState.mobilizeCountry(countryCode: defender)
            }
        }

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

    func simulateDay(currentDate: Date) {
        for i in 0..<activeWars.count {
            activeWars[i].simulateDay(currentDate: currentDate)

            // NOTE: Don't automatically move resolved wars to history
            // Let GameManager.checkForWarConclusions() handle peace terms first
            // Wars will be moved to history after peace terms are applied
        }
    }

    func changeStrategy(
        warId: UUID,
        newStrategy: War.WarStrategy,
        currentDate: Date
    ) -> Bool {
        guard let index = activeWars.firstIndex(where: { $0.id == warId }) else {
            return false
        }

        let currentStrategy = activeWars[index].currentStrategy

        // Don't change if already using this strategy
        guard newStrategy != currentStrategy else {
            return false
        }

        // Don't change if already transitioning to this strategy
        if activeWars[index].targetStrategy == newStrategy {
            return false
        }

        // Calculate transition duration
        let transitionDays = getTransitionDuration(from: currentStrategy, to: newStrategy)

        // Start transition
        activeWars[index].targetStrategy = newStrategy
        activeWars[index].transitionStartDate = currentDate
        activeWars[index].transitionDurationDays = transitionDays

        print("🔄 Strategy change initiated: \(currentStrategy.rawValue) → \(newStrategy.rawValue)")
        print("   Transition will take \(transitionDays) days")

        return true
    }

    private func getTransitionDuration(from: War.WarStrategy, to: War.WarStrategy) -> Int {
        // Aggressive ↔ Defensive is hardest
        if (from == .aggressive && to == .defensive) || (from == .defensive && to == .aggressive) {
            return 90
        }

        // Major shifts based on difficulty
        let fromDiff = from.transitionDifficulty
        let toDiff = to.transitionDifficulty
        let delta = abs(fromDiff - toDiff)

        if delta >= 2 {
            return 30 + (delta * 15)
        }

        // Standard transition
        return 30
    }

    // MARK: - AI Strategy Changes

    /// AI evaluates and potentially changes strategy based on war state
    /// Returns new strategy if AI decides to change, nil otherwise
    func evaluateAIStrategyChange(war: War, playerCountry: String) -> War.WarStrategy? {
        // Only for wars involving the player
        guard war.attacker == playerCountry || war.defender == playerCountry else { return nil }

        // Don't change if already transitioning
        guard !war.isTransitioning else { return nil }

        // Check every 30 days
        guard war.daysSinceStart % 30 == 0 else { return nil }

        // Determine AI's side
        let isAIAttacker = war.attacker != playerCountry
        let aiStrength = isAIAttacker ? war.attackerStrength : war.defenderStrength
        let playerStrength = isAIAttacker ? war.defenderStrength : war.attackerStrength
        let strengthRatio = Double(aiStrength) / Double(max(1, playerStrength))

        let aiCasualties = war.casualtiesByCountry[isAIAttacker ? war.attacker : war.defender] ?? 0
        let initialStrength = isAIAttacker ? war.attackerStrength : war.defenderStrength
        let casualtyRate = Double(aiCasualties) / Double(max(1, initialStrength))

        let warExhaustion = war.warExhaustion

        // AI decision logic
        var newStrategy: War.WarStrategy?

        // If winning decisively (2:1 advantage), go aggressive
        if strengthRatio >= 2.0 && casualtyRate < 0.3 {
            newStrategy = .aggressive
        }
        // If losing badly (1:2 disadvantage), go defensive
        else if strengthRatio <= 0.5 {
            newStrategy = .defensive
        }
        // If high exhaustion or casualties, switch to attrition
        else if warExhaustion >= 0.6 || casualtyRate >= 0.4 {
            newStrategy = .attrition
        }
        // If evenly matched, use balanced
        else if strengthRatio >= 0.8 && strengthRatio <= 1.2 {
            newStrategy = .balanced
        }

        // Only change if different from current
        if let new = newStrategy, new != war.currentStrategy {
            return new
        }

        return nil
    }

    /// Process AI strategy evaluations for all active wars involving the player
    /// Returns notifications for strategy changes
    func processAIStrategyChanges(playerCountry: String, currentDate: Date, globalCountryState: GlobalCountryState) -> [AIStrategyChangeNotification] {
        var notifications: [AIStrategyChangeNotification] = []

        for i in 0..<activeWars.count {
            guard let newStrategy = evaluateAIStrategyChange(war: activeWars[i], playerCountry: playerCountry) else {
                continue
            }

            let war = activeWars[i]
            let oldStrategy = war.currentStrategy

            // Change strategy
            let success = changeStrategy(
                warId: war.id,
                newStrategy: newStrategy,
                currentDate: currentDate
            )

            if success {
                // Determine enemy country
                let enemyCountry = war.attacker == playerCountry ? war.defender : war.attacker
                let enemyCountryName = globalCountryState.getCountry(code: enemyCountry)?.name ?? enemyCountry

                // Create notification
                let notification = AIStrategyChangeNotification(
                    war: war,
                    enemyCountryName: enemyCountryName,
                    oldStrategy: oldStrategy,
                    newStrategy: newStrategy
                )
                notifications.append(notification)
            }
        }

        return notifications
    }

    // MARK: - Peace Negotiation

    func negotiatePeace(warId: UUID, outcome: War.WarOutcome, globalCountryState: GlobalCountryState? = nil) -> Bool {
        guard let index = activeWars.firstIndex(where: { $0.id == warId }) else {
            return false
        }

        activeWars[index].resolveWar(outcome: outcome)

        // Move to history and demobilize
        endWar(warId: warId, globalCountryState: globalCountryState)

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

    func endWar(warId: UUID, globalCountryState: GlobalCountryState? = nil) {
        guard let index = activeWars.firstIndex(where: { $0.id == warId }) else { return }
        let completedWar = activeWars.remove(at: index)
        warHistory.append(completedWar)

        // Demobilize AI countries after war ends
        if let globalState = globalCountryState {
            // Check if countries are still in other wars before demobilizing
            let attackerStillAtWar = activeWars.contains { $0.attacker == completedWar.attacker || $0.defender == completedWar.attacker }
            let defenderStillAtWar = activeWars.contains { $0.attacker == completedWar.defender || $0.defender == completedWar.defender }

            if !attackerStillAtWar, let _ = globalState.getCountry(code: completedWar.attacker) {
                globalState.demobilizeCountry(countryCode: completedWar.attacker)
            }

            if !defenderStillAtWar, let _ = globalState.getCountry(code: completedWar.defender) {
                globalState.demobilizeCountry(countryCode: completedWar.defender)
            }
        }
    }

    // MARK: - Nuclear Strike

    func launchNuclearStrike(
        warId: UUID,
        attackerNukes: NuclearArsenal,
        defenderNukes: NuclearArsenal,
        globalCountryState: GlobalCountryState? = nil
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

            // Move to history and demobilize
            endWar(warId: warId, globalCountryState: globalCountryState)

            return NuclearStrikeResult(
                success: true,
                retaliation: true,
                casualties: casualties * 2  // Both sides annihilated
            )
        } else {
            // Successful first strike, automatic victory
            activeWars[index].resolveWar(outcome: .attackerVictory)

            // Move to history and demobilize
            endWar(warId: warId, globalCountryState: globalCountryState)

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

    // MARK: - AI War System

    /// Attempts to trigger AI-driven wars between countries
    /// Called periodically (e.g., monthly) to simulate global conflicts
    /// Returns the war if one was declared, nil otherwise
    func evaluateAIWarDeclarations(
        globalCountryState: GlobalCountryState,
        playerCountry: String,
        currentDate: Date
    ) -> War? {
        // Don't trigger too many wars simultaneously
        guard activeWars.count < 5 else {
            print("🤖 AI War Check: Max wars limit reached (5)")
            return nil
        }

        // Low probability - wars should be rare events
        // 2% chance per month = ~24% chance per year for any given country
        let warChance = Double.random(in: 0...1)
        guard warChance < 0.02 else {
            print("🤖 AI War Check: No war this month (rolled \(String(format: "%.2f", warChance)))")
            return nil
        }

        print("\n🎲 AI WAR EVALUATION")
        print("Active wars: \(activeWars.count)/5")

        // Select a random aggressor from all countries
        let allCountries = globalCountryState.countries
        guard let aggressor = allCountries.randomElement() else { return nil }

        print("Evaluating \(aggressor.name) as potential aggressor...")

        // Check if this country can declare war
        guard canAICountryDeclareWar(
            aggressorCode: aggressor.code,
            playerCountry: playerCountry,
            globalCountryState: globalCountryState
        ) else {
            print("❌ \(aggressor.name) cannot declare war (tier restrictions or war limit)")
            return nil
        }

        print("✅ \(aggressor.name) passed aggression check, searching for target...")

        // Find a suitable target
        guard let target = findSuitableTarget(
            for: aggressor,
            allCountries: allCountries,
            playerCountry: playerCountry,
            globalCountryState: globalCountryState
        ) else {
            print("❌ No suitable targets found for \(aggressor.name)")
            return nil
        }

        print("🎯 Target selected: \(target.name)")

        // Select appropriate justification
        let justification = selectJustification(aggressor: aggressor, target: target)

        // Mobilize both countries before getting their strength
        globalCountryState.mobilizeCountry(countryCode: aggressor.code)
        globalCountryState.mobilizeCountry(countryCode: target.code)

        // Get updated mobilized strength
        let aggressorMobilized = globalCountryState.getCountry(code: aggressor.code)!
        let targetMobilized = globalCountryState.getCountry(code: target.code)!

        // Declare AI war with mobilized strength
        let war = declareWar(
            attacker: aggressor.code,
            defender: target.code,
            type: .offensive,
            justification: justification,
            attackerStrength: aggressorMobilized.militaryStrength,
            defenderStrength: targetMobilized.militaryStrength,
            currentDate: currentDate,
            globalCountryState: globalCountryState
        )

        if let declaredWar = war {
            print("\n⚔️ AI WAR DECLARED")
            print("Attacker: \(aggressor.name) (strength: \(formatStrength(aggressor.militaryStrength)))")
            print("Defender: \(target.name) (strength: \(formatStrength(target.militaryStrength)))")
            print("Strength ratio: \(String(format: "%.2f", Double(aggressor.militaryStrength) / Double(target.militaryStrength))):1")
            print("Justification: \(justification.rawValue)")
            print("═══════════════════════════════════════\n")
            return declaredWar
        } else {
            print("❌ Failed to declare war (internal error)")
            return nil
        }
    }

    private func canAICountryDeclareWar(
        aggressorCode: String,
        playerCountry: String,
        globalCountryState: GlobalCountryState
    ) -> Bool {
        guard globalCountryState.getCountry(code: aggressorCode) != nil else { return false }

        // Already in too many wars
        let warsInvolved = activeWars.filter { $0.attacker == aggressorCode || $0.defender == aggressorCode }
        guard warsInvolved.count < 2 else { return false }

        // Major powers (top 5 by GDP) are much less aggressive
        let topPowers = globalCountryState.getRankedByGDP().prefix(5).map { $0.code }
        if topPowers.contains(aggressorCode) {
            // Major powers only have 10% the normal war chance
            return Double.random(in: 0...1) < 0.1
        }

        // Mid-tier powers (rank 6-15) are moderately aggressive
        let midTierPowers = globalCountryState.getRankedByGDP().dropFirst(5).prefix(10).map { $0.code }
        if midTierPowers.contains(aggressorCode) {
            // Mid-tier powers have 30% the normal war chance
            return Double.random(in: 0...1) < 0.3
        }

        // Smaller countries are more aggressive (100% normal chance)
        return true
    }

    private func findSuitableTarget(
        for aggressor: GlobalCountryState.CountryState,
        allCountries: [GlobalCountryState.CountryState],
        playerCountry: String,
        globalCountryState: GlobalCountryState
    ) -> GlobalCountryState.CountryState? {
        // Filter potential targets
        let potentialTargets = allCountries.filter { target in
            // Can't attack yourself
            guard target.code != aggressor.code else { return false }

            // Target must not be in too many wars already
            let targetWars = activeWars.filter { $0.attacker == target.code || $0.defender == target.code }
            guard targetWars.count < 2 else { return false }

            // Calculate strength ratio
            let strengthRatio = Double(aggressor.militaryStrength) / Double(max(1, target.militaryStrength))

            // AI must have reasonable chance of winning (at least 50% strength)
            guard strengthRatio >= 0.5 else { return false }

            // AI won't attack targets more than 5x stronger
            guard strengthRatio <= 5.0 else { return false }

            // Prefer targets of similar strength (1:1 to 2:1 ratio)
            return true
        }

        guard !potentialTargets.isEmpty else { return nil }

        // Weight selection by strategic value
        // Prefer weaker neighbors with valuable territory
        let weightedTargets = potentialTargets.map { target -> (GlobalCountryState.CountryState, Double) in
            let strengthRatio = Double(aggressor.militaryStrength) / Double(max(1, target.militaryStrength))

            // Favor targets where aggressor is 1.5-3x stronger
            var weight = 1.0
            if strengthRatio >= 1.5 && strengthRatio <= 3.0 {
                weight = 3.0  // Ideal target
            } else if strengthRatio > 3.0 {
                weight = 0.5  // Too weak, less interesting
            } else if strengthRatio < 1.0 {
                weight = 0.3  // Risky target
            }

            // Add territory value weight
            let territoryValue = target.baseTerritory / 1_000_000.0  // Normalize to millions
            weight *= (1.0 + territoryValue * 0.1)

            return (target, weight)
        }

        // Select random target weighted by strategic value
        let totalWeight = weightedTargets.reduce(0.0) { $0 + $1.1 }
        var randomValue = Double.random(in: 0..<totalWeight)

        for (target, weight) in weightedTargets {
            randomValue -= weight
            if randomValue <= 0 {
                return target
            }
        }

        return weightedTargets.first?.0
    }

    private func selectJustification(
        aggressor: GlobalCountryState.CountryState,
        target: GlobalCountryState.CountryState
    ) -> War.WarJustification {
        let strengthRatio = Double(aggressor.militaryStrength) / Double(max(1, target.militaryStrength))

        // Strong aggressors use more aggressive justifications
        if strengthRatio > 2.5 {
            return [.regimeChange, .resourceControl, .territorialDispute].randomElement() ?? .territorialDispute
        } else if strengthRatio > 1.5 {
            return [.territorialDispute, .preemptiveStrike, .resourceControl].randomElement() ?? .territorialDispute
        } else {
            // Weaker aggressors use defensive justifications
            return [.selfDefense, .retaliation, .territorialDispute].randomElement() ?? .territorialDispute
        }
    }

    /// Resolves AI wars automatically when they conclude
    /// Returns notification data if a notification should be shown
    func resolveAIWar(
        war: War,
        globalCountryState: GlobalCountryState,
        territoryManager: TerritoryManager,
        currentDate: Date
    ) -> AIWarNotification? {
        guard let outcome = war.outcome else { return nil }
        guard outcome != .nuclearAnnihilation && outcome != .stalemate else {
            // Just end the war for these outcomes
            endWar(warId: war.id, globalCountryState: globalCountryState)
            return nil
        }

        // Determine winner/loser
        let isAttackerWinner = outcome == .attackerVictory
        let winnerCode = isAttackerWinner ? war.attacker : war.defender
        let loserCode = isAttackerWinner ? war.defender : war.attacker

        // AI selects peace terms based on victory margin
        let territoryConquered = war.territoryConquered ?? 0.0
        let peaceTerm: War.PeaceTerm

        if territoryConquered >= 0.30 {
            // Decisive victory → Full Conquest
            peaceTerm = .fullConquest
        } else if territoryConquered >= 0.20 {
            // Strong victory → Partial Territory
            peaceTerm = .partialTerritory
        } else if territoryConquered >= 0.10 {
            // Narrow victory → Reparations
            peaceTerm = .reparations
        } else {
            // Pyrrhic victory → Status Quo
            peaceTerm = .statusQuo
        }

        // Apply peace terms
        let result = applyPeaceTerms(
            warId: war.id,
            peaceTerm: peaceTerm,
            globalCountryState: globalCountryState,
            territoryManager: territoryManager,
            currentDate: currentDate
        )

        // End the war
        endWar(warId: war.id, globalCountryState: globalCountryState)

        // Get country names for better logging
        let winnerName = globalCountryState.getCountry(code: winnerCode)?.name ?? winnerCode
        let loserName = globalCountryState.getCountry(code: loserCode)?.name ?? loserCode

        print("\n🏆 AI WAR CONCLUDED")
        print("Winner: \(winnerName)")
        print("Loser: \(loserName)")
        print("Outcome: \(outcome.rawValue)")
        print("Peace terms: \(peaceTerm.rawValue)")
        print("Territory %: \(String(format: "%.1f", territoryConquered * 100))%")
        print("═══════════════════════════════════════\n")

        // Create notification
        let notification = AIWarNotification(
            war: war,
            winnerName: winnerName,
            loserName: loserName,
            peaceTerm: peaceTerm,
            territoryTransferred: result.territoryTransferred,
            reparationAmount: result.reparationAmount
        )

        return notification
    }

    // MARK: - Formatting Helpers

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
