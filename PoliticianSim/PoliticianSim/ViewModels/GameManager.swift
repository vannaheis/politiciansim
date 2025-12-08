//
//  GameManager.swift
//  PoliticianSim
//
//  Main coordinator for all game systems (Singleton)
//

import Foundation
import Combine

class GameManager: ObservableObject {
    static let shared = GameManager()

    // Core managers
    @Published var characterManager = CharacterManager()
    @Published var statManager = StatManager()
    @Published var timeManager = TimeManager()
    @Published var navigationManager = NavigationManager()
    @Published var eventEngine = EventEngine()
    @Published var electionManager = ElectionManager()
    @Published var policyManager = PolicyManager()
    @Published var budgetManager = BudgetManager()
    @Published var treasuryManager = TreasuryManager()
    @Published var lawsManager = LawsManager()
    @Published var diplomacyManager = DiplomacyManager()
    @Published var publicOpinionManager = PublicOpinionManager()
    @Published var educationManager = EducationManager()
    @Published var economicDataManager = EconomicDataManager()
    @Published var governmentStatsManager = GovernmentStatsManager()
    @Published var militaryManager = MilitaryManager()
    @Published var warEngine = WarEngine()
    @Published var territoryManager = TerritoryManager()
    @Published var globalCountryState = GlobalCountryState()
    let saveManager = SaveManager.shared

    // Game state
    @Published var gameState: GameState

    // Convenience accessors
    var character: Character? {
        characterManager.character
    }

    private var cancellables = Set<AnyCancellable>()

    private init() {
        self.gameState = GameState()

        // Setup objectWillChange forwarding
        setupObjectWillChangeForwarding()

        // Load autosave if available
        _ = saveManager.loadAutosave(to: self)

        // Start autosave
        saveManager.startAutosave(gameManager: self)
    }

    // MARK: - Character Operations

    func createCharacter(
        name: String,
        gender: Character.Gender,
        country: String,
        background: Character.Background
    ) {
        let character = characterManager.createCharacter(
            name: name,
            gender: gender,
            country: country,
            background: background
        )

        statManager.initializeHistory(for: character)
    }

    func createTestCharacter() {
        let character = characterManager.createTestCharacter()
        statManager.initializeHistory(for: character)
    }

    // MARK: - Helper Methods

    func getCharacterRole() -> Character.CharacterRole {
        guard let character = character else { return .unemployed }

        if educationManager.isEnrolled() {
            return .student
        }

        return character.role
    }

    // MARK: - Time Operations

    func skipDay() {
        guard var character = character else { return }

        timeManager.skipDay(character: &character) { [weak self] char in
            guard let self = self else { return char }
            var updatedChar = self.timeManager.performDailyChecks(for: char)

            // Check for health and stress warnings BEFORE checking death
            self.checkHealthWarning(character: updatedChar)
            self.checkStressWarning(character: updatedChar)

            // Check for death (but allow economic simulation to continue)
            let isDead = self.characterManager.isDead()
            if isDead {
                self.characterManager.handleDeath()
                // Trigger game over
                if let gameOverData = self.characterManager.createGameOverData() {
                    self.gameState.gameOverData = gameOverData
                }
            }

            // Skip character-specific actions if dead, but continue economic simulation
            if !isDead {
                // Check academic progress
                self.educationManager.checkAcademicProgress(character: &updatedChar)

                // Process monthly loan payment (check every day, payment happens once per month)
                self.educationManager.makeMonthlyLoanPayment(character: &updatedChar)

                // Record approval changes
                self.statManager.recordApprovalIfChanged(character: updatedChar)

                // Check for random events (role-based)
                let role = self.getCharacterRole()
                if let event = self.eventEngine.checkForEvent(character: updatedChar, role: role) {
                    self.gameState.activeEvent = event
                }

                // Check for election day
                self.checkForElectionDay(character: updatedChar)

                // Process active opinion actions
                self.publicOpinionManager.processActiveActions(character: &updatedChar, currentDate: updatedChar.currentDate)

                // Military operations (President only)
                if updatedChar.currentPosition?.level == 5 {
                    // Advance technology research
                    self.militaryManager.advanceResearch(days: 1)

                    // Simulate active wars
                    self.warEngine.simulateDay()

                    // Process military treasury
                    self.processMilitaryTreasury(character: &updatedChar, days: 1)

                    // Update territories and check for rebellions
                    self.territoryManager.processDaily(currentDate: updatedChar.currentDate)

                    // Recalculate military strength if militaryStats exists
                    if var militaryStats = updatedChar.militaryStats {
                        militaryStats.strength = self.militaryManager.calculateStrength(militaryStats: militaryStats)
                        updatedChar.militaryStats = militaryStats
                    }
                }
            }

            // ALWAYS simulate economic changes (even if character is dead)
            self.economicDataManager.simulateEconomicChanges(character: updatedChar)

            return updatedChar
        }

        characterManager.updateCharacter(character)
    }

