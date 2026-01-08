//
//  War.swift
//  PoliticianSim
//
//  War state and mechanics for military conflicts
//

import Foundation

// MARK: - Strategy Change History

struct StrategyChange: Codable, Identifiable {
    let id: UUID
    let date: Date
    let fromStrategy: War.WarStrategy
    let toStrategy: War.WarStrategy
    let dayOfWar: Int  // Which day of the war this change occurred

    init(date: Date, from: War.WarStrategy, to: War.WarStrategy, dayOfWar: Int) {
        self.id = UUID()
        self.date = date
        self.fromStrategy = from
        self.toStrategy = to
        self.dayOfWar = dayOfWar
    }
}

// MARK: - War Model

struct War: Codable, Identifiable {
    let id: UUID
    let attacker: String  // Country code
    let defender: String  // Country code
    var type: WarType
    var justification: WarJustification
    var attackerStrength: Int
    var defenderStrength: Int
    var attackerAttrition: Double  // 0.0 to 1.0 (percentage lost)
    var defenderAttrition: Double
    var casualtiesByCountry: [String: Int]
    var costByCountry: [String: Decimal]
    var currentStrategy: WarStrategy
    let startDate: Date
    var endDate: Date?
    var outcome: WarOutcome?
    var peaceTerm: PeaceTerm?  // Peace terms selected by winner
    var territoryConquered: Double?  // Percentage of defender's territory (0.0-0.4)
    var daysSinceStart: Int
    var warExhaustion: Double  // 0.0 to 1.0 - represents public fatigue with war

    // Strategy transition tracking
    var targetStrategy: WarStrategy?           // Strategy we're transitioning to
    var transitionStartDate: Date?             // When transition began
    var transitionDurationDays: Int?           // How long transition takes
    var strategyHistory: [StrategyChange] = [] // Historical strategy changes

    enum WarType: String, Codable {
        case defensive = "Defensive War"
        case offensive = "Offensive War"
        case proxy = "Proxy War"
        case civil = "Civil War"

        var icon: String {
            switch self {
            case .defensive: return "shield.fill"
            case .offensive: return "flag.fill"
            case .proxy: return "questionmark.diamond.fill"
            case .civil: return "exclamationmark.triangle.fill"
            }
        }
    }

    enum WarJustification: String, Codable {
        case territorialDispute = "Territorial Dispute"
        case selfDefense = "Self-Defense"
        case preemptiveStrike = "Preemptive Strike"
        case regimeChange = "Regime Change"
        case resourceControl = "Resource Control"
        case ideologicalConflict = "Ideological Conflict"
        case retaliation = "Retaliation"
        case civilWar = "Civil War"
        case rebellion = "Rebellion Suppression"

        var approvalPenalty: Double {
            switch self {
            case .territorialDispute: return -12
            case .selfDefense: return 10  // Bonus for defending
            case .preemptiveStrike: return -18
            case .regimeChange: return -25
            case .resourceControl: return -20
            case .ideologicalConflict: return -15
            case .retaliation: return -8
            case .civilWar: return -5
            case .rebellion: return -3
            }
        }
    }

    enum WarStrategy: String, Codable {
        case aggressive = "Aggressive Assault"
        case balanced = "Balanced Warfare"
        case defensive = "Defensive Posture"
        case attrition = "War of Attrition"

        var attritionMultiplier: Double {
            switch self {
            case .aggressive: return 1.5      // High casualties, fast
            case .balanced: return 1.0        // Normal
            case .defensive: return 0.6       // Low casualties, slow
            case .attrition: return 0.8       // Medium casualties, medium
            }
        }

        var speedMultiplier: Double {
            switch self {
            case .aggressive: return 1.5
            case .balanced: return 1.0
            case .defensive: return 0.7
            case .attrition: return 0.9
            }
        }

        var icon: String {
            switch self {
            case .aggressive: return "bolt.fill"
            case .balanced: return "equal.circle.fill"
            case .defensive: return "shield.fill"
            case .attrition: return "clock.fill"
            }
        }

