//
//  Policy.swift
//  PoliticianSim
//
//  Policy models for the game
//

import Foundation

struct Policy: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: PolicyCategory
    let effects: PolicyEffects
    let requirements: PolicyRequirements
    var status: PolicyStatus
    var enactedDate: Date?
    var supportPercentage: Double // Public support 0-100

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: PolicyCategory,
        effects: PolicyEffects,
        requirements: PolicyRequirements,
        status: PolicyStatus = .proposed,
        enactedDate: Date? = nil,
        supportPercentage: Double = 50.0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.effects = effects
        self.requirements = requirements
        self.status = status
        self.enactedDate = enactedDate
        self.supportPercentage = supportPercentage
    }

    enum PolicyStatus: String, Codable {
        case proposed
        case debating
        case enacted
        case rejected
        case repealed
    }

    enum PolicyCategory: String, Codable, CaseIterable {
        case economy = "Economy"
        case healthcare = "Healthcare"
        case education = "Education"
        case environment = "Environment"
        case justice = "Justice"
        case infrastructure = "Infrastructure"
        case defense = "Defense"
        case socialWelfare = "Social Welfare"
        case immigration = "Immigration"
        case taxation = "Taxation"

        var iconName: String {
            switch self {
            case .economy: return "chart.line.uptrend.xyaxis"
            case .healthcare: return "cross.case.fill"
            case .education: return "book.fill"
            case .environment: return "leaf.fill"
            case .justice: return "scales"
            case .infrastructure: return "building.2.fill"
            case .defense: return "shield.fill"
            case .socialWelfare: return "heart.fill"
            case .immigration: return "globe.americas.fill"
            case .taxation: return "dollarsign.circle.fill"
            }
        }

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .economy: return (0.0, 0.8, 0.4)
            case .healthcare: return (1.0, 0.3, 0.3)
            case .education: return (0.3, 0.6, 1.0)
            case .environment: return (0.2, 0.8, 0.2)
            case .justice: return (0.6, 0.4, 0.8)
            case .infrastructure: return (0.8, 0.5, 0.2)
            case .defense: return (0.7, 0.2, 0.2)
            case .socialWelfare: return (1.0, 0.6, 0.8)
            case .immigration: return (0.4, 0.7, 0.9)
            case .taxation: return (0.9, 0.7, 0.2)
            }
        }
    }
}

struct PolicyEffects: Codable {
    var approvalChange: Double // -30 to +30
    var economicImpact: Double // -20 to +20
    var reputationChange: Int // -10 to +10
    var stressChange: Int // 0 to +20
    var fundsChange: Decimal // Can be negative or positive

    init(
        approvalChange: Double = 0,
        economicImpact: Double = 0,
        reputationChange: Int = 0,
        stressChange: Int = 0,
        fundsChange: Decimal = 0
    ) {
        self.approvalChange = approvalChange
        self.economicImpact = economicImpact
        self.reputationChange = reputationChange
        self.stressChange = stressChange
        self.fundsChange = fundsChange
    }
}

struct PolicyRequirements: Codable {
    var minPosition: Int // Position level required
    var minApproval: Double // Minimum approval rating
    var minReputation: Int // Minimum reputation
    var costToEnact: Decimal // Budget cost

    init(
        minPosition: Int = 1,
        minApproval: Double = 0,
        minReputation: Int = 0,
        costToEnact: Decimal = 0
    ) {
        self.minPosition = minPosition
        self.minApproval = minApproval
        self.minReputation = minReputation
        self.costToEnact = costToEnact
    }
}

// MARK: - Policy Templates

