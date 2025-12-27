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

    // Annual tracking for territory growth
    private var lastYearChecked: Int?
    private var previousYearGDP: [String: Double] = [:]  // For military strength evolution

    // Monthly tracking for war updates
    private var lastMonthChecked: Int?
    @Published var pendingWarUpdates: [WarUpdate] = []

    // War conclusion tracking
    @Published var pendingPeaceTerms: War? = nil  // War awaiting peace term selection
    @Published var pendingWarDefeatNotification: WarDefeatNotification? = nil  // Player defeat notification
    @Published var pendingDefensiveWarNotification: DefensiveWarNotification? = nil  // AI declares war on player
    @Published var pendingAIWarNotifications: [AIWarNotification] = []  // AI war conclusions
    @Published var pendingExhaustionWarning: WarExhaustionWarning? = nil  // War exhaustion warnings

    // Track which wars have already triggered exhaustion warnings
    private var exhaustionWarningsShown: Set<UUID> = []

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
            // Pass active wars to apply war economic effects
            self.economicDataManager.simulateEconomicChanges(character: updatedChar, activeWars: self.warEngine.activeWars)

            // Update player's GDP to include conquered territories
            self.economicDataManager.applyTerritoryGDPImpact(
                playerCountry: updatedChar.country,
                globalCountryState: self.globalCountryState,
                territoryManager: self.territoryManager
            )

            // Check for annual territory growth (year change)
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: updatedChar.currentDate)
            if self.lastYearChecked != currentYear {
                self.lastYearChecked = currentYear

                // Process annual territory aging
                let notifications = self.territoryManager.processAnnualTerritoryGrowth(currentDate: updatedChar.currentDate)

                // TODO: Display notifications to player for territories reaching 90% integration
                // For now, notifications are generated but not shown (will be added in UI phase)
                _ = notifications

                // PHASE 7: Evolve military strength for all countries based on GDP growth
                self.updateGlobalMilitaryStrength()

                // Apply automatic budget surplus/deficit for the year
                // This simulates ongoing government operations AND includes interest on debt
                // Note: applyAnnualBudgetDeficit() updates interest and reparations first,
                // then applies the deficit to treasury
                self.applyAnnualBudgetDeficit(character: &updatedChar)
            }

            // Check for monthly war updates (month change)
            let currentMonth = calendar.component(.month, from: updatedChar.currentDate)

            if self.lastMonthChecked != currentMonth {
                self.lastMonthChecked = currentMonth
                self.checkForMonthlyWarUpdates(character: updatedChar)

                // Process monthly reparation payments
                self.processMonthlyReparations(character: &updatedChar)
            }

            // Check for war conclusions
            self.checkForWarConclusions(character: updatedChar)

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

                    // Apply weekly war exhaustion penalties
                    self.applyWarExhaustionPenalties(character: &updatedChar)

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
            // Pass active wars to apply war economic effects
            self.economicDataManager.simulateEconomicChanges(character: updatedChar, activeWars: self.warEngine.activeWars)

            // Update player's GDP to include conquered territories
            self.economicDataManager.applyTerritoryGDPImpact(
                playerCountry: updatedChar.country,
                globalCountryState: self.globalCountryState,
                territoryManager: self.territoryManager
            )

            // Check for annual territory growth (year change)
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: updatedChar.currentDate)
            if self.lastYearChecked != currentYear {
                self.lastYearChecked = currentYear

                // Process annual territory aging
                let notifications = self.territoryManager.processAnnualTerritoryGrowth(currentDate: updatedChar.currentDate)

                // TODO: Display notifications to player for territories reaching 90% integration
                // For now, notifications are generated but not shown (will be added in UI phase)
                _ = notifications

                // PHASE 7: Evolve military strength for all countries based on GDP growth
                self.updateGlobalMilitaryStrength()

                // Apply automatic budget surplus/deficit for the year
                // This simulates ongoing government operations AND includes interest on debt
                // Note: applyAnnualBudgetDeficit() updates interest and reparations first,
                // then applies the deficit to treasury
                self.applyAnnualBudgetDeficit(character: &updatedChar)
            }

            // Check for monthly war updates (month change)
            let currentMonth = calendar.component(.month, from: updatedChar.currentDate)

            if self.lastMonthChecked != currentMonth {
                self.lastMonthChecked = currentMonth
                self.checkForMonthlyWarUpdates(character: updatedChar)

                // Process monthly reparation payments
                self.processMonthlyReparations(character: &updatedChar)
            }

            // Check for war conclusions
            self.checkForWarConclusions(character: updatedChar)

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

    // MARK: - Monthly War Updates

    private func checkForMonthlyWarUpdates(character: Character) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: character.currentDate)
        let year = calendar.component(.year, from: character.currentDate)

        print("\n📅 MONTHLY UPDATE - \(month)/\(year)")

        // PHASE 7: AI War Declarations (monthly trigger)
        // Evaluate if AI countries should declare war on each other (or on player)
        if let newWar = warEngine.evaluateAIWarDeclarations(
            globalCountryState: globalCountryState,
            playerCountry: character.country,
            currentDate: character.currentDate
        ) {
            // Check if player is the defender (under attack)
            if newWar.defender == character.country && character.currentPosition?.level == 5 {
                // Create defensive war notification
                if let aggressorCountry = globalCountryState.getCountry(code: newWar.attacker) {
                    let notification = DefensiveWarNotification(
                        war: newWar,
                        aggressorName: aggressorCountry.name,
                        aggressorStrength: newWar.attackerStrength,
                        playerStrength: newWar.defenderStrength,
                        justification: newWar.justification
                    )
                    pendingDefensiveWarNotification = notification

                    print("🚨 DEFENSIVE WAR NOTIFICATION: \(aggressorCountry.name) has attacked the player!")
                }
            }
        }

        // Only show war updates if character is president and has active wars
        guard character.currentPosition?.level == 5 else { return }
        guard !warEngine.activeWars.isEmpty else {
            print("No active wars involving player\n")
            return
        }

        // Generate war updates for all active wars
        var updates: [WarUpdate] = []
        let totalWars = warEngine.activeWars.count

        for (index, war) in warEngine.activeWars.enumerated() where war.isActive {
            // Calculate which month of the war this is
            let monthNumber = (war.daysSinceStart / 30) + 1

            let update = WarUpdate(
                war: war,
                monthNumber: monthNumber,
                totalWars: totalWars,
                warIndex: index
            )

            updates.append(update)
        }

        // Set pending war updates to be shown
        self.pendingWarUpdates = updates
    }

    // MARK: - Reparation Payment Processing

    private func processMonthlyReparations(character: inout Character) {
        guard let treasury = treasuryManager.currentTreasury else { return }

        let playerCountryCode = character.country
        var paymentsReceived: Decimal = 0
        var paymentsPaid: Decimal = 0

        // Calculate monthly payment (1/12 of annual)
        let monthlyMultiplier: Decimal = 1.0 / 12.0

        // Process all active reparations
        for i in 0..<territoryManager.activeReparations.count {
            var agreement = territoryManager.activeReparations[i]

            let monthlyPayment = agreement.yearlyPayment * monthlyMultiplier

            // Player is receiving reparations
            if agreement.recipientCountry == playerCountryCode {
                // Credit to player's treasury
                treasuryManager.recordReparationPayment(
                    amount: monthlyPayment,
                    description: "War reparations from \(getCountryName(agreement.payerCountry))",
                    date: character.currentDate
                )
                paymentsReceived += monthlyPayment
            }

            // Player is paying reparations
            if agreement.payerCountry == playerCountryCode {
                // Check if player can afford payment
                if treasury.cashOnHand >= monthlyPayment {
                    // Deduct from player's treasury
                    treasuryManager.recordReparationPayment(
                        amount: -monthlyPayment,
                        description: "War reparations to \(getCountryName(agreement.recipientCountry))",
                        date: character.currentDate
                    )
                    paymentsPaid += monthlyPayment
                } else {
                    // Payment default - apply penalties
                    handleReparationDefault(
                        agreement: agreement,
                        character: &character
                    )
                }
            }
        }

        // Log payments if any occurred
        if paymentsReceived > 0 || paymentsPaid > 0 {
            print("\n💰 REPARATION PAYMENTS")
            if paymentsReceived > 0 {
                print("Received: \(formatMoney(paymentsReceived))")
            }
            if paymentsPaid > 0 {
                print("Paid: \(formatMoney(paymentsPaid))")
            }
            print("")
        }
    }

    private func handleReparationDefault(agreement: ReparationAgreement, character: inout Character) {
        print("⚠️ REPARATION DEFAULT: \(character.country) cannot afford payment to \(agreement.recipientCountry)")

        // Penalties for defaulting
        // 1. Severe reputation hit
        modifyStat(.reputation, by: -15, reason: "Defaulted on war reparations")

        // 2. Diplomatic relations damage
        modifyApproval(by: -5.0, reason: "War reparations default")

        // 3. Increase stress
        character.stress = min(100, character.stress + 5)

        // Note: The agreement continues - missed payments accumulate as debt
        // In a future enhancement, could add debt enforcement mechanics
    }

    private func getCountryName(_ code: String) -> String {
        globalCountryState.getCountry(code: code)?.name ?? code
    }

    private func formatMoney(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSNumber)
        if value >= 1_000_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000_000))B"
        } else if value >= 1_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000))M"
        } else {
            return "$\(String(format: "%.0f", value))"
        }
    }

    // MARK: - Annual Budget Processing

    private func applyAnnualBudgetDeficit(character: inout Character) {
        // Initialize budget and treasury if they don't exist yet
        // This ensures automatic processing works even if player hasn't visited BudgetView
        if budgetManager.currentBudget == nil {
            // Get GDP for budget initialization
            let gdp: Double?
            if let position = character.currentPosition {
                switch position.level {
                case 1: gdp = economicDataManager.economicData.local.gdp.current
                case 2: gdp = economicDataManager.economicData.state.gdp.current
                case 3, 4, 5: gdp = economicDataManager.economicData.federal.gdp.current
                default: gdp = nil
                }
            } else {
                gdp = nil
            }

            // Initialize treasury if needed
            if treasuryManager.currentTreasury == nil {
                treasuryManager.initializeTreasury(for: character)
            }

            // Initialize budget
            budgetManager.initializeBudget(
                for: character,
                gdp: gdp,
                treasuryManager: treasuryManager,
                territoryManager: territoryManager
            )

            print("💰 Auto-initialized budget and treasury for automatic annual processing")
        }

        // CRITICAL: Update budget interest and reparations BEFORE calculating deficit
        // This ensures we're using current debt levels, not stale values
        budgetManager.updateInterestAndReparations(
            character: character,
            treasuryManager: treasuryManager,
            territoryManager: territoryManager
        )

        guard let budget = budgetManager.currentBudget else { return }

        // Calculate the annual surplus/deficit from current budget
        let surplus = budget.surplus

        // Apply to treasury (this simulates ongoing government operations)
        treasuryManager.applyBudgetResult(
            surplus: surplus,
            fiscalYear: budget.fiscalYear,
            character: character
        )

        // Log the automatic budget application
        print("\n💰 ANNUAL BUDGET AUTOMATICALLY APPLIED")
        print("Fiscal Year: \(budget.fiscalYear)")
        print("Revenue: \(formatMoney(budget.totalRevenue))")
        print("Expenses (Dept): \(formatMoney(budget.totalExpenses))")
        print("Interest on Debt: \(formatMoney(budget.interestPayment))")
        print("Reparation Payments: \(formatMoney(budget.reparationPayments))")
        print("Total Expenses: \(formatMoney(budget.totalExpensesWithInterest))")
        if surplus >= 0 {
            print("Surplus: \(formatMoney(surplus))")
        } else {
            print("Deficit: \(formatMoney(abs(surplus)))")
        }
        print("")
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

    // MARK: - War Conclusion Detection

    private func checkForWarConclusions(character: Character) {
        let playerCountryCode = character.country

        for war in warEngine.activeWars where !war.isActive {
            // War has concluded - check if player is involved
            let isPlayerAttacker = war.attacker == playerCountryCode
            let isPlayerDefender = war.defender == playerCountryCode
            let isPlayerInvolved = isPlayerAttacker || isPlayerDefender

            if !isPlayerInvolved {
                // AI vs AI war - auto-resolve using WarEngine's AI resolution logic
                if let notification = warEngine.resolveAIWar(
                    war: war,
                    globalCountryState: globalCountryState,
                    territoryManager: territoryManager,
                    currentDate: character.currentDate
                ) {
                    // Queue notification for display
                    pendingAIWarNotifications.append(notification)
                }
                continue
            }

            // Player is involved
            let isPlayerWinner = (war.outcome == .attackerVictory && isPlayerAttacker) ||
                               (war.outcome == .defenderVictory && isPlayerDefender)

            if isPlayerWinner {
                // Player victory - show peace terms selection
                if pendingPeaceTerms == nil {  // Only set if not already pending
                    pendingPeaceTerms = war
                }
            } else {
                // Player defeat - apply consequences but don't end game
                if pendingWarDefeatNotification == nil {  // Only process once
                    handleWarDefeat(war: war, character: character)
                }
            }
        }
    }

    private func handleWarDefeat(war: War, character: Character) {
        print("\n⚔️ PLAYER WAR DEFEAT")
        print("War: \(war.attacker) vs \(war.defender)")
        print("Outcome: \(war.outcome?.rawValue ?? "Unknown")")

        // Apply peace terms automatically (enemy chooses harsh terms)
        let isPlayerAttacker = war.attacker == character.country
        let enemyCode = isPlayerAttacker ? war.defender : war.attacker
        let territoryPercent = war.territoryConquered ?? 0.0

        // Select peace terms based on defeat severity
        let peaceTerm: War.PeaceTerm
        if territoryPercent >= 0.30 {
            peaceTerm = .fullConquest  // Catastrophic defeat
        } else if territoryPercent >= 0.20 {
            peaceTerm = .partialTerritory  // Major defeat
        } else {
            peaceTerm = .reparations  // Narrow defeat
        }

        print("Enemy imposing peace terms: \(peaceTerm.rawValue)")

        // Apply peace terms
        let result = warEngine.applyPeaceTerms(
            warId: war.id,
            peaceTerm: peaceTerm,
            globalCountryState: globalCountryState,
            territoryManager: territoryManager,
            currentDate: character.currentDate
        )

        // Create reparation agreement if applicable
        if result.reparationAmount > 0 {
            let reparation = ReparationAgreement(
                payerCountry: character.country,  // Player pays
                recipientCountry: enemyCode,
                totalAmount: result.reparationAmount,
                startDate: character.currentDate,
                warId: war.id
            )
            territoryManager.activeReparations.append(reparation)
            print("Reparation imposed: \(reparation.formattedTotalAmount) over \(reparation.totalYears) years")

            // Update budget with new reparation obligations
            budgetManager.updateReparationPayments(character: character, territoryManager: territoryManager)
        }

        // End the war
        warEngine.endWar(warId: war.id)

        // Apply severe political consequences
        // 1. Massive reputation hit
        modifyStat(.reputation, by: -30, reason: "Catastrophic war defeat")

        // 2. Major approval drop
        modifyApproval(by: -20.0, reason: "Lost war to \(globalCountryState.getCountry(code: enemyCode)?.name ?? enemyCode)")

        // 3. Significant stress increase
        var updatedChar = character
        updatedChar.stress = min(100, updatedChar.stress + 15)
        characterManager.updateCharacter(updatedChar)

        // 4. Log consequences
        print("Political consequences:")
        print("  - Reputation: -30")
        print("  - Approval: -20.0")
        print("  - Stress: +15")
        if result.territoryTransferred > 0 {
            print("  - Territory lost: \(String(format: "%.1fM sq mi", result.territoryTransferred / 1_000_000))")
        }
        print("═══════════════════════════════════════\n")

        // Create notification for player
        let notification = WarDefeatNotification(
            war: war,
            enemyName: globalCountryState.getCountry(code: enemyCode)?.name ?? enemyCode,
            peaceTerm: peaceTerm,
            territoryLost: result.territoryTransferred,
            reparationAmount: result.reparationAmount,
            reputationLoss: 30,
            approvalLoss: 20.0,
            stressGain: 15
        )
        pendingWarDefeatNotification = notification

        // Note: Player continues game despite defeat
        // They may face impeachment if approval/reputation drops too low
        // This creates interesting comeback narratives
    }

    private func triggerGameOver(reason: GameOverData.GameOverReason, war: War?, character: Character) {
        var territoryLost: String? = nil
        var casualties: Int? = nil

        if let war = war {
            if let territoryPercent = war.territoryConquered {
                // Get territory size from GlobalCountryState
                if let countryState = globalCountryState.getCountry(code: character.country) {
                    let sqMiles = countryState.totalTerritory * territoryPercent
                    if sqMiles >= 1_000_000 {
                        territoryLost = String(format: "%.1fM sq mi (%.0f%%)", sqMiles / 1_000_000, territoryPercent * 100)
                    } else {
                        territoryLost = String(format: "%.0fk sq mi (%.0f%%)", sqMiles / 1000, territoryPercent * 100)
                    }
                }
            }

            casualties = abs(war.casualtiesByCountry[character.country] ?? 0)
        }

        // Get current approval/reputation from character properties
        let currentApproval = character.approvalRating
        let currentReputation = Double(character.reputation)

        gameState.gameOverData = GameOverData(
            reason: reason,
            date: character.currentDate,
            finalAge: character.age,
            finalPosition: character.currentPosition?.title,
            finalApproval: Double(currentApproval),
            finalReputation: Double(currentReputation),
            territoryLost: territoryLost,
            warCasualties: casualties
        )
    }

    // MARK: - War Exhaustion Penalties

    private func applyWarExhaustionPenalties(character: inout Character) {
        guard !warEngine.activeWars.isEmpty else { return }

        var totalApprovalPenalty: Double = 0.0
        var totalStressIncrease: Int = 0

        // Apply penalties for each active war involving the player
        for war in warEngine.activeWars where war.isActive {
            let isPlayerInvolved = war.attacker == character.country || war.defender == character.country
            guard isPlayerInvolved else { continue }

            let exhaustionLevel = war.exhaustionLevel
            totalApprovalPenalty += exhaustionLevel.weeklyApprovalPenalty
            totalStressIncrease += exhaustionLevel.weeklyStressIncrease

            // Check if we should show exhaustion warning
            checkForExhaustionWarning(war: war, character: character)
        }

        // Apply cumulative penalties
        if totalApprovalPenalty != 0.0 {
            character.approvalRating = max(0, character.approvalRating + totalApprovalPenalty)
        }

        if totalStressIncrease > 0 {
            character.stress = min(100, character.stress + totalStressIncrease)
        }

        // Log if significant exhaustion
        if totalApprovalPenalty < -1.0 || totalStressIncrease > 2 {
            print("\n⚠️ WAR EXHAUSTION PENALTIES")
            print("Approval: \(totalApprovalPenalty)")
            print("Stress: +\(totalStressIncrease)")
            print("")
        }
    }

    private func checkForExhaustionWarning(war: War, character: Character) {
        // Only warn for moderate or higher exhaustion
        guard war.exhaustionLevel == .moderate ||
              war.exhaustionLevel == .high ||
              war.exhaustionLevel == .critical else {
            return
        }

        // Only show warning once per war
        guard !exhaustionWarningsShown.contains(war.id) else { return }

        // Only show if no other warning is pending
        guard pendingExhaustionWarning == nil else { return }

        // Create and show warning
        let warning = WarExhaustionWarning(
            war: war,
            exhaustionLevel: war.exhaustionLevel,
            playerCountry: character.country
        )

        pendingExhaustionWarning = warning
        exhaustionWarningsShown.insert(war.id)

        print("\n⚠️ WAR EXHAUSTION WARNING")
        print("War: \(war.attacker) vs \(war.defender)")
        print("Level: \(war.exhaustionLevel.rawValue)")
        print("Exhaustion: \(war.formattedExhaustion)")
        print("")
    }

    // MARK: - AI Military Strength Evolution

    private func updateGlobalMilitaryStrength() {
        // Update military strength for all countries based on GDP growth
        for country in globalCountryState.countries {
            let previousGDP = previousYearGDP[country.code] ?? country.currentGDP

            // Update strength using GlobalCountryState's built-in method
            globalCountryState.updateMilitaryStrength(
                countryCode: country.code,
                previousYearGDP: previousGDP
            )

            // Store current GDP for next year's calculation
            previousYearGDP[country.code] = country.currentGDP
        }

        print("📊 Annual military strength update complete")
    }
}

