//
//  PoliciesView.swift
//  PoliticianSim
//
//  Policies browsing and enactment view
//

import SwiftUI

struct PoliciesView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCategory: Policy.PolicyCategory?
    @State private var showingPolicyDetail: Policy?
    @State private var selectedTab: PolicyTab = .available

    enum PolicyTab {
        case available
        case proposed
        case enacted
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

                    Text("Policies")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Tab selector
                PolicyTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                if let character = gameManager.character {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            switch selectedTab {
                            case .available:
                                AvailablePoliciesSection(
                                    character: character,
                                    selectedCategory: $selectedCategory,
                                    showingPolicyDetail: $showingPolicyDetail
                                )
                            case .proposed:
                                ProposedPoliciesSection(
                                    character: character,
                                    showingPolicyDetail: $showingPolicyDetail
                                )
                            case .enacted:
                                EnactedPoliciesSection(
                                    character: character,
                                    showingPolicyDetail: $showingPolicyDetail
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                } else {
                    PlaceholderEmptyState(message: "No character found")
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)

            // Policy detail overlay
            if let policy = showingPolicyDetail {
                PolicyDetailView(
                    policy: policy,
                    character: gameManager.character!,
                    isShowing: $showingPolicyDetail
                )
            }
        }
    }
}

// MARK: - Tab Selector

struct PolicyTabSelector: View {
    @Binding var selectedTab: PoliciesView.PolicyTab

    var body: some View {
        HStack(spacing: 12) {
            TabButton(title: "Available", isSelected: selectedTab == .available) {
                selectedTab = .available
            }
            TabButton(title: "Proposed", isSelected: selectedTab == .proposed) {
                selectedTab = .proposed
            }
            TabButton(title: "Enacted", isSelected: selectedTab == .enacted) {
                selectedTab = .enacted
            }
        }
    }

    struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Constants.Colors.political.opacity(0.3) : Color.clear)
                    )
            }
        }
    }
}

// MARK: - Available Policies Section

struct AvailablePoliciesSection: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character
    @Binding var selectedCategory: Policy.PolicyCategory?
    @Binding var showingPolicyDetail: Policy?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryFilterButton(
                        title: "All",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }

                    ForEach(Policy.PolicyCategory.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            color: Color(
                                red: category.color.red,
                                green: category.color.green,
                                blue: category.color.blue
                            )
                        ) {
                            selectedCategory = category
                        }
                    }
                }
            }

            // Available policies
            let availablePolicies = gameManager.policyManager.getAvailablePolicies(for: character)
            let filteredPolicies = selectedCategory == nil
                ? availablePolicies
                : availablePolicies.filter { $0.category == selectedCategory }

            if filteredPolicies.isEmpty {
                EmptyPolicyState(message: "No policies available in this category")
            } else {
                ForEach(filteredPolicies) { policy in
                    PolicyCard(
                        policy: policy,
                        character: character,
                        actionType: .propose,
                        showingPolicyDetail: $showingPolicyDetail
                    )
                }
            }
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    var color: Color = Constants.Colors.political
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.05))
                )
        }
    }
}

// MARK: - Proposed Policies Section

struct ProposedPoliciesSection: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character
    @Binding var showingPolicyDetail: Policy?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if gameManager.policyManager.proposedPolicies.isEmpty {
                EmptyPolicyState(message: "No proposed policies")
            } else {
                ForEach(gameManager.policyManager.proposedPolicies) { policy in
                    PolicyCard(
                        policy: policy,
                        character: character,
                        actionType: .enact,
                        showingPolicyDetail: $showingPolicyDetail
                    )
                }
            }
        }
    }
}

// MARK: - Enacted Policies Section

struct EnactedPoliciesSection: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character
    @Binding var showingPolicyDetail: Policy?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if gameManager.policyManager.enactedPolicies.isEmpty {
                EmptyPolicyState(message: "No enacted policies yet")
            } else {
                ForEach(gameManager.policyManager.enactedPolicies) { policy in
                    PolicyCard(
                        policy: policy,
                        character: character,
                        actionType: .repeal,
                        showingPolicyDetail: $showingPolicyDetail
                    )
                }
            }
        }
    }
}

// MARK: - Policy Card

struct PolicyCard: View {
    @EnvironmentObject var gameManager: GameManager
    let policy: Policy
    let character: Character
    let actionType: ActionType
    @Binding var showingPolicyDetail: Policy?

    enum ActionType {
        case propose
        case enact
        case repeal
    }

