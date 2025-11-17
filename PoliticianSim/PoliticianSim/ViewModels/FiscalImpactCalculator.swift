//
//  FiscalImpactCalculator.swift
//  PoliticianSim
//
//  Calculates how government fiscal policy (spending, taxes, deficits) affects GDP growth
//  Uses capital stock approach with time lags and depreciation
//

import Foundation

struct FiscalImpactCalculator {

    // MARK: - Capital Stock Investment

    /// Processes new budget spending into capital stock investments
    /// - Stock-building departments (infrastructure, education, science, healthcare) build capital over time
    /// - Flow departments (welfare, defense, etc.) have immediate multiplier effects
    static func processSpendingIntoCapitalStock(
        budget: Budget,
        capitalStock: inout FiscalCapitalStock,
        currentDate: Date,
        population: Int
    ) -> Double {
        guard population > 0 else { return 0 }

        var immediateFlowEffect: Double = 0

        for department in budget.departments {
            let spending = Double(truncating: department.allocatedFunds as NSDecimalNumber)
            let perCapita = spending / Double(population)

            switch department.category {
            // STOCK-BUILDING DEPARTMENTS (time lags apply)
            case .infrastructure, .education, .science, .healthcare:
                // Add to pending capital stock (will mature after time lag)
                // Convert per-capita spending to capital stock contribution
                let capitalContribution = perCapita * Double(population) * 0.5 // 50% converts to lasting capital
                capitalStock.addSpending(
                    category: department.category,
                    amount: capitalContribution,
                    currentDate: currentDate
                )

            // FLOW DEPARTMENTS (immediate multiplier effects)
            case .welfare:
                // High marginal propensity to consume → immediate demand boost
                immediateFlowEffect += (spending / 1_000_000_000_000) * 0.0008 // 0.08% per $1T spending

            case .defense:
                // Neutral multiplier
                immediateFlowEffect += (spending / 1_000_000_000_000) * 0.0004 // 0.04% per $1T

            case .environment:
                // Modest productivity from pollution reduction
                immediateFlowEffect += (spending / 1_000_000_000_000) * 0.0005 // 0.05% per $1T

            case .justice:
                // Minimal productivity (maintains order)
                immediateFlowEffect += (spending / 1_000_000_000_000) * 0.0002 // 0.02% per $1T

            case .culture:
                // Quality of life, minimal GDP impact
                immediateFlowEffect += (spending / 1_000_000_000_000) * 0.0001 // 0.01% per $1T

            case .administration:
                // Overhead/bureaucracy (negative productivity)
                immediateFlowEffect += (spending / 1_000_000_000_000) * 0.00005 // 0.005% per $1T
            }
        }

        // Cap immediate flow effects
        return min(0.005, max(-0.001, immediateFlowEffect))
    }

    // MARK: - Flow Effects (Immediate Impact with Decay)

