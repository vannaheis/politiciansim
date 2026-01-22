//
//  MilitaryStats.swift
//  PoliticianSim
//
//  Military statistics and capabilities for a character/country
//

import Foundation

struct MilitaryStats: Codable {
    var strength: Int              // Abstract military power (0-1,000,000)
    var manpower: Int              // Active duty personnel
    var recruitmentType: RecruitmentType
    var technologyLevels: [TechCategory: Int] = [:]  // 1-10 per category
    var nuclearArsenal: NuclearArsenal
    var militaryBudget: Decimal    // Annual military spending
    var treasury: MilitaryTreasury // Military-specific treasury tracking

    enum RecruitmentType: String, Codable {
        case volunteer = "Volunteer Force"
        case conscription = "Conscription"

        var manpowerMultiplier: Double {
            switch self {
            case .volunteer: return 1.0
            case .conscription: return 2.5  // Can force more recruits
            }
        }

        var approvalImpact: Double {
            switch self {
            case .volunteer: return 0.0
            case .conscription: return -5.0  // Monthly penalty
            }
        }

        var costPerSoldier: Decimal {
            switch self {
            case .volunteer: return 80_000  // Higher pay for volunteers
            case .conscription: return 40_000  // Lower cost for conscripts
            }
        }

        var recruitmentCost: Decimal {
            switch self {
            case .volunteer: return 10_000  // Upfront recruitment cost
            case .conscription: return 5_000  // Lower upfront cost
            }
        }
    }

    init() {
        self.strength = 100_000
        self.manpower = 100_000
        self.recruitmentType = .volunteer
        self.nuclearArsenal = NuclearArsenal()
        self.militaryBudget = 50_000_000_000  // $50B default
        self.treasury = MilitaryTreasury()

        // Initialize all tech categories at level 1
        for category in TechCategory.allCases {
            self.technologyLevels[category] = 1
        }
    }
}

// MARK: - Military Treasury

struct MilitaryTreasury: Codable {
    var cashReserves: Decimal          // Available military funds
    var dailyRevenue: Decimal          // Daily allocation from budget
    var dailyExpenses: Decimal         // Daily total expenses
    var warCosts: Decimal              // Daily war operation costs
    var personnelCosts: Decimal        // Daily personnel salaries
    var researchCosts: Decimal         // Daily research expenses
    var maintenanceCosts: Decimal      // Daily equipment maintenance

    init() {
        self.cashReserves = 50_000_000_000  // Start with $50B in reserves
        self.dailyRevenue = 0
        self.dailyExpenses = 0
        self.warCosts = 0
        self.personnelCosts = 0
        self.researchCosts = 0
        self.maintenanceCosts = 0
    }

    var netDaily: Decimal {
        dailyRevenue - dailyExpenses
    }

    var isDeficit: Bool {
        dailyExpenses > dailyRevenue
    }

    mutating func processDay(budget: Decimal, manpower: Int, activeWarCost: Decimal, activeResearchCost: Decimal) {
        // Calculate daily revenue from annual budget
        dailyRevenue = budget / 365

        // Calculate daily personnel costs
        personnelCosts = Decimal(manpower) * 200 // $200/day per soldier (~$73k/year)

        // Calculate daily maintenance (2% of annual budget)
        maintenanceCosts = (budget * 0.02) / 365

        // Set war and research costs
        warCosts = activeWarCost
        researchCosts = activeResearchCost

        // Calculate total expenses
        dailyExpenses = personnelCosts + maintenanceCosts + warCosts + researchCosts

        // Update cash reserves
        cashReserves += netDaily
    }
}

// MARK: - Technology Categories

enum TechCategory: String, Codable, CaseIterable {
    case infantryWeapons = "Infantry Weapons"
    case armoredVehicles = "Armored Vehicles"
    case navalPower = "Naval Power"
    case airSuperiority = "Air Superiority"
    case missileSystems = "Missile Systems"
    case cyberWarfare = "Cyber Warfare"
    case logistics = "Logistics & Supply"
    case medicalTech = "Medical Technology"
    case intelligence = "Intelligence & Recon"
    case nuclearWeapons = "Nuclear Weapons"

    var icon: String {
        switch self {
        case .infantryWeapons: return "figure.run"
        case .armoredVehicles: return "car.fill"
        case .navalPower: return "ferry.fill"
        case .airSuperiority: return "airplane"
        case .missileSystems: return "flame.fill"
        case .cyberWarfare: return "network"
        case .logistics: return "shippingbox.fill"
        case .medicalTech: return "cross.case.fill"
        case .intelligence: return "eye.fill"
        case .nuclearWeapons: return "bolt.fill"
        }
    }

    var strengthMultiplier: Double {
        switch self {
        case .infantryWeapons: return 1.15
        case .armoredVehicles: return 1.20
        case .navalPower: return 1.12
        case .airSuperiority: return 1.25
        case .missileSystems: return 1.18
        case .cyberWarfare: return 1.10
        case .logistics: return 1.08
        case .medicalTech: return 1.05
        case .intelligence: return 1.12
        case .nuclearWeapons: return 1.30
        }
    }

    var description: String {
        switch self {
        case .infantryWeapons:
            return "Small arms, grenades, anti-tank weapons, and personal equipment for ground troops."
        case .armoredVehicles:
            return "Tanks, APCs, IFVs, and armored support vehicles for ground combat."
        case .navalPower:
            return "Aircraft carriers, destroyers, submarines, and naval support vessels."
        case .airSuperiority:
            return "Fighter jets, bombers, helicopters, and air defense systems."
        case .missileSystems:
            return "Cruise missiles, ballistic missiles, and precision-guided munitions."
        case .cyberWarfare:
            return "Electronic warfare, hacking capabilities, and digital defense systems."
        case .logistics:
            return "Supply chains, transport infrastructure, and resource management."
        case .medicalTech:
            return "Field hospitals, trauma care, and combat medicine capabilities."
        case .intelligence:
            return "Reconnaissance, surveillance, and intelligence gathering systems."
        case .nuclearWeapons:
            return "Nuclear warheads, delivery systems, and strategic deterrence."
        }
    }
}

// MARK: - Nuclear Arsenal

struct NuclearArsenal: Codable {
    var warheadCount: Int = 0
    var icbmCount: Int = 0
    var hasFirstStrikeCapability: Bool = false
    var hasSecondStrikeCapability: Bool = false  // Submarine-based

    var isNuclearPower: Bool {
        warheadCount > 0
    }

    mutating func buildWarhead() {
        warheadCount += 1
    }

    mutating func buildICBM() {
        icbmCount += 1
    }

    mutating func enableFirstStrike() {
        hasFirstStrikeCapability = true
    }

    mutating func enableSecondStrike() {
        hasSecondStrikeCapability = true
    }
}
