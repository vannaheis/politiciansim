//
//  BudgetManager.swift
//  PoliticianSim
//
//  Manages government budget, spending, and taxation
//

import Foundation
import Combine

class BudgetManager: ObservableObject {
    @Published var currentBudget: Budget?
    @Published var budgetProposals: [BudgetProposal] = []
    @Published var budgetHistory: [Budget] = []

    init() {
        // Budget will be initialized when character reaches a position
    }

    // MARK: - Budget Creation

    func initializeBudget(for character: Character, gdp: Double? = nil) {
        guard let position = character.currentPosition else { return }

        let fiscalYear = Calendar.current.component(.year, from: character.currentDate)
        // Pass GDP to createInitialBudget so department allocations are properly sized
        var budget = Budget.createInitialBudget(fiscalYear: fiscalYear, governmentLevel: position.level, gdp: gdp)

        // Update revenue based on GDP and tax rates if available
        if let gdpValue = gdp {
            updateRevenue(budget: &budget, gdp: gdpValue, governmentLevel: position.level)
        }

        currentBudget = budget
    }

    // MARK: - Department Management

    func adjustDepartmentFunding(
        departmentId: UUID,
        newAmount: Decimal,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard var budget = currentBudget else {
            return (false, "No budget available")
        }

        guard let index = budget.departments.firstIndex(where: { $0.id == departmentId }) else {
            return (false, "Department not found")
        }

        var department = budget.departments[index]
        let difference = newAmount - department.allocatedFunds

        // Calculate new total expenses
        let newTotalExpenses = budget.totalExpenses + difference

        // Update department
        department.proposedFunds = newAmount

        // Calculate satisfaction based on funding level
        let optimalFunding = budget.totalRevenue * 0.10 // 10% is "optimal"
        let fundingRatio = Double(truncating: (newAmount / optimalFunding) as NSDecimalNumber)
        department.satisfaction = min(100, max(0, fundingRatio * 100))

        budget.departments[index] = department
        budget.totalExpenses = newTotalExpenses

        currentBudget = budget

        // Add stress for making tough decisions
        character.stress = min(100, character.stress + 2)

        return (true, "Department funding adjusted")
    }

    func applyProposedBudget(character: inout Character) -> (success: Bool, message: String) {
        guard var budget = currentBudget else {
            return (false, "No budget available")
        }

        // Apply proposed funds to all departments
        for i in 0..<budget.departments.count {
            budget.departments[i].allocatedFunds = budget.departments[i].proposedFunds
        }

        // Recalculate total expenses
        budget.totalExpenses = budget.departments.reduce(Decimal(0)) { $0 + $1.allocatedFunds }

        // Calculate approval impact
        let deficitImpact = calculateDeficitApprovalImpact(budget: budget)
        let departmentImpact = calculateDepartmentSatisfactionImpact(budget: budget)

        let totalApprovalChange = deficitImpact + departmentImpact
        character.approvalRating = max(0, min(100, character.approvalRating + totalApprovalChange))

        // Update economic indicators
        updateEconomicIndicators(budget: &budget, character: character)

        currentBudget = budget

        // Add to history
        budgetHistory.append(budget)

        return (true, "Budget enacted! Approval change: \(String(format: "%.1f", totalApprovalChange))%")
    }

    // MARK: - Tax Management

    func adjustTaxRate(
        taxType: TaxType,
        newRate: Double,
        character: inout Character,
        gdp: Double? = nil
    ) -> (success: Bool, message: String) {
        guard var budget = currentBudget else {
            return (false, "No budget available")
        }

        // Validate rate ranges
        let isValid: Bool
        switch taxType {
        case .incomeLow, .incomeMiddle:
            isValid = newRate >= 0 && newRate <= 50
        case .incomeHigh:
            isValid = newRate >= 0 && newRate <= 70
        case .corporate:
            isValid = newRate >= 0 && newRate <= 50
        case .sales:
            isValid = newRate >= 0 && newRate <= 20
        }

        guard isValid else {
            return (false, "Tax rate out of valid range")
        }

        // Store old rate for approval calculation
        let oldRate = getCurrentRate(taxType: taxType, budget: budget)

        // Apply tax rate
        switch taxType {
        case .incomeLow:
            budget.taxRates.incomeTaxLow = newRate
        case .incomeMiddle:
            budget.taxRates.incomeTaxMiddle = newRate
        case .incomeHigh:
            budget.taxRates.incomeTaxHigh = newRate
        case .corporate:
            budget.taxRates.corporateTax = newRate
        case .sales:
            budget.taxRates.salesTax = newRate
        }

        // Recalculate revenue with GDP
        let governmentLevel = character.currentPosition?.level ?? 1
        updateRevenue(budget: &budget, gdp: gdp, governmentLevel: governmentLevel)

        // Calculate approval impact
        let approvalChange = calculateTaxApprovalImpact(taxType: taxType, newRate: newRate, oldRate: oldRate)
        character.approvalRating = max(0, min(100, character.approvalRating + approvalChange))

        currentBudget = budget

        return (true, "Tax rate adjusted. Approval change: \(String(format: "%.1f", approvalChange))%")
    }

