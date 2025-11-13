//
//  DiplomacyView.swift
//  PoliticianSim
//
//  International relations management interface
//

import SwiftUI

struct DiplomacyView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab: DiplomacyTab = .countries
    @State private var selectedCountry: CountryRelationship?

    enum DiplomacyTab {
        case countries, treaties, policy
    }

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header
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

                    Text("Diplomacy")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Tab Selector
                DiplomacyTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Diplomatic Summary
                DiplomaticSummaryBar()
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                // Content
                ScrollView {
                    VStack(spacing: 15) {
                        switch selectedTab {
                        case .countries:
                            CountriesSection(selectedCountry: $selectedCountry)
                        case .treaties:
                            TreatiesSection()
                        case .policy:
                            ForeignPolicySection()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }

            // Side Menu
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
        .sheet(item: $selectedCountry) { country in
            CountryDetailSheet(country: country, selectedCountry: $selectedCountry)
                .environmentObject(gameManager)
        }
    }
}

// MARK: - Diplomatic Summary Bar

struct DiplomaticSummaryBar: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        let summary = gameManager.diplomacyManager.getDiplomaticSummary()

        HStack(spacing: 20) {
            DiplomaticStatItem(label: "Allies", value: "\(summary.allies)", color: .green)
            DiplomaticStatItem(label: "Treaties", value: "\(summary.treaties)", color: .blue)
            DiplomaticStatItem(label: "Avg Relations", value: String(format: "%.0f", summary.averageRelationship), color: summary.averageRelationship >= 0 ? .green : .red)
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
}

struct DiplomaticStatItem: View {
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

struct DiplomacyTabSelector: View {
    @Binding var selectedTab: DiplomacyView.DiplomacyTab

    var body: some View {
        HStack(spacing: 8) {
            DiplomacyTabButton(title: "Countries", isSelected: selectedTab == .countries) {
                selectedTab = .countries
            }
            DiplomacyTabButton(title: "Treaties", isSelected: selectedTab == .treaties) {
                selectedTab = .treaties
            }
            DiplomacyTabButton(title: "Policy", isSelected: selectedTab == .policy) {
                selectedTab = .policy
            }
        }
    }

    struct DiplomacyTabButton: View {
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
                            .fill(isSelected ? Constants.Colors.diplomacy.opacity(0.3) : Color.clear)
                    )
            }
        }
    }
}

// MARK: - Countries Section

struct CountriesSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedCountry: CountryRelationship?

    var body: some View {
        VStack(spacing: 15) {
            let grouped = gameManager.diplomacyManager.getRelationshipsByStatus()

            ForEach(grouped, id: \.0) { status, countries in
                VStack(alignment: .leading, spacing: 12) {
                    Text(status.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .padding(.leading, 4)

                    ForEach(countries) { country in
                        CountryCard(country: country) {
                            selectedCountry = country
                        }
                    }
                }
            }
        }
    }
}

struct CountryCard: View {
    let country: CountryRelationship
    let onTap: () -> Void

