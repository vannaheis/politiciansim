//
//  Budget.swift
//  PoliticianSim
//
//  Budget management models for the game
//

import Foundation

struct Budget: Codable, Identifiable {
    let id: UUID
    var fiscalYear: Int
    var totalRevenue: Decimal
    var totalExpenses: Decimal  // Department expenses only
    var interestPayment: Decimal // Annual interest on debt
    var reparationPayments: Decimal // Annual war reparation payments owed
    var departments: [Department]
    var taxRates: TaxRates
    var economicIndicators: EconomicIndicators

    var totalExpensesWithInterest: Decimal {
        totalExpenses + interestPayment + reparationPayments
    }

    var surplus: Decimal {
        totalRevenue - totalExpensesWithInterest
    }

    var deficitPercentage: Double {
        guard totalRevenue > 0 else { return 0 }
        let deficit = totalExpensesWithInterest - totalRevenue
        return Double(truncating: (deficit / totalRevenue * 100) as NSDecimalNumber)
    }

    init(
        id: UUID = UUID(),
        fiscalYear: Int,
        totalRevenue: Decimal = 0,
        totalExpenses: Decimal = 0,
        interestPayment: Decimal = 0,
        reparationPayments: Decimal = 0,
        departments: [Department] = [],
        taxRates: TaxRates = TaxRates(),
        economicIndicators: EconomicIndicators = EconomicIndicators()
    ) {
        self.id = id
        self.fiscalYear = fiscalYear
        self.totalRevenue = totalRevenue
        self.totalExpenses = totalExpenses
        self.interestPayment = interestPayment
        self.reparationPayments = reparationPayments
        self.departments = departments
        self.taxRates = taxRates
        self.economicIndicators = economicIndicators
    }
}

struct Department: Codable, Identifiable {
    let id: UUID
    let name: String
    let category: DepartmentCategory
    var allocatedFunds: Decimal
    var proposedFunds: Decimal
    let description: String
    var satisfaction: Double // 0-100, based on funding level

    enum DepartmentCategory: String, Codable, CaseIterable {
        case education = "Education"
        case healthcare = "Healthcare"
        case defense = "Defense"
        case infrastructure = "Infrastructure"
        case welfare = "Social Welfare"
        case environment = "Environment"
        case justice = "Justice"
        case science = "Science & Research"
        case culture = "Arts & Culture"
        case administration = "Administration"
        case military = "Military"

        var iconName: String {
            switch self {
            case .education: return "book.fill"
            case .healthcare: return "cross.case.fill"
            case .defense: return "shield.fill"
            case .infrastructure: return "building.2.fill"
            case .welfare: return "heart.fill"
            case .environment: return "leaf.fill"
            case .justice: return "scales"
            case .science: return "flask.fill"
            case .culture: return "theatermasks.fill"
            case .administration: return "building.columns.fill"
            case .military: return "flag.fill"
            }
        }

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .education: return (0.3, 0.6, 1.0)
            case .healthcare: return (1.0, 0.3, 0.3)
            case .defense: return (0.7, 0.2, 0.2)
            case .infrastructure: return (0.8, 0.5, 0.2)
            case .welfare: return (1.0, 0.6, 0.8)
            case .environment: return (0.2, 0.8, 0.2)
            case .justice: return (0.6, 0.4, 0.8)
            case .science: return (0.4, 0.7, 0.9)
            case .culture: return (0.9, 0.7, 0.4)
            case .administration: return (0.6, 0.6, 0.6)
            case .military: return (0.5, 0.1, 0.1)
            }
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        category: DepartmentCategory,
        allocatedFunds: Decimal,
        proposedFunds: Decimal,
        description: String,
        satisfaction: Double = 50.0
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.allocatedFunds = allocatedFunds
        self.proposedFunds = proposedFunds
        self.description = description
        self.satisfaction = satisfaction
    }
}

struct TaxRates: Codable {
    var incomeTaxLow: Double      // 0-50%, affects low income citizens
    var incomeTaxMiddle: Double   // 0-50%, affects middle class
    var incomeTaxHigh: Double     // 0-70%, affects wealthy
    var corporateTax: Double      // 0-50%, affects businesses
    var salesTax: Double          // 0-20%, affects everyone

    init(
        incomeTaxLow: Double = 10.0,
        incomeTaxMiddle: Double = 22.0,
        incomeTaxHigh: Double = 37.0,
        corporateTax: Double = 21.0,
        salesTax: Double = 7.0
    ) {
        self.incomeTaxLow = incomeTaxLow
        self.incomeTaxMiddle = incomeTaxMiddle
        self.incomeTaxHigh = incomeTaxHigh
        self.corporateTax = corporateTax
        self.salesTax = salesTax
    }

    var averageRate: Double {
        (incomeTaxLow + incomeTaxMiddle + incomeTaxHigh + corporateTax + salesTax) / 5.0
    }
}

struct EconomicIndicators: Codable {
    var gdpGrowth: Double          // -10% to +10%
    var unemployment: Double       // 0-25%
    var inflation: Double          // -5% to +20%
    var consumerConfidence: Double // 0-100
    var deficit: Decimal

    init(
        gdpGrowth: Double = 2.5,
        unemployment: Double = 5.0,
        inflation: Double = 2.0,
        consumerConfidence: Double = 65.0,
        deficit: Decimal = 0
    ) {
        self.gdpGrowth = gdpGrowth
        self.unemployment = unemployment
        self.inflation = inflation
        self.consumerConfidence = consumerConfidence
        self.deficit = deficit
    }
}

struct BudgetProposal: Codable, Identifiable {
    let id: UUID
    let proposedBy: String
    let proposalDate: Date
    var departments: [Department]
    var taxRates: TaxRates
    var totalProposedSpending: Decimal
    var estimatedRevenue: Decimal
    var status: ProposalStatus
    var approvalRating: Double? // Public approval of this budget

