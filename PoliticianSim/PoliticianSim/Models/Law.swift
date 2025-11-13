//
//  Law.swift
//  PoliticianSim
//
//  Legislative system models for drafting, proposing, and passing laws
//

import Foundation

struct Law: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var category: LawCategory
    var sponsor: String // Character name who proposed it
    var status: LawStatus
    var dateProposed: Date
    var dateEnacted: Date?
    var votesFor: Int
    var votesAgainst: Int
    var publicSupport: Double // 0-100
    var legislativeBody: LegislativeBody
    var effects: LawEffects
    var implementationCost: Decimal?

    enum LawCategory: String, Codable, CaseIterable {
        case tax = "Taxation"
        case healthcare = "Healthcare"
        case education = "Education"
        case environment = "Environment"
        case justice = "Criminal Justice"
        case labor = "Labor & Employment"
        case infrastructure = "Infrastructure"
        case defense = "Defense & Security"
        case welfare = "Social Welfare"
        case civil = "Civil Rights"

        var iconName: String {
            switch self {
            case .tax: return "dollarsign.circle.fill"
            case .healthcare: return "cross.case.fill"
            case .education: return "book.fill"
            case .environment: return "leaf.fill"
            case .justice: return "scales"
            case .labor: return "briefcase.fill"
            case .infrastructure: return "building.2.fill"
            case .defense: return "shield.fill"
            case .welfare: return "heart.fill"
            case .civil: return "person.3.fill"
            }
        }

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .tax: return (0.2, 0.8, 0.2)
            case .healthcare: return (1.0, 0.3, 0.3)
            case .education: return (0.3, 0.6, 1.0)
            case .environment: return (0.2, 0.7, 0.2)
            case .justice: return (0.6, 0.4, 0.8)
            case .labor: return (0.8, 0.5, 0.2)
            case .infrastructure: return (0.7, 0.7, 0.2)
            case .defense: return (0.7, 0.2, 0.2)
            case .welfare: return (1.0, 0.6, 0.8)
            case .civil: return (0.5, 0.5, 1.0)
            }
        }
    }

    enum LawStatus: String, Codable {
        case draft = "Draft"
        case proposed = "Proposed"
        case inCommittee = "In Committee"
        case underDebate = "Under Debate"
        case voting = "Voting"
        case passed = "Passed"
        case enacted = "Enacted"
        case rejected = "Rejected"
        case vetoed = "Vetoed"

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .draft: return (0.6, 0.6, 0.6)
            case .proposed: return (0.4, 0.7, 1.0)
            case .inCommittee: return (0.8, 0.6, 0.2)
            case .underDebate: return (0.9, 0.5, 0.2)
            case .voting: return (1.0, 0.4, 0.4)
            case .passed: return (0.2, 0.8, 0.2)
            case .enacted: return (0.2, 0.6, 0.2)
            case .rejected: return (0.5, 0.5, 0.5)
            case .vetoed: return (0.7, 0.2, 0.2)
            }
        }
    }

    enum LegislativeBody: String, Codable {
        case cityCouncil = "City Council"
        case stateLegislature = "State Legislature"
        case congress = "Congress"
        case senate = "Senate"
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: LawCategory,
        sponsor: String,
        status: LawStatus = .draft,
        dateProposed: Date,
        dateEnacted: Date? = nil,
        votesFor: Int = 0,
        votesAgainst: Int = 0,
        publicSupport: Double = 50.0,
        legislativeBody: LegislativeBody,
        effects: LawEffects,
        implementationCost: Decimal? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.sponsor = sponsor
        self.status = status
        self.dateProposed = dateProposed
        self.dateEnacted = dateEnacted
        self.votesFor = votesFor
        self.votesAgainst = votesAgainst
        self.publicSupport = publicSupport
        self.legislativeBody = legislativeBody
        self.effects = effects
        self.implementationCost = implementationCost
    }

    var passagePercentage: Double {
        let total = votesFor + votesAgainst
        guard total > 0 else { return 0 }
        return Double(votesFor) / Double(total) * 100.0
    }
}

struct LawEffects: Codable {
    var approvalChange: Double // -50 to +50
    var economicImpact: Double // -20 to +20 (GDP %)
    var budgetImpact: Decimal // positive = cost, negative = revenue
    var statChanges: [StatChange]

    struct StatChange: Codable {
        let stat: String // "health", "education", "crime", etc.
        let change: Double
    }

    init(
        approvalChange: Double = 0,
        economicImpact: Double = 0,
        budgetImpact: Decimal = 0,
        statChanges: [StatChange] = []
    ) {
        self.approvalChange = approvalChange
        self.economicImpact = economicImpact
        self.budgetImpact = budgetImpact
        self.statChanges = statChanges
    }
}

// MARK: - Law Templates

