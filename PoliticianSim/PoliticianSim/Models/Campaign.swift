//
//  Campaign.swift
//  PoliticianSim
//
//  Campaign and Election system models
//

import Foundation

// MARK: - Campaign Model

struct Campaign: Codable, Identifiable {
    let id: UUID
    let targetPosition: Position
    let startDate: Date
    var endDate: Date
    var status: CampaignStatus
    var activities: [CampaignActivity]
    var funds: Decimal
    var pollNumbers: Double // 0-100 representing percentage of voter support

    enum CampaignStatus: String, Codable {
        case preparing = "Preparing"
        case active = "Active"
        case completed = "Completed"
        case withdrawn = "Withdrawn"
    }

    init(targetPosition: Position, startDate: Date, durationDays: Int = 90) {
        self.id = UUID()
        self.targetPosition = targetPosition
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .day, value: durationDays, to: startDate) ?? startDate
        self.status = .preparing
        self.activities = []
        self.funds = 0
        self.pollNumbers = 0
    }

    func daysRemaining(from currentDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: currentDate, to: endDate)
        return max(0, components.day ?? 0)
    }

    func isActive(on currentDate: Date) -> Bool {
        return status == .active && currentDate < endDate
    }
}

// MARK: - Campaign Activity Model

struct CampaignActivity: Codable, Identifiable {
    let id: UUID
    let type: ActivityType
    let date: Date
    let cost: Decimal
    let pollImpact: Double // Change in poll numbers
    let description: String

    enum ActivityType: String, Codable {
        case rally = "Rally"
        case advertisement = "Advertisement"
        case debate = "Debate"
        case phoneBank = "Phone Banking"
        case doorKnocking = "Door Knocking"
        case fundraiser = "Fundraiser"
        case townHall = "Town Hall"
        case socialMedia = "Social Media Campaign"
        case interview = "Media Interview"
        case endorsement = "Endorsement"

        var iconName: String {
            switch self {
            case .rally: return "megaphone.fill"
            case .advertisement: return "tv.fill"
            case .debate: return "person.2.fill"
            case .phoneBank: return "phone.fill"
            case .doorKnocking: return "door.left.hand.open"
            case .fundraiser: return "dollarsign.circle.fill"
            case .townHall: return "building.2.fill"
            case .socialMedia: return "bubble.left.and.bubble.right.fill"
            case .interview: return "mic.fill"
            case .endorsement: return "hand.thumbsup.fill"
            }
        }

        var baseCost: Decimal {
            switch self {
            case .rally: return 5000
            case .advertisement: return 10000
            case .debate: return 0
            case .phoneBank: return 500
            case .doorKnocking: return 200
            case .fundraiser: return 2000
            case .townHall: return 1000
            case .socialMedia: return 1500
            case .interview: return 0
            case .endorsement: return 0
            }
        }

        var basePollImpact: Double {
            switch self {
            case .rally: return 2.5
            case .advertisement: return 3.0
            case .debate: return 5.0
            case .phoneBank: return 0.5
            case .doorKnocking: return 0.8
            case .fundraiser: return 0.3
            case .townHall: return 1.5
            case .socialMedia: return 1.2
            case .interview: return 2.0
            case .endorsement: return 4.0
            }
        }
    }

    init(type: ActivityType, date: Date, cost: Decimal, pollImpact: Double, description: String) {
        self.id = UUID()
        self.type = type
        self.date = date
        self.cost = cost
        self.pollImpact = pollImpact
        self.description = description
    }
}

// MARK: - Election Model

struct Election: Codable, Identifiable {
    let id: UUID
    let position: Position
    let electionDate: Date
    var candidates: [Candidate]
    var results: ElectionResults?
    var voterTurnout: Double // Percentage

    init(position: Position, electionDate: Date) {
        self.id = UUID()
        self.position = position
        self.electionDate = electionDate
        self.candidates = []
        self.results = nil
        self.voterTurnout = 0
    }

    func daysUntilElection(from currentDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: currentDate, to: electionDate)
        return max(0, components.day ?? 0)
    }

    func isElectionDay(on currentDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDate, inSameDayAs: electionDate)
    }
}

// MARK: - Candidate Model

struct Candidate: Codable, Identifiable {
    let id: UUID
    let name: String
    let party: String
    var votePercentage: Double
    let isPlayer: Bool
    var charisma: Int
    var funds: Decimal

    init(name: String, party: String, isPlayer: Bool = false, charisma: Int = 50, funds: Decimal = 0) {
        self.id = UUID()
        self.name = name
        self.party = party
        self.votePercentage = 0
        self.isPlayer = isPlayer
        self.charisma = charisma
        self.funds = funds
    }
}

// MARK: - Election Results Model

struct ElectionResults: Codable {
    let winnerId: UUID
    let winnerName: String
    let finalResults: [UUID: Double] // candidateId: votePercentage
    let totalVotes: Int
    let margin: Double // Winning margin in percentage points

    init(winnerId: UUID, winnerName: String, finalResults: [UUID: Double], totalVotes: Int) {
        self.winnerId = winnerId
        self.winnerName = winnerName
        self.finalResults = finalResults
        self.totalVotes = totalVotes

        // Calculate margin
        let sortedResults = finalResults.values.sorted(by: >)
        if sortedResults.count >= 2 {
            self.margin = sortedResults[0] - sortedResults[1]
        } else {
            self.margin = sortedResults.first ?? 0
        }
    }
}
