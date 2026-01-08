//
//  ActiveWarsView.swift
//  PoliticianSim
//
//  Active wars management
//

import SwiftUI

struct ActiveWarsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showDeclareWarSheet = false
    @State private var selectedWar: War? = nil
    @State private var selectedRebellion: Rebellion? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let hasActiveWars = !gameManager.warEngine.activeWars.isEmpty
                let hasActiveRebellions = !gameManager.territoryManager.activeRebellions.isEmpty
                let hasAnyConflicts = hasActiveWars || hasActiveRebellions

                if !hasAnyConflicts {
                    VStack(spacing: 16) {
                        Image(systemName: "flag.slash")
                            .font(.system(size: 50))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("No Active Wars")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Your nation is currently at peace")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.secondaryText)

                        // Declare War Button
                        Button(action: {
                            showDeclareWarSheet = true
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                Text("Declare War")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: 200)
                            .padding(.vertical, 12)
                            .background(Constants.Colors.negative)
                            .cornerRadius(8)
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    // Active Rebellions Section
                    if hasActiveRebellions {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACTIVE REBELLIONS")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)
                                .padding(.horizontal, 4)

                            ForEach(gameManager.territoryManager.activeRebellions) { rebellion in
                                Button(action: {
                                    selectedRebellion = rebellion
                                }) {
                                    RebellionCard(
                                        rebellion: rebellion,
                                        playerStrength: gameManager.character?.militaryStats?.strength ?? 0
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                    // Active Wars Section
                    if hasActiveWars {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACTIVE WARS")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Constants.Colors.secondaryText)
                                .padding(.horizontal, 4)
                                .padding(.top, hasActiveRebellions ? 16 : 0)

                            ForEach(gameManager.warEngine.activeWars) { war in
                                Button(action: {
                                    selectedWar = war
                                }) {
                                    WarCard(war: war)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                    // Can declare another war (max 3)
                    if gameManager.warEngine.activeWars.count < 3 {
                        Button(action: {
                            showDeclareWarSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Declare Another War")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Constants.Colors.buttonPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Constants.Colors.buttonPrimary.opacity(0.15))
                            .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showDeclareWarSheet) {
            DeclareWarSheet()
                .environmentObject(gameManager)
        }
        .sheet(item: $selectedWar) { war in
            WarDetailsView(war: war)
                .environmentObject(gameManager)
        }
        .sheet(item: $selectedRebellion) { rebellion in
            RebellionDetailView(rebellion: rebellion)
                .environmentObject(gameManager)
        }
    }
}

struct WarCard: View {
    let war: War

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: war.type.icon)
                    .foregroundColor(Constants.Colors.buttonPrimary)

                Text(war.type.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text(war.formattedDuration)
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Text("\(war.attacker) vs \(war.defender)")
                .font(.system(size: 14))
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Casualties")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("\(abs(war.casualtiesByCountry[war.attacker] ?? 0))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.negative)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Cost")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(formatMoney(war.costByCountry[war.attacker] ?? 0))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.negative)
                }
            }

            // War Exhaustion Display
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: war.exhaustionLevel.icon)
                        .font(.system(size: 12))
                        .foregroundColor(exhaustionColor)

                    Text("War Exhaustion: \(war.exhaustionLevel.rawValue)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(exhaustionColor)

                    Spacer()

                    Text(war.formattedExhaustion)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(exhaustionColor)
                }

                // Exhaustion progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                            .cornerRadius(3)

                        Rectangle()
                            .fill(exhaustionColor)
                            .frame(width: geometry.size.width * CGFloat(war.warExhaustion), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)

                // Warning text for high exhaustion
                if war.exhaustionLevel == .high || war.exhaustionLevel == .critical {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                        Text("Public demands peace")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Constants.Colors.negative)
                    .padding(.top, 2)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }

    var exhaustionColor: Color {
        switch war.exhaustionLevel.color {
        case "green": return Constants.Colors.positive
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return Constants.Colors.negative
        default: return .white
        }
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0

        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return formatter.string(from: amount as NSNumber) ?? "$0"
        }
    }
}

struct RebellionCard: View {
    @EnvironmentObject var gameManager: GameManager
    let rebellion: Rebellion
    let playerStrength: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Constants.Colors.negative)

                Text("Rebellion")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text(durationText)
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Text(rebellion.territory.name)
                .font(.system(size: 14))
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rebel Forces")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("\(rebellion.strength)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.negative)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Popular Support")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("\(Int(rebellion.support * 100))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.negative)
                }
            }

            // Threat Assessment
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 12))
                    .foregroundColor(threatColor)

                Text(threatLevel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(threatColor)

                Spacer()
            }
            .padding(8)
            .background(threatColor.opacity(0.15))
            .cornerRadius(6)
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22))
        .cornerRadius(12)
    }

    var durationText: String {
        guard let currentDate = gameManager.character?.currentDate else {
            return "Unknown"
        }
        let days = Calendar.current.dateComponents([.day], from: rebellion.startDate, to: currentDate).day ?? 0
        if days == 0 {
            return "Just started"
        } else if days == 1 {
            return "1 day"
        } else {
            return "\(days) days"
        }
    }

    var strengthRatio: Double {
        Double(playerStrength) / Double(max(1, rebellion.strength))
    }

    var threatLevel: String {
        if strengthRatio >= 10.0 {
            return "Minor Uprising"
        } else if strengthRatio >= 5.0 {
            return "Moderate Threat"
        } else if strengthRatio >= 2.0 {
            return "Serious Threat"
        } else {
            return "Critical Threat"
        }
    }

    var threatColor: Color {
        if strengthRatio >= 10.0 {
            return .yellow
        } else if strengthRatio >= 5.0 {
            return .orange
        } else {
            return Constants.Colors.negative
        }
    }
}

