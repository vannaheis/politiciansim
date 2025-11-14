//
//  EconomicDataManager.swift
//  PoliticianSim
//
//  Manages economic data and simulates economic changes
//

import Foundation
import Combine

class EconomicDataManager: ObservableObject {
    @Published var economicData: EconomicData

    init() {
        self.economicData = EconomicData()
    }

    // MARK: - Economic Simulation

    /// Simulates realistic economic changes with interdependent relationships
    ///
    /// **Economic Interdependencies:**
    ///
    /// **Phillips Curve (Unemployment ↔ Inflation):**
    /// - Inverse relationship: Lower unemployment → Higher inflation
    /// - When unemployment drops 1%, inflation increases ~0.5%
    /// - Natural rate of unemployment (NAIRU): ~4.5%
    ///
    /// **Okun's Law (GDP ↔ Unemployment):**
    /// - Inverse relationship: Higher GDP growth → Lower unemployment
    /// - 1% GDP growth above trend → 0.5% unemployment reduction
    /// - Trend growth rate: ~2% annually
    ///
    /// **Federal Interest Rate (Taylor Rule):**
    /// - Targets: inflation + 2% + 0.5×(inflation - 2%) + 0.5×output gap
    /// - Responds to both inflation and unemployment
    /// - Higher rates slow GDP growth and increase unemployment
    ///
    /// **Interest Rate Impact on GDP (Symmetric):**
    /// - Neutral rate: 5% (no effect on growth)
    /// - Rates above 5% → Lower GDP growth (monetary tightening)
    /// - Rates below 5% → Higher GDP growth (monetary stimulus)
    /// - Each 1% rate deviation changes GDP growth by ±0.3%
    /// - Example: 0% rates boost growth by +1.5%, 10% rates slow growth by -1.5%
    ///
    /// **Inflation Dynamics:**
    /// - Base: Phillips curve effect from unemployment
    /// - Momentum: Previous inflation inertia (0.7 weight)
    /// - Shock: Random supply/demand shocks (±0.2%)
    ///
    /// **World GDPs:**
    /// - Developed economies (GDP ≥ $2T): 1-3% annual growth
    /// - Emerging economies (GDP < $2T): 3-7% annual growth
    /// - Rankings automatically resort after each update
    func simulateEconomicChanges(character: Character) {
        let currentDate = character.currentDate

        // Simulate federal economic changes
        simulateFederalEconomy(date: currentDate)

        // Simulate state economic changes
        simulateStateEconomy(date: currentDate)

        // Simulate local economic changes
        simulateLocalEconomy(date: currentDate)

        // Simulate world GDP changes
        simulateWorldEconomy()
    }

    private func simulateFederalEconomy(date: Date) {
        let currentGDP = economicData.federal.gdp.current
        let currentUnemployment = economicData.federal.unemploymentRate.current
        let currentInflation = economicData.federal.inflationRate.current
        let currentInterestRate = economicData.federal.federalInterestRate.current

        // Constants
        let trendGrowthRate = 0.02 // 2% annual trend growth
        let naturalUnemployment = 4.5 // NAIRU (Non-Accelerating Inflation Rate of Unemployment)
        let inflationTarget = 2.0

        // 1. Calculate GDP growth with interest rate impact
        // Interest rates affect GDP growth symmetrically:
        // - Rates above neutral (5%) slow growth (monetary tightening)
        // - Rates below neutral (5%) boost growth (monetary stimulus)
        let neutralRate = 5.0
        let baseGrowthRate = Double.random(in: 0.015...0.025) // 1.5-2.5% base
        let rateEffect = (currentInterestRate - neutralRate) * 0.003 // ±0.3% per 1% rate deviation
        let annualGrowthRate = baseGrowthRate - rateEffect
        let weeklyGrowthRate = annualGrowthRate / 52.0
        let newGDP = currentGDP * (1 + weeklyGrowthRate)

        // 2. Update unemployment using Okun's Law
        // Unemployment changes inversely with GDP growth above trend
        let gdpGap = (annualGrowthRate - trendGrowthRate) * 100 // in percentage points
        let unemploymentChange = -0.5 * gdpGap / 52.0 // Okun's coefficient: -0.5
        let randomShock = Double.random(in: -0.08...0.08)
        let newUnemployment = max(3.0, min(8.0, currentUnemployment + unemploymentChange + randomShock))

        // 3. Update inflation using Phillips Curve
        // Inflation increases when unemployment is below natural rate
        let unemploymentGap = naturalUnemployment - newUnemployment
        let phillipsCurveEffect = 0.5 * unemploymentGap / 52.0 // Phillips coefficient: 0.5
        let inflationMomentum = currentInflation * 0.7 // Inflation persistence
        let inflationShock = Double.random(in: -0.15...0.15)
        let newInflation = max(1.0, min(5.0,
            inflationMomentum * 0.3 + phillipsCurveEffect + inflationShock + inflationTarget * 0.1))

        // 4. Update interest rate using Taylor Rule
        // Fed responds to inflation gap and unemployment gap
        let inflationGap = newInflation - inflationTarget
        let outputGap = (naturalUnemployment - newUnemployment) / naturalUnemployment
        let taylorTarget = inflationTarget + 1.5 * inflationGap + 0.5 * outputGap * 100
        let targetRate = max(0.0, min(10.0, taylorTarget))
        let rateAdjustment = (targetRate - currentInterestRate) * 0.15 // Gradual adjustment
        let newRate = max(0.0, min(10.0, currentInterestRate + rateAdjustment))

        // Save all updates
        economicData.federal.gdp.addDataPoint(date: date, value: newGDP)
        economicData.federal.unemploymentRate.addDataPoint(date: date, value: newUnemployment)
        economicData.federal.inflationRate.addDataPoint(date: date, value: newInflation)
        economicData.federal.federalInterestRate.addDataPoint(date: date, value: newRate)
    }