    func skipWeek() {
        guard var character = character else { return }

        timeManager.skipWeek(character: &character) { [weak self] char in
            guard let self = self else { return char }
            var updatedChar = self.timeManager.performDailyChecks(for: char)

            // Check for health and stress warnings BEFORE checking death
            self.checkHealthWarning(character: updatedChar)
            self.checkStressWarning(character: updatedChar)

            // Check for death (but allow economic simulation to continue)
            let isDead = self.characterManager.isDead()
            if isDead {
                self.characterManager.handleDeath()
                // Trigger game over
                if let gameOverData = self.characterManager.createGameOverData() {
                    self.gameState.gameOverData = gameOverData
                }
            }

            // Skip character-specific actions if dead, but continue economic simulation
            if !isDead {
                // Check academic progress
                self.educationManager.checkAcademicProgress(character: &updatedChar)

                // Process monthly loan payment (check every day, payment happens once per month)
                self.educationManager.makeMonthlyLoanPayment(character: &updatedChar)

                self.statManager.recordApprovalIfChanged(character: updatedChar)

                // Check for random events (role-based)
                let role = self.getCharacterRole()
                if let event = self.eventEngine.checkForEvent(character: updatedChar, role: role) {
                    self.gameState.activeEvent = event
                }

                // Check for election day
                self.checkForElectionDay(character: updatedChar)

                // Process active opinion actions
                self.publicOpinionManager.processActiveActions(character: &updatedChar, currentDate: updatedChar.currentDate)

                // Military operations (President only)
                if updatedChar.currentPosition?.level == 5 {
                    // Advance technology research
                    self.militaryManager.advanceResearch(days: 7)

                    // Simulate active wars (7 days)
                    for _ in 0..<7 {
                        self.warEngine.simulateDay()
                    }

                    // Process military treasury for the week
                    self.processMilitaryTreasury(character: &updatedChar, days: 7)

                    // Update territories and check for rebellions
                    self.territoryManager.processWeekly(currentDate: updatedChar.currentDate)

                    // Recalculate military strength if militaryStats exists
                    if var militaryStats = updatedChar.militaryStats {
                        militaryStats.strength = self.militaryManager.calculateStrength(militaryStats: militaryStats)
                        updatedChar.militaryStats = militaryStats
                    }
                }
            }

            // ALWAYS simulate economic changes (even if character is dead)
            self.economicDataManager.simulateEconomicChanges(character: updatedChar)

            return updatedChar
        }

        characterManager.updateCharacter(character)
    }

    // MARK: - Stat Operations

    func modifyStat(_ stat: StatType, by amount: Int, reason: String) {
        guard var character = character else { return }
        statManager.modifyStat(character: &character, stat: stat, by: amount, reason: reason)
        characterManager.updateCharacter(character)
    }

    func modifyApproval(by amount: Double, reason: String) {
        guard var character = character else { return }
        statManager.modifyApproval(character: &character, by: amount, reason: reason)
        characterManager.updateCharacter(character)
    }

    func addFunds(_ amount: Decimal, source: String) {
        guard var character = character else { return }
        statManager.addFunds(character: &character, amount: amount, source: source)
        characterManager.updateCharacter(character)
    }

    func spendFunds(_ amount: Decimal, purpose: String) throws {
        guard var character = character else { return }
        try statManager.spendFunds(character: &character, amount: amount, purpose: purpose)
        characterManager.updateCharacter(character)
    }

    // MARK: - Event Operations

    func handleEventChoice(_ choice: Event.Choice) {
        guard var character = character else { return }
        eventEngine.handleChoice(choice: choice, character: &character)
        characterManager.updateCharacter(character)
        gameState.activeEvent = nil
    }

    func dismissEvent() {
        eventEngine.dismissEvent()
        gameState.activeEvent = nil
    }

    // MARK: - Election Operations

    private func checkForElectionDay(character: Character) {
        guard let election = electionManager.upcomingElection else { return }

        if election.isElectionDay(on: character.currentDate) {
            // Automatically simulate the election
            _ = electionManager.simulateElection(character: character)
        }
    }

    // MARK: - Military Operations

    func initializeMilitaryStats() {
        guard var character = character else { return }
        guard character.currentPosition?.level == 5 else { return } // President only
        guard character.militaryStats == nil else { return } // Don't reinitialize

        var militaryStats = MilitaryStats()

        // Sync with budget department if it exists
        if let budget = budgetManager.currentBudget,
           let militaryDept = budget.departments.first(where: { $0.category == .military }) {
            militaryStats.militaryBudget = militaryDept.allocatedFunds
        }

        character.militaryStats = militaryStats
        characterManager.updateCharacter(character)
    }

