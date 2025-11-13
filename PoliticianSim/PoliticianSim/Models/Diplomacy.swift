//
//  Diplomacy.swift
//  PoliticianSim
//
//  International relations and diplomatic system models
//

import Foundation

// MARK: - Country Relationship

struct CountryRelationship: Codable, Identifiable {
    let id: UUID
    let countryName: String
    var relationshipScore: Double // -100 to +100
    var tradeLevel: TradeLevel
    var treaties: [Treaty]
    var recentEvents: [DiplomaticEvent]
    var lastInteractionDate: Date?

    enum TradeLevel: String, Codable {
        case none = "No Trade"
        case limited = "Limited Trade"
        case moderate = "Moderate Trade"
        case extensive = "Extensive Trade"
        case alliance = "Trade Alliance"

        var multiplier: Double {
            switch self {
            case .none: return 0.0
            case .limited: return 0.25
            case .moderate: return 0.50
            case .extensive: return 0.75
            case .alliance: return 1.0
            }
        }
    }

    init(
        id: UUID = UUID(),
        countryName: String,
        relationshipScore: Double = 0,
        tradeLevel: TradeLevel = .none,
        treaties: [Treaty] = [],
        recentEvents: [DiplomaticEvent] = [],
        lastInteractionDate: Date? = nil
    ) {
        self.id = id
        self.countryName = countryName
        self.relationshipScore = relationshipScore
        self.tradeLevel = tradeLevel
        self.treaties = treaties
        self.recentEvents = recentEvents
        self.lastInteractionDate = lastInteractionDate
    }

    var relationshipStatus: RelationshipStatus {
        switch relationshipScore {
        case 75...100: return .ally
        case 25..<75: return .friendly
        case -25..<25: return .neutral
        case -75..<(-25): return .tense
        default: return .hostile
        }
    }

    enum RelationshipStatus: String {
        case ally = "Ally"
        case friendly = "Friendly"
        case neutral = "Neutral"
        case tense = "Tense"
        case hostile = "Hostile"

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .ally: return (0.2, 0.8, 0.2)
            case .friendly: return (0.5, 0.9, 0.5)
            case .neutral: return (0.7, 0.7, 0.7)
            case .tense: return (1.0, 0.7, 0.0)
            case .hostile: return (1.0, 0.2, 0.2)
            }
        }
    }
}

// MARK: - Treaty

struct Treaty: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: TreatyType
    let description: String
    let signedDate: Date
    var expirationDate: Date?
    var isActive: Bool
    var benefits: TreatyBenefits

    enum TreatyType: String, Codable, CaseIterable {
        case trade = "Trade Agreement"
        case defense = "Defense Pact"
        case nonAggression = "Non-Aggression Pact"
        case alliance = "Alliance"
        case cooperation = "Cooperation Agreement"
        case environmentalCooperation = "Environmental Cooperation"

        var iconName: String {
            switch self {
            case .trade: return "cart.fill"
            case .defense: return "shield.fill"
            case .nonAggression: return "hand.raised.fill"
            case .alliance: return "flag.2.crossed.fill"
            case .cooperation: return "hands.sparkles.fill"
            case .environmentalCooperation: return "leaf.fill"
            }
        }

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .trade: return (0.2, 0.8, 0.2)
            case .defense: return (0.8, 0.2, 0.2)
            case .nonAggression: return (0.5, 0.5, 0.9)
            case .alliance: return (1.0, 0.7, 0.0)
            case .cooperation: return (0.6, 0.4, 0.8)
            case .environmentalCooperation: return (0.2, 0.7, 0.2)
            }
        }
    }

    struct TreatyBenefits: Codable {
        var economicBonus: Double // Percentage GDP boost
        var approvalBonus: Double // Approval rating change
        var securityBonus: Double // Security improvement
    }

    init(
        id: UUID = UUID(),
        name: String,
        type: TreatyType,
        description: String,
        signedDate: Date,
        expirationDate: Date? = nil,
        isActive: Bool = true,
        benefits: TreatyBenefits
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.signedDate = signedDate
        self.expirationDate = expirationDate
        self.isActive = isActive
        self.benefits = benefits
    }
}

// MARK: - Diplomatic Action

struct DiplomaticAction: Identifiable {
    let id: UUID
    let type: ActionType
    let name: String
    let description: String
    let relationshipImpact: Double
    let approvalImpact: Double
    let cost: Decimal?
    let reputationCost: Int

    enum ActionType: String, CaseIterable {
        case sendDelegation = "Send Delegation"
        case offerAid = "Offer Foreign Aid"
        case proposeTreaty = "Propose Treaty"
        case imposeSanctions = "Impose Sanctions"
        case liftSanctions = "Lift Sanctions"
        case hostSummit = "Host Summit"
        case issueStatement = "Issue Statement"
        case recallAmbassador = "Recall Ambassador"

        var iconName: String {
            switch self {
            case .sendDelegation: return "airplane.departure"
            case .offerAid: return "gift.fill"
            case .proposeTreaty: return "doc.text.fill"
            case .imposeSanctions: return "xmark.shield.fill"
            case .liftSanctions: return "checkmark.shield.fill"
            case .hostSummit: return "person.3.fill"
            case .issueStatement: return "megaphone.fill"
            case .recallAmbassador: return "arrow.uturn.backward"
            }
        }
    }