// MARK: - Declare War Sheet

struct DeclareWarSheet: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedCountry: RivalCountry?
    @State private var selectedJustification: War.WarJustification = .territorialDispute
    @State private var showConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                StandardBackgroundView()

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Warning Banner
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Constants.Colors.negative)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Declaration of War")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)

                                    Text("This action will have severe consequences")
                                        .font(.system(size: 12))
                                        .foregroundColor(Constants.Colors.secondaryText)
                                }

                                Spacer()
                            }
                            .padding(16)
                            .background(Constants.Colors.negative.opacity(0.15))
                            .cornerRadius(12)

                            // Select Target Country
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Target Nation")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)

                                ForEach(RivalCountry.allRivals, id: \.code) { country in
                                    CountrySelectionCard(
                                        country: country,
                                        isSelected: selectedCountry?.code == country.code,
                                        playerStrength: gameManager.character?.militaryStats?.strength ?? 0
                                    ) {
                                        selectedCountry = country
                                        // Auto-scroll to justification section after a brief delay to ensure view is rendered
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation {
                                                scrollProxy.scrollTo("justification", anchor: .top)
                                            }
                                        }
                                    }
                                }
                            }

                            // War Justification
                            if selectedCountry != nil {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("War Justification")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)

                                    ForEach([War.WarJustification.territorialDispute, .regimeChange, .resourceControl, .preemptiveStrike], id: \.self) { justification in
                                        JustificationCard(
                                            justification: justification,
                                            isSelected: selectedJustification == justification
                                        ) {
                                            selectedJustification = justification
                                        }
                                    }
                                }
                                .id("justification")

                                // Declare War Button
                                Button(action: {
                                    showConfirmation = true
                                }) {
                                    Text("Declare War")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Constants.Colors.negative)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Declare War")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.buttonPrimary)
                }
            }
        }
        .alert("Confirm Declaration of War", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Declare War", role: .destructive) {
                declareWar()
            }
        } message: {
            if let country = selectedCountry {
                Text("Are you sure you want to declare war on \(country.name)?\n\nApproval penalty: \(selectedJustification.approvalPenalty > 0 ? "+" : "")\(Int(selectedJustification.approvalPenalty))%\nThis cannot be undone.")
            }
        }
    }

    private func declareWar() {
        guard var character = gameManager.character else {
            print("❌ No character found")
            return
        }
        guard let militaryStats = character.militaryStats else {
            print("❌ No military stats")
            return
        }
        guard let target = selectedCountry else {
            print("❌ No target selected")
            return
        }

        print("✅ Attempting to declare war on \(target.name)")
        print("   Player: \(character.country), Strength: \(militaryStats.strength)")
        print("   Target: \(target.code), Strength: \(target.militaryStrength)")
        print("   Active wars: \(gameManager.warEngine.activeWars.count)")

        // Check if can declare war
        let canDeclare = gameManager.warEngine.canDeclareWar(
            playerCountry: character.country,
            targetCountry: target.code,
            militaryStats: militaryStats
        )

        if !canDeclare {
            print("❌ Cannot declare war - check failed")
            print("   Same country? \(character.country == target.code)")
            print("   Too many wars? \(gameManager.warEngine.activeWars.count >= 3)")
            print("   Insufficient strength? \(militaryStats.strength < 100_000)")
            return
        }

        print("✅ Can declare war - proceeding")

        // Declare war
        let war = gameManager.warEngine.declareWar(
            attacker: character.country,
            defender: target.code,
            type: .offensive,
            justification: selectedJustification,
            attackerStrength: militaryStats.strength,
            defenderStrength: target.militaryStrength,
            currentDate: character.currentDate
        )

        if let war = war {
            print("✅ War declared successfully: \(war.id)")
            print("   Active wars now: \(gameManager.warEngine.activeWars.count)")
        } else {
            print("❌ War declaration returned nil")
            return
        }

        // Apply approval penalty
        character.approvalRating = max(0, character.approvalRating + selectedJustification.approvalPenalty)

        // Add stress (REDUCED from +20 to +5)
        character.stress = min(100, character.stress + 5)

        gameManager.characterManager.updateCharacter(character)

        // Force UI update
        DispatchQueue.main.async {
            gameManager.objectWillChange.send()
        }

        print("✅ War declaration complete, dismissing sheet")
        dismiss()
    }
}

