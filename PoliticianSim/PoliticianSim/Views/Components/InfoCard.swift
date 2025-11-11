//
//  InfoCard.swift
//  PoliticianSim
//
//  Container card with title and custom content
//

import SwiftUI

struct InfoCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: Constants.Typography.sectionTitleSize, weight: .bold))
                .foregroundColor(.white)

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        InfoCard(title: "Character Info") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name: John Smith")
                    .foregroundColor(.white)
                Text("Age: 35")
                    .foregroundColor(.white)
                Text("Position: Senator")
                    .foregroundColor(.white)
            }
        }

        InfoCard(title: "Campaign Stats") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Funds:")
                        .foregroundColor(Constants.Colors.secondaryText)
                    Spacer()
                    Text("$1,250,000")
                        .foregroundColor(Constants.Colors.money)
                        .bold()
                }
                HStack {
                    Text("Approval:")
                        .foregroundColor(Constants.Colors.secondaryText)
                    Spacer()
                    Text("67%")
                        .foregroundColor(Constants.Colors.approvalGood)
                        .bold()
                }
            }
        }
    }
    .padding()
    .background(Constants.Colors.background)
}