    enum TaxType {
        case incomeLow
        case incomeMiddle
        case incomeHigh
        case corporate
        case sales
    }

    private func getCurrentRate(taxType: TaxType, budget: Budget) -> Double {
        switch taxType {
        case .incomeLow: return budget.taxRates.incomeTaxLow
        case .incomeMiddle: return budget.taxRates.incomeTaxMiddle
        case .incomeHigh: return budget.taxRates.incomeTaxHigh
        case .corporate: return budget.taxRates.corporateTax
        case .sales: return budget.taxRates.salesTax
        }
    }

    // MARK: - Budget Analysis

    func getBudgetSummary() -> BudgetSummary? {
        guard let budget = currentBudget else { return nil }

        let avgSatisfaction = budget.departments.reduce(0.0) { $0 + $1.satisfaction } / Double(budget.departments.count)

        return BudgetSummary(
            totalRevenue: budget.totalRevenue,
            totalExpenses: budget.totalExpenses,
            surplus: budget.surplus,
            deficitPercentage: budget.deficitPercentage,
            averageDepartmentSatisfaction: avgSatisfaction,
            economicHealth: calculateEconomicHealth(budget: budget)
        )
    }

    struct BudgetSummary {
        let totalRevenue: Decimal
        let totalExpenses: Decimal
        let surplus: Decimal
        let deficitPercentage: Double
        let averageDepartmentSatisfaction: Double
        let economicHealth: Double // 0-100
    }

    // MARK: - Helper Methods

    private func updateRevenue(budget: inout Budget, gdp: Double? = nil, governmentLevel: Int = 1) {
        // Calculate revenue based on GDP and tax rates
        // Revenue = GDP × Tax Collection Rate × Government Share

        guard let gdpValue = gdp, gdpValue > 0 else {
            // Fallback to simple calculation if GDP not available
            let taxMultiplier = budget.taxRates.averageRate / 25.0
            let baseRevenue = budget.totalExpenses
            budget.totalRevenue = baseRevenue * Decimal(taxMultiplier)
            return
        }

        // Government share of GDP varies by level:
        // Level 1 (Mayor): ~1-2% of local GDP
        // Level 2 (Governor): ~8-12% of state GDP
        // Level 3 (Senator): ~3-5% of federal GDP (proportional)
        // Level 4 (VP): ~15-20% of federal GDP
        // Level 5 (President): ~20-25% of federal GDP

        let governmentSharePercentage: Double
        switch governmentLevel {
        case 1: governmentSharePercentage = 0.015  // 1.5% for local (Mayor)
        case 2: governmentSharePercentage = 0.10   // 10% for state (Governor)
        case 3: governmentSharePercentage = 0.04   // 4% for federal (Senator)
        case 4: governmentSharePercentage = 0.175  // 17.5% for federal (VP)
        case 5: governmentSharePercentage = 0.225  // 22.5% for federal (President)
        default: governmentSharePercentage = 0.15
        }

        // Tax efficiency: How much of theoretical revenue is actually collected
        // Average tax rate affects collection efficiency
        let averageTaxRate = budget.taxRates.averageRate / 100.0 // Convert to decimal
        let taxEfficiency = 0.75 + (averageTaxRate * 0.25) // 75-100% efficiency

        // Calculate total revenue
        let theoreticalRevenue = gdpValue * governmentSharePercentage * averageTaxRate
        let actualRevenue = theoreticalRevenue * taxEfficiency

        budget.totalRevenue = Decimal(actualRevenue)
    }

