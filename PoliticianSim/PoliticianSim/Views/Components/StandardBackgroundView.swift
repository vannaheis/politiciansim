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
            // Base background color
            Constants.Colors.background
                .ignoresSafeArea()

            // Optional: Background image with overlay
            // Uncomment when background image is added to Assets
            /*
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.3)
                .ignoresSafeArea()
            */
        }
    }
}

#Preview {
    StandardBackgroundView()
}
