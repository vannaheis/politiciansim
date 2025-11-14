//
//  EconomicDataView.swift
//  PoliticianSim
//
//  View for displaying economic data at federal, state, and local levels
//

import SwiftUI

struct EconomicDataView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedIndicator: IndicatorDetailType?
    @State private var selectedTab: EconomicTab = .overview

    enum EconomicTab {
        case overview
        case worldGDP
        case worldPopulation
    }

    enum IndicatorDetailType: Identifiable {
        case federalGDP
        case federalUnemployment
        case federalInflation
        case federalInterestRate
        case stateGDP
        case stateUnemployment
        case localGDP
        case localUnemployment

        var id: String {
            switch self {
            case .federalGDP: return "federalGDP"
            case .federalUnemployment: return "federalUnemployment"
            case .federalInflation: return "federalInflation"
            case .federalInterestRate: return "federalInterestRate"
            case .stateGDP: return "stateGDP"
            case .stateUnemployment: return "stateUnemployment"
            case .localGDP: return "localGDP"
            case .localUnemployment: return "localUnemployment"
            }
        }
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Header
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

                    Text("Economic Data")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Tab Selector
                HStack(spacing: 0) {
                    TabButton(title: "Overview", isSelected: selectedTab == .overview) {
                        selectedTab = .overview
                    }
                    TabButton(title: "World GDP", isSelected: selectedTab == .worldGDP) {
                        selectedTab = .worldGDP
                    }
                    TabButton(title: "Population", isSelected: selectedTab == .worldPopulation) {
                        selectedTab = .worldPopulation
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .overview:
                            OverviewTabContent(selectedIndicator: $selectedIndicator)
                        case .worldGDP:
                            WorldGDPTabContent()
                        case .worldPopulation:
                            WorldPopulationTabContent()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
        .sheet(item: $selectedIndicator) { indicator in
            IndicatorDetailView(indicator: indicator)
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)

                Rectangle()
                    .fill(isSelected ? Constants.Colors.accent : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

// MARK: - Overview Tab Content

struct OverviewTabContent: View {
    @Binding var selectedIndicator: EconomicDataView.IndicatorDetailType?

    var body: some View {
        VStack(spacing: 20) {
            // Federal Section
            FederalEconomicSection(selectedIndicator: $selectedIndicator)

            // State Section
            StateEconomicSection(selectedIndicator: $selectedIndicator)

            // Local Section
            LocalEconomicSection(selectedIndicator: $selectedIndicator)
        }
    }
}

// MARK: - World GDP Tab Content

struct WorldGDPTabContent: View {
    var body: some View {
        WorldGDPRankingsSection()
    }
}

// MARK: - World Population Tab Content

struct WorldPopulationTabContent: View {
    @EnvironmentObject var gameManager: GameManager

    var sortedByPopulation: [WorldCountryGDP] {
        gameManager.economicDataManager.economicData.worldGDPs.sorted { $0.population > $1.population }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("World Population Rankings")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                ForEach(Array(sortedByPopulation.enumerated()), id: \.element.id) { index, country in
                    WorldPopulationRankingRow(rank: index + 1, country: country)
                }
            }
        }
    }
}

struct WorldPopulationRankingRow: View {
    @EnvironmentObject var gameManager: GameManager
    let rank: Int
    let country: WorldCountryGDP

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(rank <= 3 ? .yellow : Constants.Colors.secondaryText)
                .frame(width: 35)

            // Country
            VStack(alignment: .leading, spacing: 2) {
                Text(country.countryName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                Text("GDP: \(gameManager.economicDataManager.formatGDP(country.gdp))")
                    .font(.system(size: 10))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Spacer()

            // Population
            VStack(alignment: .trailing, spacing: 2) {
                Text(gameManager.economicDataManager.formatPopulation(country.population))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Constants.Colors.accent)

                Text("Per Capita: \(gameManager.economicDataManager.formatGDP(country.gdpPerCapita))")
                    .font(.system(size: 10))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Federal Economic Section

struct FederalEconomicSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedIndicator: EconomicDataView.IndicatorDetailType?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Federal")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            // GDP Chart
            LineChartView(
                dataPoints: gameManager.economicDataManager.economicData.federal.gdp.history,
                title: "Gross Domestic Product",
                color: .green,
                formatValue: { gameManager.economicDataManager.formatGDP($0) }
            )
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            .onTapGesture {
                selectedIndicator = .federalGDP
            }

            // Other Federal Indicators
            HStack(spacing: 12) {
                FederalIndicatorCard(
                    title: "Unemployment",
                    value: gameManager.economicDataManager.economicData.federal.unemploymentRate.current,
                    format: { gameManager.economicDataManager.formatPercentage($0) },
                    color: .orange,
                    icon: "person.3.fill"
                ) {
                    selectedIndicator = .federalUnemployment
                }

                FederalIndicatorCard(
                    title: "Inflation",
                    value: gameManager.economicDataManager.economicData.federal.inflationRate.current,
                    format: { gameManager.economicDataManager.formatPercentage($0) },
                    color: .red,
                    icon: "chart.line.uptrend.xyaxis"
                ) {
                    selectedIndicator = .federalInflation
                }
            }

            FederalIndicatorCard(
                title: "Federal Interest Rate",
                value: gameManager.economicDataManager.economicData.federal.federalInterestRate.current,
                format: { gameManager.economicDataManager.formatPercentage($0) },
                color: Constants.Colors.political,
                icon: "percent"
            ) {
                selectedIndicator = .federalInterestRate
            }
        }
    }
}

struct FederalIndicatorCard: View {
    let title: String
    let value: Double
    let format: (Double) -> String
    let color: Color
    let icon: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)

                    Text(title)
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Text(format(value))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

// MARK: - State Economic Section

struct StateEconomicSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedIndicator: EconomicDataView.IndicatorDetailType?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("State: \(gameManager.economicDataManager.economicData.state.stateName)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                EconomicStatCard(
                    title: "State GDP",
                    value: gameManager.economicDataManager.formatGDP(gameManager.economicDataManager.economicData.state.gdp.current),
                    color: .green,
                    icon: "dollarsign.circle.fill"
                ) {
                    selectedIndicator = .stateGDP
                }

                EconomicStatCard(
                    title: "Unemployment",
                    value: gameManager.economicDataManager.formatPercentage(gameManager.economicDataManager.economicData.state.unemploymentRate.current),
                    color: .orange,
                    icon: "person.3.fill"
                ) {
                    selectedIndicator = .stateUnemployment
                }
            }
        }
    }
}