    enum ProposalStatus: String, Codable {
        case draft = "Draft"
        case submitted = "Submitted"
        case approved = "Approved"
        case rejected = "Rejected"
        case enacted = "Enacted"
    }

    var projectedDeficit: Decimal {
        totalProposedSpending - estimatedRevenue
    }

    init(
        id: UUID = UUID(),
        proposedBy: String,
        proposalDate: Date,
        departments: [Department],
        taxRates: TaxRates,
        totalProposedSpending: Decimal,
        estimatedRevenue: Decimal,
        status: ProposalStatus = .draft,
        approvalRating: Double? = nil
    ) {
        self.id = id
        self.proposedBy = proposedBy
        self.proposalDate = proposalDate
        self.departments = departments
        self.taxRates = taxRates
        self.totalProposedSpending = totalProposedSpending
        self.estimatedRevenue = estimatedRevenue
        self.status = status
        self.approvalRating = approvalRating
    }
}

// MARK: - Budget Templates

extension Budget {
    static func createInitialBudget(fiscalYear: Int, governmentLevel: Int, gdp: Double? = nil, taxRates: TaxRates = TaxRates()) -> Budget {
        // Calculate actual revenue from GDP and tax rates
        let totalRevenue: Decimal

        if let gdpValue = gdp, gdpValue > 0 {
            // Government share of GDP varies by level
            let governmentSharePercentage: Double
            switch governmentLevel {
            case 1: governmentSharePercentage = 0.015  // 1.5% for local (Mayor)
            case 2: governmentSharePercentage = 0.10   // 10% for state (Governor)
            case 3: governmentSharePercentage = 0.04   // 4% for federal (Senator)
            case 4: governmentSharePercentage = 0.175  // 17.5% for federal (VP)
            case 5: governmentSharePercentage = 0.225  // 22.5% for federal (President)
            default: governmentSharePercentage = 0.15
            }

            // Calculate revenue: GDP × Government Share × Tax Rate × Efficiency
            let averageTaxRate = taxRates.averageRate / 100.0
            let taxEfficiency = 0.75 + (averageTaxRate * 0.25) // 75-100% efficiency
            let theoreticalRevenue = gdpValue * governmentSharePercentage * averageTaxRate
            let actualRevenue = theoreticalRevenue * taxEfficiency

            totalRevenue = Decimal(actualRevenue)
        } else {
            // Fallback if GDP not available
            totalRevenue = Decimal(governmentLevel * 100_000_000) // $100M per level
        }

        // Set initial department allocations as reasonable defaults (% of revenue)
        // User can adjust these in the Departments tab
        var departments = [
            Department(
                name: "Education Department",
                category: .education,
                allocatedFunds: totalRevenue * 0.20,
                proposedFunds: totalRevenue * 0.20,
                description: "K-12 schools, community colleges, and education programs"
            ),
            Department(
                name: "Healthcare Services",
                category: .healthcare,
                allocatedFunds: totalRevenue * 0.18,
                proposedFunds: totalRevenue * 0.18,
                description: "Public health programs and medical services"
            ),
            Department(
                name: "Public Safety",
                category: .defense,
                allocatedFunds: totalRevenue * 0.15,
                proposedFunds: totalRevenue * 0.15,
                description: "Police, fire departments, and emergency services"
            ),
            Department(
                name: "Infrastructure & Transportation",
                category: .infrastructure,
                allocatedFunds: totalRevenue * 0.15,
                proposedFunds: totalRevenue * 0.15,
                description: "Roads, bridges, public transit, and utilities"
            ),
            Department(
                name: "Social Services",
                category: .welfare,
                allocatedFunds: totalRevenue * 0.12,
                proposedFunds: totalRevenue * 0.12,
                description: "Housing assistance, food programs, and welfare"
            ),
            Department(
                name: "Environmental Protection",
                category: .environment,
                allocatedFunds: totalRevenue * 0.08,
                proposedFunds: totalRevenue * 0.08,
                description: "Parks, conservation, and environmental programs"
            ),
            Department(
                name: "Justice & Courts",
                category: .justice,
                allocatedFunds: totalRevenue * 0.05,
                proposedFunds: totalRevenue * 0.05,
                description: "Court system and legal services"
            ),
            Department(
                name: "Science & Research",
                category: .science,
                allocatedFunds: totalRevenue * 0.03,
                proposedFunds: totalRevenue * 0.03,
                description: "Research grants and innovation programs"
            ),
            Department(
                name: "Arts & Culture",
                category: .culture,
                allocatedFunds: totalRevenue * 0.02,
                proposedFunds: totalRevenue * 0.02,
                description: "Museums, libraries, and cultural programs"
            ),
            Department(
                name: "Administration",
                category: .administration,
                allocatedFunds: totalRevenue * 0.02,
                proposedFunds: totalRevenue * 0.02,
                description: "Government operations and administrative costs"
            )
        ]

        // Add Military department for Presidents only (level 5)
        if governmentLevel == 5 {
            departments.append(
                Department(
                    name: "Military & Defense",
                    category: .military,
                    allocatedFunds: 50_000_000_000, // $50B default
                    proposedFunds: 50_000_000_000,
                    description: "Armed forces, weapons systems, and national defense"
                )
            )
        }

        let totalExpenses = departments.reduce(Decimal(0)) { $0 + $1.allocatedFunds }

        return Budget(
            fiscalYear: fiscalYear,
            totalRevenue: totalRevenue,
            totalExpenses: totalExpenses,
            departments: departments,
            taxRates: taxRates,
            economicIndicators: EconomicIndicators()
        )
    }
}
