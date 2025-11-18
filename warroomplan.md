# War Room Implementation Plan

## 🎯 Overview

The War Room is a comprehensive military warfare and defense system exclusively for **Presidents**. It encompasses offensive and defensive wars, proxy conflicts, counter-insurgency operations, military technology research, territory conquest, nuclear weapons, and civil war suppression.

This system transforms the game into a full geopolitical strategy simulator where military power, technological advancement, and territorial expansion become central to presidential gameplay.

---

## 📋 Core Design Principles

### Access Control
- **President-only feature** - Only accessible at position level 6
- Governors cannot access (no state independence wars in this version)
- Lower positions have no military authority

### War Types
1. **Defensive Wars** - Nation is attacked, must respond
2. **Offensive Wars** - Player declares war on another nation
3. **Proxy Wars** - Support allies without direct involvement
4. **Counter-Insurgency** - Suppress internal rebellions and civil wars

### Military Management
Players control:
- **Troop Levels** (manpower count)
- **Military Budget** (determines overall strength)
- **Draft/Conscription** (volunteer vs. mandatory service)
- **Technology Research** (10 military tech categories)
- **Nuclear Arsenal** (ICBMs, warheads, deterrence)

---

## 🏗️ Complete Implementation Phases

### **Phase 1: Military & Technology Foundation**

#### 1.1 Military Stats Model
**Location**: `PoliticianSim/PoliticianSim/Models/MilitaryStats.swift`

```swift
//
//  MilitaryStats.swift
//  PoliticianSim
//
//  Military statistics and capabilities
//

import Foundation

struct MilitaryStats: Codable {
    var strength: Int              // Abstract military power (0-1,000,000)
    var manpower: Int              // Active duty personnel
    var recruitmentType: RecruitmentType
    var technologyLevels: [TechCategory: Int] = [:]  // 1-10 per category
    var nuclearArsenal: NuclearArsenal

    enum RecruitmentType: String, Codable {
        case volunteer = "Volunteer"
        case conscription = "Conscription"

        var manpowerBonus: Double {
            switch self {
            case .volunteer: return 1.0
            case .conscription: return 2.5  // 2.5x more troops with draft
            }
        }

        var approvalPenalty: Double {
            switch self {
            case .volunteer: return 0
            case .conscription: return -15  // -15 approval for draft
            }
        }
    }

    init(
        strength: Int = 100000,
        manpower: Int = 500000,
        recruitmentType: RecruitmentType = .volunteer,
        technologyLevels: [TechCategory: Int] = [:],
        nuclearArsenal: NuclearArsenal = NuclearArsenal()
    ) {
        self.strength = strength
        self.manpower = manpower
        self.recruitmentType = recruitmentType
        self.technologyLevels = technologyLevels
        self.nuclearArsenal = nuclearArsenal
    }
}

enum TechCategory: String, Codable, CaseIterable {
    case infantryWeapons = "Infantry Weapons"
    case armoredVehicles = "Armored Vehicles"
    case navalPower = "Naval Power"
    case airSuperiority = "Air Superiority"
    case missileSystems = "Missile Systems"
    case cyberWarfare = "Cyber Warfare"
    case logistics = "Logistics"
    case medicalTech = "Medical Tech"
    case intelligence = "Intelligence"
    case nuclearWeapons = "Nuclear Weapons"

    var icon: String {
        switch self {
        case .infantryWeapons: return "rifle.fill"
        case .armoredVehicles: return "tank.fill"
        case .navalPower: return "ferry.fill"
        case .airSuperiority: return "airplane"
        case .missileSystems: return "rocket.fill"
        case .cyberWarfare: return "network"
        case .logistics: return "shippingbox.fill"
        case .medicalTech: return "cross.case.fill"
        case .intelligence: return "eye.fill"
        case .nuclearWeapons: return "atom"
        }
    }

    var strengthMultiplier: Double {
        switch self {
        case .infantryWeapons: return 1.2
        case .armoredVehicles: return 1.5
        case .navalPower: return 1.3
        case .airSuperiority: return 1.8
        case .missileSystems: return 1.6
        case .cyberWarfare: return 1.1
        case .logistics: return 1.4
        case .medicalTech: return 1.0
        case .intelligence: return 1.2
        case .nuclearWeapons: return 3.0
        }
    }
}

struct NuclearArsenal: Codable {
    var warheadCount: Int = 0
    var icbmCount: Int = 0
    var hasFirstStrikeCapability: Bool = false
    var hasSecondStrikeCapability: Bool = false  // Submarine-based

    var deterrenceValue: Int {
        return warheadCount * 100 + (hasSecondStrikeCapability ? 50000 : 0)
    }
}
```