// MARK: - Local Economic Section

struct LocalEconomicSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedIndicator: EconomicDataView.IndicatorDetailType?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Local: \(gameManager.economicDataManager.economicData.local.cityName)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                EconomicStatCard(
                    title: "City GDP",
                    value: gameManager.economicDataManager.formatGDP(gameManager.economicDataManager.economicData.local.gdp.current),
                    color: .green,
                    icon: "building.2.fill"
                ) {
                    selectedIndicator = .localGDP
                }

                EconomicStatCard(
                    title: "Unemployment",
                    value: gameManager.economicDataManager.formatPercentage(gameManager.economicDataManager.economicData.local.unemploymentRate.current),
                    color: .orange,
                    icon: "person.2.fill"
                ) {
                    selectedIndicator = .localUnemployment
                }
            }
        }
    }
}

struct EconomicStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)

                    Text(title)
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

// MARK: - World GDP Rankings Section

struct WorldGDPRankingsSection: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("World GDP Rankings")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                ForEach(Array(gameManager.economicDataManager.economicData.worldGDPs.enumerated()), id: \.element.id) { index, country in
                    WorldGDPRankingRow(rank: index + 1, country: country)
                }
            }
        }
    }
}

struct WorldGDPRankingRow: View {
    @EnvironmentObject var gameManager: GameManager
    let rank: Int
    let country: WorldCountryGDP

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(rank <= 3 ? .yellow : Constants.Colors.secondaryText)
                .frame(width: 35)

            // Country
            VStack(alignment: .leading, spacing: 2) {
                Text(country.countryName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                Text("Pop: \(gameManager.economicDataManager.formatPopulation(country.population))")
                    .font(.system(size: 10))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Spacer()

            // GDP
            VStack(alignment: .trailing, spacing: 2) {
                Text(gameManager.economicDataManager.formatGDP(country.gdp))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.green)

                Text("Per Capita: \(gameManager.economicDataManager.formatGDP(country.gdpPerCapita))")
                    .font(.system(size: 10))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    EconomicDataView()
        .environmentObject(GameManager.shared)
}