        var exhaustionMultiplier: Double {
            switch self {
            case .aggressive: return 1.2  // Faster exhaustion
            case .balanced: return 1.0    // Normal
            case .defensive: return 0.7   // Much slower exhaustion
            case .attrition: return 0.9   // Slightly slower
            }
        }

        func strengthModifier(strengthRatio: Double, enemyExhaustion: Double) -> Double {
            switch self {
            case .aggressive:
                // +10% when attacking (you're the aggressor)
                return 1.1

            case .balanced:
                // No modifier
                return 1.0

            case .defensive:
                // +15% when outnumbered (ratio < 0.8)
                if strengthRatio < 0.8 {
                    return 1.15
                }
                return 1.0

            case .attrition:
                // +10% when enemy is exhausted (> 0.5)
                if enemyExhaustion > 0.5 {
                    return 1.1
                }
                return 1.0
            }
        }

        var description: String {
            switch self {
            case .aggressive:
                return "Maximum offensive pressure. High casualties but fastest path to victory. Most effective when you have superior forces."
            case .balanced:
                return "Standard military doctrine with balanced offense and defense. Moderate casualties and steady progress."
            case .defensive:
                return "Minimize casualties and hold defensive positions. Slower progress but much lower losses. Very effective when outnumbered."
            case .attrition:
                return "Gradual pressure to wear down the enemy. Lower casualties and steady exhaustion of enemy forces over time."
            }
        }

        var transitionDifficulty: Int {
            switch self {
            case .aggressive: return 3
            case .balanced: return 1
            case .defensive: return 2
            case .attrition: return 2
            }
        }
    }

    enum WarOutcome: String, Codable {
        case attackerVictory = "Attacker Victory"
        case defenderVictory = "Defender Victory"
        case stalemate = "Stalemate"
        case peaceTreaty = "Peace Treaty"
        case nuclearAnnihilation = "Nuclear Annihilation"

        var icon: String {
            switch self {
            case .attackerVictory, .defenderVictory: return "crown.fill"
            case .stalemate: return "equal.square.fill"
            case .peaceTreaty: return "hand.raised.fill"
            case .nuclearAnnihilation: return "exclamationmark.octagon.fill"
            }
        }
    }

    enum PeaceTerm: String, Codable {
        case fullConquest = "Full Conquest"
        case partialTerritory = "Partial Territory"
        case reparations = "Reparations Only"
        case statusQuo = "Status Quo Ante Bellum"

        var territoryPercent: Double {
            switch self {
            case .fullConquest: return 0.35  // 30-40% territory
            case .partialTerritory: return 0.20  // 15-25% territory
            case .reparations: return 0.0
            case .statusQuo: return 0.0
            }
        }

        var reputationImpact: Double {
            switch self {
            case .fullConquest: return -35
            case .partialTerritory: return -15
            case .reparations: return -5
            case .statusQuo: return 10  // Merciful
            }
        }

        var approvalImpact: Double {
            switch self {
            case .fullConquest: return -20
            case .partialTerritory: return -8
            case .reparations: return 5
            case .statusQuo: return 2
            }
        }

        func getReparationAmount(loserGDP: Double) -> Decimal {
            switch self {
            case .fullConquest: return Decimal(loserGDP * 0.10)  // 10% GDP
            case .partialTerritory: return Decimal(loserGDP * 0.05)  // 5% GDP
            case .reparations: return Decimal(loserGDP * 0.08)  // 8% GDP
            case .statusQuo: return 0
            }
        }

        var description: String {
            switch self {
            case .fullConquest: return "Maximum territory conquest (35-40%). Severe reputation penalty."
            case .partialTerritory: return "Moderate territory gain (15-25%). Moderate reputation penalty."
            case .reparations: return "No territory, monetary reparations over 10 years. Small reputation penalty."
            case .statusQuo: return "Return to pre-war borders. Reputation boost for mercy."
            }
        }
    }

