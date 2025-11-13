//
//  LawsView.swift
//  PoliticianSim
//
//  Legislative management interface
//

import SwiftUI

struct LawsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab: LawsTab = .drafts
    @State private var showingCreateLaw = false
    @State private var selectedLaw: Law?

    enum LawsTab {
        case drafts, active, enacted, rejected
    }

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        gameManager.navigationManager.toggleMenu()
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("Legislative Affairs")
                        .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        showingCreateLaw = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Constants.Colors.accent)
                    }
                }
                .padding()
                .background(Constants.Colors.cardBackgroundDark)

                // Session Summary
                SessionSummaryBar()

                // Tab Selector
                LawsTabSelector(selectedTab: $selectedTab)

                // Content
                ScrollView {
                    VStack(spacing: 15) {
                        switch selectedTab {
                        case .drafts:
                            DraftsSection(selectedLaw: $selectedLaw)
                        case .active:
                            ActiveLawsSection(selectedLaw: $selectedLaw)
                        case .enacted:
                            EnactedLawsSection(selectedLaw: $selectedLaw)
                        case .rejected:
                            RejectedLawsSection(selectedLaw: $selectedLaw)
                        }
                    }
                    .padding()
                }
            }

            // Side Menu
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
        .sheet(isPresented: $showingCreateLaw) {
            CreateLawSheet(isPresented: $showingCreateLaw)
                .environmentObject(gameManager)
        }
        .sheet(item: $selectedLaw) { law in
            LawDetailSheet(law: law, selectedLaw: $selectedLaw)
                .environmentObject(gameManager)
        }
        .onAppear {
            if gameManager.lawsManager.currentSession == nil {
                gameManager.lawsManager.initializeSession(for: character)
            }
        }
    }
}

// MARK: - Session Summary Bar

struct SessionSummaryBar: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        let summary = gameManager.lawsManager.getSessionSummary()

        HStack(spacing: 20) {
            SessionStatItem(label: "Proposed", value: "\(summary.proposed)", color: .blue)
            SessionStatItem(label: "Passed", value: "\(summary.passed)", color: .green)
            SessionStatItem(label: "Rejected", value: "\(summary.rejected)", color: .red)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color.black.opacity(0.3))
    }
}

struct SessionStatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)
        }
    }
}

// MARK: - Tab Selector

struct LawsTabSelector: View {
    @Binding var selectedTab: LawsView.LawsTab

    var body: some View {
        HStack(spacing: 0) {
            LawsTabButton(title: "Drafts", tab: .drafts, selectedTab: $selectedTab)
            LawsTabButton(title: "Active", tab: .active, selectedTab: $selectedTab)
            LawsTabButton(title: "Enacted", tab: .enacted, selectedTab: $selectedTab)
            LawsTabButton(title: "Rejected", tab: .rejected, selectedTab: $selectedTab)
        }
        .background(Color.black.opacity(0.3))
    }
}

struct LawsTabButton: View {
    let title: String
    let tab: LawsView.LawsTab
    @Binding var selectedTab: LawsView.LawsTab

    var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? Constants.Colors.accent : Constants.Colors.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ? Color.white.opacity(0.1) : Color.clear
                )
        }
    }
}

// MARK: - Drafts Section

struct DraftsSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedLaw: Law?

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var body: some View {
        VStack(spacing: 15) {
            if gameManager.lawsManager.draftLaws.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    message: "No draft laws",
                    subtitle: "Tap + to create a new law"
                )
            } else {
                ForEach(gameManager.lawsManager.draftLaws) { law in
                    LawCard(law: law, canInteract: true) {
                        selectedLaw = law
                    }
                }
            }
        }
    }
}

// MARK: - Active Laws Section

struct ActiveLawsSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedLaw: Law?

    var body: some View {
        VStack(spacing: 15) {
            if gameManager.lawsManager.activeLaws.isEmpty {
                EmptyStateView(
                    icon: "doc.on.doc",
                    message: "No active legislation",
                    subtitle: "Propose a law from your drafts"
                )
            } else {
                ForEach(gameManager.lawsManager.activeLaws) { law in
                    LawCard(law: law, canInteract: true) {
                        selectedLaw = law
                    }
                }
            }
        }
    }
}

// MARK: - Enacted Laws Section

struct EnactedLawsSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedLaw: Law?

    var body: some View {
        VStack(spacing: 15) {
            if gameManager.lawsManager.enactedLaws.isEmpty {
                EmptyStateView(
                    icon: "checkmark.seal.fill",
                    message: "No enacted laws",
                    subtitle: "Pass legislation to see it here"
                )
            } else {
                ForEach(gameManager.lawsManager.enactedLaws) { law in
                    LawCard(law: law, canInteract: false) {
                        selectedLaw = law
                    }
                }
            }
        }
    }
}