    var statusColor: Color {
        Color(
            red: country.relationshipStatus.color.red,
            green: country.relationshipStatus.color.green,
            blue: country.relationshipStatus.color.blue
        )
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Country flag placeholder
                Circle()
                    .fill(statusColor.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(country.countryName.prefix(2)))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(statusColor)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(country.countryName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Text(country.relationshipStatus.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(statusColor)

                        Text("•")
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text(country.tradeLevel.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%+.0f", country.relationshipScore))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(statusColor)

                    if !country.treaties.isEmpty {
                        Text("\(country.treaties.count) treaties")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(Constants.Colors.secondaryText)
                    .font(.system(size: 14))
            }
            .padding()
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Treaties Section

struct TreatiesSection: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 15) {
            if gameManager.diplomacyManager.activeTreaties.isEmpty {
                EmptyDiplomacyState(
                    icon: "doc.text",
                    message: "No active treaties",
                    subtitle: "Negotiate treaties with allied nations"
                )
            } else {
                ForEach(gameManager.diplomacyManager.activeTreaties) { treaty in
                    TreatyCard(treaty: treaty)
                }
            }
        }
    }
}

struct TreatyCard: View {
    @EnvironmentObject var gameManager: GameManager
    let treaty: Treaty
    @State private var showingRevokeAlert = false

    var treatyColor: Color {
        Color(
            red: treaty.type.color.red,
            green: treaty.type.color.green,
            blue: treaty.type.color.blue
        )
    }

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: treaty.type.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(treatyColor)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(treaty.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text(treaty.type.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(treatyColor)
                }

                Spacer()
            }

            Text(treaty.description)
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.secondaryText)
                .lineLimit(2)

            // Benefits
            HStack(spacing: 15) {
                if treaty.benefits.economicBonus > 0 {
                    BenefitBadge(icon: "chart.line.uptrend.xyaxis", value: "+\(String(format: "%.1f", treaty.benefits.economicBonus))%", label: "Economy")
                }
                if treaty.benefits.approvalBonus > 0 {
                    BenefitBadge(icon: "hand.thumbsup.fill", value: "+\(String(format: "%.1f", treaty.benefits.approvalBonus))%", label: "Approval")
                }
                if treaty.benefits.securityBonus > 0 {
                    BenefitBadge(icon: "shield.fill", value: "+\(String(format: "%.1f", treaty.benefits.securityBonus))%", label: "Security")
                }
            }

            HStack {
                Text("Signed: \(formatDate(treaty.signedDate))")
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Button(action: {
                    showingRevokeAlert = true
                }) {
                    Text("Revoke")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .alert(isPresented: $showingRevokeAlert) {
            Alert(
                title: Text("Revoke Treaty"),
                message: Text("This will damage relations. Are you sure?"),
                primaryButton: .destructive(Text("Revoke")) {
                    var char = character
                    _ = gameManager.diplomacyManager.revokeTreaty(treaty.id, character: &char)
                    gameManager.characterManager.updateCharacter(char)
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct BenefitBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(value)
                .font(.system(size: 11, weight: .semibold))
            Text(label)
                .font(.system(size: 10))
        }
        .foregroundColor(.green)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.green.opacity(0.2))
        .cornerRadius(6)
    }
}

// MARK: - Foreign Policy Section

struct ForeignPolicySection: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showingChangeAlert = false
    @State private var selectedStance: ForeignPolicyStance?

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var body: some View {
        VStack(spacing: 15) {
            // Current stance
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Stance")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(gameManager.diplomacyManager.foreignPolicyStance.rawValue)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Text(gameManager.diplomacyManager.foreignPolicyStance.description)
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    Spacer()
                }
                .padding()
                .background(Constants.Colors.cardBackground)
                .cornerRadius(Constants.CornerRadius.card)
            }

            // Available stances
            VStack(alignment: .leading, spacing: 12) {
                Text("Change Policy Stance")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                ForEach(ForeignPolicyStance.allCases, id: \.self) { stance in
                    if stance != gameManager.diplomacyManager.foreignPolicyStance {
                        PolicyStanceCard(stance: stance) {
                            selectedStance = stance
                            showingChangeAlert = true
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showingChangeAlert) {
            Alert(
                title: Text("Change Foreign Policy"),
                message: Text("This will affect all international relationships."),
                primaryButton: .default(Text("Change")) {
                    if let stance = selectedStance {
                        var char = character
                        gameManager.diplomacyManager.changeForeignPolicyStance(stance, character: &char)
                        gameManager.characterManager.updateCharacter(char)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct PolicyStanceCard: View {
    let stance: ForeignPolicyStance
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(stance.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "arrow.right.circle")
                        .foregroundColor(Constants.Colors.diplomacy)
                }

                Text(stance.description)
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)

                HStack(spacing: 12) {
                    ImpactBadge(
                        label: "Relations",
                        value: String(format: "%+.0f%%", stance.relationshipModifier * 100),
                        isPositive: stance.relationshipModifier >= 0
                    )
                    ImpactBadge(
                        label: "Approval",
                        value: String(format: "%+.1f%%", stance.approvalImpact),
                        isPositive: stance.approvalImpact >= 0
                    )
                }
            }
            .padding()
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImpactBadge: View {
    let label: String
    let value: String
    let isPositive: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Constants.Colors.secondaryText)
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isPositive ? .green : .red)
        }
    }
}

// MARK: - Country Detail Sheet

struct CountryDetailSheet: View {
    let country: CountryRelationship
    @Binding var selectedCountry: CountryRelationship?
    @EnvironmentObject var gameManager: GameManager
    @State private var showingActionSheet = false
    @State private var selectedAction: DiplomaticAction?
    @State private var actionMessage = ""
    @State private var showingResult = false

    private var character: Character {
        gameManager.characterManager.character ?? gameManager.characterManager.createTestCharacter()
    }

    var statusColor: Color {
        Color(
            red: country.relationshipStatus.color.red,
            green: country.relationshipStatus.color.green,
            blue: country.relationshipStatus.color.blue
        )
    }

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        selectedCountry = nil
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
                        // Country header
                        HStack(spacing: 16) {
                            Circle()
                                .fill(statusColor.opacity(0.3))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(String(country.countryName.prefix(2)))
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(statusColor)
                                )

                            VStack(alignment: .leading, spacing: 6) {
                                Text(country.countryName)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)

                                Text(country.relationshipStatus.rawValue)
                                    .font(.system(size: 16))
                                    .foregroundColor(statusColor)
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Relationship score
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Relationship Score")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            HStack {
                                Text(String(format: "%.1f", country.relationshipScore))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(statusColor)

                                Spacer()

                                Text(country.tradeLevel.rawValue)
                                    .font(.system(size: 14))
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                        }
                        .padding()
                        .background(Constants.Colors.cardBackground)
                        .cornerRadius(Constants.CornerRadius.card)

                        // Treaties
                        if !country.treaties.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active Treaties")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                ForEach(country.treaties) { treaty in
                                    TreatyListItem(treaty: treaty)
                                }
                            }
                        }

