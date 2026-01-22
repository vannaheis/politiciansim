//
//  MilitaryManager.swift
//  PoliticianSim
//
//  Manages military statistics, recruitment, and technology research
//

import Foundation
import Combine

class MilitaryManager: ObservableObject {
    @Published var activeResearch: [TechnologyResearch] = []

    // MARK: - Military Strength Calculation

    func calculateStrength(militaryStats: MilitaryStats) -> Int {
        // Base strength from manpower (1:1 ratio)
        let baseStrength = Double(militaryStats.manpower)

        // Calculate tech multipliers (each category contributes based on level)
        var techMultiplier = 1.0
        for (category, level) in militaryStats.technologyLevels {
            // Each level contributes its proportional share of the category's multiplier
            // Example: Level 5/10 in a 1.20 multiplier category adds (5/10) * 0.20 = 0.10
            let categoryContribution = (Double(level) / 10.0) * (category.strengthMultiplier - 1.0)
            techMultiplier += categoryContribution
        }

        // Budget multiplier (for every $10B in budget, add 5% strength)
        let budgetMultiplier = 1.0 + (Double(truncating: militaryStats.militaryBudget as NSNumber) / 10_000_000_000) * 0.05

        let totalStrength = baseStrength * techMultiplier * budgetMultiplier
        return Int(totalStrength)
    }

    func calculateAverageTechLevel(militaryStats: MilitaryStats) -> Double {
        let levels = militaryStats.technologyLevels.values
        guard !levels.isEmpty else { return 1.0 }
        let sum = levels.reduce(0, +)
        return Double(sum) / Double(levels.count)
    }

    // MARK: - Recruitment

    func calculateMaxManpower(population: Int, militaryStats: MilitaryStats) -> Int {
        // Fixed 10% of population max (Total War capacity)
        let baseMax = Double(population) * 0.10
        let multiplier = militaryStats.recruitmentType.manpowerMultiplier
        return Int(baseMax * multiplier)
    }

    func changeRecruitmentType(militaryStats: inout MilitaryStats, to type: MilitaryStats.RecruitmentType) {
        militaryStats.recruitmentType = type
    }

    func recruit(militaryStats: inout MilitaryStats, soldiers: Int) -> Decimal {
        let recruitmentCost = militaryStats.recruitmentType.recruitmentCost
        let totalCost = Decimal(soldiers) * recruitmentCost

        // Immediate recruitment - no training delay
        militaryStats.manpower += soldiers

        // Recalculate strength
        militaryStats.strength = calculateStrength(militaryStats: militaryStats)

        return totalCost
    }

    func demobilize(militaryStats: inout MilitaryStats, soldiers: Int) -> Decimal {
        let actualDemobilize = min(soldiers, militaryStats.manpower)
        militaryStats.manpower -= actualDemobilize

        // Recalculate strength
        militaryStats.strength = calculateStrength(militaryStats: militaryStats)

        // Calculate severance cost for volunteers
        let severanceCost: Decimal = militaryStats.recruitmentType == .volunteer ? 5_000 : 0
        return Decimal(actualDemobilize) * severanceCost
    }

    // MARK: - Technology Research

    func canResearch(category: TechCategory, militaryStats: MilitaryStats) -> Bool {
        // Can't research if already at max level (10)
        guard let currentLevel = militaryStats.technologyLevels[category], currentLevel < 10 else {
            return false
        }

        // Can't research if already researching this category
        return !activeResearch.contains { $0.category == category }
    }

    func startResearch(category: TechCategory, militaryStats: MilitaryStats, currentDate: Date) -> TechnologyResearch? {
        guard canResearch(category: category, militaryStats: militaryStats) else {
            return nil
        }

        let currentLevel = militaryStats.technologyLevels[category] ?? 1
        let research = TechnologyResearch(category: category, currentLevel: currentLevel, startDate: currentDate)

        activeResearch.append(research)
        return research
    }

    func advanceResearch(days: Int, militaryStats: inout MilitaryStats) {
        for i in 0..<activeResearch.count {
            activeResearch[i].advanceProgress(days: days)
        }

        // Auto-complete any finished research
        var completedIndices: [Int] = []
        for (index, research) in activeResearch.enumerated() {
            if research.isComplete {
                completedIndices.append(index)
            }
        }

        // Remove completed research in reverse order to maintain indices
        for index in completedIndices.reversed() {
            let research = activeResearch.remove(at: index)

            // Upgrade technology level
            militaryStats.technologyLevels[research.category] = research.targetLevel

            print("✅ Research completed: \(research.category.rawValue) Level \(research.targetLevel)")
        }

        // Recalculate strength if any research completed
        if !completedIndices.isEmpty {
            militaryStats.strength = calculateStrength(militaryStats: militaryStats)
        }
    }

    func completeResearch(researchId: UUID, militaryStats: inout MilitaryStats) -> Bool {
        guard let index = activeResearch.firstIndex(where: { $0.id == researchId && $0.isComplete }) else {
            return false
        }

        let research = activeResearch.remove(at: index)

        // Upgrade technology level
        militaryStats.technologyLevels[research.category] = research.targetLevel

        // Recalculate strength
        militaryStats.strength = calculateStrength(militaryStats: militaryStats)

        return true
    }

    func cancelResearch(researchId: UUID) -> Decimal {
        guard let index = activeResearch.firstIndex(where: { $0.id == researchId }) else {
            return 0
        }

        let research = activeResearch.remove(at: index)

        // Refund 50% of cost
        return research.cost * 0.5
    }

    // MARK: - Nuclear Arsenal

    func buildWarhead(militaryStats: inout MilitaryStats) -> Decimal {
        let cost: Decimal = 500_000_000  // $500M per warhead
        militaryStats.nuclearArsenal.buildWarhead()

        // Recalculate strength
        militaryStats.strength = calculateStrength(militaryStats: militaryStats)

        return cost
    }

    func buildICBM(militaryStats: inout MilitaryStats) -> Decimal {
        let cost: Decimal = 2_000_000_000  // $2B per ICBM
        militaryStats.nuclearArsenal.buildICBM()

        // Recalculate strength
        militaryStats.strength = calculateStrength(militaryStats: militaryStats)

        return cost
    }

    func enableFirstStrike(militaryStats: inout MilitaryStats) -> Decimal {
        let cost: Decimal = 50_000_000_000  // $50B for first strike capability
        militaryStats.nuclearArsenal.enableFirstStrike()
        return cost
    }

    func enableSecondStrike(militaryStats: inout MilitaryStats) -> Decimal {
        let cost: Decimal = 100_000_000_000  // $100B for submarine-based second strike
        militaryStats.nuclearArsenal.enableSecondStrike()
        return cost
    }

    // MARK: - Budget

    func setMilitaryBudget(militaryStats: inout MilitaryStats, budget: Decimal) {
        militaryStats.militaryBudget = budget

        // Recalculate strength
        militaryStats.strength = calculateStrength(militaryStats: militaryStats)
    }

    func calculateAnnualMaintenanceCost(militaryStats: MilitaryStats) -> Decimal {
        // Maintenance = manpower cost + equipment maintenance
        let manpowerCost = Decimal(militaryStats.manpower) * militaryStats.recruitmentType.costPerSoldier
        let equipmentMaintenance = militaryStats.militaryBudget * 0.2  // 20% of budget for equipment

        return manpowerCost + equipmentMaintenance
    }
}
