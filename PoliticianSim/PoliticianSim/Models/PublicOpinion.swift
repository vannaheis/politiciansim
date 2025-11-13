//
//  PublicOpinion.swift
//  PoliticianSim
//
//  Public opinion tracking and polling system models
//

import Foundation

// MARK: - Opinion Poll

struct OpinionPoll: Codable, Identifiable {
    let id: UUID
    let date: Date
    var overallApproval: Double // 0-100
    var demographicBreakdown: [DemographicGroup: Double]
    var issueApproval: [IssueCategory: Double]
    var regionalApproval: [String: Double] // Region name -> approval
    var trendDirection: TrendDirection

    enum TrendDirection: String, Codable {
        case risingStrongly = "Rising Strongly"
        case rising = "Rising"
        case stable = "Stable"
        case falling = "Falling"
        case fallingStrongly = "Falling Strongly"

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .risingStrongly: return (0.2, 0.8, 0.2)
            case .rising: return (0.5, 0.9, 0.5)
            case .stable: return (0.7, 0.7, 0.7)
            case .falling: return (1.0, 0.7, 0.0)
            case .fallingStrongly: return (1.0, 0.2, 0.2)
            }
        }

        var iconName: String {
            switch self {
            case .risingStrongly: return "arrow.up.circle.fill"
            case .rising: return "arrow.up.right.circle.fill"
            case .stable: return "arrow.right.circle.fill"
            case .falling: return "arrow.down.right.circle.fill"
            case .fallingStrongly: return "arrow.down.circle.fill"
            }
        }
    }

    init(
        id: UUID = UUID(),
        date: Date,
        overallApproval: Double,
        demographicBreakdown: [DemographicGroup: Double] = [:],
        issueApproval: [IssueCategory: Double] = [:],
        regionalApproval: [String: Double] = [:],
        trendDirection: TrendDirection = .stable
    ) {
        self.id = id
        self.date = date
        self.overallApproval = overallApproval
        self.demographicBreakdown = demographicBreakdown
        self.issueApproval = issueApproval
        self.regionalApproval = regionalApproval
        self.trendDirection = trendDirection
    }
}

// MARK: - Demographic Group

enum DemographicGroup: String, Codable, CaseIterable {
    case youth = "18-29"
    case youngAdults = "30-44"
    case middleAge = "45-59"
    case seniors = "60+"
    case male = "Male"
    case female = "Female"
    case lowIncome = "Low Income"
    case middleIncome = "Middle Income"
    case highIncome = "High Income"
    case urban = "Urban"
    case suburban = "Suburban"
    case rural = "Rural"

    var iconName: String {
        switch self {
        case .youth, .youngAdults, .middleAge, .seniors:
            return "person.fill"
        case .male, .female:
            return "person.2.fill"
        case .lowIncome, .middleIncome, .highIncome:
            return "dollarsign.circle.fill"
        case .urban, .suburban, .rural:
            return "building.2.fill"
        }
    }

    var category: String {
        switch self {
        case .youth, .youngAdults, .middleAge, .seniors:
            return "Age"
        case .male, .female:
            return "Gender"
        case .lowIncome, .middleIncome, .highIncome:
            return "Income"
        case .urban, .suburban, .rural:
            return "Location"
        }
    }
}

// MARK: - Issue Category

enum IssueCategory: String, Codable, CaseIterable {
    case economy = "Economy"
    case healthcare = "Healthcare"
    case education = "Education"
    case environment = "Environment"
    case security = "Security"
    case immigration = "Immigration"
    case foreignPolicy = "Foreign Policy"
    case socialIssues = "Social Issues"