#### 1.2 Technology Research Model
**Location**: `PoliticianSim/PoliticianSim/Models/TechnologyResearch.swift`

```swift
//
//  TechnologyResearch.swift
//  PoliticianSim
//
//  Military technology research system
//

import Foundation

struct TechResearch: Codable, Identifiable {
    let id: UUID
    let category: TechCategory
    let currentLevel: Int          // 1-10
    let targetLevel: Int
    var progress: Double           // 0.0-1.0
    var researchStartDate: Date?
    var estimatedCompletion: Date?

    var isComplete: Bool {
        return progress >= 1.0
    }

    var costToNextLevel: Decimal {
        // Cost increases exponentially
        let baseCost: Decimal = 50_000_000_000  // $50B base
        let levelMultiplier = Decimal(pow(1.5, Double(targetLevel)))
        return baseCost * levelMultiplier
    }

    var timeToComplete: Int {
        // Days required (180-540 days based on level)
        return 180 + (targetLevel * 36)
    }

    init(
        id: UUID = UUID(),
        category: TechCategory,
        currentLevel: Int,
        targetLevel: Int,
        progress: Double = 0.0,
        researchStartDate: Date? = nil,
        estimatedCompletion: Date? = nil
    ) {
        self.id = id
        self.category = category
        self.currentLevel = currentLevel
        self.targetLevel = targetLevel
        self.progress = progress
        self.researchStartDate = researchStartDate
        self.estimatedCompletion = estimatedCompletion
    }
}
```

#### 1.3 Military Manager
**Location**: `PoliticianSim/PoliticianSim/ViewModels/MilitaryManager.swift`

