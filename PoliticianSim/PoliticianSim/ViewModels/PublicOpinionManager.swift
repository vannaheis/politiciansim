//
//  PublicOpinionManager.swift
//  PoliticianSim
//
//  Manages public opinion polling, media coverage, and social media
//

import Foundation
import Combine

class PublicOpinionManager: ObservableObject {
    @Published var currentPoll: OpinionPoll?
    @Published var pollHistory: [OpinionPoll] = []
    @Published var mediaCoverage: [MediaCoverage] = []
    @Published var socialMetrics: SocialMediaMetrics
    @Published var activeActions: [ActiveOpinionAction] = []

    struct ActiveOpinionAction: Identifiable {
        let id: UUID
        let action: PublicOpinionAction
        let startDate: Date
        let endDate: Date
        var dailyBoost: Double
    }

    init() {
        self.socialMetrics = SocialMediaMetrics()
        initializeBaseline()
    }

    // MARK: - Initialization

    private func initializeBaseline() {
        // Create initial poll
        let date = Date()
        currentPoll = OpinionPoll(
            date: date,
            overallApproval: 50.0,
            demographicBreakdown: generateBaseDemographics(),
            issueApproval: generateBaseIssueApproval(),
            regionalApproval: generateBaseRegionalApproval(),
            trendDirection: .stable
        )

        if let poll = currentPoll {
            pollHistory.append(poll)
        }

        // Initialize social media
        socialMetrics = SocialMediaMetrics(
            followers: 50_000,
            engagementRate: 3.5,
            sentiment: .mixed,
            recentPosts: [],
            trendingTopics: ["#Leadership", "#Policy", "#Change"]
        )
    }

    private func generateBaseDemographics() -> [DemographicGroup: Double] {
        var breakdown: [DemographicGroup: Double] = [:]
        for group in DemographicGroup.allCases {
            breakdown[group] = Double.random(in: 45...55)
        }
        return breakdown
    }

    private func generateBaseIssueApproval() -> [IssueCategory: Double] {
        var approval: [IssueCategory: Double] = [:]
        for issue in IssueCategory.allCases {
            approval[issue] = Double.random(in: 40...60)
        }
        return approval
    }

    private func generateBaseRegionalApproval() -> [String: Double] {
        let regions = ["Northeast", "Southeast", "Midwest", "Southwest", "West"]
        var approval: [String: Double] = [:]
        for region in regions {
            approval[region] = Double.random(in: 45...55)
        }
        return approval
    }

    // MARK: - Polling

    func conductPoll(character: Character) -> OpinionPoll {
        let previousApproval = currentPoll?.overallApproval ?? 50.0
        let newApproval = character.approvalRating

        // Calculate trend
        let change = newApproval - previousApproval
        let trend: OpinionPoll.TrendDirection
        switch change {
        case 5...: trend = .risingStrongly
        case 2..<5: trend = .rising
        case -2...2: trend = .stable
        case -5..<(-2): trend = .falling
        default: trend = .fallingStrongly
        }

        // Generate detailed breakdown
        let demographics = generateDemographicBreakdown(baseApproval: newApproval, character: character)
        let issues = generateIssueApproval(baseApproval: newApproval, character: character)
        let regional = generateRegionalApproval(baseApproval: newApproval)

        let poll = OpinionPoll(
            date: character.currentDate,
            overallApproval: newApproval,
            demographicBreakdown: demographics,
            issueApproval: issues,
            regionalApproval: regional,
            trendDirection: trend
        )

        currentPoll = poll
        pollHistory.append(poll)

        // Keep last 30 polls
        if pollHistory.count > 30 {
            pollHistory.removeFirst()
        }

        return poll
    }

    private func generateDemographicBreakdown(baseApproval: Double, character: Character) -> [DemographicGroup: Double] {
        var breakdown: [DemographicGroup: Double] = [:]

        for group in DemographicGroup.allCases {
            var approval = baseApproval + Double.random(in: -10...10)

            // Apply character-specific modifiers
            switch group {
            case .youth:
                approval += Double(character.charisma) / 10 - 5
            case .seniors:
                approval += Double(character.intelligence) / 10 - 5
            case .highIncome:
                approval += baseApproval > 60 ? 5 : -5
            case .lowIncome:
                approval += baseApproval < 40 ? 5 : -5
            default:
                break
            }

            breakdown[group] = max(0, min(100, approval))
        }

        return breakdown
    }

