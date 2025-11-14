//
//  EducationManager.swift
//  PoliticianSim
//
//  Manages education enrollment, progression, and completion
//

import Foundation
import Combine

class EducationManager: ObservableObject {
    @Published var enrollmentStatus = EnrollmentStatus()

    // MARK: - Enrollment

    func canEnroll(character: Character, level: EducationLevel) -> (canEnroll: Bool, reason: String?) {
        // Check if already enrolled
        if enrollmentStatus.isEnrolled {
            return (false, "Already enrolled in a degree program")
        }

        // Check prerequisites
        if !enrollmentStatus.hasPrerequisite(for: level) {
            guard let prereq = level.prerequisite else { return (true, nil) }
            return (false, "Requires \(prereq.rawValue) first")
        }

        // Check age (must be at least 18)
        if character.age < 18 {
            return (false, "Must be at least 18 years old")
        }

        return (true, nil)
    }

    func enrollInDegree(
        character: inout Character,
        level: EducationLevel,
        field: FieldOfStudy,
        institution: EducationalInstitution,
        useLoans: Bool = false
    ) -> (success: Bool, message: String) {
        let check = canEnroll(character: character, level: level)
        guard check.canEnroll else {
            return (false, check.reason ?? "Cannot enroll")
        }

        // Check if institution offers this degree
        guard institution.type.availableDegrees.contains(level) else {
            return (false, "\(institution.name) does not offer \(level.rawValue) programs")
        }

        // Calculate acceptance
        let acceptanceChance = institution.acceptanceChance(intelligence: character.intelligence, reputation: character.reputation)
        let accepted = Double.random(in: 0...1) < acceptanceChance

        if !accepted {
            return (false, "Application to \(institution.name) was not accepted")
        }

        // Calculate first year cost
        let yearCost = institution.costPerYear()

        // Calculate scholarship based on intelligence and reputation
        let scholarshipPercentage = calculateScholarship(
            intelligence: character.intelligence,
            reputation: character.reputation,
            institutionPrestige: institution.prestige
        )
        let scholarshipAmount = yearCost * Decimal(scholarshipPercentage)
        let actualCost = yearCost - scholarshipAmount

        // Check payment method
        if useLoans {
            // Take out loan for the degree
            enrollmentStatus.studentLoanDebt += actualCost
        } else {
            // Check if character has enough funds
            if character.campaignFunds < actualCost {
                return (false, "Insufficient funds. Cost: $\(actualCost), Available: $\(character.campaignFunds)")
            }
            character.campaignFunds -= actualCost
            enrollmentStatus.totalCostPaid += actualCost
        }

        // Create and enroll in degree
        let degree = Degree(
            level: level,
            field: field,
            institution: institution,
            startDate: character.currentDate
        )

        enrollmentStatus.isEnrolled = true
        enrollmentStatus.currentDegree = degree
        enrollmentStatus.scholarshipAmount += scholarshipAmount

        return (true, "Enrolled in \(degree.displayName) at \(institution.name)")
    }

    // MARK: - Progression

    func checkAcademicProgress(character: inout Character) {
        guard enrollmentStatus.isEnrolled,
              let degree = enrollmentStatus.currentDegree else { return }

        // Check if a year has passed since enrollment or last year advancement
        let calendar = Calendar.current
        let yearsSinceStart = calendar.dateComponents([.year], from: degree.startDate, to: character.currentDate).year ?? 0

        // If we've completed enough years in real game time, advance to next year
        if yearsSinceStart >= degree.currentYear {
            advanceAcademicYear(character: &character)
        }
    }

    private func advanceAcademicYear(character: inout Character) {
        guard enrollmentStatus.isEnrolled,
              var degree = enrollmentStatus.currentDegree else { return }

        // Calculate GPA for the year based on intelligence
        let yearGPA = calculateYearGPA(intelligence: character.intelligence)
        degree.gpa = ((degree.gpa * Double(degree.currentYear - 1)) + yearGPA) / Double(degree.currentYear)

        degree.currentYear += 1

        // Check if degree is completed
        if degree.currentYear > degree.level.yearsRequired {
            completeDegree(character: &character, degree: degree)
        } else {
            // Pay for next year
            let yearCost = degree.institution.costPerYear()
            let scholarshipPercentage = calculateScholarship(
                intelligence: character.intelligence,
                reputation: character.reputation,
                institutionPrestige: degree.institution.prestige
            )
            let scholarshipAmount = yearCost * Decimal(scholarshipPercentage)
            let actualCost = yearCost - scholarshipAmount

            // Check if using loans or paying directly
            if character.campaignFunds >= actualCost {
                character.campaignFunds -= actualCost
                enrollmentStatus.totalCostPaid += actualCost
            } else {
                enrollmentStatus.studentLoanDebt += actualCost
            }

            enrollmentStatus.scholarshipAmount += scholarshipAmount
            enrollmentStatus.currentDegree = degree
        }
    }

    private func completeDegree(character: inout Character, degree: Degree) {
        var completedDegree = degree
        completedDegree.isCompleted = true
        completedDegree.completionDate = character.currentDate

        // Add stat bonuses
        character.intelligence = min(100, character.intelligence + completedDegree.level.intelligenceBonus + completedDegree.field.statBonus.intelligence)
        character.charisma = min(100, character.charisma + completedDegree.field.statBonus.charisma)
        character.diplomacy = min(100, character.diplomacy + completedDegree.field.statBonus.diplomacy)
        character.reputation = min(100, character.reputation + completedDegree.level.reputationBonus + Int(Double(completedDegree.institution.prestige) * completedDegree.institution.type.reputationMultiplier))

        enrollmentStatus.completedDegrees.append(completedDegree)
        enrollmentStatus.currentDegree = nil
        enrollmentStatus.isEnrolled = false
    }