// MARK: - Rejected Laws Section

struct RejectedLawsSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedLaw: Law?

    var body: some View {
        VStack(spacing: 15) {
            if gameManager.lawsManager.rejectedLaws.isEmpty {
                EmptyStateView(
                    icon: "xmark.circle",
                    message: "No rejected laws",
                    subtitle: "Failed legislation appears here"
                )
            } else {
                ForEach(gameManager.lawsManager.rejectedLaws) { law in
                    LawCard(law: law, canInteract: false) {
                        selectedLaw = law
                    }
                }
            }
        }
    }
}

// MARK: - Law Card

struct LawCard: View {
    let law: Law
    let canInteract: Bool
    let onTap: () -> Void

    var categoryColor: Color {
        Color(
            red: law.category.color.red,
            green: law.category.color.green,
            blue: law.category.color.blue
        )
    }

    var statusColor: Color {
        Color(
            red: law.status.color.red,
            green: law.status.color.green,
            blue: law.status.color.blue
        )
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: law.category.iconName)
                        .foregroundColor(categoryColor)
                        .font(.system(size: 20))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(law.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text(law.category.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(categoryColor)
                    }

                    Spacer()
                }

                // Description
                Text(law.description)
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .lineLimit(2)

                // Status and Stats
                HStack {
                    StatusBadge(status: law.status)

                    Spacer()

                    if law.votesFor > 0 || law.votesAgainst > 0 {
                        HStack(spacing: 8) {
                            Text("👍 \(law.votesFor)")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("👎 \(law.votesAgainst)")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 10))
                        Text("\(Int(law.publicSupport))%")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(law.publicSupport >= 50 ? .green : .orange)
                }
            }
            .padding()
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusBadge: View {
    let status: Law.LawStatus

    var statusColor: Color {
        Color(
            red: status.color.red,
            green: status.color.green,
            blue: status.color.blue
        )
    }

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(8)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let message: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.5))

            Text(message)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.secondaryText.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Create Law Sheet

struct CreateLawSheet: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @State private var selectedCategory: Law.LawCategory = .tax

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Draft New Law")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }
                .padding()

                ScrollView {
                    VStack(spacing: 15) {
                        Text("Select a category to draft legislation")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.secondaryText)
                            .padding(.bottom, 10)

                        ForEach(Law.LawCategory.allCases, id: \.self) { category in
                            CategoryOptionCard(
                                category: category,
                                isSelected: selectedCategory == category,
                                onSelect: {
                                    selectedCategory = category
                                }
                            )
                        }
                    }
                    .padding()
                }

                // Create Button
                Button(action: {
                    _ = gameManager.lawsManager.createLaw(
                        category: selectedCategory,
                        character: character
                    )
                    isPresented = false
                }) {
                    Text("Draft Law")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.accent)
                        .cornerRadius(Constants.CornerRadius.card)
                }
                .padding()
            }
        }
    }
}

struct CategoryOptionCard: View {
    let category: Law.LawCategory
    let isSelected: Bool
    let onSelect: () -> Void

    var categoryColor: Color {
        Color(
            red: category.color.red,
            green: category.color.green,
            blue: category.color.blue
        )
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 15) {
                Image(systemName: category.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(categoryColor)
                    .frame(width: 40)

                Text(category.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Constants.Colors.accent)
                        .font(.system(size: 24))
                }
            }
            .padding()
            .background(
                isSelected ? Constants.Colors.accent.opacity(0.2) : Constants.Colors.cardBackground
            )
            .cornerRadius(Constants.CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.card)
                    .stroke(isSelected ? Constants.Colors.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Law Detail Sheet

struct LawDetailSheet: View {
    let law: Law
    @Binding var selectedLaw: Law?
    @EnvironmentObject var gameManager: GameManager
    @State private var showingConfirmation = false
    @State private var actionMessage = ""

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var categoryColor: Color {
        Color(
            red: law.category.color.red,
            green: law.category.color.green,
            blue: law.category.color.blue
        )
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        selectedLaw = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    Spacer()
                }
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title and Category
                        HStack {
                            Image(systemName: law.category.iconName)
                                .font(.system(size: 30))
                                .foregroundColor(categoryColor)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(law.title)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)

                                Text(law.category.rawValue)
                                    .font(.system(size: 14))
                                    .foregroundColor(categoryColor)
                            }
                        }

                        StatusBadge(status: law.status)

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            Text(law.description)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Stats
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Statistics")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            DetailStatRow(label: "Public Support", value: "\(Int(law.publicSupport))%")
                            DetailStatRow(label: "Sponsor", value: law.sponsor)
                            DetailStatRow(label: "Legislative Body", value: law.legislativeBody.rawValue)