```swift
//
//  MilitaryManager.swift
//  PoliticianSim
//
//  Manages military stats, technology research, and strength calculation
//

import Foundation
import Combine

class MilitaryManager: ObservableObject {
    @Published var militaryStats: MilitaryStats
    @Published var activeResearch: [TechResearch] = []
    @Published var completedResearch: [TechResearch] = []

    init() {
        // Initialize with base military stats
        self.militaryStats = MilitaryStats()

        // Initialize all tech categories at level 1
        for category in TechCategory.allCases {
            militaryStats.technologyLevels[category] = 1
        }
    }

    // MARK: - Strength Calculation

    /// Calculates total military strength based on manpower, tech, and budget
    func calculateMilitaryStrength(
        manpower: Int,
        techLevels: [TechCategory: Int],
        militaryBudget: Decimal
    ) -> Int {
        // Base strength from manpower
        let manpowerStrength = Double(manpower) * 0.5

        // Tech bonus (average tech level × 10000)
        let avgTechLevel = techLevels.values.reduce(0, +) / max(1, techLevels.count)
        let techBonus = Double(avgTechLevel) * 10000.0

        // Budget bonus ($100B = +10000 strength)
        let budgetBonus = Double(truncating: militaryBudget as NSNumber) / 10_000_000_000.0

        // Tech multipliers for advanced categories
        var techMultiplier = 1.0
        for (category, level) in techLevels {
            let categoryBonus = (Double(level) / 10.0) * (category.strengthMultiplier - 1.0)
            techMultiplier += categoryBonus
        }

        let totalStrength = (manpowerStrength + techBonus + budgetBonus) * techMultiplier

        return Int(totalStrength)
    }

    func updateMilitaryStrength(militaryBudget: Decimal) {
        militaryStats.strength = calculateMilitaryStrength(
            manpower: militaryStats.manpower,
            techLevels: militaryStats.technologyLevels,
            militaryBudget: militaryBudget
        )
    }

    // MARK: - Recruitment

    func toggleConscription(character: inout Character) {
        if militaryStats.recruitmentType == .volunteer {
            militaryStats.recruitmentType = .conscription
            // 2.5x manpower increase
            militaryStats.manpower = Int(Double(militaryStats.manpower) * 2.5)
            // Apply approval penalty
            character.approvalRating = max(0, character.approvalRating - 15)
        } else {
            militaryStats.recruitmentType = .volunteer
            // Return to base manpower
            militaryStats.manpower = Int(Double(militaryStats.manpower) / 2.5)
            // Restore approval
            character.approvalRating = min(100, character.approvalRating + 10)
        }
    }

    // MARK: - Technology Research

    func startResearch(
        category: TechCategory,
        character: Character
    ) -> (success: Bool, message: String) {
        let currentLevel = militaryStats.technologyLevels[category] ?? 1

        guard currentLevel < 10 else {
            return (false, "Technology already at maximum level.")
        }

        // Check if already researching this category
        if activeResearch.contains(where: { $0.category == category }) {
            return (false, "Already researching this technology.")
        }

        let research = TechResearch(
            category: category,
            currentLevel: currentLevel,
            targetLevel: currentLevel + 1
        )

        // Check funds
        guard character.campaignFunds >= research.costToNextLevel else {
            return (false, "Insufficient funds. Need $\(research.costToNextLevel)B")
        }

        var newResearch = research
        newResearch.researchStartDate = character.currentDate
        newResearch.estimatedCompletion = Calendar.current.date(
            byAdding: .day,
            value: research.timeToComplete,
            to: character.currentDate
        )

        activeResearch.append(newResearch)

        return (true, "Research started: \(category.rawValue) Level \(research.targetLevel)")
    }

    func updateResearchProgress(currentDate: Date) {
        for i in 0..<activeResearch.count {
            guard let startDate = activeResearch[i].researchStartDate else { continue }

            let elapsed = Calendar.current.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
            let totalDays = activeResearch[i].timeToComplete

            activeResearch[i].progress = min(1.0, Double(elapsed) / Double(totalDays))

            // Check completion
            if activeResearch[i].progress >= 1.0 {
                completeResearch(index: i)
            }
        }
    }

    private func completeResearch(index: Int) {
        guard index < activeResearch.count else { return }

        var research = activeResearch[index]
        research.progress = 1.0

        // Upgrade tech level
        militaryStats.technologyLevels[research.category] = research.targetLevel

        // Move to completed
        completedResearch.append(research)
        activeResearch.remove(at: index)

        // Nuclear weapons unlock arsenal
        if research.category == .nuclearWeapons && research.targetLevel >= 5 {
            unlockNuclearCapability()
        }
    }

    // MARK: - Nuclear Weapons

    private func unlockNuclearCapability() {
        militaryStats.nuclearArsenal.hasFirstStrikeCapability = true

        if militaryStats.technologyLevels[.nuclearWeapons] ?? 0 >= 8 {
            militaryStats.nuclearArsenal.hasSecondStrikeCapability = true
        }
    }

    func buildNuclearWarheads(
        count: Int,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard militaryStats.technologyLevels[.nuclearWeapons] ?? 0 >= 5 else {
            return (false, "Nuclear Weapons tech must be level 5+")
        }

        let costPerWarhead: Decimal = 5_000_000_000  // $5B each
        let totalCost = costPerWarhead * Decimal(count)

        guard character.campaignFunds >= totalCost else {
            return (false, "Insufficient funds. Need $\(totalCost)")
        }

        character.campaignFunds -= totalCost
        militaryStats.nuclearArsenal.warheadCount += count

        // International condemnation
        character.approvalRating = max(0, character.approvalRating - Double(count) * 2.0)

        return (true, "Built \(count) nuclear warheads. Total arsenal: \(militaryStats.nuclearArsenal.warheadCount)")
    }

    func buildICBM(
        count: Int,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard militaryStats.technologyLevels[.missileSystems] ?? 0 >= 6 else {
            return (false, "Missile Systems tech must be level 6+")
        }

        let costPerICBM: Decimal = 10_000_000_000  // $10B each
        let totalCost = costPerICBM * Decimal(count)

        guard character.campaignFunds >= totalCost else {
            return (false, "Insufficient funds. Need $\(totalCost)")
        }

        character.campaignFunds -= totalCost
        militaryStats.nuclearArsenal.icbmCount += count

        return (true, "Built \(count) ICBMs. Total: \(militaryStats.nuclearArsenal.icbmCount)")
    }
}
```

---

### **Phase 2: Warfare Engine**

#### 2.1 War Model
**Location**: `PoliticianSim/PoliticianSim/Models/War.swift`

