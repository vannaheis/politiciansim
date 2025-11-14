//
//  EducationView.swift
//  PoliticianSim
//
//  View for managing education and degrees
//

import SwiftUI

// MARK: - Helper Functions

private func formatCurrency(_ amount: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.groupingSeparator = ","
    formatter.usesGroupingSeparator = true
    return formatter.string(from: amount as NSDecimalNumber) ?? "0.00"
}

struct EducationView: View {
    @EnvironmentObject var gameManager: GameManager

    var character: Character? {
        gameManager.character
    }

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

                    Text("Education")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        if let char = character {
                            // Current Enrollment Status
                            if gameManager.educationManager.enrollmentStatus.isEnrolled {
                                CurrentEnrollmentCard(character: char)
                            }

                            // Completed Degrees
                            if !gameManager.educationManager.enrollmentStatus.completedDegrees.isEmpty {
                                CompletedDegreesCard()
                            }

                            // Student Loans
                            if gameManager.educationManager.enrollmentStatus.studentLoanDebt > 0 {
                                StudentLoansCard(character: char)
                            }

                            // Enroll in New Degree
                            if !gameManager.educationManager.enrollmentStatus.isEnrolled {
                                EnrollmentCard(character: char)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
    }
}

// MARK: - Current Enrollment Card

struct CurrentEnrollmentCard: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character
    @State private var showDropoutConfirmation = false

    var body: some View {
        if let degree = gameManager.educationManager.enrollmentStatus.currentDegree {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .foregroundColor(Constants.Colors.political)
                    Text("Currently Enrolled")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        showDropoutConfirmation = true
                    }) {
                        Text("Drop Out")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }

                Divider().background(Color.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 8) {
                    Text(degree.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text(degree.institution.name)
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Year")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)
                            Text("\(degree.currentYear) / \(degree.level.yearsRequired)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("GPA")
                                .font(.system(size: 11))
                                .foregroundColor(Constants.Colors.secondaryText)
                            Text(String(format: "%.2f", degree.gpa))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }

                    // Progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 6)
                                    .cornerRadius(3)

                                Rectangle()
                                    .fill(Constants.Colors.political)
                                    .frame(width: geometry.size.width * CGFloat(degree.currentYear) / CGFloat(degree.level.yearsRequired), height: 6)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
            .padding(14)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
            .alert("Drop Out?", isPresented: $showDropoutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Drop Out", role: .destructive) {
                    var char = character
                    _ = gameManager.educationManager.dropOut(character: &char)
                    gameManager.characterManager.updateCharacter(char)
                }
            } message: {
                Text("Are you sure you want to drop out? You will lose all progress toward this degree.")
            }
        }
    }
}

// MARK: - Completed Degrees Card

struct CompletedDegreesCard: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "medal.fill")
                    .foregroundColor(Constants.Colors.accent)
                Text("Completed Degrees")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Divider().background(Color.white.opacity(0.2))

            ForEach(gameManager.educationManager.enrollmentStatus.completedDegrees) { degree in
                DegreeRow(degree: degree)
            }
        }
        .padding(14)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
}

struct DegreeRow: View {
    let degree: Degree

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(degree.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            Text(degree.institution.name)
                .font(.system(size: 11))
                .foregroundColor(Constants.Colors.secondaryText)

            HStack {
                Text("GPA: \(String(format: "%.2f", degree.gpa))")
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                if let completionDate = degree.completionDate {
                    Text(formatYear(completionDate))
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }

    private func formatYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Student Loans Card

struct StudentLoansCard: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character
    @State private var showPayoffConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.orange)
                Text("Student Loans")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Divider().background(Color.white.opacity(0.2))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Debt")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                    Text("$\(formatCurrency(gameManager.educationManager.enrollmentStatus.studentLoanDebt))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Monthly Payment")
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.secondaryText)
                    Text("$\(formatCurrency(gameManager.educationManager.calculateMonthlyLoanPayment()))")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            Button(action: {
                showPayoffConfirmation = true
            }) {
                Text("Pay Off Loans")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Constants.Colors.accent)
                    .cornerRadius(8)
            }
            .disabled(character.campaignFunds < gameManager.educationManager.enrollmentStatus.studentLoanDebt)
            .opacity(character.campaignFunds < gameManager.educationManager.enrollmentStatus.studentLoanDebt ? 0.5 : 1.0)
            .alert("Pay Off Loans?", isPresented: $showPayoffConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Pay Off") {
                    var char = character
                    _ = gameManager.educationManager.payOffLoans(character: &char)
                    gameManager.characterManager.updateCharacter(char)
                }
            } message: {
                Text("Pay off $\(formatCurrency(gameManager.educationManager.enrollmentStatus.studentLoanDebt)) in student loans?")
            }
        }
        .padding(14)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
}

// MARK: - Enrollment Card

struct EnrollmentCard: View {
    @EnvironmentObject var gameManager: GameManager
    let character: Character
    @State private var showEnrollmentSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Constants.Colors.political)
                Text("Enroll in a Degree Program")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Divider().background(Color.white.opacity(0.2))

            Text("Advance your political career with higher education. Choose from community colleges, state universities, Ivy League institutions, and professional schools.")
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {
                showEnrollmentSheet = true
            }) {
                Text("Browse Programs")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Constants.Colors.political)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showEnrollmentSheet) {
                EnrollmentSheet(character: character, isPresented: $showEnrollmentSheet)
            }
        }
        .padding(14)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
}

#Preview {
    EducationView()
        .environmentObject(GameManager.shared)
}
