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
        // Base strength from manpower
        let baseStrength = Double(militaryStats.manpower) * 0.5

        // Technology bonus (average tech level × 10,000)
        let avgTechLevel = calculateAverageTechLevel(militaryStats: militaryStats)
        let techBonus = avgTechLevel * 10_000

        // Budget bonus (military budget / $10B)
        let budgetBonus = Double(truncating: militaryStats.militaryBudget as NSNumber) / 10_000_000_000

        // Calculate tech multipliers
        var techMultiplier = 1.0
        for (category, level) in militaryStats.technologyLevels {
            let categoryContribution = (Double(level) / 10.0) * (category.strengthMultiplier - 1.0)
            techMultiplier += categoryContribution
        }

        let totalStrength = (baseStrength + techBonus + budgetBonus) * techMultiplier
        return Int(totalStrength)
    }

    func calculateAverageTechLevel(militaryStats: MilitaryStats) -> Double {
        let levels = militaryStats.technologyLevels.values
        guard !levels.isEmpty else { return 1.0 }
        let sum = levels.reduce(0, +)
        return Double(sum) / Double(levels.count)
    }

    // MARK: - Recruitment

    func changeRecruitmentType(militaryStats: inout MilitaryStats, to type: MilitaryStats.RecruitmentType) {
        militaryStats.recruitmentType = type
    }

    func recruit(militaryStats: inout MilitaryStats, soldiers: Int) -> Decimal {
        let costPerSoldier = militaryStats.recruitmentType.costPerSoldier
        let totalCost = Decimal(soldiers) * costPerSoldier

        militaryStats.manpower += soldiers

        // Recalculate strength
        militaryStats.strength = calculateStrength(militaryStats: militaryStats)

        return totalCost
    }

    func demobilize(militaryStats: inout MilitaryStats, soldiers: Int) {
        militaryStats.manpower = max(0, militaryStats.manpower - soldiers)

        // Recalculate strength
        militaryStats.strength = calculateStrength(militaryStats: militaryStats)
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