struct CountrySelectionCard: View {
    let country: RivalCountry
    let isSelected: Bool
    let playerStrength: Int
    let action: () -> Void

    var strengthComparison: String {
        let ratio = Double(playerStrength) / Double(max(1, country.militaryStrength))
        if ratio >= 2.0 {
            return "Overwhelming advantage"
        } else if ratio >= 1.5 {
            return "Strong advantage"
        } else if ratio >= 1.1 {
            return "Slight advantage"
        } else if ratio >= 0.9 {
            return "Even match"
        } else if ratio >= 0.6 {
            return "Disadvantage"
        } else {
            return "Severe disadvantage"
        }
    }

    var strengthColor: Color {
        let ratio = Double(playerStrength) / Double(max(1, country.militaryStrength))
        if ratio >= 1.5 {
            return Constants.Colors.positive
        } else if ratio >= 0.9 {
            return .yellow
        } else {
            return Constants.Colors.negative
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(Constants.Colors.buttonPrimary)

                    Text(country.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Constants.Colors.positive)
                    }
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Population")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text(formatPopulation(country.population))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Military Strength")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Text("\(country.militaryStrength)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }

                HStack {
                    Text("Assessment:")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(strengthComparison)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(strengthColor)
                }
            }
            .padding(14)
            .background(isSelected ? Constants.Colors.buttonPrimary.opacity(0.2) : Color(red: 0.15, green: 0.17, blue: 0.22))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Constants.Colors.buttonPrimary : Color.clear, lineWidth: 2)
            )
        }
    }

    private func formatPopulation(_ pop: Int) -> String {
        if pop >= 1_000_000_000 {
            return String(format: "%.1fB", Double(pop) / 1_000_000_000)
        } else if pop >= 1_000_000 {
            return String(format: "%.0fM", Double(pop) / 1_000_000)
        } else {
            return "\(pop)"
        }
    }
}

struct JustificationCard: View {
    let justification: War.WarJustification
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(justification.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Approval: \(justification.approvalPenalty > 0 ? "+" : "")\(Int(justification.approvalPenalty))%")
                        .font(.system(size: 12))
                        .foregroundColor(justification.approvalPenalty >= 0 ? Constants.Colors.positive : Constants.Colors.negative)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Constants.Colors.positive)
                }
            }
            .padding(12)
            .background(isSelected ? Constants.Colors.buttonPrimary.opacity(0.2) : Color(red: 0.15, green: 0.17, blue: 0.22))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Constants.Colors.buttonPrimary : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Rival Countries (for war declarations)

struct RivalCountry {
    let name: String
    let code: String
    let population: Int
    let militaryStrength: Int

