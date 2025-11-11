//
//  ProgressBar.swift
//  PoliticianSim
//
//  Horizontal progress indicator
//

import SwiftUI

struct ProgressBar: View {
    let value: Double // 0.0 to 1.0
    let color: Color
    let height: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: height)

                // Filled portion
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * min(max(value, 0), 1), height: height)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Health: 85/100")
                .foregroundColor(.white)
            ProgressBar(value: 0.85, color: Constants.Colors.health)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Approval: 45%")
                .foregroundColor(.white)
            ProgressBar(value: 0.45, color: Constants.Colors.approvalNeutral)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Stress: 92/100")
                .foregroundColor(.white)
            ProgressBar(value: 0.92, color: Constants.Colors.stress)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Campaign Progress: 10%")
                .foregroundColor(.white)
            ProgressBar(value: 0.1, color: Constants.Colors.charisma)
        }
    }
    .padding()
    .background(Constants.Colors.background)
}