    var iconName: String {
        switch self {
        case .economy: return "dollarsign.circle.fill"
        case .healthcare: return "cross.circle.fill"
        case .education: return "graduationcap.fill"
        case .environment: return "leaf.fill"
        case .security: return "shield.fill"
        case .immigration: return "globe.americas.fill"
        case .foreignPolicy: return "flag.fill"
        case .socialIssues: return "person.3.fill"
        }
    }

    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .economy: return (0.2, 0.8, 0.2)
        case .healthcare: return (1.0, 0.2, 0.2)
        case .education: return (0.2, 0.5, 1.0)
        case .environment: return (0.2, 0.7, 0.2)
        case .security: return (0.8, 0.6, 0.2)
        case .immigration: return (0.6, 0.4, 0.8)
        case .foreignPolicy: return (0.8, 0.3, 0.3)
        case .socialIssues: return (0.9, 0.5, 0.2)
        }
    }
}

// MARK: - Media Coverage

struct MediaCoverage: Codable, Identifiable {
    let id: UUID
    let date: Date
    let headline: String
    let sentiment: MediaSentiment
    let category: IssueCategory
    var impactOnApproval: Double // -10 to +10

    enum MediaSentiment: String, Codable {
        case veryPositive = "Very Positive"
        case positive = "Positive"
        case neutral = "Neutral"
        case negative = "Negative"
        case veryNegative = "Very Negative"

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .veryPositive: return (0.2, 0.8, 0.2)
            case .positive: return (0.5, 0.9, 0.5)
            case .neutral: return (0.7, 0.7, 0.7)
            case .negative: return (1.0, 0.7, 0.0)
            case .veryNegative: return (1.0, 0.2, 0.2)
            }
        }

        var iconName: String {
            switch self {
            case .veryPositive: return "hand.thumbsup.fill"
            case .positive: return "hand.thumbsup"
            case .neutral: return "minus.circle"
            case .negative: return "hand.thumbsdown"
            case .veryNegative: return "hand.thumbsdown.fill"
            }
        }
    }

    init(
        id: UUID = UUID(),
        date: Date,
        headline: String,
        sentiment: MediaSentiment,
        category: IssueCategory,
        impactOnApproval: Double
    ) {
        self.id = id
        self.date = date
        self.headline = headline
        self.sentiment = sentiment
        self.category = category
        self.impactOnApproval = impactOnApproval
    }
}

// MARK: - Social Media Metrics

struct SocialMediaMetrics: Codable {
    var followers: Int
    var engagementRate: Double // 0-100
    var sentiment: SocialSentiment
    var recentPosts: [SocialMediaPost]
    var trendingTopics: [String]

    enum SocialSentiment: String, Codable {
        case veryPositive = "Very Positive"
        case positive = "Positive"
        case mixed = "Mixed"
        case negative = "Negative"
        case veryNegative = "Very Negative"

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .veryPositive: return (0.2, 0.8, 0.2)
            case .positive: return (0.5, 0.9, 0.5)
            case .mixed: return (0.7, 0.7, 0.7)
            case .negative: return (1.0, 0.7, 0.0)
            case .veryNegative: return (1.0, 0.2, 0.2)
            }
        }
    }

    init(
        followers: Int = 10000,
        engagementRate: Double = 3.5,
        sentiment: SocialSentiment = .mixed,
        recentPosts: [SocialMediaPost] = [],
        trendingTopics: [String] = []
    ) {
        self.followers = followers
        self.engagementRate = engagementRate
        self.sentiment = sentiment
        self.recentPosts = recentPosts
        self.trendingTopics = trendingTopics
    }
}

struct SocialMediaPost: Codable, Identifiable {
    let id: UUID
    let date: Date
    let content: String
    var likes: Int
    var shares: Int
    var comments: Int

    var engagement: Int {
        likes + shares + (comments * 2)
    }

    init(
        id: UUID = UUID(),
        date: Date,
        content: String,
        likes: Int = 0,
        shares: Int = 0,
        comments: Int = 0
    ) {
        self.id = id
        self.date = date
        self.content = content
        self.likes = likes
        self.shares = shares
        self.comments = comments
    }
}

// MARK: - Public Opinion Action