extension Law {
    static func createTemplate(category: LawCategory, sponsor: String, date: Date, body: LegislativeBody) -> Law {
        switch category {
        case .tax:
            return Law(
                title: "Tax Reform Act",
                description: "Comprehensive reform of the tax code to adjust rates and close loopholes.",
                category: .tax,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 45.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: -5.0,
                    economicImpact: 2.0,
                    budgetImpact: 50_000_000
                ),
                implementationCost: 10_000_000
            )

        case .healthcare:
            return Law(
                title: "Universal Healthcare Act",
                description: "Establish a public healthcare option for all residents.",
                category: .healthcare,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 60.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: 10.0,
                    economicImpact: -1.0,
                    budgetImpact: 200_000_000,
                    statChanges: [
                        LawEffects.StatChange(stat: "health", change: 15.0)
                    ]
                ),
                implementationCost: 500_000_000
            )

        case .education:
            return Law(
                title: "Education Investment Act",
                description: "Increase funding for schools and teacher salaries.",
                category: .education,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 70.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: 8.0,
                    economicImpact: 1.5,
                    budgetImpact: 100_000_000,
                    statChanges: [
                        LawEffects.StatChange(stat: "education", change: 12.0)
                    ]
                ),
                implementationCost: 50_000_000
            )

        case .environment:
            return Law(
                title: "Clean Energy Transition Act",
                description: "Mandate renewable energy targets and carbon emission reductions.",
                category: .environment,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 55.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: 5.0,
                    economicImpact: -0.5,
                    budgetImpact: 150_000_000,
                    statChanges: [
                        LawEffects.StatChange(stat: "environment", change: 20.0)
                    ]
                ),
                implementationCost: 100_000_000
            )

        case .justice:
            return Law(
                title: "Criminal Justice Reform Act",
                description: "Reform sentencing guidelines and improve rehabilitation programs.",
                category: .justice,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 50.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: 3.0,
                    economicImpact: 0.5,
                    budgetImpact: 30_000_000,
                    statChanges: [
                        LawEffects.StatChange(stat: "crime", change: -8.0)
                    ]
                ),
                implementationCost: 20_000_000
            )

        case .labor:
            return Law(
                title: "Minimum Wage Increase Act",
                description: "Raise the minimum wage to a living wage standard.",
                category: .labor,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 65.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: 8.0,
                    economicImpact: -1.0,
                    budgetImpact: 0,
                    statChanges: [
                        LawEffects.StatChange(stat: "poverty", change: -10.0)
                    ]
                )
            )

        case .infrastructure:
            return Law(
                title: "Infrastructure Modernization Act",
                description: "Fund major improvements to roads, bridges, and public transportation.",
                category: .infrastructure,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 72.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: 12.0,
                    economicImpact: 3.0,
                    budgetImpact: 500_000_000,
                    statChanges: [
                        LawEffects.StatChange(stat: "infrastructure", change: 18.0)
                    ]
                ),
                implementationCost: 200_000_000
            )

        case .defense:
            return Law(
                title: "Defense Spending Authorization",
                description: "Authorize increased defense spending for national security.",
                category: .defense,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 48.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: -2.0,
                    economicImpact: 1.0,
                    budgetImpact: 300_000_000,
                    statChanges: [
                        LawEffects.StatChange(stat: "security", change: 10.0)
                    ]
                ),
                implementationCost: 100_000_000
            )

        case .welfare:
            return Law(
                title: "Social Safety Net Expansion Act",
                description: "Expand unemployment benefits, food assistance, and housing support.",
                category: .welfare,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 58.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: 7.0,
                    economicImpact: -0.5,
                    budgetImpact: 120_000_000,
                    statChanges: [
                        LawEffects.StatChange(stat: "poverty", change: -15.0)
                    ]
                ),
                implementationCost: 30_000_000
            )

        case .civil:
            return Law(
                title: "Equal Rights Protection Act",
                description: "Strengthen protections against discrimination in employment and housing.",
                category: .civil,
                sponsor: sponsor,
                dateProposed: date,
                publicSupport: 62.0,
                legislativeBody: body,
                effects: LawEffects(
                    approvalChange: 6.0,
                    economicImpact: 0.5,
                    budgetImpact: 10_000_000
                ),
                implementationCost: 5_000_000
            )
        }
    }
}

// MARK: - Legislative Session

struct LegislativeSession: Codable, Identifiable {
    let id: UUID
    var sessionNumber: Int
    var startDate: Date
    var endDate: Date
    var activeLaws: [UUID] // Law IDs currently under consideration
    var passedLaws: [UUID] // Law IDs passed this session
    var rejectedLaws: [UUID] // Law IDs rejected this session

    init(
        id: UUID = UUID(),
        sessionNumber: Int,
        startDate: Date,
        endDate: Date,
        activeLaws: [UUID] = [],
        passedLaws: [UUID] = [],
        rejectedLaws: [UUID] = []
    ) {
        self.id = id
        self.sessionNumber = sessionNumber
        self.startDate = startDate
        self.endDate = endDate
        self.activeLaws = activeLaws
        self.passedLaws = passedLaws
        self.rejectedLaws = rejectedLaws
    }
}
