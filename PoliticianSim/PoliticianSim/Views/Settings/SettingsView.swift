//
//  SettingsView.swift
//  PoliticianSim
//
//  Game settings and preferences view
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showResetConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showSaveLoadSheet = false
    @State private var showAdminPanel = false

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header with menu button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameManager.navigationManager.toggleMenu()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Settings")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Spacer to balance menu button
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Game Info Card
                        GameInfoCard(character: gameManager.character)

                        // ADMIN Card (only for Reviewerx100B)
                        if let character = gameManager.character, character.name == "Reviewerx100B" {
                            AdminCard(showAdminPanel: $showAdminPanel)
                        }

                        // Save/Load Card
                        SaveLoadCard(showSaveLoadSheet: $showSaveLoadSheet)

                        // Account Actions Card
                        AccountActionsCard(
                            showResetConfirmation: $showResetConfirmation,
                            showDeleteConfirmation: $showDeleteConfirmation
                        )

                        // About Card
                        AboutCard()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
        .customAlert(
            isPresented: $showResetConfirmation,
            title: "Reset Game Progress?",
            message: "This will reset all game progress and return you to character creation. This action cannot be undone.",
            primaryButton: "Reset",
            primaryAction: { resetGame() },
            secondaryButton: "Cancel"
        )
        .customAlert(
            isPresented: $showDeleteConfirmation,
            title: "Delete Character?",
            message: "This will permanently delete your character and all associated progress. This action cannot be undone.",
            primaryButton: "Delete",
            primaryAction: { deleteCharacter() },
            secondaryButton: "Cancel"
        )
        .sheet(isPresented: $showSaveLoadSheet) {
            SaveLoadSheet(isPresented: $showSaveLoadSheet)
        }
        .sheet(isPresented: $showAdminPanel) {
            AdminPanel(isPresented: $showAdminPanel)
        }
    }

    private func resetGame() {
        gameManager.newGame()
    }

    private func deleteCharacter() {
        gameManager.newGame()
    }
}

// MARK: - Game Info Card

struct GameInfoCard: View {
    let character: Character?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Information")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            if let character = character {
                VStack(spacing: 10) {
                    SettingsInfoRow(
                        icon: "person.fill",
                        label: "Character",
                        value: character.name
                    )

                    SettingsInfoRow(
                        icon: "calendar",
                        label: "In-Game Date",
                        value: formattedDate(character.currentDate)
                    )

                    SettingsInfoRow(
                        icon: "clock.fill",
                        label: "Days Played",
                        value: "\(daysPlayed(character: character))"
                    )

                    SettingsInfoRow(
                        icon: "flag.fill",
                        label: "Country",
                        value: character.country
                    )
                }
            } else {
                Text("No active game")
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .padding(.vertical, 8)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func daysPlayed(character: Character) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: character.birthDate, to: character.currentDate)
        return components.day ?? 0
    }
}

// MARK: - Save/Load Card

struct SaveLoadCard: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showSaveLoadSheet: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Save & Load")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 8) {
                // Autosave Info
                if gameManager.saveManager.hasAutosave {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 28, height: 28)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Autosave Active")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)

                            if let lastSave = gameManager.saveManager.lastAutosaveDate {
                                Text("Last saved: \(timeAgo(lastSave))")
                                    .font(.system(size: 11))
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                    )
                }

                // Manual Save/Load Button
                Button(action: {
                    showSaveLoadSheet = true
                }) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Constants.Colors.political.opacity(0.2))
                                .frame(width: 28, height: 28)

                            Image(systemName: "tray.and.arrow.down.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.political)
                        }

                        Text("Manual Save/Load")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
    }
}

// MARK: - Account Actions Card

struct AccountActionsCard: View {
    @Binding var showResetConfirmation: Bool
    @Binding var showDeleteConfirmation: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Management")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 8) {
                // Reset Game Button
                Button(action: {
                    showResetConfirmation = true
                }) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Constants.Colors.warning.opacity(0.2))
                                .frame(width: 28, height: 28)

                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.warning)
                        }

                        Text("Reset Game Progress")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                    )
                }

                // Delete Character Button
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Constants.Colors.negative.opacity(0.2))
                                .frame(width: 28, height: 28)

                            Image(systemName: "trash.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.negative)
                        }

                        Text("Delete Character")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - About Card

