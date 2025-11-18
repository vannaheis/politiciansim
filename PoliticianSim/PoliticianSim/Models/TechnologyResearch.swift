//
//  TechnologyResearch.swift
//  PoliticianSim
//
//  Technology research system for military advancement
//

import Foundation

struct TechnologyResearch: Codable, Identifiable {
    let id: UUID
    let category: TechCategory
    let targetLevel: Int
    var progress: Double  // 0.0 to 1.0
    let cost: Decimal
    let daysRequired: Int
    let startDate: Date
    var completionDate: Date?

    init(category: TechCategory, currentLevel: Int, startDate: Date) {
        self.id = UUID()
        self.category = category
        self.targetLevel = currentLevel + 1
        self.progress = 0.0
        self.startDate = startDate

        // Calculate cost based on level (exponential growth)
        let baseCost: Decimal = 5_000_000_000  // $5B base
        self.cost = baseCost * Decimal(pow(Double(self.targetLevel), 1.5))

        // Calculate days required (90-365 days based on level)
        self.daysRequired = 90 + (self.targetLevel * 30)

        self.completionDate = nil
    }

    var isComplete: Bool {
        progress >= 1.0
    }

    var daysRemaining: Int {
        let elapsed = Int(progress * Double(daysRequired))
        return max(0, daysRequired - elapsed)
    }

    mutating func advanceProgress(days: Int) {
        let progressPerDay = 1.0 / Double(daysRequired)
        progress = min(1.0, progress + (progressPerDay * Double(days)))

        if isComplete && completionDate == nil {
            completionDate = Calendar.current.date(
                byAdding: .day,
                value: Int(Double(daysRequired) * progress),
                to: startDate
            )
        }
    }
}
