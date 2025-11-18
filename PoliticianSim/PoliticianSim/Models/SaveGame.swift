//
//  SaveGame.swift
//  PoliticianSim
//
//  Save game data structure
//

import Foundation

// MARK: - Save Game Model

struct SaveGame: Codable {
    let id: UUID
    let saveDate: Date
    let gameName: String
    let characterName: String
    let currentPosition: String
    let approvalRating: Double
    let gameDate: Date

    // All game state
    let character: Character?
    let statChanges: [StatChange]
    let approvalHistory: [ApprovalHistory]
    let fundTransactions: [FundTransaction]
    let activeCampaign: Campaign?
    let upcomingElection: Election?
    let electionHistory: [Election]
    let activeEvent: Event?
    let proposedPolicies: [Policy]
    let enactedPolicies: [Policy]
    let currentBudget: Budget?
    let budgetHistory: [Budget]
    let draftLaws: [Law]
    let activeLaws: [Law]
    let enactedLaws: [Law]
    let rejectedLaws: [Law]
    let currentLegislativeSession: LegislativeSession?
    let relationships: [CountryRelationship]
    let activeTreaties: [Treaty]
    let foreignPolicyStance: ForeignPolicyStance
    let diplomaticEvents: [DiplomaticEvent]
    let currentPoll: OpinionPoll?
    let pollHistory: [OpinionPoll]
    let mediaCoverage: [MediaCoverage]
    let socialMetrics: SocialMediaMetrics
    let enrollmentStatus: EnrollmentStatus
    let economicData: EconomicData

    // Military (President only)
    let activeResearch: [TechnologyResearch]
    let activeWars: [War]
    let warHistory: [War]
    let territories: [Territory]
    let activeRebellions: [Rebellion]
    let rebellionHistory: [Rebellion]

    init(gameManager: GameManager) {
        self.id = UUID()
        self.saveDate = Date()

        let character = gameManager.characterManager.character
        self.characterName = character?.name ?? "Unknown"
        self.currentPosition = character?.currentPosition?.title ?? "None"
        self.approvalRating = character?.approvalRating ?? 0
        self.gameDate = character?.currentDate ?? Date()
        self.gameName = "\(characterName) - \(currentPosition)"

        // Character & Stats
        self.character = character
        self.statChanges = gameManager.statManager.statChanges
        self.approvalHistory = gameManager.statManager.approvalHistory
        self.fundTransactions = gameManager.statManager.fundTransactions

        // Elections & Campaigns
        self.activeCampaign = gameManager.electionManager.activeCampaign
        self.upcomingElection = gameManager.electionManager.upcomingElection
        self.electionHistory = gameManager.electionManager.electionHistory

        // Events
        self.activeEvent = gameManager.gameState.activeEvent

        // Policies
        self.proposedPolicies = gameManager.policyManager.proposedPolicies
        self.enactedPolicies = gameManager.policyManager.enactedPolicies

        // Budget
        self.currentBudget = gameManager.budgetManager.currentBudget
        self.budgetHistory = gameManager.budgetManager.budgetHistory

        // Laws
        self.draftLaws = gameManager.lawsManager.draftLaws
        self.activeLaws = gameManager.lawsManager.activeLaws
        self.enactedLaws = gameManager.lawsManager.enactedLaws
        self.rejectedLaws = gameManager.lawsManager.rejectedLaws
        self.currentLegislativeSession = gameManager.lawsManager.currentSession

        // Diplomacy
        self.relationships = gameManager.diplomacyManager.relationships
        self.activeTreaties = gameManager.diplomacyManager.activeTreaties
        self.foreignPolicyStance = gameManager.diplomacyManager.foreignPolicyStance
        self.diplomaticEvents = gameManager.diplomacyManager.diplomaticEvents

        // Public Opinion
        self.currentPoll = gameManager.publicOpinionManager.currentPoll
        self.pollHistory = gameManager.publicOpinionManager.pollHistory
        self.mediaCoverage = gameManager.publicOpinionManager.mediaCoverage
        self.socialMetrics = gameManager.publicOpinionManager.socialMetrics

        // Education
        self.enrollmentStatus = gameManager.educationManager.enrollmentStatus

        // Economic Data
        self.economicData = gameManager.economicDataManager.economicData

        // Military
        self.activeResearch = gameManager.militaryManager.activeResearch
        self.activeWars = gameManager.warEngine.activeWars
        self.warHistory = gameManager.warEngine.warHistory
        self.territories = gameManager.territoryManager.territories
        self.activeRebellions = gameManager.territoryManager.activeRebellions
        self.rebellionHistory = gameManager.territoryManager.rebellionHistory
    }