    private func generateIssueApproval(baseApproval: Double, character: Character) -> [IssueCategory: Double] {
        var approval: [IssueCategory: Double] = [:]

        for issue in IssueCategory.allCases {
            var rating = baseApproval + Double.random(in: -15...15)

            // Modifiers based on character stats
            switch issue {
            case .economy:
                rating += Double(character.intelligence) / 10 - 5
            case .foreignPolicy:
                rating += Double(character.charisma) / 10 - 5
            case .security:
                rating += Double(character.reputation) / 10 - 5
            default:
                break
            }

            approval[issue] = max(0, min(100, rating))
        }

        return approval
    }

    private func generateRegionalApproval(baseApproval: Double) -> [String: Double] {
        let regions = ["Northeast", "Southeast", "Midwest", "Southwest", "West"]
        var approval: [String: Double] = [:]

        for region in regions {
            let variance = Double.random(in: -10...10)
            approval[region] = max(0, min(100, baseApproval + variance))
        }

        return approval
    }

    // MARK: - Media Coverage

    func generateMediaCoverage(character: Character, event: String? = nil) {
        let sentiment: MediaCoverage.MediaSentiment
        let approval = character.approvalRating

        // Determine sentiment based on approval
        switch approval {
        case 70...: sentiment = .veryPositive
        case 55..<70: sentiment = .positive
        case 45..<55: sentiment = .neutral
        case 30..<45: sentiment = .negative
        default: sentiment = .veryNegative
        }

        let category = IssueCategory.allCases.randomElement() ?? .economy
        let headlines = generateHeadlines(sentiment: sentiment, category: category, characterName: character.name)
        let headline = headlines.randomElement() ?? "Politician in the News"

        let impact: Double
        switch sentiment {
        case .veryPositive: impact = Double.random(in: 3...5)
        case .positive: impact = Double.random(in: 1...3)
        case .neutral: impact = 0
        case .negative: impact = Double.random(in: -3...(-1))
        case .veryNegative: impact = Double.random(in: -5...(-3))
        }

        let coverage = MediaCoverage(
            date: character.currentDate,
            headline: headline,
            sentiment: sentiment,
            category: category,
            impactOnApproval: impact
        )

        mediaCoverage.append(coverage)

        // Keep last 20 stories
        if mediaCoverage.count > 20 {
            mediaCoverage.removeFirst()
        }
    }

    private func generateHeadlines(sentiment: MediaCoverage.MediaSentiment, category: IssueCategory, characterName: String) -> [String] {
        switch sentiment {
        case .veryPositive:
            return [
                "\(characterName) Praised for \(category.rawValue) Leadership",
                "Approval Soars as \(characterName) Delivers on \(category.rawValue)",
                "\(characterName)'s \(category.rawValue) Plan Wins Widespread Support"
            ]
        case .positive:
            return [
                "\(characterName) Makes Progress on \(category.rawValue)",
                "Public Responds Positively to \(characterName)'s \(category.rawValue) Initiative",
                "\(characterName) Gains Ground on \(category.rawValue) Issues"
            ]
        case .neutral:
            return [
                "\(characterName) Addresses \(category.rawValue) Concerns",
                "Mixed Reactions to \(characterName)'s \(category.rawValue) Stance",
                "\(characterName) Outlines \(category.rawValue) Strategy"
            ]
        case .negative:
            return [
                "Critics Question \(characterName)'s \(category.rawValue) Approach",
                "\(characterName) Faces Backlash on \(category.rawValue)",
                "Concerns Mount Over \(characterName)'s \(category.rawValue) Policy"
            ]
        case .veryNegative:
            return [
                "Major Controversy: \(characterName)'s \(category.rawValue) Failure",
                "Calls for Action as \(characterName) Struggles with \(category.rawValue)",
                "Crisis Deepens: \(characterName)'s \(category.rawValue) Disaster"
            ]
        }
    }

    // MARK: - Social Media

    func updateSocialMedia(character: Character) {
        // Update followers based on approval
        let followerGrowth = Int(character.approvalRating - 50) * 100
        socialMetrics.followers = max(10_000, socialMetrics.followers + followerGrowth)

        // Update engagement
        socialMetrics.engagementRate = max(0.5, min(10.0, 3.5 + (character.approvalRating - 50) / 10))

        // Update sentiment
        switch character.approvalRating {
        case 70...: socialMetrics.sentiment = .veryPositive
        case 55..<70: socialMetrics.sentiment = .positive
        case 45..<55: socialMetrics.sentiment = .mixed
        case 30..<45: socialMetrics.sentiment = .negative
        default: socialMetrics.sentiment = .veryNegative
        }

        // Update trending topics
        updateTrendingTopics(character: character)
    }