    static let allRivals: [RivalCountry] = [
        // Major Powers
        RivalCountry(name: "China", code: "CHN", population: 1_412_000_000, militaryStrength: 2_035_000),
        RivalCountry(name: "Russia", code: "RUS", population: 144_000_000, militaryStrength: 1_150_000),
        RivalCountry(name: "India", code: "IND", population: 1_408_000_000, militaryStrength: 1_455_000),
        RivalCountry(name: "North Korea", code: "PRK", population: 26_000_000, militaryStrength: 1_280_000),
        RivalCountry(name: "Pakistan", code: "PAK", population: 231_000_000, militaryStrength: 654_000),

        // Regional Powers
        RivalCountry(name: "Iran", code: "IRN", population: 87_000_000, militaryStrength: 610_000),
        RivalCountry(name: "South Korea", code: "KOR", population: 52_000_000, militaryStrength: 555_000),
        RivalCountry(name: "Turkey", code: "TUR", population: 85_000_000, militaryStrength: 425_000),
        RivalCountry(name: "Egypt", code: "EGY", population: 109_000_000, militaryStrength: 440_000),
        RivalCountry(name: "Vietnam", code: "VNM", population: 98_000_000, militaryStrength: 482_000),
        RivalCountry(name: "Myanmar", code: "MMR", population: 54_000_000, militaryStrength: 406_000),
        RivalCountry(name: "Indonesia", code: "IDN", population: 275_000_000, militaryStrength: 400_000),
        RivalCountry(name: "Thailand", code: "THA", population: 71_000_000, militaryStrength: 361_000),

        // NATO & Allies (potential conflicts)
        RivalCountry(name: "United Kingdom", code: "GBR", population: 67_000_000, militaryStrength: 194_000),
        RivalCountry(name: "France", code: "FRA", population: 68_000_000, militaryStrength: 270_000),
        RivalCountry(name: "Germany", code: "DEU", population: 84_000_000, militaryStrength: 183_000),
        RivalCountry(name: "Japan", code: "JPN", population: 125_000_000, militaryStrength: 247_000),
        RivalCountry(name: "Italy", code: "ITA", population: 59_000_000, militaryStrength: 171_000),
        RivalCountry(name: "Poland", code: "POL", population: 38_000_000, militaryStrength: 164_000),

        // Middle East
        RivalCountry(name: "Saudi Arabia", code: "SAU", population: 35_000_000, militaryStrength: 257_000),
        RivalCountry(name: "Israel", code: "ISR", population: 9_500_000, militaryStrength: 169_500),
        RivalCountry(name: "Syria", code: "SYR", population: 21_000_000, militaryStrength: 169_000),
        RivalCountry(name: "Iraq", code: "IRQ", population: 43_000_000, militaryStrength: 193_000),

        // Latin America
        RivalCountry(name: "Brazil", code: "BRA", population: 215_000_000, militaryStrength: 360_000),
        RivalCountry(name: "Colombia", code: "COL", population: 52_000_000, militaryStrength: 293_000),
        RivalCountry(name: "Mexico", code: "MEX", population: 128_000_000, militaryStrength: 277_000),
        RivalCountry(name: "Venezuela", code: "VEN", population: 28_000_000, militaryStrength: 123_000),
        RivalCountry(name: "Cuba", code: "CUB", population: 11_000_000, militaryStrength: 49_000),

        // Africa
        RivalCountry(name: "Nigeria", code: "NGA", population: 218_000_000, militaryStrength: 143_000),
        RivalCountry(name: "Ethiopia", code: "ETH", population: 120_000_000, militaryStrength: 162_000),
        RivalCountry(name: "South Africa", code: "ZAF", population: 60_000_000, militaryStrength: 73_000),
        RivalCountry(name: "Algeria", code: "DZA", population: 44_000_000, militaryStrength: 130_000),

        // Oceania & Others
        RivalCountry(name: "Australia", code: "AUS", population: 26_000_000, militaryStrength: 60_000),
        RivalCountry(name: "Taiwan", code: "TWN", population: 24_000_000, militaryStrength: 165_000),
        RivalCountry(name: "Ukraine", code: "UKR", population: 38_000_000, militaryStrength: 800_000),
        RivalCountry(name: "Afghanistan", code: "AFG", population: 40_000_000, militaryStrength: 0),

        // Smaller Nations
        RivalCountry(name: "Belarus", code: "BLR", population: 9_400_000, militaryStrength: 48_000),
        RivalCountry(name: "Kazakhstan", code: "KAZ", population: 19_000_000, militaryStrength: 39_000),
        RivalCountry(name: "Serbia", code: "SRB", population: 7_000_000, militaryStrength: 28_000),
        RivalCountry(name: "Libya", code: "LBY", population: 7_000_000, militaryStrength: 32_000)
    ]
}

#Preview {
    ActiveWarsView()
        .environmentObject(GameManager.shared)
}
