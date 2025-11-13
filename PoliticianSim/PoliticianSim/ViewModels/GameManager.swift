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
    @Published var lawsManager = LawsManager()
    @Published var diplomacyManager = DiplomacyManager()

    // Game state
    @Published var gameState: GameState

    // Convenience accessors
    var character: Character? {
        characterManager.character
    }

    private var cancellables = Set<AnyCancellable>()

    private init() {
        self.gameState = GameState()

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

    // MARK: - Time Operations

    func skipDay() {
        guard var character = character else { return }

        timeManager.skipDay(character: &character) { [weak self] char in
            guard let self = self else { return char }
            let updatedChar = self.timeManager.performDailyChecks(for: char)

            // Check for death
            if self.characterManager.isDead() {
                self.characterManager.handleDeath()
                return updatedChar
            }

            // Record approval changes
            self.statManager.recordApprovalIfChanged(character: updatedChar)

            // Check for random events
            if let event = self.eventEngine.checkForEvent(character: updatedChar) {
                self.gameState.activeEvent = event
            }

            return updatedChar
        }

        characterManager.updateCharacter(character)
    }

    func skipWeek() {
        guard var character = character else { return }

        timeManager.skipWeek(character: &character) { [weak self] char in
            guard let self = self else { return char }
            let updatedChar = self.timeManager.performDailyChecks(for: char)

            if self.characterManager.isDead() {
                self.characterManager.handleDeath()
                return updatedChar
            }

            self.statManager.recordApprovalIfChanged(character: updatedChar)

            // Check for random events
            if let event = self.eventEngine.checkForEvent(character: updatedChar) {
                self.gameState.activeEvent = event
            }

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

    // MARK: - Navigation

    func navigateTo(_ view: NavigationManager.NavigationView) {
        navigationManager.navigateTo(view)
    }

    // MARK: - Save/Load (Placeholder)

    func saveGame(to slot: Int) {
        print("Saving to slot \(slot)")
        // Will implement SaveManager in Phase 1.7
    }

    func loadGame(from slot: Int) {
        print("Loading from slot \(slot)")
        // Will implement SaveManager in Phase 1.7
    }
}
