//
//  BudgetView.swift
//  PoliticianSim
//
//  Budget management and allocation view
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab: BudgetTab = .overview
    @State private var showingApplyConfirmation = false
    @State private var feedbackMessage = ""
    @State private var showingFeedback = false

    enum BudgetTab {
        case overview
        case departments
        case taxes
        case analysis
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameManager.navigationManager.toggleMenu()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Budget")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Tab selector
                BudgetTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                if gameManager.budgetManager.currentBudget != nil {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            switch selectedTab {
                            case .overview:
                                BudgetOverviewSection()
                            case .departments:
                                DepartmentsSection()
                            case .taxes:
                                TaxesSection()
                            case .analysis:
                                AnalysisSection()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }

                    // Apply Budget Button
                    ApplyBudgetButton(
                        showingConfirmation: $showingApplyConfirmation,
                        feedbackMessage: $feedbackMessage,
                        showingFeedback: $showingFeedback
                    )
                } else {
                    NoBudgetView()
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
        .onAppear {
            // Initialize budget if character has a position
            if gameManager.budgetManager.currentBudget == nil,
               let character = gameManager.character {
                // Get appropriate GDP based on position level
                let gdp = getGDPForPosition(character: character)
                gameManager.budgetManager.initializeBudget(for: character, gdp: gdp)
            }
        }
        .customAlert(
            isPresented: $showingFeedback,
            title: "Budget",
            message: feedbackMessage,
            primaryButton: "OK",
            primaryAction: {}
        )
    }

    private func getGDPForPosition(character: Character) -> Double? {
        guard let position = character.currentPosition else { return nil }

        switch position.level {
        case 1: // Mayor - use local GDP
            return gameManager.economicDataManager.economicData.local.gdp.current
        case 2: // Governor - use state GDP
            return gameManager.economicDataManager.economicData.state.gdp.current
        case 3, 4, 5: // Senator, VP, President - use federal GDP
            return gameManager.economicDataManager.economicData.federal.gdp.current
        default:
            return nil
        }
    }
}

// MARK: - Tab Selector

struct BudgetTabSelector: View {
    @Binding var selectedTab: BudgetView.BudgetTab

    var body: some View {
        HStack(spacing: 8) {
            BudgetTabButton(title: "Overview", isSelected: selectedTab == .overview) {
                selectedTab = .overview
            }
            BudgetTabButton(title: "Departments", isSelected: selectedTab == .departments) {
                selectedTab = .departments
            }
            BudgetTabButton(title: "Taxes", isSelected: selectedTab == .taxes) {
                selectedTab = .taxes
            }
            BudgetTabButton(title: "Analysis", isSelected: selectedTab == .analysis) {
                selectedTab = .analysis
            }
        }
    }

    struct BudgetTabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Constants.Colors.money.opacity(0.3) : Color.clear)
                    )
            }
        }
    }
}

// MARK: - Budget Overview Section

struct BudgetOverviewSection: View {
    @EnvironmentObject var gameManager: GameManager

    var budget: Budget? {
        gameManager.budgetManager.currentBudget
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let budget = budget {
                // Fiscal summary card
                FiscalSummaryCard(budget: budget)

                // Economic indicators card
                EconomicIndicatorsCard(indicators: budget.economicIndicators)

                // Recommendations
                if !gameManager.budgetManager.getRecommendedBudgetAdjustments().isEmpty {
                    RecommendationsCard(recommendations: gameManager.budgetManager.getRecommendedBudgetAdjustments())
                }
            }
        }
    }
}

