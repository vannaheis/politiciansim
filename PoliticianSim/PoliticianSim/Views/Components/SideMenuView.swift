//
//  SideMenuView.swift
//  PoliticianSim
//
//  Side menu navigation drawer
//

import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isOpen: Bool

    var body: some View {
        ZStack {
            // Dimmed background
            if isOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameManager.navigationManager.closeMenu()
                        }
                    }
            }

            // Menu content
            HStack(spacing: 0) {
                // Menu panel
                VStack(alignment: .leading, spacing: 0) {
                    // Header with character info
                    if let character = gameManager.character {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(character.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)

                            Text("Age \(character.age) • \(formattedDate(character.currentDate))")
                                .font(.system(size: 13))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text(formatMoney(character.campaignFunds))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Constants.Colors.positive)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 30)
                    }

                    // Menu items
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Home button (always visible)
                            MenuItemButton(
                                icon: "house.fill",
                                title: "Home",
                                isSelected: gameManager.navigationManager.currentView == .home
                            ) {
                                gameManager.navigationManager.navigateTo(.home)
                            }

                            // Grouped menu items
                            ForEach(gameManager.navigationManager.getMenuItems(), id: \.0) { section, items in
                                if section != .none && section != .settings {
                                    Text(section.rawValue)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Constants.Colors.secondaryText.opacity(0.6))
                                        .padding(.horizontal, 20)
                                        .padding(.top, 20)
                                        .padding(.bottom, 6)
                                }

                                ForEach(items, id: \.self) { item in
                                    MenuItemButton(
                                        icon: item.icon,
                                        title: item.rawValue,
                                        isSelected: gameManager.navigationManager.currentView == item
                                    ) {
                                        gameManager.navigationManager.navigateTo(item)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .frame(width: 280)
                .background(Color(red: 0.11, green: 0.13, blue: 0.18))
                .offset(x: isOpen ? 0 : -280)

                Spacer()
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Menu Item Button

struct MenuItemButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Constants.Colors.buttonPrimary : .white)
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Constants.Colors.buttonPrimary : .white)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                isSelected ? Constants.Colors.buttonPrimary.opacity(0.15) : Color.clear
            )
        }
    }
}

#Preview {
    ZStack {
        StandardBackgroundView()

        SideMenuView(isOpen: .constant(true))
            .environmentObject(GameManager.shared)
    }
}
