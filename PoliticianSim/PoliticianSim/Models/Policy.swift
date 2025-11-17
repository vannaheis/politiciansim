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
    var economicImpact: Double // -20 to +20 (DEPRECATED - use gdpGrowthImpact)
    var reputationChange: Int // -10 to +10
    var stressChange: Int // 0 to +20
    var fundsChange: Decimal // Can be negative or positive

    // New: Direct GDP growth impact (annual %, applied immediately)
    var gdpGrowthImpact: Double // -0.01 to +0.02 (annual GDP growth %)

    // New: Government stats impacts
    var governmentStatsImpacts: [Department.DepartmentCategory: Double] // Score changes per category

    init(
        approvalChange: Double = 0,
        economicImpact: Double = 0,
        reputationChange: Int = 0,
        stressChange: Int = 0,
        fundsChange: Decimal = 0,
        gdpGrowthImpact: Double = 0,
        governmentStatsImpacts: [Department.DepartmentCategory: Double] = [:]
    ) {
        self.approvalChange = approvalChange
        self.economicImpact = economicImpact
        self.reputationChange = reputationChange
        self.stressChange = stressChange
        self.fundsChange = fundsChange
        self.gdpGrowthImpact = gdpGrowthImpact
        self.governmentStatsImpacts = governmentStatsImpacts
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
                description: "Reduce taxes for small businesses to stimulate local economic growth and job creation. Boosts GDP through entrepreneurship but reduces tax revenue.",
                category: .economy,
                effects: PolicyEffects(
                    approvalChange: 8.0,
                    economicImpact: 5.0,
                    reputationChange: 3,
                    stressChange: 5,
                    fundsChange: -5_000_000_000, // $5B revenue loss
                    gdpGrowthImpact: 0.003, // +0.3% annual GDP growth (small businesses boost)
                    governmentStatsImpacts: [:]
                ),
                requirements: PolicyRequirements(
                    minPosition: 2,
                    minApproval: 30,
                    minReputation: 20,
                    costToEnact: 500_000_000 // $500M implementation cost
                ),
                supportPercentage: 65.0
            ),

            Policy(
                title: "Raise Minimum Wage",
                description: "Increase the minimum wage to $15/hour to provide better living standards for workers. May slightly reduce GDP in the short term due to business costs, but improves social welfare.",
                category: .economy,
                effects: PolicyEffects(
                    approvalChange: 12.0,
                    economicImpact: -3.0,
                    reputationChange: 5,
                    stressChange: 10,
                    fundsChange: 0,
                    gdpGrowthImpact: -0.002, // -0.2% GDP (short-term business costs, offset by consumer spending)
                    governmentStatsImpacts: [
                        .welfare: 10.0 // Improves social welfare
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 40,
                    minReputation: 30,
                    costToEnact: 200_000_000 // $200M enforcement/transition support
                ),
                supportPercentage: 58.0
            ),

            // Healthcare
            Policy(
                title: "Universal Healthcare",
                description: "Implement a comprehensive universal healthcare system for all citizens. Significant investment that boosts GDP through healthier workforce and reduces medical bankruptcies. Major improvement to healthcare system.",
                category: .healthcare,
                effects: PolicyEffects(
                    approvalChange: 15.0,
                    economicImpact: -10.0,
                    reputationChange: 8,
                    stressChange: 15,
                    fundsChange: -200_000_000_000, // $200B annual cost
                    gdpGrowthImpact: 0.005, // +0.5% GDP (healthier workforce, reduced medical bankruptcies)
                    governmentStatsImpacts: [
                        .healthcare: 25.0 // Major improvement in healthcare
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 5,
                    minApproval: 50,
                    minReputation: 50,
                    costToEnact: 50_000_000_000 // $50B implementation cost
                ),
                supportPercentage: 52.0
            ),

            Policy(
                title: "Mental Health Initiative",
                description: "Expand mental health services and reduce stigma through public programs. Modest GDP boost through reduced absenteeism and better productivity. Improves healthcare quality.",
                category: .healthcare,
                effects: PolicyEffects(
                    approvalChange: 10.0,
                    economicImpact: -2.0,
                    reputationChange: 6,
                    stressChange: 5,
                    fundsChange: -15_000_000_000, // $15B annual cost
                    gdpGrowthImpact: 0.002, // +0.2% GDP (reduced absenteeism, better productivity)
                    governmentStatsImpacts: [
                        .healthcare: 12.0 // Improve healthcare score
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 2,
                    minApproval: 35,
                    minReputation: 25,
                    costToEnact: 3_000_000_000 // $3B implementation cost
                ),
                supportPercentage: 72.0
            ),

            // Education
            Policy(
                title: "Free Community College",
                description: "Make community college tuition-free for all residents. Strong long-term GDP growth through higher skilled workforce. Significantly improves education system.",
                category: .education,
                effects: PolicyEffects(
                    approvalChange: 14.0,
                    economicImpact: 8.0,
                    reputationChange: 7,
                    stressChange: 8,
                    fundsChange: -60_000_000_000, // $60B annual cost
                    gdpGrowthImpact: 0.008, // +0.8% GDP (higher skilled workforce over time)
                    governmentStatsImpacts: [
                        .education: 18.0 // Improve education score
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 4,
                    minApproval: 45,
                    minReputation: 40,
                    costToEnact: 10_000_000_000 // $10B implementation cost
                ),
                supportPercentage: 68.0
            ),

            Policy(
                title: "Teacher Salary Increase",
                description: "Raise teacher salaries to attract and retain quality educators. Moderate GDP boost through better education quality and human capital development. Enhances education system.",
                category: .education,
                effects: PolicyEffects(
                    approvalChange: 11.0,
                    economicImpact: -4.0,
                    reputationChange: 5,
                    stressChange: 6,
                    fundsChange: -25_000_000_000, // $25B annual cost
                    gdpGrowthImpact: 0.004, // +0.4% GDP (better education quality)
                    governmentStatsImpacts: [
                        .education: 15.0 // Improve education score
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 2,
                    minApproval: 35,
                    minReputation: 25,
                    costToEnact: 5_000_000_000 // $5B implementation cost
                ),
                supportPercentage: 75.0
            ),

            // Environment
            Policy(
                title: "Green Energy Initiative",
                description: "Invest in renewable energy infrastructure and incentives. Good GDP growth from new energy sector jobs and reduced energy costs. Improves infrastructure and science research.",
                category: .environment,
                effects: PolicyEffects(
                    approvalChange: 9.0,
                    economicImpact: 6.0,
                    reputationChange: 8,
                    stressChange: 7,
                    fundsChange: -100_000_000_000, // $100B investment
                    gdpGrowthImpact: 0.006, // +0.6% GDP (new energy sector jobs, reduced energy costs)
                    governmentStatsImpacts: [
                        .infrastructure: 10.0, // Energy infrastructure improvement
                        .science: 8.0 // Research and development boost
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 40,
                    minReputation: 35,
                    costToEnact: 20_000_000_000 // $20B implementation cost
                ),
                supportPercentage: 61.0
            ),

            Policy(
                title: "Carbon Tax",
                description: "Implement a carbon tax on high-emission industries. Small GDP reduction from business costs, offset by environmental benefits. Generates significant tax revenue.",
                category: .environment,
                effects: PolicyEffects(
                    approvalChange: -5.0,
                    economicImpact: 4.0,
                    reputationChange: 4,
                    stressChange: 12,
                    fundsChange: 80_000_000_000, // $80B revenue
                    gdpGrowthImpact: -0.003, // -0.3% GDP (business costs, offset by cleaner environment)
                    governmentStatsImpacts: [:]
                ),
                requirements: PolicyRequirements(
                    minPosition: 4,
                    minApproval: 45,
                    minReputation: 40,
                    costToEnact: 2_000_000_000 // $2B enforcement infrastructure
                ),
                supportPercentage: 42.0
            ),

            // Infrastructure
            Policy(
                title: "Public Transit Expansion",
                description: "Expand and modernize public transportation systems. Strong GDP boost through reduced congestion and increased mobility. Major infrastructure improvement.",
                category: .infrastructure,
                effects: PolicyEffects(
                    approvalChange: 13.0,
                    economicImpact: 7.0,
                    reputationChange: 6,
                    stressChange: 9,
                    fundsChange: -75_000_000_000, // $75B investment
                    gdpGrowthImpact: 0.007, // +0.7% GDP (reduced congestion, increased mobility)
                    governmentStatsImpacts: [
                        .infrastructure: 20.0 // Major infrastructure improvement
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 40,
                    minReputation: 30,
                    costToEnact: 15_000_000_000 // $15B implementation cost
                ),
                supportPercentage: 70.0
            ),

            Policy(
                title: "Affordable Housing Program",
                description: "Build and subsidize affordable housing for low-income families. Moderate GDP growth from construction jobs and reduced homelessness. Improves infrastructure and social welfare.",
                category: .infrastructure,
                effects: PolicyEffects(
                    approvalChange: 16.0,
                    economicImpact: 3.0,
                    reputationChange: 7,
                    stressChange: 10,
                    fundsChange: -120_000_000_000, // $120B investment
                    gdpGrowthImpact: 0.004, // +0.4% GDP (construction jobs, reduced homelessness)
                    governmentStatsImpacts: [
                        .infrastructure: 15.0, // Housing infrastructure
                        .welfare: 12.0 // Social welfare improvement
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 4,
                    minApproval: 42,
                    minReputation: 35,
                    costToEnact: 25_000_000_000 // $25B implementation cost
                ),
                supportPercentage: 64.0
            ),

            // Social Welfare
            Policy(
                title: "Universal Basic Income Pilot",
                description: "Launch a pilot program providing basic income to low-income residents. Small GDP boost from increased consumer spending and reduced poverty. Major welfare improvement.",
                category: .socialWelfare,
                effects: PolicyEffects(
                    approvalChange: 10.0,
                    economicImpact: -8.0,
                    reputationChange: 6,
                    stressChange: 14,
                    fundsChange: -150_000_000_000, // $150B annual cost
                    gdpGrowthImpact: 0.003, // +0.3% GDP (increased consumer spending, reduced poverty)
                    governmentStatsImpacts: [
                        .welfare: 20.0 // Major welfare improvement
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 5,
                    minApproval: 48,
                    minReputation: 45,
                    costToEnact: 30_000_000_000 // $30B implementation cost
                ),
                supportPercentage: 48.0
            ),

            Policy(
                title: "Child Care Subsidy",
                description: "Subsidize child care costs for working families. Good GDP growth as more parents can work and contribute to the economy. Improves social welfare.",
                category: .socialWelfare,
                effects: PolicyEffects(
                    approvalChange: 14.0,
                    economicImpact: 2.0,
                    reputationChange: 5,
                    stressChange: 7,
                    fundsChange: -40_000_000_000, // $40B annual cost
                    gdpGrowthImpact: 0.005, // +0.5% GDP (more parents can work)
                    governmentStatsImpacts: [
                        .welfare: 15.0 // Welfare improvement
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 2,
                    minApproval: 35,
                    minReputation: 25,
                    costToEnact: 8_000_000_000 // $8B implementation cost
                ),
                supportPercentage: 73.0
            ),

            // Justice
            Policy(
                title: "Criminal Justice Reform",
                description: "Reform sentencing laws and reduce incarceration rates. Modest GDP boost from more people in workforce instead of prison. Improves justice system.",
                category: .justice,
                effects: PolicyEffects(
                    approvalChange: 6.0,
                    economicImpact: 5.0,
                    reputationChange: 8,
                    stressChange: 11,
                    fundsChange: -20_000_000_000, // $20B (rehabilitation programs, reduced prison costs)
                    gdpGrowthImpact: 0.002, // +0.2% GDP (more people in workforce instead of prison)
                    governmentStatsImpacts: [
                        .justice: 12.0 // Justice system improvement
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 42,
                    minReputation: 35,
                    costToEnact: 5_000_000_000 // $5B implementation cost
                ),
                supportPercentage: 55.0
            ),

            Policy(
                title: "Police Accountability Act",
                description: "Implement stronger oversight and accountability for law enforcement. Small GDP benefit from improved community relations and reduced civil unrest. Enhances justice system.",
                category: .justice,
                effects: PolicyEffects(
                    approvalChange: 8.0,
                    economicImpact: 0.0,
                    reputationChange: 5,
                    stressChange: 13,
                    fundsChange: -10_000_000_000, // $10B (oversight infrastructure, training)
                    gdpGrowthImpact: 0.001, // +0.1% GDP (improved community relations, reduced unrest)
                    governmentStatsImpacts: [
                        .justice: 10.0 // Justice system improvement
                    ]
                ),
                requirements: PolicyRequirements(
                    minPosition: 3,
                    minApproval: 40,
                    minReputation: 30,
                    costToEnact: 3_000_000_000 // $3B implementation cost
                ),
                supportPercentage: 59.0
            ),

            // Taxation
            Policy(
                title: "Progressive Tax Reform",
                description: "Increase taxes on high earners and reduce them for middle class. Small GDP boost as middle class spending increases offset high earner impact. Generates substantial tax revenue.",
                category: .taxation,
                effects: PolicyEffects(
                    approvalChange: 7.0,
                    economicImpact: 3.0,
                    reputationChange: 4,
                    stressChange: 12,
                    fundsChange: 120_000_000_000, // $120B revenue increase
                    gdpGrowthImpact: 0.001, // +0.1% GDP (middle class spending boost offsets high earner impact)
                    governmentStatsImpacts: [:]
                ),
                requirements: PolicyRequirements(
                    minPosition: 4,
                    minApproval: 43,
                    minReputation: 38,
                    costToEnact: 5_000_000_000 // $5B implementation cost (IRS upgrades)
                ),
                supportPercentage: 54.0
            )
        ]
    }
}