    // MARK: - Dropout

    func dropOut(character: inout Character) -> Bool {
        guard enrollmentStatus.isEnrolled,
              let _ = enrollmentStatus.currentDegree else { return false }

        // Student loan debt already reflects only the years attended
        // (debt is added year-by-year, not upfront for the entire degree)

        enrollmentStatus.isEnrolled = false
        enrollmentStatus.currentDegree = nil

        // Add stress from dropping out
        character.stress = min(100, character.stress + 10)

        return true
    }

    // MARK: - Helper Methods

    private func calculateScholarship(intelligence: Int, reputation: Int, institutionPrestige: Int) -> Double {
        let intelligenceBonus = max(0, Double(intelligence - 50)) / 100.0 // 0 to 0.5
        let reputationBonus = max(0, Double(reputation - 50)) / 200.0 // 0 to 0.25
        let prestigePenalty = Double(institutionPrestige) / 100.0 // 0.01 to 0.1

        let scholarship = (intelligenceBonus + reputationBonus - prestigePenalty) * 0.7 // Max 70% scholarship
        return max(0, min(0.7, scholarship))
    }

    private func calculateYearGPA(intelligence: Int) -> Double {
        let baseGPA = 2.5
        let intelligenceBonus = Double(intelligence - 50) / 50.0 // -1.0 to +1.0
        let randomFactor = Double.random(in: -0.3...0.3)

        return max(0.0, min(4.0, baseGPA + intelligenceBonus + randomFactor))
    }

    // MARK: - Student Loans

    func makeMonthlyLoanPayment(character: inout Character) {
        guard enrollmentStatus.studentLoanDebt > 0 else { return }

        // Check if a month has passed since last payment
        let calendar = Calendar.current
        let shouldMakePayment: Bool

        if let lastPayment = enrollmentStatus.lastLoanPaymentDate {
            let monthsSincePayment = calendar.dateComponents([.month], from: lastPayment, to: character.currentDate).month ?? 0
            shouldMakePayment = monthsSincePayment >= 1
        } else {
            // First payment
            shouldMakePayment = true
        }

        guard shouldMakePayment else { return }

        let monthlyPayment = calculateMonthlyLoanPayment()

        if character.campaignFunds >= monthlyPayment {
            character.campaignFunds -= monthlyPayment
            enrollmentStatus.studentLoanDebt = max(0, enrollmentStatus.studentLoanDebt - monthlyPayment)
            enrollmentStatus.lastLoanPaymentDate = character.currentDate
        } else {
            // Missed payment - increase stress and still record the date
            character.stress = min(100, character.stress + 5)
            enrollmentStatus.lastLoanPaymentDate = character.currentDate
        }
    }

    func calculateMonthlyLoanPayment() -> Decimal {
        // Simple 10-year repayment plan at 5% interest
        let monthlyRate = 0.05 / 12.0
        let numPayments = 120.0 // 10 years

        if enrollmentStatus.studentLoanDebt == 0 {
            return 0
        }

        let principal = Double(truncating: enrollmentStatus.studentLoanDebt as NSDecimalNumber)
        let payment = principal * (monthlyRate * pow(1 + monthlyRate, numPayments)) / (pow(1 + monthlyRate, numPayments) - 1)

        return Decimal(payment)
    }

    func payOffLoans(character: inout Character) -> Bool {
        guard enrollmentStatus.studentLoanDebt > 0 else { return false }

        if character.campaignFunds >= enrollmentStatus.studentLoanDebt {
            character.campaignFunds -= enrollmentStatus.studentLoanDebt
            enrollmentStatus.studentLoanDebt = 0
            return true
        }

        return false
    }

    // MARK: - Queries

    func isEnrolled() -> Bool {
        return enrollmentStatus.isEnrolled
    }

    func getAvailableInstitutions(for level: EducationLevel) -> [EducationalInstitution] {
        return EducationalInstitution.getInstitutions(forDegree: level)
    }

    func getAvailableFields(for level: EducationLevel) -> [FieldOfStudy] {
        // Some fields only available at certain levels
        switch level {
        case .associates:
            return [.business, .communications, .criminalJustice, .nursing, .education]
        case .bachelors:
            return FieldOfStudy.allCases
        case .masters:
            return FieldOfStudy.allCases.filter { $0 != .law && $0 != .medicine }
        case .doctorate:
            return FieldOfStudy.allCases.filter { $0 != .law && $0 != .medicine && $0 != .nursing }
        case .professional:
            return [.law, .medicine, .business] // JD, MD, MBA
        case .highSchool:
            return []
        }
    }

    func canAfford(character: Character, institution: EducationalInstitution, level: EducationLevel) -> Bool {
        let yearCost = institution.costPerYear()
        let scholarship = calculateScholarship(
            intelligence: character.intelligence,
            reputation: character.reputation,
            institutionPrestige: institution.prestige
        )
        let actualCost = yearCost * Decimal(1.0 - scholarship)

        return character.campaignFunds >= actualCost
    }
}