    private func simulateStateEconomy(date: Date) {
        // State economy correlates with federal but has regional variation
        let federalUnemployment = economicData.federal.unemploymentRate.current
        let federalGDP = economicData.federal.gdp.current

        // Get federal GDP growth (compare to history)
        let federalGrowth: Double
        if economicData.federal.gdp.history.count >= 2 {
            let prev = economicData.federal.gdp.history[economicData.federal.gdp.history.count - 2].value
            federalGrowth = (federalGDP - prev) / prev
        } else {
            federalGrowth = 0.02 / 52.0
        }

        // State GDP tracks federal with regional multiplier
        let regionalMultiplier = Double.random(in: 0.9...1.1)
        let stateGrowthRate = federalGrowth * regionalMultiplier
        let newStateGDP = economicData.state.gdp.current * (1 + stateGrowthRate)

        // State unemployment tracks federal with lag and variation
        let stateUnemploymentTarget = federalUnemployment + Double.random(in: -0.5...0.5)
        let unemploymentAdjustment = (stateUnemploymentTarget - economicData.state.unemploymentRate.current) * 0.3
        let newStateUnemployment = max(2.5, min(9.0, economicData.state.unemploymentRate.current + unemploymentAdjustment))

        economicData.state.gdp.addDataPoint(date: date, value: newStateGDP)
        economicData.state.unemploymentRate.addDataPoint(date: date, value: newStateUnemployment)
    }

    private func simulateLocalEconomy(date: Date) {
        // Local economy correlates with state but more volatile
        let stateUnemployment = economicData.state.unemploymentRate.current
        let stateGDP = economicData.state.gdp.current

        // Get state GDP growth
        let stateGrowth: Double
        if economicData.state.gdp.history.count >= 2 {
            let prev = economicData.state.gdp.history[economicData.state.gdp.history.count - 2].value
            stateGrowth = (stateGDP - prev) / prev
        } else {
            stateGrowth = 0.02 / 52.0
        }

        // Local GDP more volatile than state
        let localMultiplier = Double.random(in: 0.7...1.3)
        let localGrowthRate = stateGrowth * localMultiplier
        let newLocalGDP = economicData.local.gdp.current * (1 + localGrowthRate)

        // Local unemployment tracks state with more variation
        let localUnemploymentTarget = stateUnemployment + Double.random(in: -1.0...1.0)
        let unemploymentAdjustment = (localUnemploymentTarget - economicData.local.unemploymentRate.current) * 0.4
        let newLocalUnemployment = max(2.0, min(10.0, economicData.local.unemploymentRate.current + unemploymentAdjustment))

        economicData.local.gdp.addDataPoint(date: date, value: newLocalGDP)
        economicData.local.unemploymentRate.addDataPoint(date: date, value: newLocalUnemployment)
    }

    private func simulateWorldEconomy() {
        // Simulate GDP growth for each country
        for i in 0..<economicData.worldGDPs.count {
            // Different countries have different growth rates
            // Developed economies: 1-3% annually
            // Emerging economies: 3-7% annually
            let isDeveloped = economicData.worldGDPs[i].gdp >= 2_000_000_000_000
            let growthRange = isDeveloped ? (0.01...0.03) : (0.03...0.07)
            let annualGrowthRate = Double.random(in: growthRange)
            let weeklyGrowthRate = annualGrowthRate / 52.0

            let currentGDP = economicData.worldGDPs[i].gdp
            let newGDP = currentGDP * (1 + weeklyGrowthRate)
            economicData.worldGDPs[i].gdp = newGDP
        }

        // Re-sort by GDP (descending) to maintain rankings
        economicData.worldGDPs.sort { $0.gdp > $1.gdp }
    }

    // MARK: - Formatting Helpers

    func formatGDP(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.2fM", value / 1_000_000)
        } else {
            return String(format: "$%.2fK", value / 1_000)
        }
    }

    func formatPercentage(_ value: Double, decimals: Int = 1) -> String {
        return String(format: "%.\(decimals)f%%", value)
    }

    func formatPopulation(_ value: Int) -> String {
        if value >= 1_000_000_000 {
            return String(format: "%.2fB", Double(value) / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "%.1fM", Double(value) / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fK", Double(value) / 1_000)
        } else {
            return String(value)
        }
    }
}