```swift
//
//  War.swift
//  PoliticianSim
//
//  War state and configuration
//

import Foundation

struct War: Codable, Identifiable {
    let id: UUID
    let attacker: Country
    let defender: Country
    let startDate: Date
    var endDate: Date?
    var type: WarType
    var justification: WarJustification
    var duration: Int                                      // Days
    var attackerStrength: Int
    var defenderStrength: Int
    var casualtiesByCountry: [String: Int] = [:]          // country code → casualties
    var costByCountry: [String: Decimal] = [:]            // country code → $ spent
    var isActive: Bool = true
    var winner: Country?
    var currentStrategy: WarStrategy = .balanced
    var territoryGained: Double = 0.0                     // Percentage

    enum WarType: String, Codable {
        case defensive = "Defensive"
        case offensive = "Offensive"
        case proxy = "Proxy"
        case civil = "Civil War"
    }

    enum WarJustification: String, Codable {
        case borderDispute = "Border Dispute"
        case territorialClaim = "Territorial Claim"
        case defensivePact = "Defensive Pact"
        case regimeChange = "Regime Change"
        case counterInsurgency = "Counter-Insurgency"
        case noJustification = "No Justification"

        var approvalPenalty: Double {
            switch self {
            case .borderDispute: return -10
            case .territorialClaim: return -15
            case .defensivePact: return 5  // Bonus for defending ally
            case .regimeChange: return -25
            case .counterInsurgency: return -5
            case .noJustification: return -35
            }
        }
    }

    enum WarStrategy: String, Codable {
        case aggressive = "Aggressive"
        case balanced = "Balanced"
        case defensive = "Defensive"
        case attrition = "Attrition"

        var casualtyMultiplier: Double {
            switch self {
            case .aggressive: return 1.8
            case .balanced: return 1.0
            case .defensive: return 0.6
            case .attrition: return 0.4
            }
        }

        var victorySpeedMultiplier: Double {
            switch self {
            case .aggressive: return 1.5
            case .balanced: return 1.0
            case .defensive: return 0.7
            case .attrition: return 0.5
            }
        }
    }

    init(
        id: UUID = UUID(),
        attacker: Country,
        defender: Country,
        startDate: Date,
        endDate: Date? = nil,
        type: WarType,
        justification: WarJustification,
        duration: Int = 0,
        attackerStrength: Int,
        defenderStrength: Int
    ) {
        self.id = id
        self.attacker = attacker
        self.defender = defender
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.justification = justification
        self.duration = duration
        self.attackerStrength = attackerStrength
        self.defenderStrength = defenderStrength
    }
}
```

#### 2.2 War Engine
**Location**: `PoliticianSim/PoliticianSim/ViewModels/WarEngine.swift`