struct FiscalSummaryCard: View {
    let budget: Budget

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Constants.Colors.money.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.money)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("FISCAL YEAR \(budget.fiscalYear)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("Budget Summary")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()
            }

            Divider().background(Color.white.opacity(0.2))

            // Revenue
            BudgetRow(
                label: "Total Revenue",
                amount: budget.totalRevenue,
                icon: "arrow.down.circle.fill",
                color: Constants.Colors.positive
            )

            // Expenses
            BudgetRow(
                label: "Total Expenses",
                amount: budget.totalExpenses,
                icon: "arrow.up.circle.fill",
                color: Constants.Colors.negative
            )

            Divider().background(Color.white.opacity(0.2))

            // Surplus/Deficit
            HStack {
                Image(systemName: budget.surplus >= 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(budget.surplus >= 0 ? Constants.Colors.positive : Constants.Colors.negative)

                Text(budget.surplus >= 0 ? "Surplus" : "Deficit")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text(formatMoney(abs(budget.surplus)))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(budget.surplus >= 0 ? Constants.Colors.positive : Constants.Colors.negative)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    func formatMoney(_ amount: Decimal) -> String {
        let value = Int(truncating: amount as NSDecimalNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", Double(value) / 1_000_000_000.0)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", Double(value) / 1_000_000.0)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", Double(value) / 1_000.0)
        } else {
            return "$\(value)"
        }
    }
}

struct BudgetRow: View {
    let label: String
    let amount: Decimal
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white)

            Spacer()

            Text(formatMoney(amount))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
    }

    func formatMoney(_ amount: Decimal) -> String {
        let value = Int(truncating: amount as NSDecimalNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", Double(value) / 1_000_000_000.0)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", Double(value) / 1_000_000.0)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", Double(value) / 1_000.0)
        } else {
            return "$\(value)"
        }
    }
}

struct EconomicIndicatorsCard: View {
    let indicators: EconomicIndicators

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Economic Indicators")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                IndicatorRow(
                    label: "GDP Growth",
                    value: String(format: "%.1f%%", indicators.gdpGrowth),
                    icon: "chart.line.uptrend.xyaxis",
                    color: indicators.gdpGrowth >= 0 ? Constants.Colors.positive : Constants.Colors.negative
                )

                IndicatorRow(
                    label: "Unemployment",
                    value: String(format: "%.1f%%", indicators.unemployment),
                    icon: "person.2.fill",
                    color: indicators.unemployment < 6 ? Constants.Colors.positive : Constants.Colors.warning
                )

                IndicatorRow(
                    label: "Inflation",
                    value: String(format: "%.1f%%", indicators.inflation),
                    icon: "arrow.up.right.circle.fill",
                    color: indicators.inflation < 3 ? Constants.Colors.positive : Constants.Colors.warning
                )

                IndicatorRow(
                    label: "Consumer Confidence",
                    value: String(format: "%.0f/100", indicators.consumerConfidence),
                    icon: "heart.fill",
                    color: indicators.consumerConfidence >= 60 ? Constants.Colors.positive : Constants.Colors.warning
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct IndicatorRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

struct RecommendationsCard: View {
    let recommendations: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recommendations")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            ForEach(recommendations, id: \.self) { recommendation in
                Text(recommendation)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Constants.Colors.warning.opacity(0.1))
                    )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Departments Section

struct DepartmentsSection: View {
    @EnvironmentObject var gameManager: GameManager

    var departments: [Department] {
        gameManager.budgetManager.currentBudget?.departments ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(departments) { department in
                DepartmentCard(department: department)
            }
        }
    }
}

struct DepartmentCard: View {
    @EnvironmentObject var gameManager: GameManager
    let department: Department
    @State private var fundingAmount: Double = 0

    var categoryColor: Color {
        Color(
            red: department.category.color.red,
            green: department.category.color.green,
            blue: department.category.color.blue
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Department header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: department.category.iconName)
                        .font(.system(size: 16))
                        .foregroundColor(categoryColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(department.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)

                    Text(department.description)
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .lineLimit(1)
                }

                Spacer()
            }