struct AboutCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 10) {
                SettingsInfoRow(
                    icon: "app.badge",
                    label: "Version",
                    value: "1.0.0"
                )

                SettingsInfoRow(
                    icon: "hammer.fill",
                    label: "Build",
                    value: "Phase 1.0"
                )

                SettingsInfoRow(
                    icon: "info.circle.fill",
                    label: "Status",
                    value: "Early Development"
                )
            }

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 4)

            Text("Politician Sim")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            Text("A political life simulation game where you rise from citizen to President.")
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text("© 2024 Politician Sim. All rights reserved.")
                .font(.system(size: 11))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
                .padding(.top, 8)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Supporting Views

struct SettingsInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Constants.Colors.political.opacity(0.2))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.political)
            }

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Save/Load Sheet

struct SaveLoadSheet: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @State private var selectedTab: SaveLoadTab = .save
    @State private var showConfirmation = false
    @State private var confirmationAction: (() -> Void)?
    @State private var confirmationMessage = ""

    enum SaveLoadTab {
        case save, load
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(Constants.Colors.accent)

                    Spacer()

                    Text("Save & Load")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Tab Selector
                HStack(spacing: 8) {
                    SaveLoadTabButton(title: "Save", isSelected: selectedTab == .save) {
                        selectedTab = .save
                    }
                    SaveLoadTabButton(title: "Load", isSelected: selectedTab == .load) {
                        selectedTab = .load
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Content
                ScrollView {
                    VStack(spacing: 15) {
                        switch selectedTab {
                        case .save:
                            SaveSlotsSection(
                                showConfirmation: $showConfirmation,
                                confirmationAction: $confirmationAction,
                                confirmationMessage: $confirmationMessage,
                                isPresented: $isPresented
                            )
                        case .load:
                            LoadSlotsSection(
                                showConfirmation: $showConfirmation,
                                confirmationAction: $confirmationAction,
                                confirmationMessage: $confirmationMessage,
                                isPresented: $isPresented
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .customAlert(
            isPresented: $showConfirmation,
            title: "Confirm Action",
            message: confirmationMessage,
            primaryButton: "Confirm",
            primaryAction: { confirmationAction?() },
            secondaryButton: "Cancel"
        )
    }

    struct SaveLoadTabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Constants.Colors.accent.opacity(0.3) : Color.clear)
                    )
            }
        }
    }
}

struct SaveSlotsSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showConfirmation: Bool
    @Binding var confirmationAction: (() -> Void)?
    @Binding var confirmationMessage: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 12) {
            ForEach(gameManager.saveManager.saveSlots) { slot in
                SaveSlotCard(
                    slot: slot,
                    showConfirmation: $showConfirmation,
                    confirmationAction: $confirmationAction,
                    confirmationMessage: $confirmationMessage,
                    isPresented: $isPresented
                )
            }
        }
    }
}

struct LoadSlotsSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showConfirmation: Bool
    @Binding var confirmationAction: (() -> Void)?
    @Binding var confirmationMessage: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 12) {
            ForEach(gameManager.saveManager.saveSlots) { slot in
                LoadSlotCard(
                    slot: slot,
                    showConfirmation: $showConfirmation,
                    confirmationAction: $confirmationAction,
                    confirmationMessage: $confirmationMessage,
                    isPresented: $isPresented
                )
            }
        }
    }
}