    init(
        id: UUID = UUID(),
        type: ActionType,
        name: String,
        description: String,
        relationshipImpact: Double,
        approvalImpact: Double,
        cost: Decimal? = nil,
        reputationCost: Int = 0
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.description = description
        self.relationshipImpact = relationshipImpact
        self.approvalImpact = approvalImpact
        self.cost = cost
        self.reputationCost = reputationCost
    }
}

// MARK: - Diplomatic Event

struct DiplomaticEvent: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let date: Date
    let type: EventType
    var relationshipChange: Double

    enum EventType: String, Codable {
        case agreement = "Agreement Signed"
        case dispute = "Diplomatic Dispute"
        case crisis = "International Crisis"
        case cooperation = "Cooperation Milestone"
        case sanction = "Sanctions"
        case summit = "Summit Meeting"
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        date: Date,
        type: EventType,
        relationshipChange: Double = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.type = type
        self.relationshipChange = relationshipChange
    }
}

// MARK: - Foreign Policy Stance

enum ForeignPolicyStance: String, Codable, CaseIterable {
    case isolationist = "Isolationist"
    case pragmatic = "Pragmatic"
    case multilateral = "Multilateral"
    case interventionist = "Interventionist"

    var description: String {
        switch self {
        case .isolationist:
            return "Focus on domestic affairs, minimal foreign involvement"
        case .pragmatic:
            return "Balanced approach based on national interests"
        case .multilateral:
            return "Active engagement through international cooperation"
        case .interventionist:
            return "Proactive involvement in global affairs"
        }
    }

    var relationshipModifier: Double {
        switch self {
        case .isolationist: return -0.1
        case .pragmatic: return 0.0
        case .multilateral: return 0.15
        case .interventionist: return 0.1
        }
    }

    var approvalImpact: Double {
        switch self {
        case .isolationist: return 5.0
        case .pragmatic: return 0.0
        case .multilateral: return -2.0
        case .interventionist: return -5.0
        }
    }
}

// MARK: - Diplomatic Templates

extension DiplomaticAction {
    static func getAvailableActions(for relationship: CountryRelationship, character: Character) -> [DiplomaticAction] {
        var actions: [DiplomaticAction] = []

        // Send Delegation (always available)
        actions.append(DiplomaticAction(
            type: .sendDelegation,
            name: "Send Diplomatic Delegation",
            description: "Send diplomats to improve relations",
            relationshipImpact: 5.0,
            approvalImpact: 1.0,
            cost: 500_000,
            reputationCost: 0
        ))

        // Offer Aid (if relationship is not hostile)
        if relationship.relationshipScore > -50 {
            actions.append(DiplomaticAction(
                type: .offerAid,
                name: "Offer Foreign Aid",
                description: "Provide financial assistance",
                relationshipImpact: 15.0,
                approvalImpact: -2.0,
                cost: 5_000_000,
                reputationCost: 0
            ))
        }

        // Propose Treaty (if friendly or better)
        if relationship.relationshipScore > 25 {
            actions.append(DiplomaticAction(
                type: .proposeTreaty,
                name: "Propose Treaty",
                description: "Negotiate a formal agreement",
                relationshipImpact: 10.0,
                approvalImpact: 3.0,
                reputationCost: 10
            ))
        }

        // Impose Sanctions (if not already sanctioned)
        if relationship.relationshipScore < 50 {
            actions.append(DiplomaticAction(
                type: .imposeSanctions,
                name: "Impose Economic Sanctions",
                description: "Apply economic pressure",
                relationshipImpact: -25.0,
                approvalImpact: 2.0,
                reputationCost: 5
            ))
        }

        // Host Summit (if relationship is neutral or better)
        if relationship.relationshipScore > -25 && character.reputation >= 30 {
            actions.append(DiplomaticAction(
                type: .hostSummit,
                name: "Host International Summit",
                description: "Organize high-level talks",
                relationshipImpact: 20.0,
                approvalImpact: 5.0,
                cost: 2_000_000,
                reputationCost: 15
            ))
        }

        // Issue Statement (always available)
        actions.append(DiplomaticAction(
            type: .issueStatement,
            name: "Issue Public Statement",
            description: "Make diplomatic statement",
            relationshipImpact: 3.0,
            approvalImpact: 1.0,
            reputationCost: 0
        ))

        return actions
    }
}

extension Treaty {
    static func createTradeAgreement(with country: String, date: Date) -> Treaty {
        Treaty(
            name: "Trade Agreement with \(country)",
            type: .trade,
            description: "Bilateral trade agreement to reduce tariffs and increase commerce",
            signedDate: date,
            benefits: Treaty.TreatyBenefits(
                economicBonus: 2.0,
                approvalBonus: 3.0,
                securityBonus: 0.0
            )
        )
    }

    static func createDefensePact(with country: String, date: Date) -> Treaty {
        Treaty(
            name: "Defense Pact with \(country)",
            type: .defense,
            description: "Mutual defense agreement for collective security",
            signedDate: date,
            benefits: Treaty.TreatyBenefits(
                economicBonus: 0.0,
                approvalBonus: 5.0,
                securityBonus: 15.0
            )
        )
    }

    static func createNonAggressionPact(with country: String, date: Date) -> Treaty {
        Treaty(
            name: "Non-Aggression Pact with \(country)",
            type: .nonAggression,
            description: "Agreement to refrain from military action",
            signedDate: date,
            expirationDate: Calendar.current.date(byAdding: .year, value: 5, to: date),
            benefits: Treaty.TreatyBenefits(
                economicBonus: 1.0,
                approvalBonus: 2.0,
                securityBonus: 5.0
            )
        )
    }
}
