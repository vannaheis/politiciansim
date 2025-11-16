//
//  Treasury.swift
//  PoliticianSim
//
//  Government treasury and debt tracking
//

import Foundation

struct Treasury: Codable, Identifiable {
    let id: UUID
    var cashOnHand: Decimal  // Positive = surplus/reserves, Negative = debt
    var totalDebt: Decimal   // Cumulative debt (always positive)
    var totalSurplus: Decimal // Cumulative surplus accumulated (always positive)
    var interestRate: Double // Annual interest rate on debt (%)
    var history: [TreasuryEntry]

    var isInDebt: Bool {
        cashOnHand < 0
    }

    var debtToGDPRatio: Double? {
        // Will be calculated externally with GDP data
        nil
    }

    init(
        id: UUID = UUID(),
        cashOnHand: Decimal = 0,
        totalDebt: Decimal = 0,
        totalSurplus: Decimal = 0,
        interestRate: Double = 3.5, // Default 3.5% interest
        history: [TreasuryEntry] = []
    ) {
        self.id = id
        self.cashOnHand = cashOnHand
        self.totalDebt = totalDebt
        self.totalSurplus = totalSurplus
        self.interestRate = interestRate
        self.history = history
    }
}

struct TreasuryEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let fiscalYear: Int
    let cashChange: Decimal // Positive = surplus, Negative = deficit
    let endingBalance: Decimal
    let description: String

    init(
        id: UUID = UUID(),
        date: Date,
        fiscalYear: Int,
        cashChange: Decimal,
        endingBalance: Decimal,
        description: String
    ) {
        self.id = id
        self.date = date
        self.fiscalYear = fiscalYear
        self.cashChange = cashChange
        self.endingBalance = endingBalance
        self.description = description
    }
}

// MARK: - Treasury Templates

extension Treasury {
    static func createInitialTreasury(governmentLevel: Int) -> Treasury {
        // Start with modest debt based on government level
        // This reflects realistic government debt positions
        let initialDebt: Decimal

        switch governmentLevel {
        case 1: initialDebt = 50_000_000      // $50M for local
        case 2: initialDebt = 5_000_000_000   // $5B for state
        case 3: initialDebt = 100_000_000_000 // $100B for senator (proportional)
        case 4: initialDebt = 5_000_000_000_000   // $5T for VP
        case 5: initialDebt = 10_000_000_000_000  // $10T for President (realistic US debt)
        default: initialDebt = 1_000_000_000
        }

        return Treasury(
            cashOnHand: -initialDebt,
            totalDebt: initialDebt,
            totalSurplus: 0,
            interestRate: 3.5
        )
    }
}
