//
//  Territory.swift
//  PoliticianSim
//
//  Territory management for conquered lands
//

import Foundation

struct Territory: Codable, Identifiable {
    let id: UUID
    let name: String
    let formerOwner: String  // Country code
    let currentOwner: String // Country code
    let size: Double  // Square miles
    var population: Int
    var morale: Double  // 0.0-1.0
    var type: TerritoryType
    var rebellionRisk: Double  // 0.0-1.0
    let conquestDate: Date
    var lastRebellionCheck: Date

    enum TerritoryType: String, Codable {
        case core = "Core Territory"
        case conquered = "Conquered Territory"
        case annexed = "Annexed Territory"
        case puppet = "Puppet State"

        var icon: String {
            switch self {
            case .core: return "house.fill"
            case .conquered: return "flag.fill"
            case .annexed: return "building.2.fill"
            case .puppet: return "person.2.fill"
            }
        }

        var moraleDecay: Double {
            switch self {
            case .core: return 0.0
            case .conquered: return 0.02      // -2% per month
            case .annexed: return 0.01        // -1% per month
            case .puppet: return 0.005        // -0.5% per month
            }
        }

        var baseRebellionRisk: Double {
            switch self {
            case .core: return 0.0
            case .conquered: return 0.3
            case .annexed: return 0.15
            case .puppet: return 0.1
            }
        }
    }

    init(
        name: String,
        formerOwner: String,
        currentOwner: String,
        size: Double,
        population: Int,
        conquestDate: Date
    ) {
        self.id = UUID()
        self.name = name
        self.formerOwner = formerOwner
        self.currentOwner = currentOwner
        self.size = size
        self.population = population
        self.morale = 0.3  // Start very low after conquest
        self.type = .conquered
        self.rebellionRisk = 0.3
        self.conquestDate = conquestDate
        self.lastRebellionCheck = conquestDate
    }

    var formattedSize: String {
        if size >= 1_000_000 {
            return String(format: "%.1fM sq mi", size / 1_000_000)
        } else {
            return String(format: "%.0fk sq mi", size / 1000)
        }
    }

    var formattedPopulation: String {
        if population >= 1_000_000 {
            return String(format: "%.1fM", Double(population) / 1_000_000)
        } else {
            return String(format: "%.0fk", Double(population) / 1000)
        }
    }

    var moraleStatus: String {
        if morale >= 0.7 {
            return "Content"
        } else if morale >= 0.4 {
            return "Discontent"
        } else if morale >= 0.2 {
            return "Hostile"
        } else {
            return "Rebellious"
        }
    }

    var moraleColor: String {
        if morale >= 0.7 {
            return "green"
        } else if morale >= 0.4 {
            return "yellow"
        } else if morale >= 0.2 {
            return "orange"
        } else {
            return "red"
        }
    }

    var yearsSinceConquest: Int {
        Calendar.current.dateComponents([.year], from: conquestDate, to: Date()).year ?? 0
    }

    func yearsSinceConquest(currentDate: Date) -> Int {
        Calendar.current.dateComponents([.year], from: conquestDate, to: currentDate).year ?? 0
    }

    var gdpContributionMultiplier: Double {
        switch yearsSinceConquest {
        case 0: return 0.30  // Year 1: 30% productivity
        case 1: return 0.50  // Year 2: 50% productivity
        case 2: return 0.70  // Year 3: 70% productivity
        case 3...: return morale >= 0.5 ? 0.90 : 0.70  // Year 4+: 90% if stable, else 70%
        default: return 0.30
        }
    }

    func gdpContributionMultiplier(currentDate: Date) -> Double {
        switch years {
        case 0: return 0.30  // Year 1: 30% productivity
        case 1: return 0.50  // Year 2: 50% productivity
        case 2: return 0.70  // Year 3: 70% productivity
        case 3...: return morale >= 0.5 ? 0.90 : 0.70  // Year 4+: 90% if stable, else 70%
        default: return 0.30
        }
    }

    mutating func updateMorale(days: Int) {
        // Natural morale decay based on territory type
        let dailyDecay = type.moraleDecay / 30.0  // Convert monthly to daily
        morale = max(0.0, morale - (dailyDecay * Double(days)))

        // Update rebellion risk based on morale
        rebellionRisk = type.baseRebellionRisk + (1.0 - morale) * 0.3
    }

    mutating func investInTerritory(amount: Decimal) {
        // Investment improves morale
        let improvementPerBillion = 0.05  // +5% morale per $1B invested
        let improvement = Double(truncating: amount as NSNumber) / 1_000_000_000 * improvementPerBillion
        morale = min(1.0, morale + improvement)
    }

    mutating func annex() {
        guard type == .conquered else { return }
        type = .annexed
    }

    mutating func grantAutonomy() {
        guard type == .conquered || type == .annexed else { return }
        type = .puppet
        morale = min(1.0, morale + 0.2)  // Boost morale
    }
}

// MARK: - Rebellion

struct Rebellion: Codable, Identifiable {
    let id: UUID
    let territory: Territory
    var strength: Int  // Rebel military strength
    var support: Double  // 0.0-1.0 popular support
    let startDate: Date
    var endDate: Date?
    var outcome: RebellionOutcome?

    enum RebellionOutcome: String, Codable {
        case suppressed = "Suppressed"
        case independence = "Independence Won"
        case autonomy = "Autonomy Granted"
    }

    init(territory: Territory, currentDate: Date) {
        self.id = UUID()
        self.territory = territory

        // Rebel strength based on population (0.1-2% of population joins rebellion)
        let rebellionRate = Double.random(in: 0.001...0.02)
        self.strength = Int(Double(territory.population) * rebellionRate)

        self.support = 1.0 - territory.morale  // Low morale = high support
        self.startDate = currentDate
        self.endDate = nil
        self.outcome = nil
    }

    var isActive: Bool {
        outcome == nil
    }
}