    func restore(to gameManager: GameManager) {
        // Restore character
        if let character = character {
            gameManager.characterManager.character = character
        }

        // Restore stats
        gameManager.statManager.statChanges = statChanges
        gameManager.statManager.approvalHistory = approvalHistory
        gameManager.statManager.fundTransactions = fundTransactions

        // Restore elections & campaigns
        gameManager.electionManager.activeCampaign = activeCampaign
        gameManager.electionManager.upcomingElection = upcomingElection
        gameManager.electionManager.electionHistory = electionHistory

        // Restore events
        gameManager.gameState.activeEvent = activeEvent

        // Restore policies
        gameManager.policyManager.proposedPolicies = proposedPolicies
        gameManager.policyManager.enactedPolicies = enactedPolicies

        // Restore budget
        gameManager.budgetManager.currentBudget = currentBudget
        gameManager.budgetManager.budgetHistory = budgetHistory

        // Restore laws
        gameManager.lawsManager.draftLaws = draftLaws
        gameManager.lawsManager.activeLaws = activeLaws
        gameManager.lawsManager.enactedLaws = enactedLaws
        gameManager.lawsManager.rejectedLaws = rejectedLaws
        gameManager.lawsManager.currentSession = currentLegislativeSession

        // Restore diplomacy
        gameManager.diplomacyManager.relationships = relationships
        gameManager.diplomacyManager.activeTreaties = activeTreaties
        gameManager.diplomacyManager.foreignPolicyStance = foreignPolicyStance
        gameManager.diplomacyManager.diplomaticEvents = diplomaticEvents

        // Restore public opinion
        gameManager.publicOpinionManager.currentPoll = currentPoll
        gameManager.publicOpinionManager.pollHistory = pollHistory
        gameManager.publicOpinionManager.mediaCoverage = mediaCoverage
        gameManager.publicOpinionManager.socialMetrics = socialMetrics

        // Restore education
        gameManager.educationManager.enrollmentStatus = enrollmentStatus

        // Restore economic data
        gameManager.economicDataManager.economicData = economicData

        // Restore military
        gameManager.militaryManager.activeResearch = activeResearch
        gameManager.warEngine.activeWars = activeWars
        gameManager.warEngine.warHistory = warHistory
        gameManager.territoryManager.territories = territories
        gameManager.territoryManager.activeRebellions = activeRebellions
        gameManager.territoryManager.rebellionHistory = rebellionHistory
    }
}

// MARK: - Save Slot Info

struct SaveSlotInfo: Codable, Identifiable {
    var id: Int { slotNumber }
    let slotNumber: Int
    let isEmpty: Bool
    let saveDate: Date?
    let gameName: String?
    let characterName: String?
    let currentPosition: String?
    let approvalRating: Double?
    let gameDate: Date?

    enum CodingKeys: String, CodingKey {
        case slotNumber
        case isEmpty
        case saveDate
        case gameName
        case characterName
        case currentPosition
        case approvalRating
        case gameDate
    }

    static func empty(slot: Int) -> SaveSlotInfo {
        SaveSlotInfo(
            slotNumber: slot,
            isEmpty: true,
            saveDate: nil,
            gameName: nil,
            characterName: nil,
            currentPosition: nil,
            approvalRating: nil,
            gameDate: nil
        )
    }

    init(slot: Int, saveGame: SaveGame) {
        self.slotNumber = slot
        self.isEmpty = false
        self.saveDate = saveGame.saveDate
        self.gameName = saveGame.gameName
        self.characterName = saveGame.characterName
        self.currentPosition = saveGame.currentPosition
        self.approvalRating = saveGame.approvalRating
        self.gameDate = saveGame.gameDate
    }

    private init(slotNumber: Int, isEmpty: Bool, saveDate: Date?, gameName: String?, characterName: String?, currentPosition: String?, approvalRating: Double?, gameDate: Date?) {
        self.slotNumber = slotNumber
        self.isEmpty = isEmpty
        self.saveDate = saveDate
        self.gameName = gameName
        self.characterName = characterName
        self.currentPosition = currentPosition
        self.approvalRating = approvalRating
        self.gameDate = gameDate
    }
}