    private func updateTrendingTopics(character: Character) {
        var topics: [String] = ["#\(character.name.replacingOccurrences(of: " ", with: ""))"]

        // Add random trending topics based on recent activity
        let possibleTopics = [
            "#Leadership", "#Policy", "#Change", "#Reform",
            "#Progress", "#Justice", "#Economy", "#Healthcare",
            "#Education", "#Environment", "#Security"
        ]

        topics.append(contentsOf: possibleTopics.shuffled().prefix(4))
        socialMetrics.trendingTopics = topics
    }

    func createSocialPost(content: String, character: Character) {
        let baseEngagement = Int(Double(socialMetrics.followers) * (socialMetrics.engagementRate / 100))

        let post = SocialMediaPost(
            date: character.currentDate,
            content: content,
            likes: Int.random(in: (baseEngagement/2)...(baseEngagement*2)),
            shares: Int.random(in: (baseEngagement/10)...(baseEngagement/5)),
            comments: Int.random(in: (baseEngagement/20)...(baseEngagement/10))
        )

        socialMetrics.recentPosts.insert(post, at: 0)

        // Keep last 10 posts
        if socialMetrics.recentPosts.count > 10 {
            socialMetrics.recentPosts.removeLast()
        }
    }

    // MARK: - Public Opinion Actions

    func performAction(
        _ action: PublicOpinionAction,
        character: inout Character
    ) -> (success: Bool, message: String) {
        // Check reputation requirement
        if character.reputation < action.reputationCost {
            return (false, "Insufficient reputation (need \(action.reputationCost)+)")
        }

        // Check funds if required
        if let cost = action.cost {
            guard character.campaignFunds >= cost else {
                return (false, "Insufficient funds")
            }
            character.campaignFunds -= cost
        }

        // Apply reputation cost
        character.reputation = max(0, character.reputation - action.reputationCost)

        // Create active action for duration
        let endDate = Calendar.current.date(byAdding: .day, value: action.duration, to: character.currentDate) ?? character.currentDate
        let activeAction = ActiveOpinionAction(
            id: UUID(),
            action: action,
            startDate: character.currentDate,
            endDate: endDate,
            dailyBoost: action.approvalImpact / Double(action.duration)
        )
        activeActions.append(activeAction)

        // Immediate partial boost
        character.approvalRating = max(0, min(100, character.approvalRating + (action.approvalImpact * 0.3)))

        // Generate positive media coverage
        generateMediaCoverage(character: character, event: action.name)

        // Add stress
        character.stress = min(100, character.stress + 2)  // REDUCED from +5 to +2

        return (true, "\(action.name) initiated successfully!")
    }

    func processActiveActions(character: inout Character, currentDate: Date) {
        var completedActions: [UUID] = []

        for i in 0..<activeActions.count {
            let action = activeActions[i]

            // Check if action is complete
            if currentDate >= action.endDate {
                completedActions.append(action.id)
            } else {
                // Apply daily boost
                character.approvalRating = max(0, min(100, character.approvalRating + action.dailyBoost))
            }
        }

        // Remove completed actions
        activeActions.removeAll { completedActions.contains($0.id) }
    }

    // MARK: - Queries

    func getApprovalTrend(days: Int = 7) -> [(Date, Double)] {
        let recentPolls = pollHistory.suffix(days)
        return recentPolls.map { ($0.date, $0.overallApproval) }
    }

    func getStrongestDemographic() -> (DemographicGroup, Double)? {
        guard let poll = currentPoll else { return nil }
        return poll.demographicBreakdown.max(by: { $0.value < $1.value })
    }

    func getWeakestDemographic() -> (DemographicGroup, Double)? {
        guard let poll = currentPoll else { return nil }
        return poll.demographicBreakdown.min(by: { $0.value < $1.value })
    }

    func getBestIssue() -> (IssueCategory, Double)? {
        guard let poll = currentPoll else { return nil }
        return poll.issueApproval.max(by: { $0.value < $1.value })
    }

    func getWorstIssue() -> (IssueCategory, Double)? {
        guard let poll = currentPoll else { return nil }
        return poll.issueApproval.min(by: { $0.value < $1.value })
    }

    func getRecentCoverage(limit: Int = 10) -> [MediaCoverage] {
        return Array(mediaCoverage.suffix(limit).reversed())
    }

    func getAverageMediaSentiment() -> Double {
        guard !mediaCoverage.isEmpty else { return 0 }

        let sentimentValues: [MediaCoverage.MediaSentiment: Double] = [
            .veryPositive: 2.0,
            .positive: 1.0,
            .neutral: 0.0,
            .negative: -1.0,
            .veryNegative: -2.0
        ]

        let total = mediaCoverage.reduce(0.0) { sum, coverage in
            sum + (sentimentValues[coverage.sentiment] ?? 0)
        }

        return total / Double(mediaCoverage.count)
    }
}
