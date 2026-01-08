//
//  ElectionManager.swift
//  PoliticianSim
//
//  Manages campaigns, elections, and voting simulation
//

import Foundation
import Combine

class ElectionManager: ObservableObject {
    @Published var activeCampaign: Campaign?
    @Published var upcomingElection: Election?
    @Published var electionHistory: [Election] = []

    // MARK: - Campaign Management

    func startCampaign(for position: Position, character: Character) -> Campaign {
        let campaign = Campaign(
            targetPosition: position,
            startDate: character.currentDate,
            durationDays: 90
        )

        var updatedCampaign = campaign
        updatedCampaign.status = .active
        updatedCampaign.funds = character.campaignFunds
        updatedCampaign.pollNumbers = calculateInitialPollNumbers(character: character)

        activeCampaign = updatedCampaign

        // Create election
        createElection(for: position, character: character)

        return updatedCampaign
    }

    func performCampaignActivity(
        _ activityType: CampaignActivity.ActivityType,
        character: inout Character
    ) -> CampaignActivity? {
        guard var campaign = activeCampaign else { return nil }

        let baseCost = activityType.baseCost
        let basePollImpact = activityType.basePollImpact

        // Check if character has enough funds
        guard character.campaignFunds >= baseCost else { return nil }

        // Calculate actual impact based on character stats
        let charismaBonus = Double(character.charisma) / 100.0
        let actualPollImpact = basePollImpact * (1 + charismaBonus * 0.5)

        // Create activity
        let activity = CampaignActivity(
            type: activityType,
            date: character.currentDate,
            cost: baseCost,
            pollImpact: actualPollImpact,
            description: generateActivityDescription(type: activityType, character: character)
        )

        // Deduct funds
        character.campaignFunds -= baseCost

        // Update poll numbers
        campaign.pollNumbers = min(100, campaign.pollNumbers + actualPollImpact)
        campaign.funds -= baseCost
        campaign.activities.append(activity)

        // Add stress from campaigning
        character.stress = min(100, character.stress + 2)  // REDUCED from +5 to +2

        activeCampaign = campaign

        return activity
    }

    private func generateActivityDescription(type: CampaignActivity.ActivityType, character: Character) -> String {
        switch type {
        case .rally:
            return "\(character.name) held a passionate rally, energizing supporters."
        case .advertisement:
            return "Launched new TV and online advertisements highlighting key policies."
        case .debate:
            return "\(character.name) participated in a public debate with other candidates."
        case .phoneBank:
            return "Volunteers made hundreds of calls to potential voters."
        case .doorKnocking:
            return "Campaign team knocked on doors in key neighborhoods."
        case .fundraiser:
            return "Hosted a fundraising dinner with local supporters."
        case .townHall:
            return "\(character.name) answered questions at a community town hall."
        case .socialMedia:
            return "Ran a targeted social media campaign reaching thousands."
        case .interview:
            return "\(character.name) gave an interview to a major news outlet."
        case .endorsement:
            return "Received a major endorsement from a popular figure."
        }
    }

    // MARK: - Election Management

    private func createElection(for position: Position, character: Character) {
        let electionDate = Calendar.current.date(byAdding: .day, value: 90, to: character.currentDate) ?? character.currentDate

        var election = Election(position: position, electionDate: electionDate)

        // Add player as candidate
        let playerCandidate = Candidate(
            name: character.name,
            party: "Independent",
            isPlayer: true,
            charisma: character.charisma,
            funds: character.campaignFunds
        )

        // Generate AI opponents based on position level
        let numOpponents = min(position.level, 3) // More competitive at higher levels
        var opponents: [Candidate] = []

        for i in 0..<numOpponents {
            let opponentCharisma = Int.random(in: 40...80)
            let opponentFunds = Decimal(Int.random(in: 50000...500000))

            let opponent = Candidate(
                name: generateOpponentName(),
                party: ["Democrat", "Republican"].randomElement() ?? "Independent",
                isPlayer: false,
                charisma: opponentCharisma,
                funds: opponentFunds
            )
            opponents.append(opponent)
        }

        election.candidates = [playerCandidate] + opponents
        upcomingElection = election
    }

