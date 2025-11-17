//
//  FiscalImpactCalculator.swift
//  PoliticianSim
//
//  Calculates how government fiscal policy (spending, taxes, deficits) affects GDP growth
//

import Foundation

struct FiscalImpactCalculator {

    // MARK: - Fiscal Multiplier Effects

    /// Calculates GDP growth impact from government spending by department
    ///
    /// **Fiscal Multiplier Theory:**
    /// - Different spending categories have different economic multipliers
    /// - Infrastructure: 1.5x (creates jobs, boosts private investment, long-term productivity)
    /// - Education: 1.3x (human capital development, productivity gains)
    /// - Healthcare: 1.2x (healthier workforce, reduced absenteeism)
    /// - Social Welfare: 1.4x (high marginal propensity to consume, immediate demand boost)
    /// - Public Safety: 1.0x (neutral, maintains order but no productivity gain)
    /// - Environment: 1.1x (sustainable growth, prevents future costs)
    /// - Justice: 0.9x (necessary but not productive)
    /// - Science/R&D: 1.8x (innovation, patents, future growth)
    /// - Culture: 0.8x (quality of life but low economic impact)
    /// - Administration: 0.6x (overhead, bureaucracy, low productivity)
    ///
    /// **Formula:**
    /// GDP Impact = Σ(Department Spending × Multiplier) / Total GDP
    static func calculateSpendingMultiplierEffect(
        budget: Budget,
        gdp: Double,
        governmentLevel: Int
    ) -> Double {
        guard gdp > 0 else { return 0 }

        var totalWeightedSpending: Double = 0

        for department in budget.departments {
            let spending = Double(truncating: department.allocatedFunds as NSDecimalNumber)
            let multiplier = getMultiplier(for: department.category, level: governmentLevel)
            totalWeightedSpending += spending * multiplier
        }

        // Convert to GDP growth impact (annualized)
        // Base formula: (weighted spending / GDP) × efficiency factor
        let spendingRatio = totalWeightedSpending / gdp
        let efficiencyFactor = 0.15 // 15% of spending flows through to GDP growth annually

        return spendingRatio * efficiencyFactor
    }

    private static func getMultiplier(for category: Department.DepartmentCategory, level: Int) -> Double {
        // Base multipliers by department type
        let baseMultiplier: Double

        switch category {
        case .infrastructure:
            baseMultiplier = 1.5
        case .education:
            baseMultiplier = 1.3
        case .healthcare:
            baseMultiplier = 1.2
        case .welfare:
            baseMultiplier = 1.4
        case .defense:
            baseMultiplier = 1.0
        case .environment:
            baseMultiplier = 1.1
        case .justice:
            baseMultiplier = 0.9
        case .science:
            baseMultiplier = 1.8
        case .culture:
            baseMultiplier = 0.8
        case .administration:
            baseMultiplier = 0.6
        }

        // Regional multiplier adjustment (local spending has higher multiplier due to less leakage)
        let regionalAdjustment: Double
        switch level {
        case 1: // Mayor - local spending, high multiplier
            regionalAdjustment = 1.2
        case 2: // Governor - state spending, moderate multiplier
            regionalAdjustment = 1.1
        case 3, 4, 5: // Federal - leakage to imports
            regionalAdjustment = 1.0
        default:
            regionalAdjustment = 1.0
        }

        return baseMultiplier * regionalAdjustment
    }

    // MARK: - Crowding Out Effect

    /// Calculates negative GDP impact from excessive deficit spending
    ///
    /// **Crowding Out Theory:**
    /// - Large deficits consume available capital and raise interest rates
    /// - This "crowds out" private investment, reducing GDP growth
    /// - Effect is non-linear: small deficits have minimal impact, large deficits are severe
    ///
    /// **Thresholds:**
    /// - Deficit < 3% of GDP: Minimal crowding out (-0.05% growth)
    /// - Deficit 3-5%: Moderate (-0.15% growth)
    /// - Deficit 5-8%: Significant (-0.35% growth)
    /// - Deficit > 8%: Severe (-0.60% growth)
    static func calculateCrowdingOutEffect(deficitPercentage: Double) -> Double {
        if deficitPercentage < 3.0 {
            return -0.0005 * deficitPercentage // Minimal impact
        } else if deficitPercentage < 5.0 {
            return -0.015 * (deficitPercentage - 3.0) - 0.0015 // Moderate
        } else if deficitPercentage < 8.0 {
            return -0.035 * (deficitPercentage - 5.0) - 0.045 // Significant
        } else {
            return -0.06 * (deficitPercentage - 8.0) - 0.15 // Severe
        }
    }