    var categoryColor: Color {
        Color(
            red: policy.category.color.red,
            green: policy.category.color.green,
            blue: policy.category.color.blue
        )
    }

    var body: some View {
        Button(action: {
            showingPolicyDetail = policy
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Category badge
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.2))
                            .frame(width: 32, height: 32)

                        Image(systemName: policy.category.iconName)
                            .font(.system(size: 14))
                            .foregroundColor(categoryColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(policy.category.rawValue.uppercased())
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(categoryColor)

                        Text(policy.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Support percentage
                    VStack(spacing: 2) {
                        Text("\(Int(policy.supportPercentage))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(supportColor)

                        Text("support")
                            .font(.system(size: 9))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }

                // Description
                Text(policy.description)
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .lineLimit(2)

                Divider()
                    .background(Color.white.opacity(0.2))

                // Effects preview
                HStack(spacing: 16) {
                    if policy.effects.approvalChange != 0 {
                        EffectPreview(
                            icon: "hand.thumbsup.fill",
                            value: formatChange(policy.effects.approvalChange),
                            color: policy.effects.approvalChange > 0 ? Constants.Colors.positive : Constants.Colors.negative
                        )
                    }

                    if policy.effects.reputationChange != 0 {
                        EffectPreview(
                            icon: "star.fill",
                            value: formatChange(Double(policy.effects.reputationChange)),
                            color: policy.effects.reputationChange > 0 ? Constants.Colors.positive : Constants.Colors.negative
                        )
                    }

                    if policy.requirements.costToEnact > 0 {
                        EffectPreview(
                            icon: "dollarsign.circle.fill",
                            value: "-$\(formatMoney(policy.requirements.costToEnact))",
                            color: Constants.Colors.money
                        )
                    }

                    Spacer()
                }

                // Action button
                ActionButton(policy: policy, character: character, actionType: actionType)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(categoryColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var supportColor: Color {
        if policy.supportPercentage >= 60 {
            return Constants.Colors.positive
        } else if policy.supportPercentage >= 40 {
            return Color.yellow
        } else {
            return Constants.Colors.negative
        }
    }

    private func formatChange(_ value: Double) -> String {
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.0f", value))"
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Int(truncating: amount as NSDecimalNumber)
        if value >= 1_000_000 {
            return String(format: "%.1fM", Double(value) / 1_000_000.0)
        } else if value >= 1_000 {
            return String(format: "%.0fK", Double(value) / 1_000.0)
        } else {
            return "\(value)"
        }
    }
}

struct EffectPreview: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

struct ActionButton: View {
    @EnvironmentObject var gameManager: GameManager
    let policy: Policy
    let character: Character
    let actionType: PolicyCard.ActionType
    @State private var showingFeedback = false
    @State private var feedbackMessage = ""

    var body: some View {
        Button(action: performAction) {
            HStack {
                Image(systemName: actionIcon)
                    .font(.system(size: 12))

                Text(actionTitle)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(canPerformAction ? actionColor : Color.gray.opacity(0.3))
            )
        }
        .disabled(!canPerformAction)
        .customAlert(
            isPresented: $showingFeedback,
            title: "Policy Action",
            message: feedbackMessage,
            primaryButton: "OK",
            primaryAction: {}
        )
    }

    private var actionTitle: String {
        switch actionType {
        case .propose: return "Propose Policy"
        case .enact: return "Enact Policy"
        case .repeal: return "Repeal Policy"
        }
    }

    private var actionIcon: String {
        switch actionType {
        case .propose: return "plus.circle.fill"
        case .enact: return "checkmark.circle.fill"
        case .repeal: return "xmark.circle.fill"
        }
    }

    private var actionColor: Color {
        switch actionType {
        case .propose: return Constants.Colors.political
        case .enact: return Constants.Colors.positive
        case .repeal: return Constants.Colors.negative
        }
    }

    private var canPerformAction: Bool {
        switch actionType {
        case .propose:
            return gameManager.policyManager.meetsRequirements(policy: policy, character: character)
        case .enact:
            return gameManager.policyManager.canEnactPolicy(policy: policy, character: character)
        case .repeal:
            return true
        }
    }

    private func performAction() {
        var updatedCharacter = character

        let result: (success: Bool, message: String)

        switch actionType {
        case .propose:
            result = gameManager.policyManager.proposePolicy(policy, character: character)
        case .enact:
            result = gameManager.policyManager.enactPolicy(policy.id, character: &updatedCharacter)
            if result.success {
                gameManager.characterManager.updateCharacter(updatedCharacter)
            }
        case .repeal:
            result = gameManager.policyManager.repealPolicy(policy.id, character: &updatedCharacter)
            if result.success {
                gameManager.characterManager.updateCharacter(updatedCharacter)
            }
        }

        feedbackMessage = result.message
        showingFeedback = true
    }
}

// MARK: - Policy Detail View

struct PolicyDetailView: View {
    @EnvironmentObject var gameManager: GameManager
    let policy: Policy
    let character: Character
    @Binding var isShowing: Policy?
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var categoryColor: Color {
        Color(
            red: policy.category.color.red,
            green: policy.category.color.green,
            blue: policy.category.color.blue
        )
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: { dismissView() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                    }

                    // Category badge
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(categoryColor.opacity(0.2))
                                .frame(width: 40, height: 40)

                            Image(systemName: policy.category.iconName)
                                .font(.system(size: 18))
                                .foregroundColor(categoryColor)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(policy.category.rawValue.uppercased())
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(categoryColor)

                            Text(policy.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }

                    // Description
                    Text(policy.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .lineSpacing(4)

                    Divider().background(Color.white.opacity(0.2))

                    // Public support
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Public Support")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        HStack {
                            Text("\(Int(policy.supportPercentage))%")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(categoryColor)

                            Spacer()
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(categoryColor)
                                    .frame(width: geometry.size.width * CGFloat(policy.supportPercentage / 100.0))
                            }
                        }
                        .frame(height: 8)
                    }

                    Divider().background(Color.white.opacity(0.2))

                    // Effects
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Policy Effects")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        if policy.effects.approvalChange != 0 {
                            EffectRow(
                                icon: "hand.thumbsup.fill",
                                label: "Approval Rating",
                                value: formatChange(policy.effects.approvalChange) + "%",
                                color: policy.effects.approvalChange > 0 ? Constants.Colors.positive : Constants.Colors.negative
                            )
                        }

                        if policy.effects.reputationChange != 0 {
                            EffectRow(
                                icon: "star.fill",
                                label: "Reputation",
                                value: formatChange(Double(policy.effects.reputationChange)),
                                color: policy.effects.reputationChange > 0 ? Constants.Colors.positive : Constants.Colors.negative
                            )
                        }

                        if policy.effects.stressChange != 0 {
                            EffectRow(
                                icon: "brain.head.profile",
                                label: "Stress",
                                value: "+\(policy.effects.stressChange)",
                                color: Color.orange
                            )
                        }

                        if policy.effects.economicImpact != 0 {
                            EffectRow(
                                icon: "chart.line.uptrend.xyaxis",
                                label: "Economic Impact",
                                value: formatChange(policy.effects.economicImpact) + "%",
                                color: policy.effects.economicImpact > 0 ? Constants.Colors.positive : Constants.Colors.negative
                            )
                        }

                        if policy.requirements.costToEnact > 0 {
                            EffectRow(
                                icon: "dollarsign.circle.fill",
                                label: "Cost to Enact",
                                value: "$\(formatMoney(policy.requirements.costToEnact))",
                                color: Constants.Colors.money
                            )
                        }
                    }

                    Divider().background(Color.white.opacity(0.2))

                    // Requirements
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Requirements")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Constants.Colors.secondaryText)

                        ForEach(gameManager.policyManager.getRequirementStatus(policy: policy, character: character), id: \.self) { status in
                            Text(status)
                                .font(.system(size: 12))
                                .foregroundColor(status.hasPrefix("✓") ? Constants.Colors.positive : Constants.Colors.negative)
                        }
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: 400, maxHeight: 650)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                categoryColor.opacity(0.4),
                                categoryColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: categoryColor.opacity(0.3), radius: 30, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
            .padding(.vertical, 60)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private func dismissView() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.8
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isShowing = nil
        }
    }

    private func formatChange(_ value: Double) -> String {
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.0f", value))"
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Int(truncating: amount as NSDecimalNumber)
        if value >= 1_000_000 {
            return String(format: "%.1fM", Double(value) / 1_000_000.0)
        } else if value >= 1_000 {
            return String(format: "%.0fK", Double(value) / 1_000.0)
        } else {
            return "\(value)"
        }
    }
}

struct EffectRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Empty State

struct EmptyPolicyState: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondaryText)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    PoliciesView()
        .environmentObject(GameManager.shared)
}
