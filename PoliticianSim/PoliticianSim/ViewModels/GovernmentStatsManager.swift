//
//  GovernmentStatsManager.swift
//  PoliticianSim
//
//  Manages government performance statistics based on per-capita spending
//

import Foundation
import Combine

class GovernmentStatsManager: ObservableObject {
    @Published var currentStats: GovernmentStats?

    init() {}

    // MARK: - Stats Initialization

    func initializeStats(for character: Character) {
        guard character.currentPosition != nil else { return }
        currentStats = GovernmentStats()
    }

    // MARK: - Stats Calculation

    /// Calculates government performance scores based on per-capita spending
    ///
    /// **Scoring Formula:**
    /// - Score = f(Department Funding / Population)
    /// - Uses sigmoid curve to prevent linear scaling with GDP
    /// - Optimal per-capita spending thresholds by department
    /// - Rich nations operating on surplus are NOT penalized
    ///
    /// **Per-Capita Thresholds (annual spending per person):**
    /// - Education: $2,000/person = 100 score
    /// - Healthcare: $2,500/person = 100 score
    /// - Public Safety: $800/person = 100 score
    /// - Infrastructure: $1,000/person = 100 score
    /// - Social Welfare: $1,500/person = 100 score
    /// - Environment: $300/person = 100 score
    /// - Justice: $400/person = 100 score
    /// - Science: $500/person = 100 score
    /// - Culture: $200/person = 100 score
    /// - Administration: $300/person = 100 score
    func updateStats(
        budget: Budget,
        population: Int,
        character: inout Character
    ) {
        guard population > 0 else { return }

        var stats = currentStats ?? GovernmentStats()

        // Calculate per-capita spending for each department
        for department in budget.departments {
            let annualFunding = Double(truncating: department.allocatedFunds as NSDecimalNumber)
            let perCapitaSpending = annualFunding / Double(population)

            // Calculate score based on department category
            let score = calculateDepartmentScore(
                category: department.category,
                perCapitaSpending: perCapitaSpending
            )

            // Update stats for this department
            switch department.category {
            case .education:
                stats.educationScore = score
            case .healthcare:
                stats.healthcareScore = score
            case .defense:
                stats.publicSafetyScore = score
            case .infrastructure:
                stats.infrastructureScore = score
            case .welfare:
                stats.socialWelfareScore = score
            case .environment:
                stats.environmentScore = score
            case .justice:
                stats.justiceScore = score
            case .science:
                stats.scienceScore = score
            case .culture:
                stats.cultureScore = score
            case .administration:
                stats.administrationScore = score
            case .military:
                // Military doesn't affect government stats directly
                break
            }
        }

        currentStats = stats

        // Apply approval impact based on overall score
        let approvalImpact = calculateApprovalImpact(overallScore: stats.overallScore)
        character.approvalRating = max(0, min(100, character.approvalRating + approvalImpact))
    }

    // MARK: - Policy Impact

    /// Modifies a department's score directly (e.g., from policy effects)
    func modifyDepartmentScore(department: Department.DepartmentCategory, change: Double) {
        guard var stats = currentStats else { return }

        switch department {
        case .education:
            stats.educationScore = min(100, max(0, stats.educationScore + change))
        case .healthcare:
            stats.healthcareScore = min(100, max(0, stats.healthcareScore + change))
        case .defense:
            stats.publicSafetyScore = min(100, max(0, stats.publicSafetyScore + change))
        case .infrastructure:
            stats.infrastructureScore = min(100, max(0, stats.infrastructureScore + change))
        case .welfare:
            stats.socialWelfareScore = min(100, max(0, stats.socialWelfareScore + change))
        case .environment:
            stats.environmentScore = min(100, max(0, stats.environmentScore + change))
        case .justice:
            stats.justiceScore = min(100, max(0, stats.justiceScore + change))
        case .science:
            stats.scienceScore = min(100, max(0, stats.scienceScore + change))
        case .culture:
            stats.cultureScore = min(100, max(0, stats.cultureScore + change))
        case .administration:
            stats.administrationScore = min(100, max(0, stats.administrationScore + change))
        case .military:
            // Military doesn't affect government stats directly
            break
        }

        currentStats = stats
    }

    // MARK: - Scoring Logic

    private func calculateDepartmentScore(
        category: Department.DepartmentCategory,
        perCapitaSpending: Double
    ) -> Double {
        // Define optimal per-capita spending thresholds for each department
        let optimalThreshold: Double

        switch category {
        case .education:
            optimalThreshold = 2000 // $2,000/person annually
        case .healthcare:
            optimalThreshold = 2500 // $2,500/person annually
        case .defense:
            optimalThreshold = 800 // $800/person annually
        case .infrastructure:
            optimalThreshold = 1000 // $1,000/person annually
        case .welfare:
            optimalThreshold = 1500 // $1,500/person annually
        case .environment:
            optimalThreshold = 300 // $300/person annually
        case .justice:
            optimalThreshold = 400 // $400/person annually
        case .science:
            optimalThreshold = 500 // $500/person annually
        case .culture:
            optimalThreshold = 200 // $200/person annually
        case .administration:
            optimalThreshold = 300 // $300/person annually
        case .military:
            optimalThreshold = 1500 // $1,500/person annually
        }

        // Use sigmoid-like curve to calculate score (0-100)
        // This prevents linear scaling and creates diminishing returns
        // Formula: score = 100 * (1 / (1 + e^(-k * (x - threshold))))
        // Simplified: score = 100 * (spending / (spending + threshold))

        let ratio = perCapitaSpending / optimalThreshold

        // Sigmoid curve: returns 0-100
        // - ratio = 0.5 → score ≈ 33
        // - ratio = 1.0 → score ≈ 50
        // - ratio = 2.0 → score ≈ 67
        // - ratio = 4.0 → score ≈ 80
        // - ratio = 9.0 → score ≈ 90
        let score = 100.0 * (ratio / (ratio + 1.0))

        return min(100.0, max(0.0, score))
    }

    private func calculateApprovalImpact(overallScore: Double) -> Double {
        // Approval impact based on overall government performance
        if overallScore >= 80 {
            return 2.0 // Excellent performance
        } else if overallScore >= 60 {
            return 1.0 // Good performance
        } else if overallScore >= 40 {
            return 0.0 // Fair performance (neutral)
        } else if overallScore >= 20 {
            return -1.0 // Poor performance
        } else {
            return -3.0 // Critical performance
        }
    }

    // MARK: - Summary

    func getStatsSummary() -> StatsSummary? {
        guard let stats = currentStats else { return nil }

        let departmentScores = stats.getAllDepartmentScores()
        let lowestScore = departmentScores.min(by: { $0.score < $1.score })
        let highestScore = departmentScores.max(by: { $0.score < $1.score })

        return StatsSummary(
            overallScore: stats.overallScore,
            lowestDepartment: lowestScore,
            highestDepartment: highestScore,
            allScores: departmentScores
        )
    }

    struct StatsSummary {
        let overallScore: Double
        let lowestDepartment: DepartmentScoreInfo?
        let highestDepartment: DepartmentScoreInfo?
        let allScores: [DepartmentScoreInfo]
    }
}
