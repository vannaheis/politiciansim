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

    /// Simulates realistic economic changes across all levels (federal, state, local, world)
    ///
    /// **Economic Formulas:**
    ///
    /// **Federal GDP:**
    /// - Annual growth: 1-3% (realistic US range)
    /// - Weekly rate: annualRate / 52
    /// - Formula: `newGDP = currentGDP × (1 + weeklyRate)`
    ///
    /// **Unemployment:**
    /// - Random walk model: ±0.2% per week
    /// - Federal bounds: 3-8%
    /// - State bounds: 2.5-9%
    /// - Local bounds: 2-10%
    /// - Formula: `newRate = clamp(currentRate + random(-0.2, 0.2), min, max)`
    ///
    /// **Inflation:**
    /// - Random walk: ±0.3% per week
    /// - Bounds: 1-5% (target ~2%)
    /// - Formula: `newRate = clamp(currentRate + random(-0.3, 0.3), 1.0, 5.0)`
    ///
    /// **Federal Interest Rate:**
    /// - Taylor Rule inspired: targets inflation + 2%
    /// - Gradual adjustment: 10% of gap each week
    /// - Formula: `targetRate = inflation + 2.0; newRate = currentRate + 0.1 × (targetRate - currentRate)`
    /// - Bounds: 0-10%
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
        // GDP growth (1-3% annually, converted to weekly)
        let gdpGrowthRate = Double.random(in: 0.01...0.03) / 52.0
        let newGDP = economicData.federal.gdp.current * (1 + gdpGrowthRate)
        economicData.federal.gdp.addDataPoint(date: date, value: newGDP)

        // Unemployment (random walk between 3-8%)
        let unemploymentChange = Double.random(in: -0.2...0.2)
        let newUnemployment = max(3.0, min(8.0, economicData.federal.unemploymentRate.current + unemploymentChange))
        economicData.federal.unemploymentRate.addDataPoint(date: date, value: newUnemployment)

        // Inflation (target 2%, varies between 1-5%)
        let inflationChange = Double.random(in: -0.3...0.3)
        let newInflation = max(1.0, min(5.0, economicData.federal.inflationRate.current + inflationChange))
        economicData.federal.inflationRate.addDataPoint(date: date, value: newInflation)

        // Federal interest rate (responds to inflation)
        let targetRate = economicData.federal.inflationRate.current + 2.0
        let currentRate = economicData.federal.federalInterestRate.current
        let rateAdjustment = (targetRate - currentRate) * 0.1
        let newRate = max(0.0, min(10.0, currentRate + rateAdjustment))
        economicData.federal.federalInterestRate.addDataPoint(date: date, value: newRate)
    }

    private func simulateStateEconomy(date: Date) {
        // State GDP tracks federal GDP with some variation
        let stateGrowthRate = Double.random(in: 0.008...0.035) / 52.0
        let newStateGDP = economicData.state.gdp.current * (1 + stateGrowthRate)
        economicData.state.gdp.addDataPoint(date: date, value: newStateGDP)

        // State unemployment slightly different from federal
        let unemploymentChange = Double.random(in: -0.25...0.25)
        let newStateUnemployment = max(2.5, min(9.0, economicData.state.unemploymentRate.current + unemploymentChange))
        economicData.state.unemploymentRate.addDataPoint(date: date, value: newStateUnemployment)
    }

    private func simulateLocalEconomy(date: Date) {
        // Local GDP
        let localGrowthRate = Double.random(in: 0.005...0.04) / 52.0
        let newLocalGDP = economicData.local.gdp.current * (1 + localGrowthRate)
        economicData.local.gdp.addDataPoint(date: date, value: newLocalGDP)

        // Local unemployment more volatile
        let unemploymentChange = Double.random(in: -0.3...0.3)
        let newLocalUnemployment = max(2.0, min(10.0, economicData.local.unemploymentRate.current + unemploymentChange))
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