            // Current allocation
            HStack {
                Text("Current:")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text(formatMoney(department.allocatedFunds))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Satisfaction bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Satisfaction")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Spacer()

                    Text("\(Int(department.satisfaction))%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(satisfactionColor)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(satisfactionColor)
                            .frame(width: geometry.size.width * CGFloat(department.satisfaction / 100.0))
                    }
                }
                .frame(height: 6)
            }

            // Funding slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Proposed: \(formatMoney(Decimal(fundingAmount)))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(categoryColor)

                Slider(value: $fundingAmount, in: 0...maxFunding, step: stepSize)
                    .accentColor(categoryColor)
                    .onChange(of: fundingAmount) { newValue in
                        adjustFunding(newAmount: Decimal(newValue))
                    }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(categoryColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            fundingAmount = Double(truncating: department.proposedFunds as NSDecimalNumber)
        }
    }

    private var satisfactionColor: Color {
        if department.satisfaction >= 70 {
            return Constants.Colors.positive
        } else if department.satisfaction >= 40 {
            return Color.yellow
        } else {
            return Constants.Colors.negative
        }
    }

    private var maxFunding: Double {
        guard let budget = gameManager.budgetManager.currentBudget else { return 1_000_000_000 }
        return Double(truncating: (budget.totalRevenue * 0.5) as NSDecimalNumber)
    }

    private var stepSize: Double {
        maxFunding / 100.0
    }

    private func adjustFunding(newAmount: Decimal) {
        guard var character = gameManager.character else { return }
        let _ = gameManager.budgetManager.adjustDepartmentFunding(
            departmentId: department.id,
            newAmount: newAmount,
            character: &character
        )
        gameManager.characterManager.updateCharacter(character)
    }

    func formatMoney(_ amount: Decimal) -> String {
        let value = Int(truncating: amount as NSDecimalNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", Double(value) / 1_000_000_000.0)
        } else if value >= 1_000_000 {
            return String(format: "$%.0fM", Double(value) / 1_000_000.0)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", Double(value) / 1_000.0)
        } else {
            return "$\(value)"
        }
    }
}

// MARK: - Taxes Section

struct TaxesSection: View {
    @EnvironmentObject var gameManager: GameManager

    var taxRates: TaxRates? {
        gameManager.budgetManager.currentBudget?.taxRates
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let rates = taxRates {
                TaxRateCard(
                    title: "Low Income Tax",
                    description: "Tax rate for low-income earners",
                    currentRate: rates.incomeTaxLow,
                    minRate: 0,
                    maxRate: 50,
                    taxType: .incomeLow
                )

                TaxRateCard(
                    title: "Middle Income Tax",
                    description: "Tax rate for middle-class earners",
                    currentRate: rates.incomeTaxMiddle,
                    minRate: 0,
                    maxRate: 50,
                    taxType: .incomeMiddle
                )

                TaxRateCard(
                    title: "High Income Tax",
                    description: "Tax rate for wealthy individuals",
                    currentRate: rates.incomeTaxHigh,
                    minRate: 0,
                    maxRate: 70,
                    taxType: .incomeHigh
                )

                TaxRateCard(
                    title: "Corporate Tax",
                    description: "Tax rate for businesses",
                    currentRate: rates.corporateTax,
                    minRate: 0,
                    maxRate: 50,
                    taxType: .corporate
                )

                TaxRateCard(
                    title: "Sales Tax",
                    description: "Tax on goods and services",
                    currentRate: rates.salesTax,
                    minRate: 0,
                    maxRate: 20,
                    taxType: .sales
                )
            }
        }
    }
}

struct TaxRateCard: View {
    @EnvironmentObject var gameManager: GameManager
    let title: String
    let description: String
    let currentRate: Double
    let minRate: Double
    let maxRate: Double
    let taxType: BudgetManager.TaxType

    @State private var proposedRate: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            HStack {
                Text("Current Rate:")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text(String(format: "%.1f%%", currentRate))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Proposed: \(String(format: "%.1f%%", proposedRate))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Constants.Colors.money)

