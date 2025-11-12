//
//  StatManager.swift
//  PoliticianSim
//
//  Manages all character stat modifications and tracking
//

import Foundation
import Combine

class StatManager: ObservableObject {
    @Published var statChanges: [StatChange] = []
    @Published var approvalHistory: [ApprovalHistory] = []
    @Published var fundTransactions: [FundTransaction] = []

    // MARK: - Base Attribute Modifications

    func modifyStat(
        character: inout Character,
        stat: StatType,
        by amount: Int,
        reason: String
    ) {
        let previousValue: Int

        switch stat {
        case .charisma:
            previousValue = character.charisma
            character.modifyCharisma(by: amount)
        case .intelligence:
            previousValue = character.intelligence
            character.modifyIntelligence(by: amount)
        case .reputation:
            previousValue = character.reputation
            character.modifyReputation(by: amount)
        case .luck:
            previousValue = character.luck
            character.modifyLuck(by: amount)
        case .diplomacy:
            previousValue = character.diplomacy
            character.modifyDiplomacy(by: amount)
        }

        recordStatChange(
            stat: stat.rawValue,
            previousValue: previousValue,
            newValue: getCurrentStatValue(character, stat: stat),
            reason: reason
        )
    }

    private func getCurrentStatValue(_ character: Character, stat: StatType) -> Int {
        switch stat {
        case .charisma: return character.charisma
        case .intelligence: return character.intelligence
        case .reputation: return character.reputation
        case .luck: return character.luck
        case .diplomacy: return character.diplomacy
        }
    }

    // MARK: - Approval Management

    func modifyApproval(
        character: inout Character,
        by amount: Double,
        reason: String
    ) {
        character.modifyApproval(by: amount)

        approvalHistory.append(
            ApprovalHistory(
                date: character.currentDate,
                rating: character.approvalRating,
                reason: reason
            )
        )
    }

    // MARK: - Fund Management

    func addFunds(
        character: inout Character,
        amount: Decimal,
        source: String
    ) {
        character.addFunds(amount)

        fundTransactions.append(
            FundTransaction(
                date: character.currentDate,
                amount: amount,
                type: .donation,
                description: source
            )
        )
    }

    func spendFunds(
        character: inout Character,
        amount: Decimal,
        purpose: String
    ) throws {
        try character.spendFunds(amount)

        fundTransactions.append(
            FundTransaction(
                date: character.currentDate,
                amount: -amount,
                type: .expense,
                description: purpose
            )
        )
    }

    // MARK: - History Tracking

    func initializeHistory(for character: Character) {
        approvalHistory.append(
            ApprovalHistory(
                date: character.currentDate,
                rating: character.approvalRating,
                reason: "Character created"
            )
        )

        fundTransactions.append(
            FundTransaction(
                date: character.currentDate,
                amount: character.campaignFunds,
                type: .salary,
                description: "Starting funds"
            )
        )
    }

    private func recordStatChange(
        stat: String,
        previousValue: Int,
        newValue: Int,
        reason: String
    ) {
        statChanges.append(
            StatChange(
                stat: stat,
                previousValue: previousValue,
                newValue: newValue,
                reason: reason
            )
        )
    }

    func recordApprovalIfChanged(character: Character) {
        if let lastApproval = approvalHistory.last,
           lastApproval.rating != character.approvalRating {
            approvalHistory.append(
                ApprovalHistory(
                    date: character.currentDate,
                    rating: character.approvalRating
                )
            )
        }
    }

    // MARK: - Clear History

    func clearHistory() {
        statChanges.removeAll()
        approvalHistory.removeAll()
        fundTransactions.removeAll()
    }
}

// MARK: - Stat Type Enum

enum StatType: String {
    case charisma = "Charisma"
    case intelligence = "Intelligence"
    case reputation = "Reputation"
    case luck = "Luck"
    case diplomacy = "Diplomacy"
}
