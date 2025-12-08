//
//  War.swift
//  PoliticianSim
//
//  War state and mechanics for military conflicts
//

import Foundation

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

    mutating func simulateDay() {
        guard isActive else { return }

        daysSinceStart += 1

        // Calculate daily attrition
        let strengthRatio = Double(attackerStrength) / Double(defenderStrength)
        let baseAttrition = 0.001 // 0.1% per day baseline

        // Attacker takes more losses when weaker, less when stronger
        let attackerDailyAttrition = baseAttrition * currentStrategy.attritionMultiplier * (2.0 - strengthRatio)
        let defenderDailyAttrition = baseAttrition * currentStrategy.attritionMultiplier * strengthRatio

        attackerAttrition = min(1.0, attackerAttrition + attackerDailyAttrition)
        defenderAttrition = min(1.0, defenderAttrition + defenderDailyAttrition)

        // Calculate casualties
        let attackerCasualties = Int(Double(attackerStrength) * attackerDailyAttrition)
        let defenderCasualties = Int(Double(defenderStrength) * defenderDailyAttrition)

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

        // Calculate territory conquered for attacker victories
        if outcome == .attackerVictory {
            let victorStrength = 1.0 - attackerAttrition
            let loserStrength = 1.0 - defenderAttrition
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
}
