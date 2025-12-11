//
//  ReparationAgreement.swift
//  PoliticianSim
//
//  Reparations payment tracking for war outcomes
//

import Foundation

struct ReparationAgreement: Codable, Identifiable {
    let id: UUID
    let payerCountry: String        // Country code paying reparations
    let recipientCountry: String    // Country code receiving reparations
    let totalAmount: Decimal        // Total reparations amount
    let yearlyPayment: Decimal      // Annual payment
    let startDate: Date
    var yearsPaid: Int
    let totalYears: Int
    let warId: UUID                 // Reference to originating war

    init(
        payerCountry: String,
        recipientCountry: String,
        totalAmount: Decimal,
        startDate: Date,
        warId: UUID,
        totalYears: Int = 10
    ) {
        self.id = UUID()
        self.payerCountry = payerCountry
        self.recipientCountry = recipientCountry
        self.totalAmount = totalAmount
        self.yearlyPayment = totalAmount / Decimal(totalYears)
        self.startDate = startDate
        self.yearsPaid = 0
        self.totalYears = totalYears
        self.warId = warId
    }

    var isComplete: Bool {
        yearsPaid >= totalYears
    }

    var remainingAmount: Decimal {
        totalAmount - (yearlyPayment * Decimal(yearsPaid))
    }

    var progressPercent: Double {
        Double(truncating: (Decimal(yearsPaid) / Decimal(totalYears)) as NSNumber)
    }

    var formattedTotalAmount: String {
        formatMoney(totalAmount)
    }

    var formattedYearlyPayment: String {
        formatMoney(yearlyPayment)
    }

    var formattedRemainingAmount: String {
        formatMoney(remainingAmount)
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 1

        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000_000_000))T"
        } else if value >= 1_000_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000_000))B"
        } else if value >= 1_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000))M"
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }
}
