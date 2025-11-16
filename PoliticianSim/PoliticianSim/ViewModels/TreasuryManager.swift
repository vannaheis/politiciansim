//
//  TreasuryManager.swift
//  PoliticianSim
//
//  Manages government treasury operations
//

import Foundation
import Combine

class TreasuryManager: ObservableObject {
    @Published var currentTreasury: Treasury?

    init() {
        // Treasury will be initialized when character reaches a position
    }

    // MARK: - Treasury Creation

    func initializeTreasury(for character: Character) {
        guard let position = character.currentPosition else { return }

        let treasury = Treasury.createInitialTreasury(governmentLevel: position.level)
        currentTreasury = treasury
    }

    // MARK: - Budget Application

    func applyBudgetResult(
        surplus: Decimal,
        fiscalYear: Int,
        character: Character
    ) {
        guard var treasury = currentTreasury else { return }

        // Apply surplus/deficit to cash on hand
        treasury.cashOnHand += surplus

        // Track cumulative totals
        if surplus > 0 {
            // Surplus - add to cumulative surplus
            treasury.totalSurplus += surplus
        } else if surplus < 0 {
            // Deficit - add to cumulative debt
            let deficit = abs(surplus)
            treasury.totalDebt += deficit
        }

        // Record entry
        let entry = TreasuryEntry(
            date: character.currentDate,
            fiscalYear: fiscalYear,
            cashChange: surplus,
            endingBalance: treasury.cashOnHand,
            description: surplus > 0 ? "Budget Surplus" : "Budget Deficit"
        )
        treasury.history.append(entry)

        currentTreasury = treasury
    }

    // MARK: - Interest on Debt

    func applyAnnualInterest(character: Character) {
        guard var treasury = currentTreasury else { return }

        // Only apply interest if in debt
        guard treasury.cashOnHand < 0 else { return }

        let debt = abs(treasury.cashOnHand)
        let annualInterest = Decimal(treasury.interestRate / 100.0) * debt

        // Interest increases debt
        treasury.cashOnHand -= annualInterest
        treasury.totalDebt += annualInterest

        // Record interest payment
        let fiscalYear = Calendar.current.component(.year, from: character.currentDate)
        let entry = TreasuryEntry(
            date: character.currentDate,
            fiscalYear: fiscalYear,
            cashChange: -annualInterest,
            endingBalance: treasury.cashOnHand,
            description: "Annual Debt Interest (\(String(format: "%.1f", treasury.interestRate))%)"
        )
        treasury.history.append(entry)

        currentTreasury = treasury
    }

    // MARK: - Treasury Analysis

    func getTreasurySummary(gdp: Double?) -> TreasurySummary? {
        guard let treasury = currentTreasury else { return nil }

        let currentBalance = treasury.cashOnHand
        let isInDebt = currentBalance < 0
        let absoluteAmount = abs(currentBalance)

        var debtToGDPRatio: Double? = nil
        if let gdpValue = gdp, gdpValue > 0, isInDebt {
            let debtDouble = Double(truncating: absoluteAmount as NSDecimalNumber)
            debtToGDPRatio = (debtDouble / gdpValue) * 100.0
        }

        let annualInterestPayment: Decimal
        if isInDebt {
            annualInterestPayment = Decimal(treasury.interestRate / 100.0) * absoluteAmount
        } else {
            annualInterestPayment = 0
        }

        return TreasurySummary(
            currentBalance: currentBalance,
            isInDebt: isInDebt,
            totalDebt: treasury.totalDebt,
            totalSurplus: treasury.totalSurplus,
            interestRate: treasury.interestRate,
            annualInterestPayment: annualInterestPayment,
            debtToGDPRatio: debtToGDPRatio,
            recentEntries: Array(treasury.history.suffix(10).reversed())
        )
    }

    struct TreasurySummary {
        let currentBalance: Decimal
        let isInDebt: Bool
        let totalDebt: Decimal
        let totalSurplus: Decimal
        let interestRate: Double
        let annualInterestPayment: Decimal
        let debtToGDPRatio: Double?
        let recentEntries: [TreasuryEntry]
    }

    // MARK: - Helper Methods

    func adjustInterestRate(newRate: Double) {
        guard var treasury = currentTreasury else { return }
        treasury.interestRate = max(0, min(20, newRate)) // Clamp between 0-20%
        currentTreasury = treasury
    }
}
