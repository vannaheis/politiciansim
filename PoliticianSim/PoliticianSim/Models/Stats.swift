//
//  Stats.swift
//  PoliticianSim
//
//  Stat tracking and calculations
//

import Foundation

// MARK: - Stat Change Record

struct StatChange: Identifiable, Codable {
    let id: UUID
    let stat: String
    let previousValue: Int
    let newValue: Int
    let change: Int
    let reason: String
    let timestamp: Date

    init(stat: String, previousValue: Int, newValue: Int, reason: String) {
        self.id = UUID()
        self.stat = stat
        self.previousValue = previousValue
        self.newValue = newValue
        self.change = newValue - previousValue
        self.reason = reason
        self.timestamp = Date()
    }

    var changeDescription: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(change)"
    }
}

// MARK: - Approval History

struct ApprovalHistory: Identifiable, Codable {
    let id: UUID
    let date: Date
    let rating: Double
    let reason: String?

    init(date: Date, rating: Double, reason: String? = nil) {
        self.id = UUID()
        self.date = date
        self.rating = rating
        self.reason = reason
    }
}

// MARK: - Fund Transaction

struct FundTransaction: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Decimal
    let type: TransactionType
    let description: String

    enum TransactionType: String, Codable {
        case donation = "Donation"
        case fundraising = "Fundraising"
        case expense = "Expense"
        case scandal = "Scandal Penalty"
        case salary = "Salary"
    }

    init(date: Date, amount: Decimal, type: TransactionType, description: String) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.type = type
        self.description = description
    }

    var isPositive: Bool {
        amount > 0
    }
}

// MARK: - Stat Utilities

enum StatUtilities {
    /// Calculate approval impact from tax rate
    static func approvalImpactFromTaxRate(_ taxRate: Double) -> Double {
        switch taxRate {
        case 0...0.20:
            return 5.0 // +5% approval
        case 0.21...0.40:
            return 0.0 // No change
        case 0.41...0.60:
            return -10.0 // -10% approval
        default:
            return -25.0 // -25% approval (extreme taxes)
        }
    }

    /// Calculate adjusted scandal risk based on reputation
    static func adjustedScandalRisk(baseRisk: Double, reputation: Int) -> Double {
        var adjusted = baseRisk

        if reputation >= 70 {
            adjusted *= 0.7 // -30% exposure chance
        } else if reputation < 40 {
            adjusted *= 1.5 // +50% exposure chance
        }

        return min(100, max(0, adjusted))
    }

    /// Calculate health decay based on stress and age
    static func calculateHealthDecay(stress: Int, age: Int) -> Int {
        var decay = 0

        // Stress impact
        if stress > 80 {
            decay += 2
        } else if stress > 60 {
            decay += 1
        }

        // Age impact
        if age > 70 {
            decay += 2
        } else if age > 50 {
            decay += 1
        }

        return decay
    }

    /// Format large numbers (e.g., funds, population)
    static func formatLargeNumber(_ number: Decimal) -> String {
        let nsNumber = number as NSDecimalNumber
        let doubleValue = nsNumber.doubleValue

        if doubleValue >= 1_000_000_000 {
            return String(format: "$%.1fB", doubleValue / 1_000_000_000)
        } else if doubleValue >= 1_000_000 {
            return String(format: "$%.1fM", doubleValue / 1_000_000)
        } else if doubleValue >= 1_000 {
            return String(format: "$%.0fk", doubleValue / 1_000)
        } else {
            return String(format: "$%.0f", doubleValue)
        }
    }

    /// Format integer large numbers
    static func formatLargeNumber(_ number: Int) -> String {
        if number >= 1_000_000_000 {
            return String(format: "%.1fB", Double(number) / 1_000_000_000)
        } else if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.0fk", Double(number) / 1_000)
        } else {
            return String(describing: number)
        }
    }
}