    // MARK: - Tax Effects on Growth

    /// Calculates GDP growth impact from tax policy
    ///
    /// **Tax Burden Theory:**
    /// - Income taxes affect labor supply and consumption
    /// - Corporate taxes affect business investment
    /// - Sales taxes affect consumption directly
    /// - Effects are non-linear (Laffer curve: very high taxes reduce growth AND revenue)
    ///
    /// **Optimal tax rates (minimize growth drag):**
    /// - Income (low): 10-15%
    /// - Income (middle): 20-25%
    /// - Income (high): 30-40%
    /// - Corporate: 18-25%
    /// - Sales: 5-8%
    static func calculateTaxDragEffect(taxRates: TaxRates) -> Double {
        var totalDrag: Double = 0

        // Income tax on low earners (affects consumption heavily)
        let lowIncomeDrag: Double
        if taxRates.incomeTaxLow < 10 {
            lowIncomeDrag = 0.001 // Minimal tax = slight boost
        } else if taxRates.incomeTaxLow < 15 {
            lowIncomeDrag = 0
        } else if taxRates.incomeTaxLow < 25 {
            lowIncomeDrag = -0.002 * (taxRates.incomeTaxLow - 15)
        } else {
            lowIncomeDrag = -0.004 * (taxRates.incomeTaxLow - 25) - 0.02
        }
        totalDrag += lowIncomeDrag * 0.3 // 30% weight (large population)

        // Income tax on middle class (affects labor supply and consumption)
        let middleIncomeDrag: Double
        if taxRates.incomeTaxMiddle < 20 {
            middleIncomeDrag = 0.0005
        } else if taxRates.incomeTaxMiddle < 25 {
            middleIncomeDrag = 0
        } else if taxRates.incomeTaxMiddle < 35 {
            middleIncomeDrag = -0.003 * (taxRates.incomeTaxMiddle - 25)
        } else {
            middleIncomeDrag = -0.005 * (taxRates.incomeTaxMiddle - 35) - 0.03
        }
        totalDrag += middleIncomeDrag * 0.4 // 40% weight (largest tax base)

        // Income tax on high earners (affects investment and entrepreneurship)
        let highIncomeDrag: Double
        if taxRates.incomeTaxHigh < 30 {
            highIncomeDrag = 0.001
        } else if taxRates.incomeTaxHigh < 40 {
            highIncomeDrag = -0.001 * (taxRates.incomeTaxHigh - 30)
        } else if taxRates.incomeTaxHigh < 50 {
            highIncomeDrag = -0.002 * (taxRates.incomeTaxHigh - 40) - 0.01
        } else {
            highIncomeDrag = -0.004 * (taxRates.incomeTaxHigh - 50) - 0.03
        }
        totalDrag += highIncomeDrag * 0.2 // 20% weight

        // Corporate tax (affects business investment heavily)
        let corporateDrag: Double
        if taxRates.corporateTax < 18 {
            corporateDrag = 0.002 * (18 - taxRates.corporateTax) // Boost investment
        } else if taxRates.corporateTax < 25 {
            corporateDrag = 0
        } else if taxRates.corporateTax < 35 {
            corporateDrag = -0.004 * (taxRates.corporateTax - 25)
        } else {
            corporateDrag = -0.006 * (taxRates.corporateTax - 35) - 0.04
        }
        totalDrag += corporateDrag * 0.5 // 50% weight (crucial for investment)

        // Sales tax (affects consumption directly)
        let salesDrag: Double
        if taxRates.salesTax < 5 {
            salesDrag = 0
        } else if taxRates.salesTax < 10 {
            salesDrag = -0.001 * (taxRates.salesTax - 5)
        } else {
            salesDrag = -0.003 * (taxRates.salesTax - 10) - 0.005
        }
        totalDrag += salesDrag * 0.3 // 30% weight

        return totalDrag
    }

    // MARK: - Debt-to-GDP Feedback

    /// Calculates GDP growth penalty from high debt-to-GDP ratio
    ///
    /// **Debt Sustainability Theory:**
    /// - Low debt (<60% GDP): Minimal impact
    /// - Moderate debt (60-90%): Interest payments crowd out productive spending
    /// - High debt (>90%): Debt spiral, market confidence loss, growth drag
    ///
    /// **Empirical thresholds (Reinhart-Rogoff):**
    /// - <60%: Safe zone
    /// - 60-90%: Caution zone (-0.1% per 10% increase)
    /// - >90%: Danger zone (-0.3% per 10% increase)
    static func calculateDebtDragEffect(debtToGDPRatio: Double) -> Double {
        if debtToGDPRatio < 60 {
            return 0 // Safe zone
        } else if debtToGDPRatio < 90 {
            let excessDebt = debtToGDPRatio - 60
            return -0.001 * excessDebt // -0.1% per 10% excess
        } else {
            let moderateDebt = 30.0 // 60-90% range
            let severeDebt = debtToGDPRatio - 90
            return -0.001 * moderateDebt - 0.003 * severeDebt // -0.3% per 10% above 90%
        }
    }

