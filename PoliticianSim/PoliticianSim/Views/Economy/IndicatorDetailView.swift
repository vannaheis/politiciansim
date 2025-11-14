//
//  IndicatorDetailView.swift
//  PoliticianSim
//
//  Detailed view for individual economic indicators showing history
//

import SwiftUI

struct IndicatorDetailView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    let indicator: EconomicDataView.IndicatorDetailType

    var indicatorData: (title: String, history: [EconomicDataPoint], color: Color, formatValue: (Double) -> String) {
        let manager = gameManager.economicDataManager
        switch indicator {
        case .federalGDP:
            return ("Federal GDP", manager.economicData.federal.gdp.history, .green, { manager.formatGDP($0) })
        case .federalUnemployment:
            return ("Federal Unemployment Rate", manager.economicData.federal.unemploymentRate.history, .orange, { manager.formatPercentage($0) })
        case .federalInflation:
            return ("Federal Inflation Rate", manager.economicData.federal.inflationRate.history, .red, { manager.formatPercentage($0) })
        case .federalInterestRate:
            return ("Federal Interest Rate", manager.economicData.federal.federalInterestRate.history, Constants.Colors.political, { manager.formatPercentage($0) })
        case .stateGDP:
            return ("State GDP", manager.economicData.state.gdp.history, .green, { manager.formatGDP($0) })
        case .stateUnemployment:
            return ("State Unemployment Rate", manager.economicData.state.unemploymentRate.history, .orange, { manager.formatPercentage($0) })
        case .localGDP:
            return ("Local GDP", manager.economicData.local.gdp.history, .green, { manager.formatGDP($0) })
        case .localUnemployment:
            return ("Local Unemployment Rate", manager.economicData.local.unemploymentRate.history, .orange, { manager.formatPercentage($0) })
        }
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.accent)
                    .frame(height: 44)

                    Spacer()

                    Text(indicatorData.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 60, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Current Value
                        if let currentValue = indicatorData.history.last?.value {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Value")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text(indicatorData.formatValue(currentValue))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(indicatorData.color)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }

                        // Chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Historical Trend")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)

                            LineChartView(
                                dataPoints: indicatorData.history,
                                title: "",
                                color: indicatorData.color,
                                formatValue: indicatorData.formatValue
                            )
                            .frame(height: 200)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        // Statistics
                        if !indicatorData.history.isEmpty {
                            StatisticsSection(
                                history: indicatorData.history,
                                formatValue: indicatorData.formatValue
                            )
                        }

                        // History Table
                        if !indicatorData.history.isEmpty {
                            HistoryTableSection(
                                history: indicatorData.history,
                                formatValue: indicatorData.formatValue
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}

// MARK: - Statistics Section

struct StatisticsSection: View {
    let history: [EconomicDataPoint]
    let formatValue: (Double) -> String

    var statistics: (min: Double, max: Double, avg: Double, change: Double) {
        let values = history.map { $0.value }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 0
        let avg = values.reduce(0, +) / Double(max(values.count, 1))
        let change = (values.last ?? 0) - (values.first ?? 0)
        return (minValue, maxValue, avg, change)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                StatRow(label: "Minimum", value: formatValue(statistics.min))
                StatRow(label: "Maximum", value: formatValue(statistics.max))
                StatRow(label: "Average", value: formatValue(statistics.avg))
                StatRow(
                    label: "Total Change",
                    value: formatValue(statistics.change),
                    valueColor: statistics.change >= 0 ? .green : .red
                )
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - History Table Section

struct HistoryTableSection: View {
    let history: [EconomicDataPoint]
    let formatValue: (Double) -> String

    var reversedHistory: [EconomicDataPoint] {
        Array(history.reversed().prefix(20))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent History")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 1) {
                // Header
                HStack {
                    Text("Date")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Value")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .frame(width: 100, alignment: .trailing)

                    Text("Change")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .frame(width: 80, alignment: .trailing)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))

                // Rows
                ForEach(Array(reversedHistory.enumerated()), id: \.element.id) { index, point in
                    let previousValue = index < reversedHistory.count - 1 ? reversedHistory[index + 1].value : point.value
                    let change = point.value - previousValue

                    HStack {
                        Text(formatDate(point.date))
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(formatValue(point.value))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 100, alignment: .trailing)

                        HStack(spacing: 4) {
                            if abs(change) > 0.001 {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.system(size: 8))
                                    .foregroundColor(change >= 0 ? .green : .red)
                            }

                            Text(formatValue(abs(change)))
                                .font(.system(size: 11))
                                .foregroundColor(abs(change) > 0.001 ? (change >= 0 ? .green : .red) : Constants.Colors.secondaryText)
                        }
                        .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(index % 2 == 0 ? Color.white.opacity(0.03) : Color.clear)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    IndicatorDetailView(indicator: .federalGDP)
        .environmentObject(GameManager.shared)
}
