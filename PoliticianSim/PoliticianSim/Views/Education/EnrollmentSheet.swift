//
//  EnrollmentSheet.swift
//  PoliticianSim
//
//  Sheet for browsing and enrolling in degree programs
//

import SwiftUI

struct EnrollmentSheet: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character
    @Binding var isPresented: Bool

    @State private var selectedLevel: EducationLevel = .bachelors
    @State private var selectedField: FieldOfStudy = .politicalScience
    @State private var selectedInstitution: EducationalInstitution?
    @State private var useLoans: Bool = false
    @State private var showConfirmation = false
    @State private var enrollmentMessage = ""

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
                    .frame(height: 44)

                    Spacer()

                    Text("Enroll in Program")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 60, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Degree Level Selection
                        DegreeLevelSection(selectedLevel: $selectedLevel)

                        // Field of Study Selection
                        FieldOfStudySection(selectedLevel: selectedLevel, selectedField: $selectedField)

                        // Institution Selection
                        InstitutionSection(
                            selectedLevel: selectedLevel,
                            selectedInstitution: $selectedInstitution,
                            character: character
                        )

                        // Payment Options
                        if let institution = selectedInstitution {
                            PaymentOptionsSection(
                                institution: institution,
                                selectedLevel: selectedLevel,
                                useLoans: $useLoans,
                                character: character
                            )

                            // Enroll Button
                            EnrollButton(
                                selectedLevel: selectedLevel,
                                selectedField: selectedField,
                                institution: institution,
                                useLoans: useLoans,
                                character: character,
                                showConfirmation: $showConfirmation,
                                enrollmentMessage: $enrollmentMessage,
                                isPresented: $isPresented
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .alert("Enrollment Result", isPresented: $showConfirmation) {
            Button("OK") { }
        } message: {
            Text(enrollmentMessage)
        }
    }
}

// MARK: - Degree Level Section