                Slider(value: $proposedRate, in: minRate...maxRate, step: 0.5)
                    .accentColor(Constants.Colors.money)
                    .onChange(of: proposedRate) { newValue in
                        adjustTaxRate(newRate: newValue)
                    }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .onAppear {
            proposedRate = currentRate
        }
    }

    private func adjustTaxRate(newRate: Double) {
        guard var character = gameManager.character else { return }

        // Get appropriate GDP based on position level
        let gdp: Double?
        if let position = character.currentPosition {
            switch position.level {
            case 1: // Mayor - use local GDP
                gdp = gameManager.economicDataManager.economicData.local.gdp.current
            case 2: // Governor - use state GDP
                gdp = gameManager.economicDataManager.economicData.state.gdp.current
            case 3, 4, 5: // Senator, VP, President - use federal GDP
                gdp = gameManager.economicDataManager.economicData.federal.gdp.current
            default:
                gdp = nil
            }
        } else {
            gdp = nil
        }

        let _ = gameManager.budgetManager.adjustTaxRate(
            taxType: taxType,
            newRate: newRate,
            character: &character,
            gdp: gdp
        )
        gameManager.characterManager.updateCharacter(character)
    }
}

// MARK: - Analysis Section

struct AnalysisSection: View {
    @EnvironmentObject var gameManager: GameManager

    var summary: BudgetManager.BudgetSummary? {
        gameManager.budgetManager.getBudgetSummary()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let summary = summary {
                // Overall health card
                OverallHealthCard(summary: summary)

                // Detailed metrics
                DetailedMetricsCard(summary: summary)
            }
        }
    }
}

struct OverallHealthCard: View {
    let summary: BudgetManager.BudgetSummary

    var healthColor: Color {
        if summary.economicHealth >= 70 {
            return Constants.Colors.positive
        } else if summary.economicHealth >= 40 {
            return Color.yellow
        } else {
            return Constants.Colors.negative
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Economic Health")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            HStack {
                Text("\(Int(summary.economicHealth))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(healthColor)

                Text("/100")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(healthColor)
                        .frame(width: geometry.size.width * CGFloat(summary.economicHealth / 100.0))
                }
            }
            .frame(height: 12)

            Text(healthDescription)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private var healthDescription: String {
        if summary.economicHealth >= 80 {
            return "Excellent economic performance"
        } else if summary.economicHealth >= 60 {
            return "Good economic stability"
        } else if summary.economicHealth >= 40 {
            return "Moderate economic concerns"
        } else {
            return "Significant economic challenges"
        }
    }
}

struct DetailedMetricsCard: View {
    let summary: BudgetManager.BudgetSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Analysis")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            MetricRow(
                label: "Deficit Ratio",
                value: String(format: "%.1f%%", summary.deficitPercentage),
                status: summary.deficitPercentage < 0 ? "Surplus" : "Deficit"
            )

            MetricRow(
                label: "Dept. Satisfaction",
                value: String(format: "%.0f/100", summary.averageDepartmentSatisfaction),
                status: summary.averageDepartmentSatisfaction >= 60 ? "Good" : "Low"
            )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let status: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)

                Text(status)
                    .font(.system(size: 10))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
        }
    }
}

// MARK: - Apply Budget Button

struct ApplyBudgetButton: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showingConfirmation: Bool
    @Binding var feedbackMessage: String
    @Binding var showingFeedback: Bool

    var body: some View {
        Button(action: {
            applyBudget()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Apply Budget")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Constants.Colors.positive)
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func applyBudget() {
        guard var character = gameManager.character else { return }

        let result = gameManager.budgetManager.applyProposedBudget(character: &character)

        if result.success {
            gameManager.characterManager.updateCharacter(character)
            feedbackMessage = result.message
            showingFeedback = true
        }
    }
}

// MARK: - No Budget View

struct NoBudgetView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "chart.bar.doc.horizontal.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryText)

            Text("No Budget Available")
                .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                .foregroundColor(.white)

            Text("You need a government position to manage a budget")
                .font(.system(size: Constants.Typography.bodyTextSize))
                .foregroundColor(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

#Preview {
    BudgetView()
        .environmentObject(GameManager.shared)
}
