//
//  DiplomacyManager.swift
//  PoliticianSim
//
//  Manages international relations and diplomatic actions
//

import Foundation
import Combine

class DiplomacyManager: ObservableObject {
    @Published var relationships: [CountryRelationship] = []
    @Published var activeTreaties: [Treaty] = []
    @Published var foreignPolicyStance: ForeignPolicyStance = .pragmatic
    @Published var diplomaticEvents: [DiplomaticEvent] = []

    init() {
        // Initialize with major countries
        initializeCountries()
    }

    // MARK: - Initialization

    private func initializeCountries() {
        let majorCountries = [
            ("China", 0.0),
            ("Russia", -10.0),
            ("United Kingdom", 40.0),
            ("France", 35.0),
            ("Germany", 30.0),
            ("Japan", 45.0),
            ("Canada", 50.0),
            ("Mexico", 25.0),
            ("Brazil", 15.0),
            ("India", 20.0),
            ("Australia", 45.0),
            ("South Korea", 40.0)
        ]

        relationships = majorCountries.map { country in
            CountryRelationship(
                countryName: country.0,
                relationshipScore: country.1,
                tradeLevel: country.1 > 30 ? .moderate : .limited
            )
        }
    }

    // MARK: - Relationship Management

    func getRelationship(with country: String) -> CountryRelationship? {
        return relationships.first { $0.countryName == country }
    }

    func updateRelationship(
        with country: String,
        scoreChange: Double,
        event: DiplomaticEvent? = nil
    ) {
        guard let index = relationships.firstIndex(where: { $0.countryName == country }) else {
            return
        }

        var relationship = relationships[index]
        relationship.relationshipScore = max(-100, min(100, relationship.relationshipScore + scoreChange))
        relationship.lastInteractionDate = Date()

        if let event = event {
            var eventWithChange = event
            eventWithChange.relationshipChange = scoreChange
            relationship.recentEvents.append(eventWithChange)

            // Keep only recent events (last 10)
            if relationship.recentEvents.count > 10 {
                relationship.recentEvents.removeFirst()
            }

            diplomaticEvents.append(eventWithChange)
        }

        relationships[index] = relationship

        // Update trade level based on relationship
        updateTradeLevel(for: index)
    }

    private func updateTradeLevel(for index: Int) {
        var relationship = relationships[index]
        let score = relationship.relationshipScore

        let newTradeLevel: CountryRelationship.TradeLevel
        switch score {
        case 75...100:
            newTradeLevel = .alliance
        case 50..<75:
            newTradeLevel = .extensive
        case 25..<50:
            newTradeLevel = .moderate
        case 0..<25:
            newTradeLevel = .limited
        default:
            newTradeLevel = .none
        }

        relationship.tradeLevel = newTradeLevel
        relationships[index] = relationship
    }

    // MARK: - Diplomatic Actions

    func performAction(
        _ action: DiplomaticAction,
        with country: String,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard relationships.contains(where: { $0.countryName == country }) else {
            return (false, "Country not found")
        }

        // Check reputation requirement
        if character.reputation < action.reputationCost {
            return (false, "Insufficient reputation (need \(action.reputationCost)+)")
        }

        // Check funds if required
        if let cost = action.cost {
            guard character.campaignFunds >= cost else {
                return (false, "Insufficient funds")
            }
            character.campaignFunds -= cost
        }

        // Apply reputation cost
        character.reputation = max(0, character.reputation - action.reputationCost)

        // Apply relationship impact
        let event = DiplomaticEvent(
            title: action.name,
            description: "\(action.description) with \(country)",
            date: character.currentDate,
            type: determineDiplomaticEventType(for: action.type),
            relationshipChange: action.relationshipImpact
        )

        updateRelationship(with: country, scoreChange: action.relationshipImpact, event: event)

        // Apply approval impact
        character.approvalRating = max(0, min(100, character.approvalRating + action.approvalImpact))

        // Add stress for diplomatic work
        character.stress = min(100, character.stress + 2)

        return (true, "Diplomatic action completed successfully")
    }

    private func determineDiplomaticEventType(for actionType: DiplomaticAction.ActionType) -> DiplomaticEvent.EventType {
        switch actionType {
        case .sendDelegation, .hostSummit:
            return .summit
        case .offerAid:
            return .cooperation
        case .proposeTreaty:
            return .agreement
        case .imposeSanctions:
            return .sanction
        case .liftSanctions:
            return .cooperation
        case .issueStatement:
            return .cooperation
        case .recallAmbassador:
            return .dispute
        }
    }

    // MARK: - Treaty Management

