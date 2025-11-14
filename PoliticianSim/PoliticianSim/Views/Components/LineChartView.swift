//
//  LineChartView.swift
//  PoliticianSim
//
//  Beautiful line chart component for economic data visualization
//

import SwiftUI

struct LineChartView: View {
    let dataPoints: [EconomicDataPoint]
    let title: String
    let color: Color
    let formatValue: (Double) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            if dataPoints.isEmpty {
                Text("No data available")
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .frame(height: 120)
            } else {
                GeometryReader { geometry in
                    ZStack(alignment: .bottomLeading) {
                        // Grid lines
                        GridLines(geometry: geometry)

                        // Line chart
                        LineShape(dataPoints: dataPoints, geometry: geometry)
                            .stroke(color, lineWidth: 2)

                        // Gradient fill
                        LineShape(dataPoints: dataPoints, geometry: geometry)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.0)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        // Value labels
                        ValueLabels(
                            dataPoints: dataPoints,
                            geometry: geometry,
                            formatValue: formatValue,
                            color: color
                        )
                    }
                }
                .frame(height: 120)
            }
        }
    }
}

// MARK: - Grid Lines

struct GridLines: View {
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                if i < 4 {
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Line Shape

struct LineShape: Shape {
    let dataPoints: [EconomicDataPoint]
    let geometry: GeometryProxy

    func path(in rect: CGRect) -> Path {
        guard dataPoints.count >= 2 else { return Path() }

        let values = dataPoints.map { $0.value }
        guard let minValue = values.min(), let maxValue = values.max() else { return Path() }

        let range = maxValue - minValue
        let safeRange = range > 0 ? range : 1.0

        var path = Path()

        for (index, point) in dataPoints.enumerated() {
            let x = rect.width * CGFloat(index) / CGFloat(max(dataPoints.count - 1, 1))
            let normalizedValue = (point.value - minValue) / safeRange
            let y = rect.height * (1 - CGFloat(normalizedValue))

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        // Close the path for fill
        if !dataPoints.isEmpty {
            let lastX = rect.width
            path.addLine(to: CGPoint(x: lastX, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }

        return path
    }
}

// MARK: - Value Labels

struct ValueLabels: View {
    let dataPoints: [EconomicDataPoint]
    let geometry: GeometryProxy
    let formatValue: (Double) -> String
    let color: Color

    var body: some View {
        if let firstValue = dataPoints.first?.value,
           let lastValue = dataPoints.last?.value {
            HStack {
                // First value
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatValue(firstValue))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                }

                Spacer()

                // Last value with indicator
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: lastValue >= firstValue ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 8))
                            .foregroundColor(lastValue >= firstValue ? .green : .red)

                        Text(formatValue(lastValue))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            LineChartView(
                dataPoints: [
                    EconomicDataPoint(date: Date(), value: 25.0),
                    EconomicDataPoint(date: Date().addingTimeInterval(86400), value: 25.5),
                    EconomicDataPoint(date: Date().addingTimeInterval(172800), value: 25.2),
                    EconomicDataPoint(date: Date().addingTimeInterval(259200), value: 26.0),
                    EconomicDataPoint(date: Date().addingTimeInterval(345600), value: 25.8)
                ],
                title: "Federal GDP",
                color: .green,
                formatValue: { String(format: "$%.1fT", $0) }
            )
            .padding()
        }
    }
}