struct SaveSlotCard: View {
    @EnvironmentObject var gameManager: GameManager
    let slot: SaveSlotInfo
    @Binding var showConfirmation: Bool
    @Binding var confirmationAction: (() -> Void)?
    @Binding var confirmationMessage: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Slot \(slot.slotNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if !slot.isEmpty {
                    Button(action: {
                        confirmationMessage = "Delete save in Slot \(slot.slotNumber)?"
                        confirmationAction = {
                            _ = gameManager.deleteSlot(slot.slotNumber)
                        }
                        showConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
            }

            if slot.isEmpty {
                Text("Empty Slot")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(slot.gameName ?? "Unknown")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)

                    if let date = slot.saveDate {
                        Text(formatDate(date))
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }
            }

            Button(action: {
                guard gameManager.characterManager.character != nil else { return }

                confirmationMessage = slot.isEmpty ?
                    "Save to Slot \(slot.slotNumber)?" :
                    "Overwrite save in Slot \(slot.slotNumber)?"
                confirmationAction = {
                    if gameManager.saveGame(to: slot.slotNumber) {
                        isPresented = false
                    }
                }
                showConfirmation = true
            }) {
                Text(slot.isEmpty ? "Save Here" : "Overwrite")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Constants.Colors.accent)
                    .cornerRadius(8)
            }
            .disabled(gameManager.characterManager.character == nil)
        }
        .padding(14)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct LoadSlotCard: View {
    @EnvironmentObject var gameManager: GameManager
    let slot: SaveSlotInfo
    @Binding var showConfirmation: Bool
    @Binding var confirmationAction: (() -> Void)?
    @Binding var confirmationMessage: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Slot \(slot.slotNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if !slot.isEmpty {
                    Button(action: {
                        confirmationMessage = "Delete save in Slot \(slot.slotNumber)?"
                        confirmationAction = {
                            _ = gameManager.deleteSlot(slot.slotNumber)
                        }
                        showConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
            }

            if slot.isEmpty {
                Text("Empty Slot")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .frame(height: 40)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(slot.gameName ?? "Unknown")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)

                    if let date = slot.saveDate {
                        Text(formatDate(date))
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    if let approval = slot.approvalRating {
                        Text("Approval: \(String(format: "%.1f%%", approval))")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }

                Button(action: {
                    confirmationMessage = "Load save from Slot \(slot.slotNumber)? Current progress will be lost."
                    confirmationAction = {
                        if gameManager.loadGame(from: slot.slotNumber) {
                            isPresented = false
                        }
                    }
                    showConfirmation = true
                }) {
                    Text("Load Game")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Constants.Colors.political)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .opacity(slot.isEmpty ? 0.5 : 1.0)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Admin Card

struct AdminCard: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showAdminPanel: Bool
    @State private var showWarConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                    .font(.system(size: 12))
                    .foregroundColor(.red)

                Text("ADMIN")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.red)
            }

            Button(action: {
                showAdminPanel = true
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 28, height: 28)

                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }

                    Text("Select Career Position")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                )
            }

            // Force Defensive War Button
            if gameManager.character?.currentPosition?.level == 5 {
                Button(action: {
                    showWarConfirmation = true
                }) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))

                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        }

                        Text("Force Defensive War")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .customAlert(
            isPresented: $showWarConfirmation,
            title: "Force Defensive War?",
            message: "This will immediately trigger a random AI country to declare war on the USA for testing purposes.",
            primaryButton: "Declare War",
            primaryAction: { forceDefensiveWar() },
            secondaryButton: "Cancel"
        )
    }

    private func forceDefensiveWar() {
        guard let character = gameManager.character else { return }
        guard character.currentPosition?.level == 5 else { return }

        let playerCountryCode = character.country
        let allCountries = gameManager.globalCountryState.countries

        // Find a suitable aggressor (exclude player)
        let potentialAggressors = allCountries.filter { country in
            country.code != playerCountryCode && country.militaryStrength > 0
        }

        guard let aggressor = potentialAggressors.randomElement() else {
            print("❌ No suitable aggressor found")
            return
        }

        // Get player's military strength
        guard let playerCountry = allCountries.first(where: { $0.code == playerCountryCode }) else {
            print("❌ Player country not found")
            return
        }

        // Select a random justification
        let justifications: [War.WarJustification] = [
            .territorialDispute,
            .resourceControl,
            .regimeChange,
            .preemptiveStrike,
            .retaliation
        ]
        let justification = justifications.randomElement() ?? .territorialDispute

        // Declare war
        if let war = gameManager.warEngine.declareWar(
            attacker: aggressor.code,
            defender: playerCountryCode,
            type: .offensive,
            justification: justification,
            attackerStrength: aggressor.militaryStrength,
            defenderStrength: playerCountry.militaryStrength,
            currentDate: character.currentDate
        ) {
            // Create and show defensive war notification
            let notification = DefensiveWarNotification(
                war: war,
                aggressorName: aggressor.name,
                aggressorStrength: aggressor.militaryStrength,
                playerStrength: playerCountry.militaryStrength,
                justification: justification
            )
            gameManager.pendingDefensiveWarNotification = notification

            print("\n🚨 ADMIN: FORCED DEFENSIVE WAR")
            print("Aggressor: \(aggressor.name)")
            print("Defender: USA")
            print("Justification: \(justification.rawValue)")
            print("═══════════════════════════════════════\n")
        }
    }
}

