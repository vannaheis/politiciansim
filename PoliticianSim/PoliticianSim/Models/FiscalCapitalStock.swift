//
//  FiscalCapitalStock.swift
//  PoliticianSim
//
//  Tracks accumulated capital stocks from government spending over time
//  Implements time lags, depreciation, and persistent effects of fiscal policy
//

import Foundation

/// Tracks capital stocks accumulated from government spending
/// Different spending categories build up capital that depreciates over time
struct FiscalCapitalStock: Codable {
    // MARK: - Capital Stock Components

    /// Infrastructure capital stock (roads, bridges, transit)
    /// - Builds from infrastructure spending
    /// - Lag: 1-2 years (medium-term)
    /// - Depreciation: 10% per year
    var infrastructureStock: Double = 0

    /// Education human capital stock (skilled workforce)
    /// - Builds from education spending
    /// - Lag: 3-5 years (long-term, generational)
    /// - Depreciation: 5% per year (knowledge persists longer)
    var educationStock: Double = 0

    /// R&D/Innovation capital stock (patents, technology)
    /// - Builds from science spending
    /// - Lag: 3-5 years (long-term)
    /// - Depreciation: 8% per year (technology becomes obsolete)
    var scienceStock: Double = 0

    /// Healthcare capital stock (population health)
    /// - Builds from healthcare spending
    /// - Lag: 1-2 years (medium-term)
    /// - Depreciation: 12% per year (health degrades faster)
    var healthcareStock: Double = 0

    // MARK: - Pending Investments (Time Lags)

    /// Infrastructure projects under construction (1-2 year lag)
    var pendingInfrastructure: [PendingInvestment] = []

    /// Education investments maturing (3-5 year lag)
    var pendingEducation: [PendingInvestment] = []

    /// R&D projects in pipeline (3-5 year lag)
    var pendingScience: [PendingInvestment] = []

    /// Healthcare capacity being built (1-2 year lag)
    var pendingHealthcare: [PendingInvestment] = []

    // MARK: - Flow Effects (Immediate Impact)

    /// Tax policy effect (decays 50% per year as behavior adjusts)
    var taxEffect: Double = 0
    var taxEffectAge: Int = 0 // Years since tax change

    /// Deficit crowding-out effect (decays 20% per year)
    var crowdingOutEffect: Double = 0
    var crowdingOutAge: Int = 0

    /// Debt drag effect (decays 5% per year, very persistent)
    var debtDragEffect: Double = 0
    var debtDragAge: Int = 0

    // MARK: - Depreciation & Maturation

    /// Apply annual depreciation to all capital stocks
    mutating func applyAnnualDepreciation() {
        // Capital stock depreciation
        infrastructureStock *= 0.90  // 10% depreciation
        educationStock *= 0.95       // 5% depreciation
        scienceStock *= 0.92         // 8% depreciation
        healthcareStock *= 0.88      // 12% depreciation

        // Flow effect decay
        taxEffect *= 0.50            // 50% decay (rapid behavioral adjustment)
        taxEffectAge += 1

        crowdingOutEffect *= 0.80    // 20% decay
        crowdingOutAge += 1

        debtDragEffect *= 0.95       // 5% decay (very persistent)
        debtDragAge += 1
    }

    /// Process pending investments that have matured (called weekly)
    mutating func processPendingInvestments(currentDate: Date) {
        // Process infrastructure (1-2 year lag)
        pendingInfrastructure = pendingInfrastructure.filter { investment in
            if investment.maturityDate <= currentDate {
                infrastructureStock += investment.amount
                return false // Remove from pending
            }
            return true // Keep pending
        }

        // Process education (3-5 year lag)
        pendingEducation = pendingEducation.filter { investment in
            if investment.maturityDate <= currentDate {
                educationStock += investment.amount
                return false
            }
            return true
        }

        // Process science (3-5 year lag)
        pendingScience = pendingScience.filter { investment in
            if investment.maturityDate <= currentDate {
                scienceStock += investment.amount
                return false
            }
            return true
        }

        // Process healthcare (1-2 year lag)
        pendingHealthcare = pendingHealthcare.filter { investment in
            if investment.maturityDate <= currentDate {
                healthcareStock += investment.amount
                return false
            }
            return true
        }
    }