    init(
        attacker: String,
        defender: String,
        type: WarType,
        justification: WarJustification,
        attackerStrength: Int,
        defenderStrength: Int,
        startDate: Date
    ) {
        self.id = UUID()
        self.attacker = attacker
        self.defender = defender
        self.type = type
        self.justification = justification
        self.attackerStrength = attackerStrength
        self.defenderStrength = defenderStrength
        self.attackerAttrition = 0.0
        self.defenderAttrition = 0.0
        self.casualtiesByCountry = [attacker: 0, defender: 0]
        self.costByCountry = [attacker: 0, defender: 0]
        self.currentStrategy = .balanced
        self.startDate = startDate
        self.endDate = nil
        self.outcome = nil
        self.peaceTerm = nil
        self.territoryConquered = nil
        self.daysSinceStart = 0
        self.warExhaustion = 0.0
    }

    var isActive: Bool {
        outcome == nil
    }

    var formattedDuration: String {
        let days = daysSinceStart
        let months = days / 30
        if months > 0 {
            return "\(months) month\(months == 1 ? "" : "s")"
        } else {
            return "\(days) day\(days == 1 ? "" : "s")"
        }
    }

    // MARK: - War Exhaustion

    /// Calculates current war exhaustion based on duration and casualties
    /// Returns 0.0 to 1.0 where 1.0 is total exhaustion
    mutating func updateWarExhaustion(exhaustionMultiplier: Double = 1.0) {
        // Duration component (wars longer than 1 year = high exhaustion)
        let daysInYear: Double = 365.0
        let durationFactor = min(1.0, Double(daysSinceStart) / daysInYear)

        // Casualty component (relative to initial strength)
        let attackerCasualties = Double(casualtiesByCountry[attacker] ?? 0)
        let defenderCasualties = Double(casualtiesByCountry[defender] ?? 0)
        let totalInitialStrength = Double(attackerStrength + defenderStrength)
        let totalCasualties = attackerCasualties + defenderCasualties

        let casualtyFactor = min(1.0, totalCasualties / (totalInitialStrength * 0.5))  // 50% casualties = max exhaustion

        // Cost component (wars costing > $500B = high exhaustion)
        let attackerCost = Double(truncating: (costByCountry[attacker] ?? 0) as NSNumber)
        let defenderCost = Double(truncating: (costByCountry[defender] ?? 0) as NSNumber)
        let totalCost = attackerCost + defenderCost
        let costFactor = min(1.0, totalCost / 500_000_000_000.0)  // $500B threshold

        // Weighted average (duration has most impact, then casualties, then cost)
        let baseExhaustion = (durationFactor * 0.5) + (casualtyFactor * 0.35) + (costFactor * 0.15)

        // Apply strategy exhaustion multiplier
        warExhaustion = min(1.0, max(0.0, baseExhaustion * exhaustionMultiplier))
    }

    var exhaustionLevel: ExhaustionLevel {
        if warExhaustion >= 0.8 {
            return .critical
        } else if warExhaustion >= 0.6 {
            return .high
        } else if warExhaustion >= 0.4 {
            return .moderate
        } else if warExhaustion >= 0.2 {
            return .low
        } else {
            return .minimal
        }
    }

    enum ExhaustionLevel: String {
        case minimal = "Minimal"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case critical = "Critical"

        var color: String {
            switch self {
            case .minimal: return "green"
            case .low: return "yellow"
            case .moderate: return "orange"
            case .high: return "red"
            case .critical: return "red"
            }
        }

        var icon: String {
            switch self {
            case .minimal: return "checkmark.circle.fill"
            case .low: return "exclamationmark.circle.fill"
            case .moderate: return "exclamationmark.triangle.fill"
            case .high: return "exclamationmark.triangle.fill"
            case .critical: return "exclamationmark.octagon.fill"
            }
        }