```swift
//
//  WarEngine.swift
//  PoliticianSim
//
//  Manages war declaration, simulation, and resolution
//

import Foundation
import Combine

class WarEngine: ObservableObject {
    @Published var activeWars: [War] = []
    @Published var completedWars: [War] = []

    // MARK: - War Declaration

    func declareWar(
        attacker: Country,
        defender: Country,
        justification: War.WarJustification,
        character: inout Character,
        militaryManager: MilitaryManager
    ) -> War {
        let war = War(
            id: UUID(),
            attacker: attacker,
            defender: defender,
            startDate: character.currentDate,
            type: .offensive,
            justification: justification,
            attackerStrength: militaryManager.militaryStats.strength,
            defenderStrength: defender.militaryStrength
        )

        // Apply approval penalty based on justification
        character.approvalRating = max(0, character.approvalRating + justification.approvalPenalty)

        // Stress from war decision
        character.stress = min(100, character.stress + 20)

        activeWars.append(war)

        return war
    }

    // MARK: - War Simulation

    func simulateWarDay(war: inout War, currentDate: Date) {
        war.duration += 1

        // Calculate daily losses
        let attackerLosses = calculateDailyLosses(
            strength: war.attackerStrength,
            opponentStrength: war.defenderStrength,
            strategy: war.currentStrategy
        )

        let defenderLosses = calculateDailyLosses(
            strength: war.defenderStrength,
            opponentStrength: war.attackerStrength,
            strategy: .balanced  // AI uses balanced
        )

        // Apply losses
        war.attackerStrength -= attackerLosses
        war.defenderStrength -= defenderLosses

        // Track casualties
        war.casualtiesByCountry[war.attacker.code, default: 0] += attackerLosses
        war.casualtiesByCountry[war.defender.code, default: 0] += defenderLosses

        // Daily war cost ($2B per day base)
        let dailyCost: Decimal = 2_000_000_000
        war.costByCountry[war.attacker.code, default: 0] += dailyCost
        war.costByCountry[war.defender.code, default: 0] += dailyCost

        // Check victory conditions
        checkVictoryConditions(war: &war, currentDate: currentDate)
    }

    private func calculateDailyLosses(
        strength: Int,
        opponentStrength: Int,
        strategy: War.WarStrategy
    ) -> Int {
        // Base attrition: 0.1% per day
        let baseAttrition = Double(strength) * 0.001

        // Strength ratio modifier
        let strengthRatio = Double(opponentStrength) / Double(max(1, strength))

        // Strategy modifier
        let strategyMod = strategy.casualtyMultiplier

        let totalLosses = Int(baseAttrition * strengthRatio * strategyMod)

        return max(1, totalLosses)
    }

    private func checkVictoryConditions(war: inout War, currentDate: Date) {
        // Victory if opponent reduced to 20% strength
        if war.defenderStrength < Int(Double(war.attackerStrength) * 0.2) {
            endWar(war: &war, winner: war.attacker, currentDate: currentDate)
        } else if war.attackerStrength < Int(Double(war.defenderStrength) * 0.2) {
            endWar(war: &war, winner: war.defender, currentDate: currentDate)
        }

        // Average duration: 240 days (8 months)
        // Random chance to end after this point
        if war.duration > 240 && Double.random(in: 0...1) > 0.95 {
            let winner = war.attackerStrength > war.defenderStrength ? war.attacker : war.defender
            endWar(war: &war, winner: winner, currentDate: currentDate)
        }
    }

    // MARK: - War Resolution

    func endWar(war: inout War, winner: Country, currentDate: Date) {
        war.isActive = false
        war.endDate = currentDate
        war.winner = winner

        // Calculate spoils
        distributeSpoils(war: &war)

        // Move to completed
        if let index = activeWars.firstIndex(where: { $0.id == war.id }) {
            completedWars.append(war)
            activeWars.remove(at: index)
        }
    }

    private func distributeSpoils(war: inout War) {
        guard let winner = war.winner else { return }

        let loser = winner.code == war.attacker.code ? war.defender : war.attacker

        // Territory gain: 10-40% based on strength ratio
        let strengthRatio = Double(winner.militaryStrength) / Double(max(1, loser.militaryStrength))
        let territoryGainPercentage = min(0.4, 0.1 + (strengthRatio - 1.0) * 0.15)

        war.territoryGained = territoryGainPercentage

        // Reparations: 10-30% of loser's treasury
        // (This will be applied by GameManager)
    }

    // MARK: - Strategy Changes

    func changeStrategy(warId: UUID, newStrategy: War.WarStrategy) {
        if let index = activeWars.firstIndex(where: { $0.id == warId }) {
            activeWars[index].currentStrategy = newStrategy
        }
    }

    // MARK: - Nuclear Strike

    func launchNuclearStrike(
        war: inout War,
        character: inout Character,
        militaryManager: MilitaryManager
    ) -> (success: Bool, message: String) {
        guard militaryManager.militaryStats.nuclearArsenal.warheadCount > 0 else {
            return (false, "No nuclear warheads available.")
        }

        guard militaryManager.militaryStats.nuclearArsenal.icbmCount > 0 else {
            return (false, "No ICBMs available for delivery.")
        }

        // Instant victory but massive consequences
        war.defenderStrength = 0
        war.isActive = false
        war.winner = war.attacker

        // Apocalyptic approval penalty
        character.approvalRating = max(0, character.approvalRating - 50)

        // Massive civilian casualties
        let civilianDeaths = war.defender.population / 2  // 50% of population
        war.casualtiesByCountry[war.defender.code, default: 0] += civilianDeaths

        // Use up warheads
        militaryManager.militaryStats.nuclearArsenal.warheadCount -= 1
        militaryManager.militaryStats.nuclearArsenal.icbmCount -= 1

        return (true, "Nuclear strike launched. \(civilianDeaths.formatted()) casualties. The world will never forgive this.")
    }
}
```

---

### **Phase 3: Territory System**