                        // Recent events
                        if !country.recentEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Events")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                ForEach(country.recentEvents.suffix(5).reversed()) { event in
                                    EventListItem(event: event)
                                }
                            }
                        }

                        // Available actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Diplomatic Actions")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Constants.Colors.secondaryText)

                            let actions = DiplomaticAction.getAvailableActions(for: country, character: character)
                            ForEach(actions) { action in
                                DiplomaticActionButton(action: action) {
                                    selectedAction = action
                                    showingActionSheet = true
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .alert(isPresented: $showingActionSheet) {
            if let action = selectedAction {
                return Alert(
                    title: Text(action.name),
                    message: Text(action.description),
                    primaryButton: .default(Text("Proceed")) {
                        performAction(action)
                    },
                    secondaryButton: .cancel()
                )
            } else {
                return Alert(title: Text("Error"))
            }
        }
        .alert(isPresented: $showingResult) {
            Alert(
                title: Text("Action Complete"),
                message: Text(actionMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func performAction(_ action: DiplomaticAction) {
        var char = character
        let result = gameManager.diplomacyManager.performAction(action, with: country.countryName, character: &char)
        gameManager.characterManager.updateCharacter(char)
        actionMessage = result.message
        showingResult = true

        if result.success {
            // Refresh country data
            if let updated = gameManager.diplomacyManager.getRelationship(with: country.countryName) {
                selectedCountry = updated
            }
        }
    }
}

struct TreatyListItem: View {
    let treaty: Treaty

    var treatyColor: Color {
        Color(
            red: treaty.type.color.red,
            green: treaty.type.color.green,
            blue: treaty.type.color.blue
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: treaty.type.iconName)
                .foregroundColor(treatyColor)
                .font(.system(size: 16))

            Text(treaty.type.rawValue)
                .font(.system(size: 14))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(treatyColor.opacity(0.2))
        .cornerRadius(8)
    }
}

struct EventListItem: View {
    let event: DiplomaticEvent

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(event.relationshipChange >= 0 ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(event.title)
                .font(.system(size: 13))
                .foregroundColor(.white)

            Spacer()

            Text(String(format: "%+.0f", event.relationshipChange))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(event.relationshipChange >= 0 ? .green : .red)
        }
        .padding(.vertical, 6)
    }
}

struct DiplomaticActionButton: View {
    let action: DiplomaticAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: action.type.iconName)
                    .foregroundColor(Constants.Colors.accent)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(action.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    if let cost = action.cost {
                        Text("Cost: $\(formatCurrency(cost))")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)
                    } else if action.reputationCost > 0 {
                        Text("Cost: \(action.reputationCost) Reputation")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Constants.Colors.secondaryText)
                    .font(.system(size: 12))
            }
            .padding()
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        let millions = number.doubleValue / 1_000_000
        return String(format: "%.1fM", millions)
    }
}

// MARK: - Empty State

struct EmptyDiplomacyState: View {
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

#Preview {
    DiplomacyView()
        .environmentObject(GameManager.shared)
}
