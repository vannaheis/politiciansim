//
//  StandardBackgroundView.swift
//  PoliticianSim
//
//  Standard background for all game screens
//

import SwiftUI

struct StandardBackgroundView: View {
    var body: some View {
        ZStack {
            // Base background color (fallback)
            Constants.Colors.background
                .ignoresSafeArea()

            // Background image
            GeometryReader { geometry in
                Image("BackgroundImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            // Dark overlay for better text readability
            Color.black.opacity(0.3)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    StandardBackgroundView()
}