        /// Weekly approval penalty for this exhaustion level
        var weeklyApprovalPenalty: Double {
            switch self {
            case .minimal: return 0.0
            case .low: return -0.5
            case .moderate: return -1.0
            case .high: return -2.0
            case .critical: return -4.0
            }
        }

        /// Weekly stress increase for this exhaustion level (DRASTICALLY REDUCED)
        var weeklyStressIncrease: Int {
            switch self {
            case .minimal: return 0
            case .low: return 0
            case .moderate: return 1  // Was 2
            case .high: return 1      // Was 3
            case .critical: return 2  // Was 5
            }
        }
    }

    var formattedExhaustion: String {
        return "\(Int(warExhaustion * 100))%"
    }

    mutating func simulateDay(currentDate: Date) {
        guard isActive else { return }

        daysSinceStart += 1

        // Check if transition is complete
        if isTransitioning {
            let progress = transitionProgress(currentDate: currentDate)
            if progress >= 1.0 {
                completeTransition()
            }
        }

        // Get effective strategy multipliers (blended if transitioning)
        let effectiveMultipliers = effectiveStrategyMultipliers(currentDate: currentDate)

        // Update war exhaustion with strategy-modified rate
        updateWarExhaustion(exhaustionMultiplier: effectiveMultipliers.exhaustion)

        // Safely calculate daily attrition with zero-strength protection
        guard attackerStrength > 0 && defenderStrength > 0 else {
            // If either side has no strength, resolve the war immediately
            if attackerStrength <= 0 {
                resolveWar(outcome: .defenderVictory)
            } else {
                resolveWar(outcome: .attackerVictory)
            }
            return
        }

        // Calculate base strength ratio
        let baseStrengthRatio = Double(attackerStrength) / Double(defenderStrength)

        // Apply strategy modifiers
        let attackerStrategyMod = currentStrategy.strengthModifier(
            strengthRatio: baseStrengthRatio,
            enemyExhaustion: defenderAttrition
        )

        // Defender uses balanced strategy for now (AI strategy coming later)
        let defenderStrategyMod = 1.0

        let adjustedAttackerStrength = Double(attackerStrength) * attackerStrategyMod
        let adjustedDefenderStrength = Double(defenderStrength) * defenderStrategyMod
        let adjustedRatio = adjustedAttackerStrength / adjustedDefenderStrength

        // Calculate daily attrition with strategy multipliers
        let baseAttrition = 0.001 // 0.1% per day baseline

        // Attacker takes more losses when weaker, less when stronger
        // Now modified by strategy
        let attackerDailyAttrition = baseAttrition * effectiveMultipliers.attrition * (2.0 - adjustedRatio)
        let defenderDailyAttrition = baseAttrition * 1.0 * adjustedRatio  // Defender uses balanced

        // Ensure values are finite before use
        guard attackerDailyAttrition.isFinite && defenderDailyAttrition.isFinite else { return }

        attackerAttrition = min(1.0, attackerAttrition + attackerDailyAttrition)
        defenderAttrition = min(1.0, defenderAttrition + defenderDailyAttrition)

        // Calculate casualties with safe conversion
        let attackerCasualtiesDouble = Double(attackerStrength) * attackerDailyAttrition
        let defenderCasualtiesDouble = Double(defenderStrength) * defenderDailyAttrition

        let attackerCasualties = attackerCasualtiesDouble.isFinite ? Int(attackerCasualtiesDouble) : 0
        let defenderCasualties = defenderCasualtiesDouble.isFinite ? Int(defenderCasualtiesDouble) : 0

        casualtiesByCountry[attacker, default: 0] += attackerCasualties
        casualtiesByCountry[defender, default: 0] += defenderCasualties

        // Calculate daily cost ($1M per day per 1000 soldiers active)
        let attackerDailyCost = Decimal(attackerStrength / 1000) * 1_000_000
        let defenderDailyCost = Decimal(defenderStrength / 1000) * 1_000_000

        costByCountry[attacker, default: 0] += attackerDailyCost
        costByCountry[defender, default: 0] += defenderDailyCost

        // Check for automatic resolution (attrition > 80%)
        if attackerAttrition >= 0.8 {
            resolveWar(outcome: .defenderVictory)
        } else if defenderAttrition >= 0.8 {
            resolveWar(outcome: .attackerVictory)
        }
    }