struct DegreeLevelSection: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var selectedLevel: EducationLevel

    var availableLevels: [EducationLevel] {
        EducationLevel.allCases.filter { level in
            if level == .highSchool { return false }
            let check = gameManager.educationManager.canEnroll(
                character: gameManager.character!,
                level: level
            )
            return check.canEnroll
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Degree Level")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            ForEach(availableLevels, id: \.self) { level in
                Button(action: {
                    selectedLevel = level
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(level.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)

                            Text("\(level.yearsRequired) years • +\(level.intelligenceBonus) Intelligence")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }

                        Spacer()

                        if selectedLevel == level {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Constants.Colors.political)
                        }
                    }
                    .padding(12)
                    .background(selectedLevel == level ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Field of Study Section

struct FieldOfStudySection: View {
    @EnvironmentObject var gameManager: GameManager
    let selectedLevel: EducationLevel
    @Binding var selectedField: FieldOfStudy

    var availableFields: [FieldOfStudy] {
        gameManager.educationManager.getAvailableFields(for: selectedLevel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Field of Study")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            ForEach(availableFields, id: \.self) { field in
                Button(action: {
                    selectedField = field
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)

                            HStack(spacing: 8) {
                                Text("Charisma +\(field.statBonus.charisma)")
                                    .font(.system(size: 10))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("Intel +\(field.statBonus.intelligence)")
                                    .font(.system(size: 10))
                                    .foregroundColor(Constants.Colors.secondaryText)

                                Text("Diplomacy +\(field.statBonus.diplomacy)")
                                    .font(.system(size: 10))
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                        }

                        Spacer()

                        if selectedField == field {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Constants.Colors.political)
                        }
                    }
                    .padding(12)
                    .background(selectedField == field ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Institution Section

struct InstitutionSection: View {
    @EnvironmentObject var gameManager: GameManager
    let selectedLevel: EducationLevel
    @Binding var selectedInstitution: EducationalInstitution?
    let character: Character

    var availableInstitutions: [EducationalInstitution] {
        gameManager.educationManager.getAvailableInstitutions(for: selectedLevel)
            .sorted { $0.prestige > $1.prestige }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Institution")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            ForEach(availableInstitutions) { institution in
                InstitutionCard(
                    institution: institution,
                    selectedLevel: selectedLevel,
                    isSelected: selectedInstitution?.id == institution.id,
                    character: character,
                    onSelect: {
                        selectedInstitution = institution
                    }
                )
            }
        }
    }
}

struct InstitutionCard: View {
    @EnvironmentObject var gameManager: GameManager
    let institution: EducationalInstitution
    let selectedLevel: EducationLevel
    let isSelected: Bool
    let character: Character
    let onSelect: () -> Void

    var acceptanceChance: Double {
        institution.acceptanceChance(intelligence: character.intelligence, reputation: character.reputation)
    }

    var yearCost: Decimal {
        institution.costPerYear()
    }

    var scholarship: Double {
        let intelligenceBonus = max(0, Double(character.intelligence - 50)) / 100.0
        let reputationBonus = max(0, Double(character.reputation - 50)) / 200.0
        let prestigePenalty = Double(institution.prestige) / 100.0
        return max(0, min(0.7, (intelligenceBonus + reputationBonus - prestigePenalty) * 0.7))
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(institution.name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)

                        Text("\(institution.type.rawValue) • \(institution.location)")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Constants.Colors.political)
                    }
                }

                HStack(spacing: 12) {
                    // Prestige
                    HStack(spacing: 4) {
                        ForEach(0..<institution.prestige, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                        }
                    }

                    Text("•")
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("Accept: \(Int(acceptanceChance * 100))%")
                        .font(.system(size: 11))
                        .foregroundColor(acceptanceChance > 0.7 ? .green : acceptanceChance > 0.4 ? .orange : .red)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tuition/Year")
                            .font(.system(size: 10))
                            .foregroundColor(Constants.Colors.secondaryText)
                        Text("$\(yearCost)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    if scholarship > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Scholarship")
                                .font(.system(size: 10))
                                .foregroundColor(Constants.Colors.secondaryText)
                            Text("\(Int(scholarship * 100))%")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding(12)
            .background(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

// MARK: - Payment Options Section

struct PaymentOptionsSection: View {
    let institution: EducationalInstitution
    let selectedLevel: EducationLevel
    @Binding var useLoans: Bool
    let character: Character

    var yearCost: Decimal {
        institution.costPerYear()
    }

    var scholarship: Decimal {
        let intelligenceBonus = max(0, Double(character.intelligence - 50)) / 100.0
        let reputationBonus = max(0, Double(character.reputation - 50)) / 200.0
        let prestigePenalty = Double(institution.prestige) / 100.0
        let scholarshipPercent = max(0, min(0.7, (intelligenceBonus + reputationBonus - prestigePenalty) * 0.7))
        return yearCost * Decimal(scholarshipPercent)
    }

    var actualCost: Decimal {
        yearCost - scholarship
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            // Cost Breakdown
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Tuition (first year)")
                    Spacer()
                    Text("$\(yearCost)")
                }
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)

                if scholarship > 0 {
                    HStack {
                        Text("Scholarship")
                        Spacer()
                        Text("-$\(scholarship)")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                }

                Divider().background(Color.white.opacity(0.2))

                HStack {
                    Text("Total Cost")
                    Spacer()
                    Text("$\(actualCost)")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)

            // Payment Method
            VStack(spacing: 8) {
                Button(action: {
                    useLoans = false
                }) {
                    HStack {
                        Image(systemName: useLoans ? "circle" : "checkmark.circle.fill")
                            .foregroundColor(Constants.Colors.political)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pay Now")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)

                            Text("Available: $\(character.campaignFunds)")
                                .font(.system(size: 11))
                                .foregroundColor(character.campaignFunds >= actualCost ? .green : .red)
                        }

                        Spacer()
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }

                Button(action: {
                    useLoans = true
                }) {
                    HStack {
                        Image(systemName: useLoans ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(Constants.Colors.political)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Student Loans")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)

                            Text("5% APR, 10-year repayment")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }

                        Spacer()
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Enroll Button

struct EnrollButton: View {
    @EnvironmentObject var gameManager: GameManager
    let selectedLevel: EducationLevel
    let selectedField: FieldOfStudy
    let institution: EducationalInstitution
    let useLoans: Bool
    let character: Character
    @Binding var showConfirmation: Bool
    @Binding var enrollmentMessage: String
    @Binding var isPresented: Bool

    var canEnroll: Bool {
        let check = gameManager.educationManager.canEnroll(character: character, level: selectedLevel)
        return check.canEnroll
    }

    var body: some View {
        Button(action: {
            var char = character
            let result = gameManager.educationManager.enrollInDegree(
                character: &char,
                level: selectedLevel,
                field: selectedField,
                institution: institution,
                useLoans: useLoans
            )
            gameManager.characterManager.updateCharacter(char)
            enrollmentMessage = result.message
            showConfirmation = true

            if result.success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPresented = false
                }
            }
        }) {
            Text("Enroll in Program")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(canEnroll ? Constants.Colors.political : Color.gray)
                .cornerRadius(8)
        }
        .disabled(!canEnroll)
        .padding(.top, 8)
    }
}

#Preview {
    EnrollmentSheet(character: Character(name: "Test", gender: .male, country: "USA", background: .middleClass), isPresented: .constant(true))
        .environmentObject(GameManager.shared)
}
