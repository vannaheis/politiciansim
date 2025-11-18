//
//  TechnologyResearchView.swift
//  PoliticianSim
//
//  Technology research management
//

import SwiftUI

struct TechnologyResearchView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Coming Soon")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    TechnologyResearchView()
        .environmentObject(GameManager.shared)
}