    func proposeTreaty(
        type: Treaty.TreatyType,
        with country: String,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard let relationship = getRelationship(with: country) else {
            return (false, "Country not found")
        }

        // Check if relationship is good enough
        if relationship.relationshipScore < 25 {
            return (false, "Relationship not strong enough to propose treaty")
        }

        // Check reputation
        if character.reputation < 20 {
            return (false, "Insufficient reputation (need 20+)")
        }

        // Create treaty
        let treaty: Treaty
        switch type {
        case .trade:
            treaty = Treaty.createTradeAgreement(with: country, date: character.currentDate)
        case .defense:
            treaty = Treaty.createDefensePact(with: country, date: character.currentDate)
        case .nonAggression:
            treaty = Treaty.createNonAggressionPact(with: country, date: character.currentDate)
        default:
            treaty = Treaty(
                name: "\(type.rawValue) with \(country)",
                type: type,
                description: "Formal agreement between nations",
                signedDate: character.currentDate,
                benefits: Treaty.TreatyBenefits(
                    economicBonus: 1.0,
                    approvalBonus: 2.0,
                    securityBonus: 1.0
                )
            )
        }

        // Simulate negotiation success (based on relationship and charisma)
        let successChance = (relationship.relationshipScore / 100.0) + (Double(character.charisma) / 200.0)
        let success = Double.random(in: 0...1) < successChance

        if success {
            activeTreaties.append(treaty)

            // Update relationship
            if let index = relationships.firstIndex(where: { $0.countryName == country }) {
                var rel = relationships[index]
                rel.treaties.append(treaty)
                relationships[index] = rel
            }

            // Apply benefits
            character.approvalRating = max(0, min(100, character.approvalRating + treaty.benefits.approvalBonus))

            // Record event
            let event = DiplomaticEvent(
                title: "Treaty Signed",
                description: "\(treaty.name) successfully negotiated",
                date: character.currentDate,
                type: .agreement,
                relationshipChange: 15.0
            )
            updateRelationship(with: country, scoreChange: 15.0, event: event)

            // Cost reputation
            character.reputation = max(0, character.reputation - 10)
            character.stress = min(100, character.stress + 2)  // REDUCED from +5 to +2

            return (true, "Treaty signed successfully!")
        } else {
            // Failed negotiation
            updateRelationship(with: country, scoreChange: -5.0)
            character.approvalRating = max(0, character.approvalRating - 2.0)
            character.reputation = max(0, character.reputation - 5)

            return (false, "Treaty negotiations failed")
        }
    }

    func revokeTreaty(_ treatyId: UUID, character: inout Character) -> (success: Bool, message: String) {
        guard let index = activeTreaties.firstIndex(where: { $0.id == treatyId }) else {
            return (false, "Treaty not found")
        }

        var treaty = activeTreaties.remove(at: index)
        treaty.isActive = false

        // Find country and update relationship
        if let countryIndex = relationships.firstIndex(where: { $0.treaties.contains(where: { $0.id == treatyId }) }) {
            let country = relationships[countryIndex].countryName

            // Remove treaty from country's list
            var relationship = relationships[countryIndex]
            relationship.treaties.removeAll { $0.id == treatyId }
            relationships[countryIndex] = relationship

            // Negative impact on relationship
            let event = DiplomaticEvent(
                title: "Treaty Revoked",
                description: "\(treaty.name) has been terminated",
                date: character.currentDate,
                type: .dispute,
                relationshipChange: -20.0
            )
            updateRelationship(with: country, scoreChange: -20.0, event: event)
        }

        // Approval penalty
        character.approvalRating = max(0, character.approvalRating - 5.0)

        return (true, "Treaty revoked")
    }

    // MARK: - Foreign Policy

    func changeForeignPolicyStance(_ newStance: ForeignPolicyStance, character: inout Character) {
        foreignPolicyStance = newStance

        // Apply approval impact
        character.approvalRating = max(0, min(100, character.approvalRating + newStance.approvalImpact))

        // Apply relationship modifier to all countries
        for i in 0..<relationships.count {
            let modifier = newStance.relationshipModifier * 10.0
            relationships[i].relationshipScore = max(-100, min(100, relationships[i].relationshipScore + modifier))
        }
    }

    // MARK: - Queries

    func getRelationshipsByStatus() -> [(CountryRelationship.RelationshipStatus, [CountryRelationship])] {
        var grouped: [CountryRelationship.RelationshipStatus: [CountryRelationship]] = [:]

        for relationship in relationships {
            let status = relationship.relationshipStatus
            if grouped[status] == nil {
                grouped[status] = []
            }
            grouped[status]?.append(relationship)
        }

        let order: [CountryRelationship.RelationshipStatus] = [.ally, .friendly, .neutral, .tense, .hostile]
        return order.compactMap { status in
            guard let items = grouped[status], !items.isEmpty else { return nil }
            return (status, items.sorted { $0.relationshipScore > $1.relationshipScore })
        }
    }

    func getTreatiesByType() -> [(Treaty.TreatyType, [Treaty])] {
        var grouped: [Treaty.TreatyType: [Treaty]] = [:]

        for treaty in activeTreaties {
            if grouped[treaty.type] == nil {
                grouped[treaty.type] = []
            }
            grouped[treaty.type]?.append(treaty)
        }

        return grouped.map { ($0.key, $0.value) }.sorted { $0.0.rawValue < $1.0.rawValue }
    }

    func getRecentEvents(limit: Int = 10) -> [DiplomaticEvent] {
        return Array(diplomaticEvents.suffix(limit).reversed())
    }

    func getDiplomaticSummary() -> (allies: Int, treaties: Int, averageRelationship: Double) {
        let allyCount = relationships.filter { $0.relationshipStatus == .ally }.count
        let treatyCount = activeTreaties.count
        let avgRelationship = relationships.reduce(0.0) { $0 + $1.relationshipScore } / Double(relationships.count)

        return (allyCount, treatyCount, avgRelationship)
    }
}