    func simulateElection(character: Character) -> ElectionResults? {
        guard var election = upcomingElection else { return nil }

        // Calculate voter turnout (50-75% based on position importance)
        let baseTurnout = 50.0
        let levelBonus = Double(election.position.level) * 3.0
        election.voterTurnout = min(75.0, baseTurnout + levelBonus)

        let totalVoters = 100000 * Int(election.position.level) // Scale with position importance
        let actualVoters = Int(Double(totalVoters) * (election.voterTurnout / 100.0))

        var finalResults: [UUID: Double] = [:]

        // Calculate vote percentages for each candidate
        for (index, candidate) in election.candidates.enumerated() {
            var voteShare: Double

            if candidate.isPlayer {
                // Player's vote share based on campaign performance
                if let campaign = activeCampaign {
                    voteShare = campaign.pollNumbers
                } else {
                    voteShare = Double(character.charisma) / 2.0 + Double(character.reputation) / 4.0
                }

                // Add approval rating impact
                voteShare += character.approvalRating * 0.2

                // Add some randomness (±5%)
                voteShare += Double.random(in: -5...5)

            } else {
                // AI candidate vote share
                let baseShare = Double(candidate.charisma) / 2.0
                let fundsBonus = min(10.0, Double(truncating: candidate.funds as NSDecimalNumber) / 50000.0)
                voteShare = baseShare + fundsBonus + Double.random(in: -10...10)
            }

            voteShare = max(0, min(100, voteShare))
            finalResults[candidate.id] = voteShare
        }

        // Normalize to 100%
        let totalShares = finalResults.values.reduce(0, +)
        if totalShares > 0 {
            for (id, share) in finalResults {
                finalResults[id] = (share / totalShares) * 100.0
            }
        }

        // Find winner
        let winnerEntry = finalResults.max(by: { $0.value < $1.value })!
        let winnerId = winnerEntry.key
        let winnerCandidate = election.candidates.first(where: { $0.id == winnerId })!

        let results = ElectionResults(
            winnerId: winnerId,
            winnerName: winnerCandidate.name,
            finalResults: finalResults,
            totalVotes: actualVoters
        )

        election.results = results
        electionHistory.append(election)
        upcomingElection = nil

        // Clear active campaign
        if activeCampaign?.targetPosition.id == election.position.id {
            var campaign = activeCampaign!
            campaign.status = .completed
            activeCampaign = nil
        }

        return results
    }

    func wonElection(character: Character) -> Bool {
        guard let election = electionHistory.last,
              let results = election.results else {
            return false
        }

        let playerCandidate = election.candidates.first(where: { $0.isPlayer })
        return results.winnerId == playerCandidate?.id
    }

    // MARK: - Helper Methods

    private func calculateInitialPollNumbers(character: Character) -> Double {
        let baseSupport = Double(character.charisma) / 3.0
        let reputationBonus = Double(character.reputation) / 5.0
        let approvalBonus = character.approvalRating / 5.0

        return min(50.0, baseSupport + reputationBonus + approvalBonus)
    }

    private func generateOpponentName() -> String {
        let firstNames = ["John", "Sarah", "Michael", "Emily", "David", "Jennifer", "Robert", "Lisa", "William", "Mary"]
        let lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"]

        let firstName = firstNames.randomElement() ?? "John"
        let lastName = lastNames.randomElement() ?? "Smith"

        return "\(firstName) \(lastName)"
    }

    func getAvailableCampaignActivities() -> [CampaignActivity.ActivityType] {
        return [
            .rally,
            .advertisement,
            .phoneBank,
            .doorKnocking,
            .townHall,
            .socialMedia
        ]
    }

    func endCampaign() {
        activeCampaign = nil
    }
}
