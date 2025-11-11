//
//  Badge.swift
//  PoliticianSim
//
//  Colored pill badge for tags and labels
//

import SwiftUI

struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: Constants.Typography.captionSize, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 8) {
            Badge(text: "Democrat", color: .blue)
            Badge(text: "Senator", color: Constants.Colors.political)
        }

        HStack(spacing: 8) {
            Badge(text: "Popular", color: Constants.Colors.approvalGood)
            Badge(text: "Wealthy", color: Constants.Colors.money)
        }

        HStack(spacing: 8) {
            Badge(text: "Charismatic", color: Constants.Colors.charisma)
            Badge(text: "Intelligent", color: Constants.Colors.intelligence)
        }

        HStack(spacing: 8) {
            Badge(text: "Military", color: Constants.Colors.military)
            Badge(text: "Scandal", color: Constants.Colors.negative)
        }
    }
    .padding()
    .background(Constants.Colors.background)
}
