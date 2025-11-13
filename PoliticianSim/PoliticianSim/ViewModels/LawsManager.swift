//
//  LawsManager.swift
//  PoliticianSim
//
//  Manages legislative process, law drafting, voting, and enactment
//

import Foundation
import Combine

class LawsManager: ObservableObject {
    @Published var draftLaws: [Law] = []
    @Published var activeLaws: [Law] = []
    @Published var enactedLaws: [Law] = []
    @Published var rejectedLaws: [Law] = []
    @Published var currentSession: LegislativeSession?

    init() {
        // Legislative session will be initialized when character reaches a position
    }

    // MARK: - Session Management

    func initializeSession(for character: Character) {
        guard let position = character.currentPosition else { return }

        let sessionNumber = 1
        let calendar = Calendar.current
        let startDate = character.currentDate
        let endDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate

        currentSession = LegislativeSession(
            sessionNumber: sessionNumber,
            startDate: startDate,
            endDate: endDate
        )
    }

    func getLegislativeBody(for position: Position) -> Law.LegislativeBody {
        switch position.level {
        case 1: return .cityCouncil
        case 2: return .stateLegislature
        case 3, 4: return .congress
        default: return .senate
        }
    }

    // MARK: - Law Creation

    func createLaw(
        category: Law.LawCategory,
        character: Character
    ) -> Law {
        guard let position = character.currentPosition else {
            return Law.createTemplate(
                category: category,
                sponsor: character.name,
                date: character.currentDate,
                body: .cityCouncil
            )
        }

        let body = getLegislativeBody(for: position)
        let law = Law.createTemplate(
            category: category,
            sponsor: character.name,
            date: character.currentDate,
            body: body
        )

        draftLaws.append(law)
        return law
    }

    func customizeLaw(
        lawId: UUID,
        title: String,
        description: String
    ) -> (success: Bool, message: String) {
        guard let index = draftLaws.firstIndex(where: { $0.id == lawId }) else {
            return (false, "Law not found")
        }

        draftLaws[index].title = title
        draftLaws[index].description = description

        return (true, "Law updated")
    }

    // MARK: - Legislative Process

    func proposeLaw(
        lawId: UUID,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard let index = draftLaws.firstIndex(where: { $0.id == lawId }) else {
            return (false, "Law not found")
        }

        var law = draftLaws.remove(at: index)

        // Check if character has reputation to propose
        if character.reputation < 20 {
            draftLaws.insert(law, at: index)
            return (false, "Insufficient reputation to propose laws (need 20+)")
        }

        // Propose the law
        law.status = .proposed
        activeLaws.append(law)

        // Add to session
        if var session = currentSession {
            session.activeLaws.append(law.id)
            currentSession = session
        }

        // Cost reputation
        character.reputation = max(0, character.reputation - 5)
        character.stress = min(100, character.stress + 3)

        return (true, "Law proposed successfully")
    }

    func advanceLaw(
        lawId: UUID,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard let index = activeLaws.firstIndex(where: { $0.id == lawId }) else {
            return (false, "Law not found")
        }

        var law = activeLaws[index]

        // Progress through legislative stages
        switch law.status {
        case .proposed:
            law.status = .inCommittee
            activeLaws[index] = law
            return (true, "Law sent to committee")

        case .inCommittee:
            // Committee review affects public support
            let committeeBonus = Double.random(in: -5.0...10.0)
            law.publicSupport = max(0, min(100, law.publicSupport + committeeBonus))
            law.status = .underDebate
            activeLaws[index] = law
            return (true, "Law cleared committee and is under debate")

        case .underDebate:
            // Character can lobby for support
            if character.charisma >= 70 {
                law.publicSupport += 5.0
            }
            law.status = .voting
            activeLaws[index] = law
            return (true, "Law proceeding to vote")

        case .voting:
            // Simulate vote
            let (passed, votesFor, votesAgainst) = simulateVote(law: law, character: character)
            law.votesFor = votesFor
            law.votesAgainst = votesAgainst

            activeLaws.remove(at: index)

            if passed {
                law.status = .passed
                law.dateEnacted = character.currentDate
                enactedLaws.append(law)

                // Apply effects
                applyLawEffects(law: law, character: &character)

                if var session = currentSession {
                    session.passedLaws.append(law.id)
                    session.activeLaws.removeAll { $0 == law.id }
                    currentSession = session
                }

                return (true, "Law passed! Effects applied.")
            } else {
                law.status = .rejected
                rejectedLaws.append(law)

                if var session = currentSession {
                    session.rejectedLaws.append(law.id)
                    session.activeLaws.removeAll { $0 == law.id }
                    currentSession = session
                }

                // Approval penalty for failed legislation
                character.approvalRating = max(0, character.approvalRating - 3.0)

                return (false, "Law rejected by vote")
            }

        case .draft, .passed, .enacted, .rejected, .vetoed:
            return (false, "Law cannot be advanced from current status")
        }
    }