extension Policy {
    static func getAvailablePolicies() -> [Policy] {
        return [
            // Economy
            Policy(
                title: "Small Business Tax Relief",
                description: "Reduce taxes for small businesses to stimulate local economic growth.",
                category: .economy,
                effects: PolicyEffects(
                    approvalChange: 8.0,
                    economicImpact: 5.0,
                    reputationChange: 3,
                    stressChange: 5,
                    fundsChange: -50000
                ),
                requirements: PolicyRequirements(
                    minPosition: 2,
                    minApproval: 30,
                    minReputation: 20,
                    costToEnact: 50000
                ),
                supportPercentage: 65.0
            ),

            Policy(
                title: "Raise Minimum Wage",
                description: "Increase the minimum wage to provide better living standards for workers.",
                category: .economy,
                effects: PolicyEffects(
                    approvalChange: 12.0,
                    economicImpact: -3.0,
                    reputationChange: 5,
                    stressChange: 10,
                    fundsChange: 0
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 40,
                    minReputation: 30,
                    costToEnact: 0
                ),
                supportPercentage: 58.0
            ),

            // Healthcare
            Policy(
                title: "Universal Healthcare",
                description: "Implement a comprehensive universal healthcare system for all citizens.",
                category: .healthcare,
                effects: PolicyEffects(
                    approvalChange: 15.0,
                    economicImpact: -10.0,
                    reputationChange: 8,
                    stressChange: 15,
                    fundsChange: -500000
                ),
                requirements: PolicyRequirements(
                    minPosition: 5,
                    minApproval: 50,
                    minReputation: 50,
                    costToEnact: 500000
                ),
                supportPercentage: 52.0
            ),

            Policy(
                title: "Mental Health Initiative",
                description: "Expand mental health services and reduce stigma through public programs.",
                category: .healthcare,
                effects: PolicyEffects(
                    approvalChange: 10.0,
                    economicImpact: -2.0,
                    reputationChange: 6,
                    stressChange: 5,
                    fundsChange: -100000
                ),
                requirements: PolicyRequirements(
                    minPosition: 2,
                    minApproval: 35,
                    minReputation: 25,
                    costToEnact: 100000
                ),
                supportPercentage: 72.0
            ),

            // Education
            Policy(
                title: "Free Community College",
                description: "Make community college tuition-free for all residents.",
                category: .education,
                effects: PolicyEffects(
                    approvalChange: 14.0,
                    economicImpact: 8.0,
                    reputationChange: 7,
                    stressChange: 8,
                    fundsChange: -300000
                ),
                requirements: PolicyRequirements(
                    minPosition: 4,
                    minApproval: 45,
                    minReputation: 40,
                    costToEnact: 300000
                ),
                supportPercentage: 68.0
            ),

            Policy(
                title: "Teacher Salary Increase",
                description: "Raise teacher salaries to attract and retain quality educators.",
                category: .education,
                effects: PolicyEffects(
                    approvalChange: 11.0,
                    economicImpact: -4.0,
                    reputationChange: 5,
                    stressChange: 6,
                    fundsChange: -150000
                ),
                requirements: PolicyRequirements(
                    minPosition: 2,
                    minApproval: 35,
                    minReputation: 25,
                    costToEnact: 150000
                ),
                supportPercentage: 75.0
            ),

            // Environment
            Policy(
                title: "Green Energy Initiative",
                description: "Invest in renewable energy infrastructure and incentives.",
                category: .environment,
                effects: PolicyEffects(
                    approvalChange: 9.0,
                    economicImpact: 6.0,
                    reputationChange: 8,
                    stressChange: 7,
                    fundsChange: -400000
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 40,
                    minReputation: 35,
                    costToEnact: 400000
                ),
                supportPercentage: 61.0
            ),

            Policy(
                title: "Carbon Tax",
                description: "Implement a carbon tax on high-emission industries.",
                category: .environment,
                effects: PolicyEffects(
                    approvalChange: -5.0,
                    economicImpact: 4.0,
                    reputationChange: 4,
                    stressChange: 12,
                    fundsChange: 200000
                ),
                requirements: PolicyRequirements(
                    minPosition: 4,
                    minApproval: 45,
                    minReputation: 40,
                    costToEnact: 0
                ),
                supportPercentage: 42.0
            ),

            // Infrastructure
            Policy(
                title: "Public Transit Expansion",
                description: "Expand and modernize public transportation systems.",
                category: .infrastructure,
                effects: PolicyEffects(
                    approvalChange: 13.0,
                    economicImpact: 7.0,
                    reputationChange: 6,
                    stressChange: 9,
                    fundsChange: -350000
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 40,
                    minReputation: 30,
                    costToEnact: 350000
                ),
                supportPercentage: 70.0
            ),

            Policy(
                title: "Affordable Housing Program",
                description: "Build and subsidize affordable housing for low-income families.",
                category: .infrastructure,
                effects: PolicyEffects(
                    approvalChange: 16.0,
                    economicImpact: 3.0,
                    reputationChange: 7,
                    stressChange: 10,
                    fundsChange: -450000
                ),
                requirements: PolicyRequirements(
                    minPosition: 4,
                    minApproval: 42,
                    minReputation: 35,
                    costToEnact: 450000
                ),
                supportPercentage: 64.0
            ),

            // Social Welfare
            Policy(
                title: "Universal Basic Income Pilot",
                description: "Launch a pilot program providing basic income to low-income residents.",
                category: .socialWelfare,
                effects: PolicyEffects(
                    approvalChange: 10.0,
                    economicImpact: -8.0,
                    reputationChange: 6,
                    stressChange: 14,
                    fundsChange: -600000
                ),
                requirements: PolicyRequirements(
                    minPosition: 5,
                    minApproval: 48,
                    minReputation: 45,
                    costToEnact: 600000
                ),
                supportPercentage: 48.0
            ),

            Policy(
                title: "Child Care Subsidy",
                description: "Subsidize child care costs for working families.",
                category: .socialWelfare,
                effects: PolicyEffects(
                    approvalChange: 14.0,
                    economicImpact: 2.0,
                    reputationChange: 5,
                    stressChange: 7,
                    fundsChange: -200000
                ),
                requirements: PolicyRequirements(
                    minPosition: 2,
                    minApproval: 35,
                    minReputation: 25,
                    costToEnact: 200000
                ),
                supportPercentage: 73.0
            ),

            // Justice
            Policy(
                title: "Criminal Justice Reform",
                description: "Reform sentencing laws and reduce incarceration rates.",
                category: .justice,
                effects: PolicyEffects(
                    approvalChange: 6.0,
                    economicImpact: 5.0,
                    reputationChange: 8,
                    stressChange: 11,
                    fundsChange: -80000
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 42,
                    minReputation: 35,
                    costToEnact: 80000
                ),
                supportPercentage: 55.0
            ),

            Policy(
                title: "Police Accountability Act",
                description: "Implement stronger oversight and accountability for law enforcement.",
                category: .justice,
                effects: PolicyEffects(
                    approvalChange: 8.0,
                    economicImpact: 0.0,
                    reputationChange: 5,
                    stressChange: 13,
                    fundsChange: -50000
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 40,
                    minReputation: 30,
                    costToEnact: 50000
                ),
                supportPercentage: 59.0
            ),

            // Taxation
            Policy(
                title: "Progressive Tax Reform",
                description: "Increase taxes on high earners and reduce them for middle class.",
                category: .taxation,
                effects: PolicyEffects(
                    approvalChange: 7.0,
                    economicImpact: 3.0,
                    reputationChange: 4,
                    stressChange: 12,
                    fundsChange: 300000
                ),
                requirements: PolicyRequirements(
                    minPosition: 4,
                    minApproval: 43,
                    minReputation: 38,
                    costToEnact: 0
                ),
                supportPercentage: 54.0
            )
        ]
    }
}