    private func calculateDeficitApprovalImpact(budget: Budget) -> Double {
        let deficitPercent = budget.deficitPercentage

        if deficitPercent < -5 { // Surplus > 5%
            return 3.0 // Good surplus = approval boost
        } else if deficitPercent < 0 { // Small surplus
            return 1.0
        } else if deficitPercent < 3 { // Small deficit
            return -1.0
        } else if deficitPercent < 10 { // Moderate deficit
            return -3.0
        } else { // Large deficit
            return -8.0
        }
    }

    private func calculateDepartmentSatisfactionImpact(budget: Budget) -> Double {
        let avgSatisfaction = budget.departments.reduce(0.0) { $0 + $1.satisfaction } / Double(budget.departments.count)

        if avgSatisfaction >= 80 {
            return 5.0
        } else if avgSatisfaction >= 60 {
            return 2.0
        } else if avgSatisfaction >= 40 {
            return -2.0
        } else {
            return -5.0
        }
    }

    private func calculateTaxApprovalImpact(taxType: TaxType, newRate: Double, oldRate: Double) -> Double {
        let change = newRate - oldRate

        switch taxType {
        case .incomeLow:
            // Raising taxes on poor hurts more
            return change < 0 ? 2.0 : -4.0
        case .incomeMiddle:
            // Middle class is largest voting bloc
            return change < 0 ? 3.0 : -5.0
        case .incomeHigh:
            // Wealthy have less votes but more influence
            return change < 0 ? -1.0 : 2.0
        case .corporate:
            // Business impact
            return change < 0 ? 1.0 : -2.0
        case .sales:
            // Everyone affected
            return change < 0 ? 2.0 : -3.0
        }
    }

    private func updateEconomicIndicators(budget: inout Budget, character: Character) {
        // Simple economic simulation
        var indicators = budget.economicIndicators

        // Deficit affects economy
        let deficitImpact = -budget.deficitPercentage * 0.1
        indicators.gdpGrowth = max(-10, min(10, indicators.gdpGrowth + deficitImpact))

        // High taxes reduce growth
        let taxBurden = budget.taxRates.averageRate - 25.0 // Above/below 25% baseline
        indicators.gdpGrowth -= taxBurden * 0.05

        // Spending affects unemployment
        let spendingLevel = Double(truncating: (budget.totalExpenses / budget.totalRevenue) as NSDecimalNumber)
        indicators.unemployment = max(0, min(25, 5.0 - (spendingLevel - 1.0) * 2.0))

        // Consumer confidence based on approval
        indicators.consumerConfidence = character.approvalRating * 0.7 + 30

        // Store deficit
        indicators.deficit = budget.totalExpenses - budget.totalRevenue

        budget.economicIndicators = indicators
    }

    private func calculateEconomicHealth(budget: Budget) -> Double {
        let indicators = budget.economicIndicators

        var health = 50.0

        // GDP growth impact
        health += indicators.gdpGrowth * 3.0

        // Unemployment impact
        health -= indicators.unemployment * 1.5

        // Inflation impact
        health -= abs(indicators.inflation - 2.0) * 2.0 // 2% is target

        // Consumer confidence impact
        health += (indicators.consumerConfidence - 50) * 0.3

        // Deficit impact
        let deficitPercent = budget.deficitPercentage
        health -= max(0, deficitPercent) * 0.5

        return max(0, min(100, health))
    }

    func getRecommendedBudgetAdjustments() -> [String] {
        guard let budget = currentBudget else { return [] }

        var recommendations: [String] = []

        // Check deficit
        if budget.deficitPercentage > 5 {
            recommendations.append("⚠️ High deficit: Consider cutting spending or raising taxes")
        } else if budget.deficitPercentage < -10 {
            recommendations.append("💰 Large surplus: Consider investing more in departments")
        }

        // Check department satisfaction
        for dept in budget.departments {
            if dept.satisfaction < 30 {
                recommendations.append("❌ \(dept.name) severely underfunded")
            }
        }

        // Check economic indicators
        if budget.economicIndicators.unemployment > 8 {
            recommendations.append("📉 High unemployment: Increase infrastructure spending")
        }

        if budget.economicIndicators.gdpGrowth < 0 {
            recommendations.append("📊 Negative GDP growth: Review economic policies")
        }

        return recommendations
    }
}