#### 3.1 Territory Model
**Location**: `PoliticianSim/PoliticianSim/Models/Territory.swift`

```swift
//
//  Territory.swift
//  PoliticianSim
//
//  Conquered and controlled territories
//

import Foundation

struct Territory: Codable, Identifiable {
    let id: UUID
    var name: String
    var size: Double                   // Square kilometers
    var population: Int
    var morale: Double                 // 0.0-1.0
    var type: TerritoryType
    var rebellionRisk: Double          // 0.0-1.0
    var taxRevenue: Decimal
    var controlledSince: Date

    enum TerritoryType: String, Codable {
        case core = "Core Territory"
        case conquered = "Conquered"
        case annexed = "Annexed"
        case puppet = "Puppet State"
    }

    var isRebelling: Bool {
        return rebellionRisk >= 0.75
    }

    init(
        id: UUID = UUID(),
        name: String,
        size: Double,
        population: Int,
        morale: Double,
        type: TerritoryType,
        rebellionRisk: Double,
        taxRevenue: Decimal,
        controlledSince: Date
    ) {
        self.id = id
        self.name = name
        self.size = size
        self.population = population
        self.morale = morale
        self.type = type
        self.rebellionRisk = rebellionRisk
        self.taxRevenue = taxRevenue
        self.controlledSince = controlledSince
    }
}

struct Rebellion: Codable, Identifiable {
    let id: UUID
    let territory: Territory
    var rebelStrength: Int
    var startDate: Date
    var demands: String
    var supportPercentage: Double      // 0.0-1.0

    init(
        id: UUID = UUID(),
        territory: Territory,
        rebelStrength: Int,
        startDate: Date,
        demands: String,
        supportPercentage: Double
    ) {
        self.id = id
        self.territory = territory
        self.rebelStrength = rebelStrength
        self.startDate = startDate
        self.demands = demands
        self.supportPercentage = supportPercentage
    }
}
```

#### 3.2 Territory Manager
**Location**: `PoliticianSim/PoliticianSim/ViewModels/TerritoryManager.swift`

```swift
//
//  TerritoryManager.swift
//  PoliticianSim
//
//  Manages conquered territories and rebellions
//

import Foundation
import Combine

class TerritoryManager: ObservableObject {
    @Published var territories: [Territory] = []
    @Published var activeRebellions: [Rebellion] = []

    // MARK: - Territory Acquisition

    func conqueredTerritory(
        from war: War,
        percentage: Double,
        currentDate: Date
    ) -> Territory {
        let loser = war.winner!.code == war.attacker.code ? war.defender : war.attacker
        let sizeGained = loser.territorySize * percentage
        let populationGained = Int(Double(loser.population) * percentage)

        let territory = Territory(
            name: "\(loser.name) Territory",
            size: sizeGained,
            population: populationGained,
            morale: 0.45,              // Low morale for conquered
            type: .conquered,
            rebellionRisk: 0.30,       // 30% base rebellion risk
            taxRevenue: 0,
            controlledSince: currentDate
        )

        territories.append(territory)
        return territory
    }

    // MARK: - Morale & Rebellion

    func updateTerritoryMorale(currentDate: Date) {
        for i in 0..<territories.count {
            // Conquered territories slowly improve morale over time
            if territories[i].type == .conquered {
                // 1% morale improvement per year
                let yearsSinceConquest = Calendar.current.dateComponents(
                    [.year],
                    from: territories[i].controlledSince,
                    to: currentDate
                ).year ?? 0

                territories[i].morale = min(0.8, 0.45 + (Double(yearsSinceConquest) * 0.01))

                // Rebellion risk decreases as morale improves
                territories[i].rebellionRisk = max(0.1, 0.3 - (territories[i].morale - 0.45))
            }

            // Check for rebellion trigger
            if territories[i].rebellionRisk >= 0.75 && Double.random(in: 0...1) < 0.05 {
                triggerRebellion(territory: territories[i], currentDate: currentDate)
            }
        }
    }

    private func triggerRebellion(territory: Territory, currentDate: Date) {
        let rebelStrength = calculateRebelStrength(territory: territory)

        let rebellion = Rebellion(
            territory: territory,
            rebelStrength: rebelStrength,
            startDate: currentDate,
            demands: "Independence from foreign occupation",
            supportPercentage: 1.0 - territory.morale
        )

        activeRebellions.append(rebellion)
    }

    private func calculateRebelStrength(territory: Territory) -> Int {
        // 30-60% of government military strength
        let populationFactor = territory.population / 1_000_000
        let moraleFactor = 1.0 - territory.morale
        return Int(Double(populationFactor) * moraleFactor * 50000)
    }

    // MARK: - Counter-Insurgency

    func suppressRebellion(
        rebellion: Rebellion,
        militaryStrength: Int,
        character: Character,
        warEngine: WarEngine
    ) -> War {
        // Create civil war
        let civilWar = War(
            id: UUID(),
            attacker: Country(
                name: character.country,
                code: character.country,
                population: 0,  // Will be filled
                militaryStrength: militaryStrength,
                territorySize: 0,
                gdp: 0,
                governmentType: .presidential
            ),
            defender: Country(
                name: "Rebel Forces - \(rebellion.territory.name)",
                code: "REBEL",
                population: rebellion.territory.population,
                militaryStrength: rebellion.rebelStrength,
                territorySize: rebellion.territory.size,
                gdp: 0,
                governmentType: .singleParty
            ),
            startDate: character.currentDate,
            type: .civil,
            justification: .counterInsurgency,
            attackerStrength: militaryStrength,
            defenderStrength: rebellion.rebelStrength
        )

        return civilWar
    }

    func grantAutonomy(rebellion: Rebellion, character: inout Character) {
        // Grant independence, lose territory
        if let index = territories.firstIndex(where: { $0.id == rebellion.territory.id }) {
            territories.remove(at: index)
        }

        // Remove rebellion
        if let index = activeRebellions.firstIndex(where: { $0.id == rebellion.id }) {
            activeRebellions.remove(at: index)
        }

        // Approval penalty for "losing" territory
        character.approvalRating = max(0, character.approvalRating - 10)
    }
}
```