struct PublicOpinionAction: Identifiable {
    let id: UUID
    let type: ActionType
    let name: String
    let description: String
    let cost: Decimal?
    let reputationCost: Int
    let approvalImpact: Double
    let duration: Int // Days for effect

    enum ActionType: String, CaseIterable {
        case pressConference = "Press Conference"
        case townHall = "Town Hall Meeting"
        case mediaInterview = "Media Interview"
        case socialMediaCampaign = "Social Media Campaign"
        case publicAppearance = "Public Appearance"
        case addressNation = "Address the Nation"
        case communityEvent = "Community Event"
        case damageControl = "Damage Control"

        var iconName: String {
            switch self {
            case .pressConference: return "mic.fill"
            case .townHall: return "person.3.fill"
            case .mediaInterview: return "tv.fill"
            case .socialMediaCampaign: return "iphone"
            case .publicAppearance: return "hand.wave.fill"
            case .addressNation: return "megaphone.fill"
            case .communityEvent: return "building.2.fill"
            case .damageControl: return "bandage.fill"
            }
        }
    }

    init(
        id: UUID = UUID(),
        type: ActionType,
        name: String,
        description: String,
        cost: Decimal? = nil,
        reputationCost: Int = 0,
        approvalImpact: Double,
        duration: Int = 1
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.description = description
        self.cost = cost
        self.reputationCost = reputationCost
        self.approvalImpact = approvalImpact
        self.duration = duration
    }
}

// MARK: - Action Templates

extension PublicOpinionAction {
    static func getAvailableActions(character: Character) -> [PublicOpinionAction] {
        var actions: [PublicOpinionAction] = []

        // Press Conference (always available)
        actions.append(PublicOpinionAction(
            type: .pressConference,
            name: "Hold Press Conference",
            description: "Address media to clarify positions and build support",
            cost: 50_000,
            reputationCost: 0,
            approvalImpact: 2.0,
            duration: 3
        ))

        // Town Hall
        actions.append(PublicOpinionAction(
            type: .townHall,
            name: "Host Town Hall Meeting",
            description: "Meet constituents directly and hear concerns",
            cost: 100_000,
            reputationCost: 0,
            approvalImpact: 3.0,
            duration: 5
        ))

        // Media Interview
        actions.append(PublicOpinionAction(
            type: .mediaInterview,
            name: "Schedule Media Interview",
            description: "Appear on major news outlet",
            reputationCost: 5,
            approvalImpact: 2.5,
            duration: 2
        ))

        // Social Media Campaign
        actions.append(PublicOpinionAction(
            type: .socialMediaCampaign,
            name: "Launch Social Media Campaign",
            description: "Boost online presence and engagement",
            cost: 200_000,
            reputationCost: 0,
            approvalImpact: 1.5,
            duration: 7
        ))

        // Public Appearance
        actions.append(PublicOpinionAction(
            type: .publicAppearance,
            name: "Make Public Appearance",
            description: "Attend public events and ceremonies",
            cost: 25_000,
            reputationCost: 0,
            approvalImpact: 1.0,
            duration: 1
        ))

        // Address Nation (high reputation required)
        if character.reputation >= 40 {
            actions.append(PublicOpinionAction(
                type: .addressNation,
                name: "Address the Nation",
                description: "Deliver major televised address",
                cost: 500_000,
                reputationCost: 15,
                approvalImpact: 5.0,
                duration: 7
            ))
        }

        // Community Event
        actions.append(PublicOpinionAction(
            type: .communityEvent,
            name: "Attend Community Event",
            description: "Show support for local communities",
            cost: 50_000,
            reputationCost: 0,
            approvalImpact: 2.0,
            duration: 2
        ))

        // Damage Control (only if approval is low)
        if character.approvalRating < 40 {
            actions.append(PublicOpinionAction(
                type: .damageControl,
                name: "Crisis Management",
                description: "Respond to controversies and rebuild trust",
                cost: 300_000,
                reputationCost: 10,
                approvalImpact: 4.0,
                duration: 5
            ))
        }

        return actions
    }
}