    /// Updates tax drag effect (immediate impact, decays 50% per year)
    static func updateTaxEffect(
        taxRates: TaxRates,
        capitalStock: inout FiscalCapitalStock
    ) {
        var totalDrag: Double = 0

        // Income tax on low earners (affects consumption heavily)
        let lowIncomeDrag: Double
        if taxRates.incomeTaxLow < 10 {
            lowIncomeDrag = 0.0001
        } else if taxRates.incomeTaxLow < 15 {
            lowIncomeDrag = 0
        } else if taxRates.incomeTaxLow < 25 {
            lowIncomeDrag = -0.0002 * (taxRates.incomeTaxLow - 15)
        } else {
            lowIncomeDrag = -0.0004 * (taxRates.incomeTaxLow - 25) - 0.002
        }
        totalDrag += lowIncomeDrag * 0.3

        // Income tax on middle class
        let middleIncomeDrag: Double
        if taxRates.incomeTaxMiddle < 20 {
            middleIncomeDrag = 0.00005
        } else if taxRates.incomeTaxMiddle < 25 {
            middleIncomeDrag = 0
        } else if taxRates.incomeTaxMiddle < 35 {
            middleIncomeDrag = -0.0003 * (taxRates.incomeTaxMiddle - 25)
        } else {
            middleIncomeDrag = -0.0005 * (taxRates.incomeTaxMiddle - 35) - 0.003
        }
        totalDrag += middleIncomeDrag * 0.4

        // Income tax on high earners
        let highIncomeDrag: Double
        if taxRates.incomeTaxHigh < 30 {
            highIncomeDrag = 0.0001
        } else if taxRates.incomeTaxHigh < 40 {
            highIncomeDrag = -0.0001 * (taxRates.incomeTaxHigh - 30)
        } else if taxRates.incomeTaxHigh < 50 {
            highIncomeDrag = -0.0002 * (taxRates.incomeTaxHigh - 40) - 0.001
        } else {
            highIncomeDrag = -0.0004 * (taxRates.incomeTaxHigh - 50) - 0.003
        }
        totalDrag += highIncomeDrag * 0.2

        // Corporate tax
        let corporateDrag: Double
        if taxRates.corporateTax < 18 {
            corporateDrag = 0.0002 * (18 - taxRates.corporateTax)
        } else if taxRates.corporateTax < 25 {
            corporateDrag = 0
        } else if taxRates.corporateTax < 35 {
            corporateDrag = -0.0004 * (taxRates.corporateTax - 25)
        } else {
            corporateDrag = -0.0006 * (taxRates.corporateTax - 35) - 0.004
        }
        totalDrag += corporateDrag * 0.5

        // Sales tax
        let salesDrag: Double
        if taxRates.salesTax < 5 {
            salesDrag = 0
        } else if taxRates.salesTax < 10 {
            salesDrag = -0.0001 * (taxRates.salesTax - 5)
        } else {
            salesDrag = -0.0003 * (taxRates.salesTax - 10) - 0.0005
        }
        totalDrag += salesDrag * 0.3

        // Update capital stock with new tax effect (replaces old, decays over time)
        capitalStock.taxEffect = min(0.005, max(-0.015, totalDrag))
        capitalStock.taxEffectAge = 0 // Reset age
    }

    /// Updates crowding-out effect from deficit (decays 20% per year)
    static func updateCrowdingOutEffect(
        deficitPercentage: Double,
        capitalStock: inout FiscalCapitalStock
    ) {
        let effect: Double
        if deficitPercentage < 3.0 {
            effect = -0.00005 * deficitPercentage
        } else if deficitPercentage < 5.0 {
            effect = -0.0015 * (deficitPercentage - 3.0) - 0.00015
        } else if deficitPercentage < 8.0 {
            effect = -0.0035 * (deficitPercentage - 5.0) - 0.00315
        } else {
            effect = -0.006 * (deficitPercentage - 8.0) - 0.01365
        }

        capitalStock.crowdingOutEffect = effect
        capitalStock.crowdingOutAge = 0
    }

    /// Updates debt drag effect (decays 5% per year, very persistent)
    static func updateDebtDragEffect(
        debtToGDPRatio: Double,
        capitalStock: inout FiscalCapitalStock
    ) {
        let effect: Double
        if debtToGDPRatio < 60 {
            effect = 0
        } else if debtToGDPRatio < 90 {
            let excessDebt = debtToGDPRatio - 60
            effect = -0.0001 * excessDebt
        } else {
            let moderateDebt = 30.0
            let severeDebt = debtToGDPRatio - 90
            effect = -0.0001 * moderateDebt - 0.0003 * severeDebt
        }

        capitalStock.debtDragEffect = effect
        capitalStock.debtDragAge = 0
    }

    // MARK: - Main Entry Point

    /// Processes budget into capital stock system and updates all fiscal effects
    /// This is the main function called when a new budget is enacted
    static func processBudget(
        budget: Budget,
        capitalStock: inout FiscalCapitalStock,
        currentDate: Date,
        population: Int,
        debtToGDPRatio: Double
    ) -> Double {
        // 1. Process spending into capital stocks (with time lags) and get immediate flow effects
        let immediateFlowEffect = processSpendingIntoCapitalStock(
            budget: budget,
            capitalStock: &capitalStock,
            currentDate: currentDate,
            population: population
        )

        // 2. Update flow effects (tax, deficit, debt)
        updateTaxEffect(taxRates: budget.taxRates, capitalStock: &capitalStock)
        updateCrowdingOutEffect(deficitPercentage: budget.deficitPercentage, capitalStock: &capitalStock)
        updateDebtDragEffect(debtToGDPRatio: debtToGDPRatio, capitalStock: &capitalStock)

        // 3. Return total current fiscal impact (stocks + flows + immediate)
        return capitalStock.getTotalFiscalImpact(population: population) + immediateFlowEffect
    }
}