---

### **Phase 4: War Room UI**

#### 4.1 War Room View
**Location**: `PoliticianSim/PoliticianSim/Views/WarRoom/WarRoomView.swift`

```swift
//
//  WarRoomView.swift
//  PoliticianSim
//
//  Main War Room interface for presidents
//

import SwiftUI

struct WarRoomView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab: WarRoomTab = .activeWars

    enum WarRoomTab: String, CaseIterable {
        case activeWars = "Active Wars"
        case military = "Military"
        case technology = "Technology"
        case territories = "Territories"
        case nuclear = "Nuclear"
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)

                    Text("War Room")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Military strength badge
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                        Text("\(gameManager.militaryManager.militaryStats.strength)")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.red.opacity(0.3))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Tab selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(WarRoomTab.allCases, id: \.self) { tab in
                            TabButton(
                                title: tab.rawValue,
                                isSelected: selectedTab == tab
                            ) {
                                selectedTab = tab
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)

                // Content
                ScrollView {
                    switch selectedTab {
                    case .activeWars:
                        ActiveWarsView()
                    case .military:
                        MilitaryManagementView()
                    case .technology:
                        TechnologyResearchView()
                    case .territories:
                        TerritoriesView()
                    case .nuclear:
                        NuclearArsenalView()
                    }
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.red.opacity(0.3) : Color.white.opacity(0.05))
                )
        }
    }
}
```

---

## 📊 Complete File Structure

```
PoliticianSim/PoliticianSim/
├── Models/
│   ├── MilitaryStats.swift           (NEW - Phase 1)
│   ├── TechnologyResearch.swift      (NEW - Phase 1)
│   ├── War.swift                     (NEW - Phase 2)
│   ├── Territory.swift               (NEW - Phase 3)
│   └── NuclearArsenal.swift          (included in MilitaryStats)
│
├── ViewModels/
│   ├── MilitaryManager.swift         (NEW - Phase 1)
│   ├── WarEngine.swift               (NEW - Phase 2)
│   └── TerritoryManager.swift        (NEW - Phase 3)
│
├── Views/
│   └── WarRoom/
│       ├── WarRoomView.swift         (NEW - Phase 4)
│       ├── ActiveWarsView.swift      (NEW - Phase 4)
│       ├── MilitaryManagementView.swift (NEW - Phase 4)
│       ├── TechnologyResearchView.swift (NEW - Phase 4)
│       ├── TerritoriesView.swift     (NEW - Phase 4)
│       ├── NuclearArsenalView.swift  (NEW - Phase 4)
│       ├── WarCard.swift             (NEW - Phase 4)
│       └── WarDetailSheet.swift      (NEW - Phase 4)
│
└── Updated Files:
    ├── NavigationManager.swift       (MODIFY - add .warRoom case)
    ├── GameManager.swift             (MODIFY - add managers, war simulation)
    ├── ContentView.swift             (MODIFY - routing)
    └── SaveGame.swift                (MODIFY - serialization)
```