    /// Add new government spending to pending investments
    mutating func addSpending(
        category: Department.DepartmentCategory,
        amount: Double,
        currentDate: Date
    ) {
        switch category {
        case .infrastructure:
            // 1-2 year lag: random between 52-104 weeks
            let lagWeeks = Int.random(in: 52...104)
            let maturityDate = Calendar.current.date(byAdding: .weekOfYear, value: lagWeeks, to: currentDate)!
            pendingInfrastructure.append(PendingInvestment(amount: amount, maturityDate: maturityDate))

        case .education:
            // 3-5 year lag: random between 156-260 weeks
            let lagWeeks = Int.random(in: 156...260)
            let maturityDate = Calendar.current.date(byAdding: .weekOfYear, value: lagWeeks, to: currentDate)!
            pendingEducation.append(PendingInvestment(amount: amount, maturityDate: maturityDate))

        case .science:
            // 3-5 year lag: random between 156-260 weeks
            let lagWeeks = Int.random(in: 156...260)
            let maturityDate = Calendar.current.date(byAdding: .weekOfYear, value: lagWeeks, to: currentDate)!
            pendingScience.append(PendingInvestment(amount: amount, maturityDate: maturityDate))

        case .healthcare:
            // 1-2 year lag: random between 52-104 weeks
            let lagWeeks = Int.random(in: 52...104)
            let maturityDate = Calendar.current.date(byAdding: .weekOfYear, value: lagWeeks, to: currentDate)!
            pendingHealthcare.append(PendingInvestment(amount: amount, maturityDate: maturityDate))

        default:
            // Other departments have immediate flow effects, no capital stock
            break
        }
    }

    /// Calculate total GDP growth impact from all capital stocks
    func calculateStockEffect(population: Int) -> Double {
        guard population > 0 else { return 0 }

        var totalEffect: Double = 0

        // Infrastructure stock: 0.02% GDP growth per $1,000/capita stock
        let infraPerCapita = infrastructureStock / Double(population)
        totalEffect += (infraPerCapita / 1000.0) * 0.0002

        // Education stock: 0.03% GDP growth per $1,000/capita stock
        let eduPerCapita = educationStock / Double(population)
        totalEffect += (eduPerCapita / 1000.0) * 0.0003

        // Science stock: 0.04% GDP growth per $1,000/capita stock (highest productivity)
        let sciencePerCapita = scienceStock / Double(population)
        totalEffect += (sciencePerCapita / 1000.0) * 0.0004

        // Healthcare stock: 0.02% GDP growth per $1,000/capita stock
        let healthPerCapita = healthcareStock / Double(population)
        totalEffect += (healthPerCapita / 1000.0) * 0.0002

        return totalEffect
    }

    /// Calculate total GDP growth impact from flow effects (tax, deficit, debt)
    func calculateFlowEffect() -> Double {
        return taxEffect + crowdingOutEffect + debtDragEffect
    }

    /// Get total fiscal impact on GDP growth
    func getTotalFiscalImpact(population: Int) -> Double {
        let stockEffect = calculateStockEffect(population: population)
        let flowEffect = calculateFlowEffect()
        let total = stockEffect + flowEffect

        // Cap at ±3% annual GDP growth (stocks can have larger long-term effects)
        return min(0.03, max(-0.03, total))
    }
}

/// Represents an investment that will mature in the future
struct PendingInvestment: Codable, Identifiable {
    let id: UUID
    let amount: Double
    let maturityDate: Date

    init(amount: Double, maturityDate: Date) {
        self.id = UUID()
        self.amount = amount
        self.maturityDate = maturityDate
    }
}