    mutating func resolveWar(outcome: WarOutcome) {
        self.outcome = outcome
        self.endDate = Calendar.current.date(byAdding: .day, value: daysSinceStart, to: startDate)

        // Calculate territory conquered for victories
        if outcome == .attackerVictory {
            let victorStrength = 1.0 - attackerAttrition
            let loserStrength = 1.0 - defenderAttrition
            let strengthDifference = victorStrength - loserStrength

            // 10-40% territory based on victory margin
            territoryConquered = min(0.4, max(0.1, strengthDifference * 0.5))
        } else if outcome == .defenderVictory {
            // Defender also gets to claim territory from failed invader
            let victorStrength = 1.0 - defenderAttrition
            let loserStrength = 1.0 - attackerAttrition
            let strengthDifference = victorStrength - loserStrength

            // 10-40% territory based on victory margin
            territoryConquered = min(0.4, max(0.1, strengthDifference * 0.5))
        } else {
            territoryConquered = 0.0
        }
    }

    mutating func changeStrategy(to newStrategy: WarStrategy) {
        currentStrategy = newStrategy
    }

    // MARK: - Strategy Transition

    /// Check if war is currently transitioning between strategies
    var isTransitioning: Bool {
        return targetStrategy != nil && transitionStartDate != nil
    }

    /// Get transition progress (0.0 to 1.0)
    func transitionProgress(currentDate: Date) -> Double {
        guard let startDate = transitionStartDate,
              let duration = transitionDurationDays else {
            return 1.0  // No transition, fully using current strategy
        }

        let daysPassed = Calendar.current.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
        return min(1.0, Double(daysPassed) / Double(duration))
    }

    /// Get the effective strategy multipliers (blended during transition)
    func effectiveStrategyMultipliers(currentDate: Date) -> (attrition: Double, speed: Double, exhaustion: Double) {
        if !isTransitioning {
            return (
                attrition: currentStrategy.attritionMultiplier,
                speed: currentStrategy.speedMultiplier,
                exhaustion: currentStrategy.exhaustionMultiplier
            )
        }

        guard let target = targetStrategy else {
            return (
                attrition: currentStrategy.attritionMultiplier,
                speed: currentStrategy.speedMultiplier,
                exhaustion: currentStrategy.exhaustionMultiplier
            )
        }

        let progress = transitionProgress(currentDate: currentDate)

        // Blend old and new strategy effects
        let oldAttrition = currentStrategy.attritionMultiplier
        let newAttrition = target.attritionMultiplier
        let blendedAttrition = oldAttrition * (1.0 - progress) + newAttrition * progress

        let oldSpeed = currentStrategy.speedMultiplier
        let newSpeed = target.speedMultiplier
        let blendedSpeed = oldSpeed * (1.0 - progress) + newSpeed * progress

        let oldExhaustion = currentStrategy.exhaustionMultiplier
        let newExhaustion = target.exhaustionMultiplier
        let blendedExhaustion = oldExhaustion * (1.0 - progress) + newExhaustion * progress

        return (attrition: blendedAttrition, speed: blendedSpeed, exhaustion: blendedExhaustion)
    }

    /// Finalize a strategy transition
    mutating func completeTransition() {
        guard let target = targetStrategy else { return }

        // Record the change in history
        if let startDate = transitionStartDate {
            let change = StrategyChange(
                date: startDate,
                from: currentStrategy,
                to: target,
                dayOfWar: daysSinceStart
            )
            strategyHistory.append(change)
        }

        // Apply new strategy
        currentStrategy = target

        // Clear transition state
        targetStrategy = nil
        transitionStartDate = nil
        transitionDurationDays = nil
    }
}
