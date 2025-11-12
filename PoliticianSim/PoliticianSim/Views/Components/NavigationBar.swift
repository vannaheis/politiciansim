//
//  NavigationBar.swift
//  PoliticianSim
//
//  Bottom navigation bar component
//

import SwiftUI

struct NavigationBar: View {
    @Binding var currentView: NavigationManager.NavigationView

    var body: some View {
        HStack(spacing: 0) {
            NavBarItem(
                icon: "house.fill",
                label: "Home",
                isSelected: currentView == .home
            ) {
                currentView = .home
            }

            NavBarItem(
                icon: "person.circle.fill",
                label: "Profile",
                isSelected: currentView == .profile
            ) {
                currentView = .profile
            }

            NavBarItem(
                icon: "briefcase.fill",
                label: "Position",
                isSelected: currentView == .position
            ) {
                currentView = .position
            }

            NavBarItem(
                icon: "chart.bar.fill",
                label: "Stats",
                isSelected: currentView == .stats
            ) {
                currentView = .stats
            }

            NavBarItem(
                icon: "gearshape.fill",
                label: "Settings",
                isSelected: currentView == .settings
            ) {
                currentView = .settings
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Color.black.opacity(0.95)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct NavBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? Constants.Colors.buttonPrimary : Constants.Colors.secondaryText)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Constants.Colors.buttonPrimary : Constants.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    VStack {
        Spacer()

        NavigationBar(currentView: .constant(.home))
    }
    .background(Constants.Colors.background)
}