---

## 🎮 Gameplay Balance

### Military Strength Formula
```
Base Strength = Manpower × 0.5
Tech Bonus = Average Tech Level × 10,000
Budget Bonus = (Military Budget / $10B)
Tech Multipliers = Sum of (Tech Level / 10) × (Category Multiplier - 1)

Total Strength = (Base + Tech Bonus + Budget Bonus) × Tech Multipliers
```

**Example**:
- Manpower: 1,000,000 (volunteer)
- Avg Tech Level: 5
- Military Budget: $700B
- Total Strength ≈ 570,000

### War Duration
- **Average**: 240 days (8 months)
- **Quick Victory**: 60-120 days (overwhelming force)
- **Long War**: 365-540 days (evenly matched)

### Technology Research Costs
| Level | Cost | Time |
|-------|------|------|
| 1→2 | $75B | 216 days |
| 2→3 | $112B | 252 days |
| 5→6 | $284B | 396 days |
| 9→10 | $1.7T | 540 days |

### Nuclear Arsenal
- **Warhead Cost**: $5B each
- **ICBM Cost**: $10B each
- **Minimum Tech**: Nuclear Weapons Level 5
- **Second Strike**: Nuclear Weapons Level 8

---

## ✅ Implementation Checklist

### Phase 1: Military Foundation ☐
- [ ] Create MilitaryStats.swift
- [ ] Create TechnologyResearch.swift
- [ ] Create MilitaryManager.swift
- [ ] Implement strength calculation formula
- [ ] Implement conscription toggle
- [ ] Implement tech research start/progress
- [ ] Implement nuclear arsenal management
- [ ] Test all military manager methods

### Phase 2: Warfare Engine ☐
- [ ] Create War.swift
- [ ] Create WarEngine.swift
- [ ] Implement war declaration
- [ ] Implement daily war simulation
- [ ] Implement casualty calculations
- [ ] Implement victory/defeat conditions
- [ ] Implement strategy changes
- [ ] Implement nuclear strike mechanics
- [ ] Test 8-month average duration

### Phase 3: Territory System ☐
- [ ] Create Territory.swift
- [ ] Create TerritoryManager.swift
- [ ] Implement territory conquest from wars
- [ ] Implement morale system
- [ ] Implement rebellion generation
- [ ] Implement counter-insurgency wars
- [ ] Implement autonomy grants
- [ ] Test rebellion probabilities

### Phase 4: War Room UI ☐
- [ ] Create WarRoomView.swift (main)
- [ ] Create ActiveWarsView.swift
- [ ] Create MilitaryManagementView.swift
- [ ] Create TechnologyResearchView.swift
- [ ] Create TerritoriesView.swift
- [ ] Create NuclearArsenalView.swift
- [ ] Create WarCard.swift component
- [ ] Create WarDetailSheet.swift
- [ ] Test all UI flows

### Phase 5: Integration ☐
- [ ] Update NavigationManager.swift
- [ ] Update GameManager.swift
- [ ] Add war simulation to skipDay/skipWeek
- [ ] Update SaveGame.swift
- [ ] Test save/load with wars
- [ ] Test full war cycle end-to-end

---

## 🎯 Success Criteria

After implementation, War Room should:
1. ✅ Be accessible only to Presidents
2. ✅ Support defensive, offensive, proxy, and counter-insurgency wars
3. ✅ Provide troop/budget/tech management
4. ✅ Include draft/conscription mechanics
5. ✅ Feature 10 technology categories
6. ✅ Enable territory conquest and management
7. ✅ Include nuclear weapons with MAD consequences
8. ✅ Average 8-month war duration
9. ✅ Integrate with approval, GDP, and budget systems
10. ✅ Feel like commanding a nation's military

---

This comprehensive plan provides everything needed to implement a full-featured War Room system for presidential gameplay!