    func withdrawLaw(
        lawId: UUID,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard let index = activeLaws.firstIndex(where: { $0.id == lawId }) else {
            return (false, "Law not found")
        }

        var law = activeLaws.remove(at: index)
        law.status = .draft
        draftLaws.append(law)

        // Slight approval penalty for withdrawing
        character.approvalRating = max(0, character.approvalRating - 1.0)

        if var session = currentSession {
            session.activeLaws.removeAll { $0 == law.id }
            currentSession = session
        }

        return (true, "Law withdrawn")
    }

    // MARK: - Voting Simulation

    private func simulateVote(law: Law, character: Character) -> (passed: Bool, votesFor: Int, votesAgainst: Int) {
        // Base vote count depends on legislative body
        let totalVotes: Int
        switch law.legislativeBody {
        case .cityCouncil: totalVotes = Int.random(in: 7...15)
        case .stateLegislature: totalVotes = Int.random(in: 40...80)
        case .congress: totalVotes = 435
        case .senate: totalVotes = 100
        }

        // Calculate support percentage
        var supportChance = law.publicSupport / 100.0

        // Character's reputation and charisma affect outcome
        let reputationBonus = Double(character.reputation) / 200.0 // 0-0.5
        let charismaBonus = Double(character.charisma) / 200.0 // 0-0.5
        supportChance += reputationBonus + charismaBonus

        // Party alignment (simplified)
        supportChance += 0.1 // Default party loyalty

        // Clamp to 0-1
        supportChance = max(0, min(1, supportChance))

        // Simulate votes
        let votesFor = Int(Double(totalVotes) * supportChance)
        let votesAgainst = totalVotes - votesFor

        // Determine if passed (majority + 1)
        let requiredVotes = (totalVotes / 2) + 1
        let passed = votesFor >= requiredVotes

        return (passed, votesFor, votesAgainst)
    }

    // MARK: - Law Effects

    private func applyLawEffects(law: Law, character: inout Character) {
        // Apply approval change
        character.approvalRating = max(0, min(100, character.approvalRating + law.effects.approvalChange))

        // Budget impact
        // (This would ideally interact with BudgetManager, but keeping it simple for now)

        // Note: Economic impact and stat changes would need to be tracked in a broader game state
        // For now, we'll just log them
        print("Law enacted: \(law.title)")
        print("- Approval change: \(law.effects.approvalChange)")
        print("- Economic impact: \(law.effects.economicImpact)%")
        print("- Budget impact: $\(law.effects.budgetImpact)")
    }

    // MARK: - Queries

    func getLawsByStatus(status: Law.LawStatus) -> [Law] {
        switch status {
        case .draft:
            return draftLaws
        case .proposed, .inCommittee, .underDebate, .voting:
            return activeLaws.filter { $0.status == status }
        case .passed, .enacted:
            return enactedLaws
        case .rejected, .vetoed:
            return rejectedLaws
        }
    }

    func getLawsByCategory(category: Law.LawCategory) -> [Law] {
        var allLaws = draftLaws + activeLaws + enactedLaws + rejectedLaws
        return allLaws.filter { $0.category == category }
    }

    func getSessionSummary() -> (proposed: Int, passed: Int, rejected: Int) {
        guard let session = currentSession else {
            return (0, 0, 0)
        }
        return (
            session.activeLaws.count,
            session.passedLaws.count,
            session.rejectedLaws.count
        )
    }

    // MARK: - Helper Methods

    func canProposeLaw(character: Character) -> Bool {
        return character.reputation >= 20
    }

    func getReputationCost() -> Int {
        return 5
    }

    func getLawCount() -> (draft: Int, active: Int, enacted: Int, rejected: Int) {
        return (
            draftLaws.count,
            activeLaws.count,
            enactedLaws.count,
            rejectedLaws.count
        )
    }

    func deleteDraftLaw(lawId: UUID) -> Bool {
        if let index = draftLaws.firstIndex(where: { $0.id == lawId }) {
            draftLaws.remove(at: index)
            return true
        }
        return false
    }
}
