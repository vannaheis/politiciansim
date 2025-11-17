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

    // Track accumulated capital stocks from government spending
    var fiscalCapitalStock: FiscalCapitalStock = FiscalCapitalStock()

    init() {
        self.economicData = EconomicData()
    }

    // MARK: - Fiscal Policy Integration

    /// Apply fiscal policy effects when budget is enacted
    /// Processes spending into capital stocks with time lags
    func applyFiscalPolicy(
        budget: Budget,
        population: Int,
        governmentLevel: Int,
        debtToGDPRatio: Double,
        currentDate: Date
    ) {
        // Process budget into capital stock system
        _ = FiscalImpactCalculator.processBudget(
            budget: budget,
            capitalStock: &fiscalCapitalStock,
            currentDate: currentDate,
            population: population,
            debtToGDPRatio: debtToGDPRatio
        )
    }

    /// Get current fiscal impact on GDP growth
    /// This is called every week during economic simulation
    func getFiscalGrowthModifier(population: Int) -> Double {
        return fiscalCapitalStock.getTotalFiscalImpact(population: population)
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
    /// **Fiscal Policy Impact on GDP:**
    /// - Government spending affects GDP through fiscal multipliers
    /// - Different departments have different multipliers (infrastructure 1.5x, R&D 1.8x, etc.)
    /// - Deficits cause "crowding out" that reduces private investment
    /// - High taxes create drag on growth through reduced incentives
    /// - High debt-to-GDP ratios (>90%) severely harm growth
    /// - Per-capita spending thresholds optimize productivity
    ///
    /// **Inflation Dynamics:**
    /// - Base: Phillips curve effect from unemployment
    /// - Momentum: Previous inflation inertia (0.7 weight)
    /// - Shock: Random supply/demand shocks (±0.2%)
    ///
    /// **World GDPs (Economic Convergence Theory):**
    /// - Growth rates based on GDP per capita (development level):
    ///   - High income (>$40k/capita): 1.5-2.5% growth (USA, Germany, UK)
    ///   - Upper-middle income ($13k-$40k): 3-5% growth (China)
    ///   - Lower-middle income ($4k-$13k): 4-7% growth (India)
    ///   - Low income (<$4k): 5-8% growth (frontier markets)
    /// - Size penalty: Economies >$20T GDP grow 0.2% slower
    /// - Reflects catch-up growth: poorer countries grow faster
    /// - Rankings automatically resort after each update
    ///
    /// **Population Growth (Demographic Transition Theory):**
    /// - Growth rates decline as countries develop (inverse relationship with GDP per capita):
    ///   - High income (>$40k/capita): 0.2-0.5% annual growth (mature, aging populations)
    ///   - Upper-middle income ($13k-$40k): 0.3-0.8% growth (declining fertility)
    ///   - Lower-middle income ($4k-$13k): 0.8-1.3% growth (demographic dividend)
    ///   - Low income (<$4k): 1.5-2.5% growth (high fertility, young populations)
    /// - Reflects demographic transition: developing countries have higher birth rates
    /// - Population rankings update as countries grow at different rates
    func simulateEconomicChanges(character: Character) {
        let currentDate = character.currentDate

        // Process pending fiscal investments (capital stocks maturing)
        fiscalCapitalStock.processPendingInvestments(currentDate: currentDate)

        // Check if it's been a full year (365 days) since last depreciation to apply annual effects
        if let lastDepreciation = economicData.lastDepreciationDate {
            let daysSinceLastDepreciation = Calendar.current.dateComponents([.day], from: lastDepreciation, to: currentDate).day ?? 0

            // Apply depreciation once per 365 days
            if daysSinceLastDepreciation >= 365 {
                // Apply annual depreciation to capital stocks
                fiscalCapitalStock.applyAnnualDepreciation()
                economicData.lastDepreciationDate = currentDate
            }
        } else {
            economicData.lastDepreciationDate = currentDate
        }

        // Get US population for fiscal growth calculations
        let usPopulation = getUSPopulation()

        // Simulate federal economic changes
        simulateFederalEconomy(date: currentDate, population: usPopulation)

        // Simulate state economic changes
        simulateStateEconomy(date: currentDate)

        // Simulate local economic changes
        simulateLocalEconomy(date: currentDate)

        // Simulate world GDP changes
        simulateWorldEconomy()
    }

    private func getUSPopulation() -> Int {
        if let usa = economicData.worldGDPs.first(where: { $0.countryCode == "USA" }) {
            return usa.population
        }
        return 335_000_000 // Default
    }

    private func simulateFederalEconomy(date: Date, population: Int) {
        let currentGDP = economicData.federal.gdp.current
        let currentUnemployment = economicData.federal.unemploymentRate.current
        let currentInflation = economicData.federal.inflationRate.current
        let currentInterestRate = economicData.federal.federalInterestRate.current

        // Constants
        let trendGrowthRate = 0.02 // 2% annual trend growth
        let naturalUnemployment = 4.5 // NAIRU (Non-Accelerating Inflation Rate of Unemployment)
        let inflationTarget = 2.0

        // 1. Calculate GDP growth with interest rate impact + fiscal policy
        // Interest rates affect GDP growth symmetrically:
        // - Rates above neutral (5%) slow growth (monetary tightening)
        // - Rates below neutral (5%) boost growth (monetary stimulus)
        let neutralRate = 5.0
        let baseGrowthRate = Double.random(in: 0.015...0.025) // 1.5-2.5% base
        let rateEffect = (currentInterestRate - neutralRate) * 0.003 // ±0.3% per 1% rate deviation

        // Add fiscal policy impact (government spending, taxes, deficit effects from capital stocks)
        let fiscalModifier = getFiscalGrowthModifier(population: population)
        let annualGrowthRate = baseGrowthRate - rateEffect + fiscalModifier
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

        // Inflation dynamics: persistence + Phillips curve + target anchor + shock
        let inflationPersistence = currentInflation * 0.7 // 70% of current inflation carries forward
        let targetAnchor = inflationTarget * 0.3 // 30% weight on 2% target (anchors expectations)
        let inflationShock = Double.random(in: -0.1...0.1)

        let newInflation = max(1.0, min(5.0,
            inflationPersistence + targetAnchor + phillipsCurveEffect + inflationShock))

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

        // Synchronize federal GDP with USA entry in worldGDPs
        // This ensures home view and world rankings show the same GDP (including fiscal effects)
        if let usaIndex = economicData.worldGDPs.firstIndex(where: { $0.countryCode == "USA" }) {
            economicData.worldGDPs[usaIndex].gdp = newGDP
        }
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
        // Simulate GDP and population growth based on economic/demographic theories
        // GDP: Smaller/developing economies grow faster (catch-up growth)
        // Population: Developing countries have higher birth rates (demographic transition)

        // Create a mutable copy to work with
        var updatedCountries = economicData.worldGDPs

        for i in 0..<updatedCountries.count {
            let currentGDP = updatedCountries[i].gdp
            let currentPopulation = updatedCountries[i].population
            let gdpPerCapita = updatedCountries[i].gdpPerCapita

            // === GDP GROWTH ===
            // Determine GDP growth based on development level (GDP per capita)
            // High income (>$40k): 1.5-2.5% annual growth (mature economies)
            // Upper-middle income ($13k-$40k): 3-5% annual growth
            // Lower-middle income ($4k-$13k): 4-7% annual growth
            // Low income (<$4k): 5-8% annual growth (catch-up growth)

            let annualGDPGrowthRate: Double
            if gdpPerCapita >= 40_000 {
                // Mature developed economies (USA, Germany, UK)
                annualGDPGrowthRate = Double.random(in: 0.015...0.025)
            } else if gdpPerCapita >= 13_000 {
                // Upper-middle income (China, some Eastern Europe)
                annualGDPGrowthRate = Double.random(in: 0.03...0.05)
            } else if gdpPerCapita >= 4_000 {
                // Lower-middle income (India, some emerging markets)
                annualGDPGrowthRate = Double.random(in: 0.04...0.07)
            } else {
                // Low income (frontier markets)
                annualGDPGrowthRate = Double.random(in: 0.05...0.08)
            }

            // Economic size penalty: very large economies grow slightly slower
            let sizePenalty = currentGDP >= 20_000_000_000_000 ? 0.002 : 0.0
            let adjustedGDPGrowthRate = max(0.01, annualGDPGrowthRate - sizePenalty)

            let weeklyGDPGrowthRate = adjustedGDPGrowthRate / 52.0
            let newGDP = currentGDP * (1 + weeklyGDPGrowthRate)

            // === POPULATION GROWTH (Demographic Transition Theory) ===
            // Population growth DECLINES as countries develop (inverse of GDP growth)
            // High income: 0.2-0.5% annual growth (aging populations, low fertility)
            // Upper-middle: 0.3-0.8% growth (fertility declining)
            // Lower-middle: 0.8-1.3% growth (demographic dividend phase)
            // Low income: 1.5-2.5% growth (high fertility, young populations)

            let annualPopulationGrowthRate: Double
            if gdpPerCapita >= 40_000 {
                // Developed countries: aging populations, low/negative growth
                annualPopulationGrowthRate = Double.random(in: 0.002...0.005)
            } else if gdpPerCapita >= 13_000 {
                // Upper-middle: declining fertility as development increases
                annualPopulationGrowthRate = Double.random(in: 0.003...0.008)
            } else if gdpPerCapita >= 4_000 {
                // Lower-middle: demographic dividend phase
                annualPopulationGrowthRate = Double.random(in: 0.008...0.013)
            } else {
                // Low income: high fertility, young populations
                annualPopulationGrowthRate = Double.random(in: 0.015...0.025)
            }

            let weeklyPopulationGrowthRate = annualPopulationGrowthRate / 52.0
            let newPopulation = Int(Double(currentPopulation) * (1 + weeklyPopulationGrowthRate))

            // Update both GDP and population
            updatedCountries[i].gdp = newGDP
            updatedCountries[i].population = newPopulation
        }

        // Re-sort by GDP (descending) to maintain rankings
        updatedCountries.sort { $0.gdp > $1.gdp }

        // Reassign to trigger @Published update (SwiftUI needs this to detect changes)
        economicData.worldGDPs = updatedCountries

        // Manually trigger objectWillChange to ensure SwiftUI updates
        objectWillChange.send()
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
