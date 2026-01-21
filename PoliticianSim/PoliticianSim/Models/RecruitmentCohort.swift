//
//  RecruitmentCohort.swift
//  PoliticianSim
//
//  Training cohorts for military recruitment
//

import Foundation

struct RecruitmentCohort: Codable, Identifiable {
    let id: UUID
    let soldierCount: Int
    let recruitmentType: MilitaryStats.RecruitmentType
    let startDate: Date
    let completionDate: Date
    var daysRemaining: Int

    init(soldierCount: Int, recruitmentType: MilitaryStats.RecruitmentType, startDate: Date) {
        self.id = UUID()
        self.soldierCount = soldierCount
        self.recruitmentType = recruitmentType
        self.startDate = startDate

        // 90-day training period
        self.completionDate = Calendar.current.date(byAdding: .day, value: 90, to: startDate) ?? startDate
        self.daysRemaining = 90
    }

    var isComplete: Bool {
        daysRemaining <= 0
    }

    mutating func advanceDays(_ days: Int) {
        daysRemaining = max(0, daysRemaining - days)
    }
}
