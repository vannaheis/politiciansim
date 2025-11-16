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

            // Check for death
            if self.characterManager.isDead() {
                self.characterManager.handleDeath()
                return updatedChar
            }

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
            var charWithOpinion = updatedChar
            self.publicOpinionManager.processActiveActions(character: &charWithOpinion, currentDate: updatedChar.currentDate)

            // Simulate economic changes
            self.economicDataManager.simulateEconomicChanges(character: charWithOpinion)

            return charWithOpinion
        }

        characterManager.updateCharacter(character)
    }

    func skipWeek() {
        guard var character = character else { return }

        timeManager.skipWeek(character: &character) { [weak self] char in
            guard let self = self else { return char }
            var updatedChar = self.timeManager.performDailyChecks(for: char)

            if self.characterManager.isDead() {
                self.characterManager.handleDeath()
                return updatedChar
            }

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
            var charWithOpinion = updatedChar
            self.publicOpinionManager.processActiveActions(character: &charWithOpinion, currentDate: updatedChar.currentDate)

            // Simulate economic changes
            self.economicDataManager.simulateEconomicChanges(character: charWithOpinion)

            return charWithOpinion
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
    }
}