    private func processMilitaryTreasury(character: inout Character, days: Int) {
        guard var militaryStats = character.militaryStats else { return }

        // Calculate war costs
        var totalWarCost: Decimal = 0
        for war in warEngine.activeWars where war.isActive {
            if let cost = war.costByCountry[character.country] {
                let dailyCost = Decimal(war.attacker == character.country ? war.attackerStrength : war.defenderStrength) / 1000 * 1_000_000
                totalWarCost += dailyCost
            }
        }

        // Calculate research costs (sum of all active research costs per day)
        var totalResearchCost: Decimal = 0
        for research in militaryManager.activeResearch {
            totalResearchCost += research.cost / Decimal(research.daysRequired)
        }

        // Process each day
        for _ in 0..<days {
            militaryStats.treasury.processDay(
                budget: militaryStats.militaryBudget,
                manpower: militaryStats.manpower,
                activeWarCost: totalWarCost,
                activeResearchCost: totalResearchCost
            )
        }

        // Update character's military stats
        character.militaryStats = militaryStats

        // Add stress if military is running a significant deficit
        if militaryStats.treasury.isDeficit {
            let deficitAmount = militaryStats.treasury.dailyExpenses - militaryStats.treasury.dailyRevenue
            let deficitPercentage = Double(truncating: (deficitAmount / militaryStats.treasury.dailyRevenue * 100) as NSDecimalNumber)

            if deficitPercentage > 20 {
                character.stress = min(100, character.stress + 1)
            }
        }
    }

    // MARK: - Navigation

    func navigateTo(_ view: NavigationManager.NavigationView) {
        navigationManager.navigateTo(view)
    }

    // MARK: - Save/Load

    func saveGame(to slot: Int) -> Bool {
        return saveManager.saveToSlot(slot, gameManager: self)
    }

    func loadGame(from slot: Int) -> Bool {
        return saveManager.loadFromSlot(slot, to: self)
    }

    func deleteSlot(_ slot: Int) -> Bool {
        return saveManager.deleteSlot(slot)
    }

    func loadAutosave() -> Bool {
        return saveManager.loadAutosave(to: self)
    }

    func newGame() {
        // INDUSTRY STANDARD: Reinitialize ALL managers with fresh instances
        // This ensures complete reset with no hidden state retained

        // CRITICAL: Delete autosave first to prevent old data from being loaded back
        saveManager.deleteAutosave()

        // Reinitialize all managers (complete reset)
        characterManager = CharacterManager()
        statManager = StatManager()
        timeManager = TimeManager()
        navigationManager = NavigationManager()
        eventEngine = EventEngine()
        electionManager = ElectionManager()
        policyManager = PolicyManager()
        budgetManager = BudgetManager()
        treasuryManager = TreasuryManager()
        lawsManager = LawsManager()
        diplomacyManager = DiplomacyManager()
        publicOpinionManager = PublicOpinionManager()
        educationManager = EducationManager()
        economicDataManager = EconomicDataManager()
        governmentStatsManager = GovernmentStatsManager()
        militaryManager = MilitaryManager()
        warEngine = WarEngine()
        territoryManager = TerritoryManager()

        // Reset game state
        gameState = GameState()

        // Navigate to home
        navigationManager.navigateTo(.home)

        // Re-establish objectWillChange forwarding (required after manager reinitialization)
        setupObjectWillChangeForwarding()
    }

    private func setupObjectWillChangeForwarding() {
        // Clear old subscriptions
        cancellables.removeAll()

        // Sync character between managers
        characterManager.$character
            .sink { [weak self] character in
                self?.gameState.character = character
            }
            .store(in: &cancellables)

        // Forward changes from nested ObservableObjects to GameManager
        characterManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        statManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        timeManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        navigationManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        eventEngine.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        electionManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        policyManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        budgetManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        treasuryManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        lawsManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        diplomacyManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        publicOpinionManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        educationManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        economicDataManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        governmentStatsManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        militaryManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        warEngine.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        territoryManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Health and Stress Warnings

    private func checkHealthWarning(character: Character) {
        // Warn when health drops below 30 for the first time
        if character.health <= 30 && !gameState.healthWarningShown {
            gameState.healthWarningShown = true
            // Warning will be shown in UI
        }
    }

    private func checkStressWarning(character: Character) {
        // Warn when stress exceeds 80 for the first time
        if character.stress >= 80 && !gameState.stressWarningShown {
            gameState.stressWarningShown = true
            // Warning will be shown in UI
        }
    }
}