    // MARK: - Per-Capita Spending Effects

    /// Calculates GDP growth impact from optimal vs. suboptimal per-capita spending
    ///
    /// **Threshold Theory:**
    /// - Underfunding critical departments (education, infrastructure) hurts long-term growth
    /// - Overfunding creates waste and inefficiency
    /// - Optimal spending levels maximize productivity
    static func calculatePerCapitaSpendingEffect(
        budget: Budget,
        population: Int
    ) -> Double {
        guard population > 0 else { return 0 }

        var growthImpact: Double = 0

        for department in budget.departments {
            let perCapita = Double(truncating: department.allocatedFunds as NSDecimalNumber) / Double(population)
            let impact = getPerCapitaImpact(category: department.category, perCapita: perCapita)
            growthImpact += impact
        }

        return growthImpact / 10.0 // Average across departments
    }

    private static func getPerCapitaImpact(category: Department.DepartmentCategory, perCapita: Double) -> Double {
        // Define optimal ranges and calculate deviation penalty
        switch category {
        case .infrastructure:
            // Optimal: $1,000-$1,500/capita
            if perCapita < 500 {
                return -0.003 // Severe underfunding hurts growth
            } else if perCapita < 1000 {
                return -0.001 // Underfunding
            } else if perCapita <= 1500 {
                return 0.002 // Optimal range (growth boost)
            } else if perCapita <= 2500 {
                return 0.001 // Slight overfunding (diminishing returns)
            } else {
                return -0.001 // Waste
            }

        case .education:
            // Optimal: $2,000-$3,000/capita
            if perCapita < 1000 {
                return -0.004 // Human capital degradation
            } else if perCapita < 2000 {
                return -0.002
            } else if perCapita <= 3000 {
                return 0.003 // Optimal (strong long-term growth)
            } else if perCapita <= 4000 {
                return 0.001
            } else {
                return -0.001 // Bureaucracy
            }

        case .science:
            // Optimal: $500-$800/capita
            if perCapita < 300 {
                return -0.002 // Innovation deficit
            } else if perCapita < 500 {
                return -0.001
            } else if perCapita <= 800 {
                return 0.004 // Innovation boost (highest multiplier)
            } else if perCapita <= 1200 {
                return 0.002
            } else {
                return 0 // Diminishing returns
            }

        case .healthcare:
            // Optimal: $2,500-$4,000/capita
            if perCapita < 1500 {
                return -0.002 // Productivity loss (sick workers)
            } else if perCapita < 2500 {
                return -0.001
            } else if perCapita <= 4000 {
                return 0.002 // Healthy workforce
            } else if perCapita <= 6000 {
                return 0.001
            } else {
                return -0.001 // Over-medicalization
            }

        default:
            // Other departments have neutral long-term growth impact
            return 0
        }
    }

    // MARK: - Combined Fiscal Impact

    /// Calculates total GDP growth impact from all fiscal policy effects
    static func calculateTotalFiscalImpact(
        budget: Budget,
        gdp: Double,
        population: Int,
        governmentLevel: Int,
        debtToGDPRatio: Double
    ) -> Double {
        // 1. Fiscal multiplier effect (positive from government spending)
        let spendingEffect = calculateSpendingMultiplierEffect(
            budget: budget,
            gdp: gdp,
            governmentLevel: governmentLevel
        )

        // 2. Crowding out effect (negative from deficit spending)
        let crowdingOutEffect = calculateCrowdingOutEffect(
            deficitPercentage: budget.deficitPercentage
        )

        // 3. Tax drag effect (negative from high taxes)
        let taxEffect = calculateTaxDragEffect(taxRates: budget.taxRates)

        // 4. Debt drag effect (negative from high debt)
        let debtEffect = calculateDebtDragEffect(debtToGDPRatio: debtToGDPRatio)

        // 5. Per-capita spending optimization effect
        let perCapitaEffect = calculatePerCapitaSpendingEffect(
            budget: budget,
            population: population
        )

        // Combine all effects
        let totalEffect = spendingEffect + crowdingOutEffect + taxEffect + debtEffect + perCapitaEffect

        return totalEffect
    }
}