                            if law.votesFor > 0 || law.votesAgainst > 0 {
                                DetailStatRow(label: "Votes For", value: "\(law.votesFor)")
                                DetailStatRow(label: "Votes Against", value: "\(law.votesAgainst)")
                                DetailStatRow(label: "Passage %", value: String(format: "%.1f%%", law.passagePercentage))
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Effects
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Projected Effects")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            DetailStatRow(
                                label: "Approval Impact",
                                value: String(format: "%+.1f%%", law.effects.approvalChange),
                                valueColor: law.effects.approvalChange >= 0 ? .green : .red
                            )
                            DetailStatRow(
                                label: "Economic Impact",
                                value: String(format: "%+.1f%%", law.effects.economicImpact),
                                valueColor: law.effects.economicImpact >= 0 ? .green : .red
                            )
                            DetailStatRow(
                                label: "Budget Impact",
                                value: formatCurrency(law.effects.budgetImpact),
                                valueColor: law.effects.budgetImpact <= 0 ? .green : .red
                            )

                            if let cost = law.implementationCost {
                                DetailStatRow(
                                    label: "Implementation Cost",
                                    value: formatCurrency(cost),
                                    valueColor: .orange
                                )
                            }
                        }
                    }
                    .padding()
                }

                // Actions
                if law.status == .draft {
                    DraftActions(law: law, actionMessage: $actionMessage)
                } else if law.status == .proposed || law.status == .inCommittee ||
                          law.status == .underDebate || law.status == .voting {
                    ActiveLawActions(law: law, actionMessage: $actionMessage)
                }
            }
        }
        .alert(isPresented: $showingConfirmation) {
            Alert(
                title: Text("Action Complete"),
                message: Text(actionMessage),
                dismissButton: .default(Text("OK")) {
                    if law.status == .passed || law.status == .rejected {
                        selectedLaw = nil
                    }
                }
            )
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

struct DetailStatRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}

struct DraftActions: View {
    let law: Law
    @Binding var actionMessage: String
    @EnvironmentObject var gameManager: GameManager
    @State private var showingAlert = false

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var canPropose: Bool {
        gameManager.lawsManager.canProposeLaw(character: character)
    }

    var body: some View {
        VStack(spacing: 12) {
            if !canPropose {
                Text("Insufficient reputation (need 20+)")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
            }

            HStack(spacing: 12) {
                Button(action: {
                    _ = gameManager.lawsManager.deleteDraftLaw(lawId: law.id)
                    actionMessage = "Law deleted"
                    showingAlert = true
                }) {
                    Text("Delete")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(Constants.CornerRadius.card)
                }

                Button(action: {
                    var char = character
                    let result = gameManager.lawsManager.proposeLaw(lawId: law.id, character: &char)
                    gameManager.characterManager.updateCharacter(char)
                    actionMessage = result.message
                    showingAlert = true
                }) {
                    Text("Propose Law (-5 Reputation)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canPropose ? Constants.Colors.accent : Color.gray)
                        .cornerRadius(Constants.CornerRadius.card)
                }
                .disabled(!canPropose)
            }
            .padding()
        }
        .background(Color.black.opacity(0.3))
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Action Complete"),
                message: Text(actionMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ActiveLawActions: View {
    let law: Law
    @Binding var actionMessage: String
    @EnvironmentObject var gameManager: GameManager
    @State private var showingAlert = false

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var actionButtonText: String {
        switch law.status {
        case .proposed: return "Send to Committee"
        case .inCommittee: return "Move to Debate"
        case .underDebate: return "Call for Vote"
        case .voting: return "Hold Vote"
        default: return "Advance"
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: {
                    var char = character
                    let result = gameManager.lawsManager.withdrawLaw(lawId: law.id, character: &char)
                    gameManager.characterManager.updateCharacter(char)
                    actionMessage = result.message
                    showingAlert = true
                }) {
                    Text("Withdraw")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.7))
                        .cornerRadius(Constants.CornerRadius.card)
                }

                Button(action: {
                    var char = character
                    let result = gameManager.lawsManager.advanceLaw(lawId: law.id, character: &char)
                    gameManager.characterManager.updateCharacter(char)
                    actionMessage = result.message
                    showingAlert = true
                }) {
                    Text(actionButtonText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.accent)
                        .cornerRadius(Constants.CornerRadius.card)
                }
            }
            .padding()
        }
        .background(Color.black.opacity(0.3))
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Action Complete"),
                message: Text(actionMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    LawsView()
        .environmentObject(GameManager.shared)
}
