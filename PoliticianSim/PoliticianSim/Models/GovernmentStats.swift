//
//  GovernmentStats.swift
//  PoliticianSim
//
//  Government performance statistics based on department funding
//

import Foundation

struct GovernmentStats: Codable {
    var educationScore: Double          // 0-100
    var healthcareScore: Double         // 0-100
    var publicSafetyScore: Double       // 0-100
    var infrastructureScore: Double     // 0-100
    var socialWelfareScore: Double      // 0-100
    var environmentScore: Double        // 0-100
    var justiceScore: Double            // 0-100
    var scienceScore: Double            // 0-100
    var cultureScore: Double            // 0-100
    var administrationScore: Double     // 0-100

    var overallScore: Double {
        let scores = [
            educationScore,
            healthcareScore,
            publicSafetyScore,
            infrastructureScore,
            socialWelfareScore,
            environmentScore,
            justiceScore,
            scienceScore,
            cultureScore,
            administrationScore
        ]
        return scores.reduce(0, +) / Double(scores.count)
    }

    init(
        educationScore: Double = 50.0,
        healthcareScore: Double = 50.0,
        publicSafetyScore: Double = 50.0,
        infrastructureScore: Double = 50.0,
        socialWelfareScore: Double = 50.0,
        environmentScore: Double = 50.0,
        justiceScore: Double = 50.0,
        scienceScore: Double = 50.0,
        cultureScore: Double = 50.0,
        administrationScore: Double = 50.0
    ) {
        self.educationScore = educationScore
        self.healthcareScore = healthcareScore
        self.publicSafetyScore = publicSafetyScore
        self.infrastructureScore = infrastructureScore
        self.socialWelfareScore = socialWelfareScore
        self.environmentScore = environmentScore
        self.justiceScore = justiceScore
        self.scienceScore = scienceScore
        self.cultureScore = cultureScore
        self.administrationScore = administrationScore
    }
}

// Department score metadata
struct DepartmentScoreInfo {
    let name: String
    let score: Double
    let category: Department.DepartmentCategory
    let icon: String
    let color: (red: Double, green: Double, blue: Double)
    let description: String

    var scoreLabel: String {
        if score >= 80 {
            return "Excellent"
        } else if score >= 60 {
            return "Good"
        } else if score >= 40 {
            return "Fair"
        } else if score >= 20 {
            return "Poor"
        } else {
            return "Critical"
        }
    }

    var scoreColor: (red: Double, green: Double, blue: Double) {
        if score >= 80 {
            return (0.2, 0.8, 0.2) // Green
        } else if score >= 60 {
            return (0.4, 0.7, 0.9) // Blue
        } else if score >= 40 {
            return (0.9, 0.7, 0.4) // Orange
        } else {
            return (1.0, 0.3, 0.3) // Red
        }
    }
}

extension GovernmentStats {
    func getAllDepartmentScores() -> [DepartmentScoreInfo] {
        return [
            DepartmentScoreInfo(
                name: "Education",
                score: educationScore,
                category: .education,
                icon: "book.fill",
                color: (0.3, 0.6, 1.0),
                description: "Quality of public education and literacy rates"
            ),
            DepartmentScoreInfo(
                name: "Healthcare",
                score: healthcareScore,
                category: .healthcare,
                icon: "cross.case.fill",
                color: (1.0, 0.3, 0.3),
                description: "Public health services and medical accessibility"
            ),
            DepartmentScoreInfo(
                name: "Public Safety",
                score: publicSafetyScore,
                category: .defense,
                icon: "shield.fill",
                color: (0.7, 0.2, 0.2),
                description: "Crime rates and emergency response effectiveness"
            ),
            DepartmentScoreInfo(
                name: "Infrastructure",
                score: infrastructureScore,
                category: .infrastructure,
                icon: "building.2.fill",
                color: (0.8, 0.5, 0.2),
                description: "Roads, bridges, and public transit quality"
            ),
            DepartmentScoreInfo(
                name: "Social Welfare",
                score: socialWelfareScore,
                category: .welfare,
                icon: "heart.fill",
                color: (1.0, 0.6, 0.8),
                description: "Poverty reduction and social support programs"
            ),
            DepartmentScoreInfo(
                name: "Environment",
                score: environmentScore,
                category: .environment,
                icon: "leaf.fill",
                color: (0.2, 0.8, 0.2),
                description: "Environmental quality and conservation efforts"
            ),
            DepartmentScoreInfo(
                name: "Justice",
                score: justiceScore,
                category: .justice,
                icon: "scales",
                color: (0.6, 0.4, 0.8),
                description: "Legal system efficiency and fairness"
            ),
            DepartmentScoreInfo(
                name: "Science & Research",
                score: scienceScore,
                category: .science,
                icon: "flask.fill",
                color: (0.4, 0.7, 0.9),
                description: "Innovation and research output"
            ),
            DepartmentScoreInfo(
                name: "Arts & Culture",
                score: cultureScore,
                category: .culture,
                icon: "theatermasks.fill",
                color: (0.9, 0.7, 0.4),
                description: "Cultural preservation and arts accessibility"
            ),
            DepartmentScoreInfo(
                name: "Administration",
                score: administrationScore,
                category: .administration,
                icon: "building.columns.fill",
                color: (0.6, 0.6, 0.6),
                description: "Government efficiency and bureaucracy"
            )
        ]
    }
}