// MARK: - Admin Panel

struct AdminPanel: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @State private var showConfirmation = false
    @State private var selectedPosition: Position?

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(Constants.Colors.accent)

                    Spacer()

                    Text("ADMIN: Select Position")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)

                    Spacer()

                    Color.clear.frame(width: 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Warning Banner
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)

                    Text("Admin mode: Bypass normal career progression")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.orange.opacity(0.1))

                // Positions List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(USAPositions.allPositions, id: \.id) { position in
                            AdminPositionCard(
                                position: position,
                                isCurrentPosition: gameManager.character?.currentPosition?.id == position.id,
                                onSelect: {
                                    selectedPosition = position
                                    showConfirmation = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .customAlert(
            isPresented: $showConfirmation,
            title: "Set Position?",
            message: "Set your position to \(selectedPosition?.title ?? "Unknown")? This will bypass all requirements.",
            primaryButton: "Confirm",
            primaryAction: {
                if let position = selectedPosition {
                    setPosition(position)
                }
            },
            secondaryButton: "Cancel"
        )
    }

    private func setPosition(_ position: Position) {
        guard var character = gameManager.character else { return }

        // Remove from current position if exists
        if let currentPos = character.currentPosition,
           let index = character.careerHistory.firstIndex(where: { $0.position.id == currentPos.id }) {
            var entry = character.careerHistory[index]
            entry.endDate = character.currentDate
            entry.finalApproval = character.approvalRating
            character.careerHistory[index] = entry
        }

        // Set new position
        character.currentPosition = position

        // Add to career history if not already there
        if !character.careerHistory.contains(where: { $0.position.id == position.id }) {
            let newEntry = CareerEntry(position: position, startDate: character.currentDate)
            character.careerHistory.append(newEntry)
        }

        // Update character
        gameManager.characterManager.updateCharacter(character)

        isPresented = false
    }
}

struct AdminPositionCard: View {
    let position: Position
    let isCurrentPosition: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Position icon
                ZStack {
                    Circle()
                        .fill(isCurrentPosition ? Constants.Colors.achievement.opacity(0.2) : Color.red.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: isCurrentPosition ? "star.fill" : "circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isCurrentPosition ? Constants.Colors.achievement : .red)
                }

                // Position info
                VStack(alignment: .leading, spacing: 4) {
                    Text(position.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    HStack(spacing: 12) {
                        Label("\(position.level)", systemImage: "chart.bar.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Label("\(position.minAge)+ years", systemImage: "person.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Label("\(position.termLengthYears)y term", systemImage: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    if isCurrentPosition {
                        Text("CURRENT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Constants.Colors.achievement)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Constants.Colors.achievement.opacity(0.2))
                            )
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isCurrentPosition ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isCurrentPosition ? Constants.Colors.achievement.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .disabled(isCurrentPosition)
        .opacity(isCurrentPosition ? 0.7 : 1.0)
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameManager.shared)
}
