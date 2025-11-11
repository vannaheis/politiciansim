# Politician Sim - Development Game Plan

## Overview
This document outlines the comprehensive implementation strategy for Politician Sim, a political life simulation game built with Swift/SwiftUI for iOS. Development is structured into 5 major phases spanning approximately 18-23 months.

---

## Development Philosophy

### Core Principles
1. **Incremental Delivery:** Each phase produces a playable build
2. **USA-First Approach:** Phase 1-2 focus exclusively on USA, then expand to 10 countries
3. **Data-Driven Design:** All game mechanics configurable via JSON/Codable structs
4. **Component Reusability:** Build UI components library in Phase 1, reuse throughout
5. **Testing at Every Stage:** Unit tests for game logic, UI tests for critical flows

### Technology Stack
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI (iOS 16+)
- **Architecture:** MVVM + Combine for reactivity
- **Data Persistence:** Codable JSON (FileManager-based)
- **State Management:** ObservableObject + @Published properties
- **Testing:** XCTest for unit tests, SwiftUI Preview for rapid iteration

---

## Phase 1: Foundation & Early Life (Months 1-4)

### Goal
Build core architecture and playable early life simulation (birth to age 18, USA only).

---

### 1.1 Project Setup & Architecture (Week 1-2)

#### Tasks
- [ ] Create Xcode project (iOS app, minimum deployment iOS 16.0)
- [ ] Set up folder structure:
  ```
  PoliticianSim/
  ├── App/
  │   ├── PoliticianSimApp.swift
  │   └── ContentView.swift
  ├── Models/
  │   ├── Character.swift
  │   ├── GameState.swift
  │   ├── Stats.swift
  │   ├── Event.swift
  │   └── Country.swift
  ├── ViewModels/
  │   ├── GameManager.swift
  │   ├── CharacterViewModel.swift
  │   └── EventViewModel.swift
  ├── Views/
  │   ├── Home/
  │   ├── Profile/
  │   ├── Career/
  │   ├── Shared/
  │   └── Components/
  ├── Services/
  │   ├── SaveManager.swift
  │   ├── EventEngine.swift
  │   └── TimeManager.swift
  ├── Resources/
  │   ├── Events/
  │   │   ├── EarlyLife.json
  │   │   └── ...
  │   └── Countries/
  │       └── USA.json
  └── Utilities/
      ├── Extensions/
      └── Constants.swift
  ```
- [ ] Set up Git repository with .gitignore
- [ ] Configure build settings and Info.plist
- [ ] Add SF Symbols usage (no external dependencies initially)

#### Deliverables
- Clean Xcode project with organized folder structure
- Basic `Character` and `GameState` models
- `GameManager` singleton with @Published properties

---

### 1.2 Core Data Models (Week 2-3)

#### Character Model
```swift
struct Character: Codable, Identifiable {
    let id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var country: Country
    var background: Background

    // Base Attributes (0-100)
    var charisma: Int
    var intelligence: Int
    var reputation: Int
    var luck: Int
    var diplomacy: Int

    // Secondary Stats
    var approvalRating: Double
    var campaignFunds: Decimal
    var health: Int
    var stress: Int

    // Career
    var currentPosition: Position?
    var careerHistory: [CareerEntry]

    // Dates
    var birthDate: Date
    var currentDate: Date

    enum Gender: String, Codable {
        case male, female, nonBinary
    }

    enum Background: String, Codable {
        case workingClass, middleClass, wealthy
    }
}
```

#### GameState Model
```swift
class GameState: ObservableObject {
    @Published var character: Character
    @Published var eventQueue: [Event]
    @Published var activeEvents: [Event]
    @Published var policies: [Policy]
    @Published var scandalRisks: [ScandalRisk]

    // Time management
    @Published var isPaused: Bool = false
    @Published var timeSpeed: TimeSpeed = .day

    enum TimeSpeed {
        case day, week
    }
}
```

#### Event Model
```swift
struct Event: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: EventCategory
    let choices: [Choice]
    let triggers: [Trigger]
    let ageRange: ClosedRange<Int>
    let requiredPosition: Position?

    struct Choice: Codable, Identifiable {
        let id: UUID
        let text: String
        let outcomePreview: String
        let effects: [Effect]
    }

    enum EventCategory: String, Codable {
        case earlyLife, education, political, economic,
             international, scandal, crisis, personal
    }
}
```

#### Tasks
- [ ] Implement all core models with Codable conformance
- [ ] Create model unit tests (test encoding/decoding)
- [ ] Build sample data for testing
- [ ] Implement computed properties for derived stats

#### Deliverables
- Complete model layer with documentation
- 100% test coverage on models
- Sample JSON files for events and country data

---

### 1.3 UI Component Library (Week 3-4)

Build reusable SwiftUI components following UI.md specifications.

#### Components to Build

**StandardBackgroundView**
```swift
struct StandardBackgroundView: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.3)
                .ignoresSafeArea()
        }
    }
}
```

**StatCard**
```swift
struct StatCard: View {
    let iconName: String
    let iconColor: Color
    let label: String
    let value: String
    let valueColor: Color

    var body: some View {
        // Circular icon + label + value layout
    }
}
```

**InfoCard**
```swift
struct InfoCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        // Gray background card with title and content
    }
}
```

**ProgressBar**
```swift
struct ProgressBar: View {
    let value: Double // 0.0 to 1.0
    let color: Color
    let height: CGFloat = 8

    var body: some View {
        // Filled/unfilled progress bar
    }
}
```

**Badge**
```swift
struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        // Colored pill badge
    }
}
```

#### Tasks
- [ ] Implement all 13 reusable components from UI.md
- [ ] Create SwiftUI Previews for each component
- [ ] Build component showcase view for testing
- [ ] Document component usage in code comments

#### Deliverables
- Complete component library in `Views/Components/`
- Preview canvas for all components
- Component documentation

---

### 1.4 Character Creation Flow (Week 4-5)

#### Screens to Build
1. **Country Selection Screen**
   - Alphabetical list of countries (USA only for Phase 1)
   - Display flag, territory, population, government type
   - Tap to select

2. **Character Details Screen**
   - Name input (TextField)
   - Gender selection (Picker)
   - Background selection (3 options)

3. **Attribute Generation Screen**
   - Show randomized base attributes (67/100 format)
   - Option to "Reroll" attributes
   - Continue button

#### Character Creation Flow
```swift
enum CharacterCreationStep {
    case country
    case details
    case attributes
    case summary
}

class CharacterCreationViewModel: ObservableObject {
    @Published var currentStep: CharacterCreationStep = .country
    @Published var selectedCountry: Country?
    @Published var name: String = ""
    @Published var gender: Character.Gender = .male
    @Published var background: Character.Background = .middleClass
    @Published var attributes: [String: Int] = [:]

    func generateAttributes() {
        // Randomize 0-100 for each attribute
    }

    func createCharacter() -> Character {
        // Combine all inputs into Character model
    }
}
```

#### Tasks
- [ ] Build country selection view with USA data
- [ ] Build character details form
- [ ] Build attribute generation screen with reroll
- [ ] Implement navigation between steps
- [ ] Create character creation ViewModel
- [ ] Add validation (name required, etc.)

#### Deliverables
- Complete character creation flow
- Functional ViewModel with state management
- Validation and error handling

---

### 1.5 Time System & Game Loop (Week 5-6)

#### Time Management System
```swift
class TimeManager: ObservableObject {
    @Published var currentDate: Date
    @Published var characterAge: Int

    func skipDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        updateAge()
        checkForEvents()
    }

    func skipWeek() {
        currentDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
        updateAge()
        checkForEvents()
    }

    private func updateAge() {
        // Calculate age from birthDate
    }

    private func checkForEvents() {
        // Trigger events if conditions met
    }
}
```

#### Home View with Time Controls
```swift
struct HomeView: View {
    @ObservedObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack {
                // Top bar with Day/Week buttons
                HStack {
                    Spacer()
                    Button("Day") {
                        gameManager.timeManager.skipDay()
                    }
                    Button("Week") {
                        gameManager.timeManager.skipWeek()
                    }
                }

                // Character overview card
                // Stats breakdown
                // Current events
                // Quick actions
            }
        }
    }
}
```

#### Tasks
- [ ] Implement TimeManager with date calculations
- [ ] Build Home View following UI.md specs
- [ ] Add Day/Week buttons with proper styling
- [ ] Implement age calculation and updates
- [ ] Add visual feedback for time passage
- [ ] Test time progression edge cases (year changes, birthdays)

#### Deliverables
- Functional time system with manual controls
- Home View with time buttons
- Age calculation working correctly

---

### 1.6 Event Engine (Week 6-8)

#### Event Engine Architecture
```swift
class EventEngine: ObservableObject {
    @Published var activeEvent: Event?

    private var eventPool: [Event] = []
    private let character: Character

    func loadEvents(from filename: String) {
        // Load events from JSON
    }

    func triggerEvent() {
        // Check triggers, select random event from pool
    }

    func evaluateChoice(_ choice: Event.Choice) {
        // Apply effects to character/gamestate
    }

    private func checkTriggers(for event: Event) -> Bool {
        // Evaluate age range, position, stats, etc.
    }
}
```

#### Event JSON Structure
```json
{
  "events": [
    {
      "id": "early_life_001",
      "title": "Invited to Spelling Bee",
      "description": "Your teacher thinks you'd be great in the school spelling bee competition.",
      "category": "earlyLife",
      "ageRange": [8, 12],
      "triggers": [
        {
          "type": "stat",
          "stat": "intelligence",
          "min": 40
        }
      ],
      "choices": [
        {
          "id": "choice_1",
          "text": "Accept and study hard",
          "outcomePreview": "Intelligence +5, Stress +3",
          "effects": [
            {
              "type": "statChange",
              "stat": "intelligence",
              "change": 5
            },
            {
              "type": "statChange",
              "stat": "stress",
              "change": 3
            }
          ]
        },
        {
          "id": "choice_2",
          "text": "Decline politely",
          "outcomePreview": "No change",
          "effects": []
        }
      ]
    }
  ]
}
```

#### Event Notification UI
```swift
struct EventNotificationView: View {
    let event: Event
    let onChoiceSelected: (Event.Choice) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: event.category.icon)
                    .font(.system(size: 40))

                Text(event.title)
                    .font(.system(size: 18, weight: .bold))

                Text(event.description)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)

                ForEach(event.choices) { choice in
                    ChoiceButton(choice: choice) {
                        onChoiceSelected(choice)
                    }
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.95))
            .cornerRadius(16)
            .padding(40)
        }
    }
}
```

#### Tasks
- [ ] Implement EventEngine with trigger evaluation
- [ ] Create 20-30 early life events (ages 0-17) in JSON
- [ ] Build event notification overlay UI
- [ ] Implement choice selection and effect application
- [ ] Add event history tracking
- [ ] Test event triggering and effects

#### Deliverables
- Functional event engine with JSON loading
- 20-30 early life events
- Event notification UI
- Effect application system

---

### 1.7 Save/Load System (Week 8-9)

#### Save Manager
```swift
class SaveManager {
    private let fileManager = FileManager.default
    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func save(gameState: GameState, to slot: Int) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(gameState)
        let filename = "save_slot_\(slot).json"
        let fileURL = documentsURL.appendingPathComponent(filename)

        try data.write(to: fileURL)
    }

    func load(from slot: Int) throws -> GameState {
        let filename = "save_slot_\(slot).json"
        let fileURL = documentsURL.appendingPathComponent(filename)

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(GameState.self, from: data)
    }

    func listSaves() -> [SaveSlot] {
        // Return list of available saves with metadata
    }

    func deleteSave(slot: Int) throws {
        let filename = "save_slot_\(slot).json"
        let fileURL = documentsURL.appendingPathComponent(filename)
        try fileManager.removeItem(at: fileURL)
    }
}
```

#### Autosave System
```swift
class AutosaveManager: ObservableObject {
    private var timer: Timer?
    private let saveManager = SaveManager()
    private let interval: TimeInterval = 2.0 // 2 seconds

    func startAutosave(for gameState: GameState) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            try? self.saveManager.save(gameState: gameState, to: 0) // Slot 0 = autosave
        }
    }

    func stopAutosave() {
        timer?.invalidate()
        timer = nil
    }
}
```

#### Save/Load UI
```swift
struct SaveLoadView: View {
    @State private var saveSlots: [SaveSlot] = []
    let saveManager = SaveManager()

    var body: some View {
        List {
            Section("Autosave") {
                // Autosave slot
            }

            Section("Manual Saves") {
                ForEach(saveSlots) { slot in
                    SaveSlotRow(slot: slot)
                }
            }
        }
        .onAppear {
            saveSlots = saveManager.listSaves()
        }
    }
}
```

#### Tasks
- [ ] Implement SaveManager with JSON encoding/decoding
- [ ] Create autosave system with 2-second interval
- [ ] Build save/load UI screens
- [ ] Add save slot metadata (date, character name, age)
- [ ] Implement delete save functionality
- [ ] Test save/load with complex game states
- [ ] Handle save errors gracefully

#### Deliverables
- Functional save/load system
- Autosave running every 2 seconds
- Save/load UI with slot management
- Error handling for corrupted saves

---

### 1.8 Phase 1 Integration & Polish (Week 9-10)

#### Integration Tasks
- [ ] Connect all systems (character creation → home view → time system → events)
- [ ] Test full early life playthrough (birth to age 18)
- [ ] Add sound effects for button clicks
- [ ] Implement stat change animations
- [ ] Add haptic feedback
- [ ] Polish UI transitions
- [ ] Fix any bugs found during playtesting

#### Testing
- [ ] Unit tests for all core systems
- [ ] Integration tests for save/load
- [ ] UI tests for character creation flow
- [ ] Performance testing (memory leaks, frame rate)
- [ ] Beta test with 3-5 users

#### Documentation
- [ ] Code documentation (DocC comments)
- [ ] README updates
- [ ] Known issues list

#### Deliverables
- **Playable Phase 1 Build:** Birth to age 18 simulation
- Complete test suite
- Performance benchmarks
- Bug-free core systems

---

## Phase 2: Local Politics & Career System (Months 5-8)

### Goal
Implement career progression from Community Organizer to Mayor, including elections, approval management, taxation, scandals, and policies.

---

### 2.1 Career System Foundation (Week 11-12)

#### Career Models
```swift
struct Position: Codable, Identifiable {
    let id: UUID
    let title: String
    let level: Int
    let termLength: Int // years
    let minAge: Int
    let requirements: Requirements
    let unlocks: [String]

    struct Requirements: Codable {
        let approvalRating: Double?
        let reputation: Int?
        let funds: Decimal?
        let age: Int?
    }
}

struct CareerEntry: Codable, Identifiable {
    let id: UUID
    let position: Position
    let startDate: Date
    let endDate: Date?
    let finalApproval: Double?
    let achievements: [String]
}
```

#### Career Progression Manager
```swift
class CareerManager: ObservableObject {
    @Published var availablePositions: [Position] = []
    @Published var currentPosition: Position?

    func loadCareerPath(for country: Country) {
        // Load positions from country JSON
    }

    func checkEligibility(for position: Position, character: Character) -> Bool {
        // Evaluate requirements
    }

    func runForOffice(position: Position) {
        // Start election campaign
    }
}
```

#### Tasks
- [ ] Implement Position and CareerEntry models
- [ ] Create USA career path JSON (8 positions: Community Organizer → President)
- [ ] Build CareerManager with eligibility checking
- [ ] Create career progression UI (unlock tree)
- [ ] Implement position requirements validation
- [ ] Add career history tracking

#### Deliverables
- Complete career system models
- USA career path data
- Career view with position cards
- Eligibility checking logic

---

### 2.2 Election System (Week 13-15)

#### Election Models
```swift
struct Election: Codable, Identifiable {
    let id: UUID
    let position: Position
    let date: Date
    let candidates: [Candidate]
    var results: ElectionResults?

    struct Candidate: Codable, Identifiable {
        let id: UUID
        let name: String
        let party: String
        var polling: Double
        var funds: Decimal
        let stats: CandidateStats
    }

    struct ElectionResults: Codable {
        let winner: UUID
        let votes: [UUID: Int]
    }
}
```

#### Campaign Phase
```swift
class CampaignManager: ObservableObject {
    @Published var currentCampaign: Campaign?
    @Published var daysUntilElection: Int

    func startCampaign(for position: Position) {
        // Initialize campaign with opponents
    }

    func runAdCampaign(cost: Decimal) {
        // Increase polling, decrease funds
    }

    func holdRally(cost: Decimal) {
        // Increase approval, increase stress
    }

    func fundraisingEvent(cost: Decimal) {
        // Raise funds, spend time
    }

    func calculateElectionResults() -> ElectionResults {
        // Weighted calculation based on polling, funds, charisma, luck
    }
}
```

#### Election UI
```swift
struct ElectionView: View {
    @ObservedObject var campaignManager: CampaignManager

    var body: some View {
        ScrollView {
            // Election overview card
            ElectionOverviewCard()

            // Opponents list
            OpponentsSection()

            // Campaign actions
            CampaignActionsGrid()

            // Polling tracker
            PollingChart()
        }
    }
}
```

#### Tasks
- [ ] Implement election and campaign models
- [ ] Create AI opponent generation system
- [ ] Build campaign phase UI
- [ ] Implement campaign actions (ads, rallies, fundraising)
- [ ] Create election results calculation
- [ ] Build polling tracker with line chart
- [ ] Add election victory/defeat screens
- [ ] Create 5-10 election events (debates, endorsements, scandals)

#### Deliverables
- Functional election system
- AI opponents with varying stats
- Campaign UI with actions
- Election results with victory screen

---

### 2.3 Approval Rating & Fund Management (Week 15-16)

#### Approval System
```swift
class ApprovalManager: ObservableObject {
    @Published var currentApproval: Double
    @Published var approvalHistory: [Date: Double] = [:]
    @Published var voterBlocs: [VoterBloc] = []

    struct VoterBloc: Identifiable {
        let id: UUID
        let name: String
        var approval: Double
        let weight: Double // influence on overall approval
    }

    func modifyApproval(by amount: Double, reason: String) {
        currentApproval = min(100, max(0, currentApproval + amount))
        recordChange(reason: reason)
    }

    func calculateOverallApproval() -> Double {
        // Weight voter blocs and return overall approval
    }
}
```

#### Fund Management
```swift
class FundManager: ObservableObject {
    @Published var campaignFunds: Decimal
    @Published var fundHistory: [FundTransaction] = []

    struct FundTransaction: Identifiable {
        let id: UUID
        let date: Date
        let amount: Decimal
        let type: TransactionType
        let description: String

        enum TransactionType {
            case donation, fundraising, expense, scandal
        }
    }

    func addFunds(amount: Decimal, source: String) {
        campaignFunds += amount
        recordTransaction(amount: amount, type: .donation, description: source)
    }

    func spendFunds(amount: Decimal, purpose: String) throws {
        guard campaignFunds >= amount else {
            throw FundError.insufficientFunds
        }
        campaignFunds -= amount
        recordTransaction(amount: -amount, type: .expense, description: purpose)
    }
}
```

#### Tasks
- [ ] Implement ApprovalManager with voter blocs
- [ ] Create approval history tracking with chart
- [ ] Build FundManager with transaction history
- [ ] Add donation events (triggered by approval)
- [ ] Create fund expense system
- [ ] Build approval/fund visualization charts
- [ ] Implement approval decay over time

#### Deliverables
- Approval system with voter blocs
- Fund management with transactions
- Approval rating chart on home view
- Fund income/expense tracker

---

### 2.4 Taxation & Government Budget (Week 16-17)

#### Government Budget Models
```swift
struct GovernmentBudget: Codable {
    var treasury: Decimal
    var monthlyRevenue: Decimal
    var monthlyExpenses: Decimal

    var allocation: BudgetAllocation

    struct BudgetAllocation: Codable {
        var military: Double = 0.35
        var socialPrograms: Double = 0.28
        var infrastructure: Double = 0.20
        var administration: Double = 0.12
        var debtPayments: Double = 0.05

        var total: Double {
            military + socialPrograms + infrastructure + administration + debtPayments
        }
    }
}
```

#### Taxation System
```swift
class TaxationManager: ObservableObject {
    @Published var currentTaxRate: Double = 0.32
    @Published var budget: GovernmentBudget

    func setTaxRate(_ rate: Double) {
        currentTaxRate = min(1.0, max(0.0, rate))
        calculateRevenue()
        applyApprovalImpact()
    }

    func calculateRevenue() {
        // Revenue = Tax Rate × Territory Size × Population
    }

    func applyApprovalImpact() {
        // Apply approval changes based on tax rate ranges
    }

    func allocateBudget(category: String, percentage: Double) {
        // Adjust budget allocation
    }
}
```

#### Budget UI
```swift
struct BudgetView: View {
    @ObservedObject var taxationManager: TaxationManager

    var body: some View {
        ScrollView {
            // Treasury overview
            TreasuryCard()

            // Tax rate slider
            TaxRateSlider(
                value: $taxationManager.currentTaxRate,
                approvalImpact: taxationManager.calculateApprovalImpact()
            )

            // Budget allocation
            BudgetAllocationSection()
        }
    }
}
```

#### Tasks
- [ ] Implement GovernmentBudget and TaxationManager
- [ ] Create tax rate slider with live approval preview
- [ ] Build budget allocation UI with progress bars
- [ ] Implement revenue calculation formulas
- [ ] Add budget category effects (military → strength, etc.)
- [ ] Create tax change events and consequences
- [ ] Test approval impact formulas

#### Deliverables
- Functional taxation system (Mayor+)
- Government budget UI
- Tax slider with approval preview
- Budget allocation with effects

---

### 2.5 Scandal System (Week 17-18)

#### Scandal Models
```swift
struct ScandalRisk: Codable, Identifiable {
    let id: UUID
    let action: String
    let date: Date
    let riskPercentage: Double
    var hasExposed: Bool = false
    let severity: ScandalSeverity

    enum ScandalSeverity: String, Codable {
        case minor, major, careerEnding
    }
}

struct Scandal: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let severity: ScandalRisk.ScandalSeverity
    let approvalPenalty: Double
    let reputationPenalty: Int
    var response: ScandalResponse?

    enum ScandalResponse: String, Codable {
        case deny, apologize, spin, resign
    }
}
```

#### Scandal Manager
```swift
class ScandalManager: ObservableObject {
    @Published var activeScandals: [Scandal] = []
    @Published var scandalRisks: [ScandalRisk] = []

    func addScandalRisk(action: String, risk: Double, severity: ScandalRisk.ScandalSeverity) {
        let scandalRisk = ScandalRisk(
            id: UUID(),
            action: action,
            date: Date(),
            riskPercentage: risk,
            severity: severity
        )
        scandalRisks.append(scandalRisk)
    }

    func checkForScandalExposure(character: Character) {
        for var risk in scandalRisks where !risk.hasExposed {
            let adjustedRisk = calculateAdjustedRisk(risk: risk, reputation: character.reputation)

            if Double.random(in: 0...100) < adjustedRisk {
                exposeScandal(risk: risk)
                risk.hasExposed = true
            }
        }
    }

    func respondToScandal(scandal: Scandal, response: Scandal.ScandalResponse, character: Character) {
        // Apply consequences based on response type
    }

    private func calculateAdjustedRisk(risk: ScandalRisk, reputation: Int) -> Double {
        var adjusted = risk.riskPercentage

        if reputation >= 70 {
            adjusted *= 0.7 // -30% exposure chance
        } else if reputation < 40 {
            adjusted *= 1.5 // +50% exposure chance
        }

        return adjusted
    }
}
```

#### Scandal Response UI
```swift
struct ScandalResponseView: View {
    let scandal: Scandal
    let character: Character
    let onResponse: (Scandal.ScandalResponse) -> Void

    var body: some View {
        ZStack {
            // Scandal notification overlay
            VStack {
                Text("SCANDAL EXPOSED")
                    .foregroundColor(.red)

                Text(scandal.title)
                Text(scandal.description)

                // Response options
                ResponseButton(type: .deny)
                ResponseButton(type: .apologize)
                ResponseButton(type: .spin)
                ResponseButton(type: .resign)
            }
        }
    }
}
```

#### Tasks
- [ ] Implement ScandalRisk and Scandal models
- [ ] Create ScandalManager with exposure checking
- [ ] Add scandal risk to unethical event choices
- [ ] Build scandal exposure logic (time-delayed)
- [ ] Create scandal response UI
- [ ] Implement response consequences (deny gamble, apologize recovery, etc.)
- [ ] Add scandal events to event pool
- [ ] Test reputation impact on scandal exposure

#### Deliverables
- Functional scandal system
- Hidden scandal risk tracking
- Scandal exposure and response UI
- Reputation-based risk adjustment

---

### 2.6 Policy System (Week 18-19)

#### Policy Models
```swift
struct Policy: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: PolicyCategory
    let immediateEffects: [Effect]
    let delayedEffects: [DelayedEffect]
    let requirements: Requirements
    var enactedDate: Date?
    var isActive: Bool = false

    enum PolicyCategory: String, Codable {
        case economic, social, environmental, criminalJustice, foreign
    }

    struct DelayedEffect: Codable {
        let effect: Effect
        let delayMonths: Int
        var triggerDate: Date?
    }
}
```

#### Policy Manager
```swift
class PolicyManager: ObservableObject {
    @Published var activePolicies: [Policy] = []
    @Published var availablePolicies: [Policy] = []
    @Published var delayedEffectsQueue: [Policy.DelayedEffect] = []

    func loadPolicies(for position: Position) {
        // Load position-appropriate policies from JSON
    }

    func enactPolicy(_ policy: Policy, gameState: GameState) {
        // Apply immediate effects
        applyEffects(policy.immediateEffects, to: gameState)

        // Queue delayed effects
        for var delayedEffect in policy.delayedEffects {
            delayedEffect.triggerDate = Calendar.current.date(
                byAdding: .month,
                value: delayedEffect.delayMonths,
                to: Date()
            )
            delayedEffectsQueue.append(delayedEffect)
        }

        activePolicies.append(policy)
    }

    func checkDelayedEffects(currentDate: Date, gameState: GameState) {
        for effect in delayedEffectsQueue {
            if let triggerDate = effect.triggerDate, currentDate >= triggerDate {
                applyEffects([effect.effect], to: gameState)
                // Remove from queue
            }
        }
    }
}
```

#### Policy UI
```swift
struct PoliciesView: View {
    @ObservedObject var policyManager: PolicyManager

    var body: some View {
        ScrollView {
            Section("Active Policies") {
                ForEach(policyManager.activePolicies) { policy in
                    PolicyCard(policy: policy, isActive: true)
                }
            }

            Section("Available Policies") {
                ForEach(policyManager.availablePolicies) { policy in
                    PolicyCard(policy: policy, isActive: false)
                        .onTapGesture {
                            // Show policy detail sheet
                        }
                }
            }
        }
    }
}
```

#### Tasks
- [ ] Implement Policy model with delayed effects
- [ ] Create PolicyManager with effect queue
- [ ] Build policy JSON library (10-15 policies per category)
- [ ] Implement delayed effect triggering system
- [ ] Create policies view UI
- [ ] Build policy proposal sheet with requirements check
- [ ] Add policy impact events (citizens react to policies)
- [ ] Test delayed effects triggering correctly

#### Deliverables
- Policy system with immediate and delayed effects
- 50-75 policies across 5 categories
- Policies view UI
- Delayed effects queue working correctly

---

### 2.7 Local Politics Events & Polish (Week 19-20)

#### Event Creation
- [ ] Create 40-60 events for Community Organizer (ages 18-20)
- [ ] Create 40-60 events for City Council Member (ages 21-23)
- [ ] Create 60-80 events for Mayor (ages 25-29)
- [ ] Add crisis events (natural disasters, protests, pandemics)
- [ ] Add scandal events tied to scandal system
- [ ] Add policy events (citizens react to policies)

#### UI Polish
- [ ] Refine all local politics UI screens
- [ ] Add animations for stat changes
- [ ] Implement approval rating line chart
- [ ] Add sound effects for elections, scandals
- [ ] Polish event notification overlay
- [ ] Add haptic feedback for important events

#### Testing & Bug Fixes
- [ ] Integration testing for career progression
- [ ] Test election system with various outcomes
- [ ] Verify scandal exposure timing
- [ ] Test policy delayed effects
- [ ] Balance testing (difficulty, stat impacts)
- [ ] Bug fixes from playtesting

#### Deliverables
- 140-200 total events for local politics
- Polished UI with animations
- Balanced gameplay for local politics career path
- Bug-free Phase 2 build

---

## Phase 3: National Politics & Multi-Country (Months 9-14)

### Goal
Implement national-level positions (Governor, Senator, VP, President), expand to all 10 countries with unique government systems and events.

---

### 3.1 National Politics Positions (Week 21-23)

#### State/Regional System
```swift
struct Region: Codable, Identifiable {
    let id: UUID
    let name: String
    let territorySize: Double // square miles
    let population: Int
    var morale: Double
    let country: Country
    let type: RegionType

    enum RegionType: String, Codable {
        case state, province, autonomousRegion, specialAdministrativeRegion
    }
}
```

#### Governor Position Mechanics
```swift
class GovernorManager: ObservableObject {
    @Published var controlledRegion: Region
    @Published var regionalBudget: GovernmentBudget

    func manageRegionalTaxes() {
        // State-level taxation
    }

    func proposeStateLegislation() {
        // Regional policies
    }
}
```

#### National Legislature System
```swift
struct Legislature: Codable {
    var members: [Legislator]
    var pendingBills: [Bill]
    var passedLaws: [Law]

    struct Legislator: Codable, Identifiable {
        let id: UUID
        let name: String
        let party: String
        var voteAlignment: Double // how likely to vote with player
    }

    struct Bill: Codable, Identifiable {
        let id: UUID
        let title: String
        let description: String
        let sponsor: UUID
        let effects: [Effect]
        var votes: [UUID: Vote]

        enum Vote: String, Codable {
            case yes, no, abstain
        }
    }
}
```

#### Tasks
- [ ] Implement Region model for USA states
- [ ] Create Governor position mechanics (regional governance)
- [ ] Build Senator position mechanics (national legislature)
- [ ] Implement VP position (influence, preparation for presidency)
- [ ] Create President position (full executive control)
- [ ] Add USA state data (50 states with populations, sizes)
- [ ] Build national legislature simulation
- [ ] Create bill voting system

#### Deliverables
- National position mechanics for USA
- 50 USA states with data
- Legislature simulation
- Governor → President progression path

---

### 3.2 Foreign Relations & Diplomacy (Week 23-24)

#### Diplomacy System
```swift
struct DiplomaticRelation: Codable, Identifiable {
    let id: UUID
    let country1: Country
    let country2: Country
    var relationshipScore: Double // -100 to +100
    var type: RelationType

    enum RelationType: String, Codable {
        case ally, neutral, rival, enemy, war
    }
}

class DiplomacyManager: ObservableObject {
    @Published var relations: [DiplomaticRelation] = []
    @Published var activeAlliances: [Alliance] = []
    @Published var tradeDeal: [TradeDeal] = []

    func proposeAlliance(with country: Country, playerDiplomacy: Int) -> Bool {
        // Diplomacy check to form alliance
    }

    func negotiateTradeDeal(with country: Country) {
        // Trade agreement mechanics
    }

    func declareWar(on country: Country) {
        // War declaration (implemented in Phase 4)
    }
}
```

#### International Events
```json
{
  "id": "intl_001",
  "title": "Border Dispute with Canada",
  "description": "Canada is claiming territorial waters in the Arctic. How do you respond?",
  "category": "international",
  "requiredPosition": "president",
  "choices": [
    {
      "text": "Negotiate diplomatically",
      "effects": [
        {"type": "diplomacyCheck", "difficulty": 60},
        {"type": "relationshipChange", "country": "Canada", "change": 10}
      ]
    },
    {
      "text": "Threaten military action",
      "effects": [
        {"type": "relationshipChange", "country": "Canada", "change": -30},
        {"type": "approvalChange", "change": 5}
      ]
    }
  ]
}
```

#### Tasks
- [ ] Implement DiplomaticRelation model
- [ ] Create DiplomacyManager with relationship tracking
- [ ] Build diplomacy view UI (world relations)
- [ ] Create 20-30 international events
- [ ] Implement trade deal system
- [ ] Add alliance formation mechanics
- [ ] Create diplomacy skill checks

#### Deliverables
- Diplomacy system with relationship tracking
- International events for national positions
- Diplomacy UI view
- Alliance and trade mechanics

---

### 3.3 Multi-Country Implementation: Templates (Week 25-27)

#### Country Configuration System
```swift
struct Country: Codable, Identifiable {
    let id: UUID
    let name: String
    let code: String // USA, GBR, CHN, etc.
    let flag: String // Asset name
    let territorySize: Double
    let population: Int
    let governmentType: GovernmentType
    let positions: [Position]
    let regions: [Region]
    let startingStats: CountryStats

    enum GovernmentType: String, Codable {
        case presidential, parliamentary, singleParty, absoluteMonarchy
    }

    struct CountryStats: Codable {
        var militaryStrength: Int
        var technologyLevel: Int
        var gdp: Decimal
    }
}
```

#### Government Template System
```swift
protocol GovernmentTemplate {
    var positions: [Position] { get }
    var electionMechanics: ElectionSystem { get }
    var specialRules: [String] { get }
}

struct PresidentialTemplate: GovernmentTemplate {
    var positions: [Position] = [
        // Community Organizer → President (8 levels)
    ]

    var electionMechanics: ElectionSystem = .directElection
    var specialRules: [String] = ["Vice President succession rights"]
}

struct ParliamentaryTemplate: GovernmentTemplate {
    var positions: [Position] = [
        // Community Organizer → Prime Minister (8 levels)
    ]

    var electionMechanics: ElectionSystem = .parliamentaryVote
    var specialRules: [String] = ["No confidence votes possible"]
}
```

#### Tasks
- [ ] Design Country configuration JSON structure
- [ ] Implement 4 government templates (A, B, C, D)
- [ ] Create country loading system
- [ ] Build template → position mapping
- [ ] Add localized position titles per country
- [ ] Test template flexibility

#### Deliverables
- Country configuration system
- 4 government templates
- Template-based position generation
- Localized titles

---

### 3.4 Multi-Country Implementation: UK (Week 27-28)

#### UK-Specific Features
```swift
struct UKGovernment {
    var regions: [Region] = [
        Region(name: "England", territorySize: 130_000, population: 56_000_000, type: .core),
        Region(name: "Scotland", territorySize: 30_000, population: 5_500_000, type: .devolved),
        Region(name: "Wales", territorySize: 8_000, population: 3_000_000, type: .devolved),
        Region(name: "Northern Ireland", territorySize: 5_000, population: 1_900_000, type: .devolved)
    ]

    var devolvedParliaments: [DevolvedParliament] = [
        DevolvedParliament(region: "Scotland", independenceRisk: 0.3),
        DevolvedParliament(region: "Wales", independenceRisk: 0.1),
        DevolvedParliament(region: "Northern Ireland", independenceRisk: 0.2)
    ]
}

struct DevolvedParliament {
    let region: String
    var independenceRisk: Double // 0.0 to 1.0

    func triggerReferendum() {
        // Independence referendum event
    }
}
```

#### UK Events
- Brexit-style referendum events
- Scottish independence votes
- NHS funding crises
- Royal family scandals
- Northern Ireland peace process events

#### Tasks
- [ ] Create UK country JSON with Parliamentary template
- [ ] Implement 4 devolved regions
- [ ] Add Scottish/Welsh/NI separatist mechanics
- [ ] Create 15-20 UK-specific events
- [ ] Build referendum system
- [ ] Add First Minister positions for devolved regions
- [ ] Test UK career progression (Councillor → Prime Minister)

#### Deliverables
- Complete UK implementation
- Devolution and separatist mechanics
- 15-20 UK-specific events
- Referendum system

---

### 3.5 Multi-Country Implementation: Remaining 8 Countries (Week 29-35)

#### Implementation Order
1. **Germany** (Parliamentary, Week 29-30)
   - 16 federal states (Länder)
   - Chancellor → Bundestag system
   - EU leadership events
   - Refugee crisis events

2. **France** (Presidential, Week 30-31)
   - 13 metropolitan regions + overseas territories
   - President → Prime Minister dual executive
   - Labor strike events
   - Colonial legacy events

3. **China** (Single-Party, Week 31-32)
   - 23 provinces + 5 autonomous regions + 2 SARs
   - Party election mechanics (internal voting)
   - Hong Kong/Tibet/Xinjiang separatist risks
   - Economic planning events
   - Tiananmen-style events

4. **Russia** (Presidential, Week 32-33)
   - 46 oblasts + 22 republics
   - Strong executive system
   - Oligarch relations
   - Crimea-style annexation events
   - Opposition protest events

5. **Japan** (Parliamentary, Week 33-34)
   - 47 prefectures
   - Prime Minister → Diet system
   - Earthquake/tsunami disasters
   - Aging population events
   - US alliance events

6. **India** (Parliamentary, Week 34)
   - 28 states + 8 union territories
   - Prime Minister → Chief Minister system
   - Caste politics events
   - Kashmir conflict events
   - Climate disaster events

7. **Brazil** (Presidential, Week 34-35)
   - 26 states + federal district
   - Amazon deforestation events
   - Favela violence events
   - Corruption scandal events
   - Carnival culture events

8. **Saudi Arabia** (Absolute Monarchy, Week 35)
   - 13 provinces
   - Inheritance/succession mechanics
   - Oil price shock events
   - Hajj management events
   - Women's rights reform events
   - Yemen conflict events

#### Per-Country Tasks
- [ ] Create country JSON with government template
- [ ] Define internal regions with separatist risks
- [ ] Create 10-15 country-specific events
- [ ] Add localized position titles
- [ ] Implement unique mechanics (monarchy succession, party elections, etc.)
- [ ] Test career progression for each country

#### Deliverables (Week 35 End)
- All 10 countries fully implemented
- 100-150 country-specific events total
- Unique mechanics per government type
- Playable career paths in all countries

---

### 3.6 World Simulation Foundation (Week 36-37)

#### World State System
```swift
struct WorldState: Codable {
    var countries: [Country] = [] // All ~195 countries
    var diplomaticRelations: [DiplomaticRelation] = []
    var activeWars: [War] = []
    var alliances: [Alliance] = []

    func simulateAIActions() {
        // AI countries declare wars, form alliances, etc.
    }
}

class WorldSimulator: ObservableObject {
    @Published var worldState: WorldState

    func loadWorldCountries() {
        // Load all 195 countries (10 playable + 185 AI)
    }

    func simulateMonth() {
        // AI countries take actions (wars, alliances, growth)
    }

    func generateAIWar() -> War? {
        // Random AI countries declare war on each other
    }
}
```

#### AI Country System
```swift
struct AICountry: Codable {
    let name: String
    let code: String
    var territorySize: Double
    var population: Int
    var militaryStrength: Int
    var technologyLevel: Int
    var relationships: [String: Double] // country code → relationship score
}
```

#### Tasks
- [ ] Create simplified data for 185 non-playable countries
- [ ] Implement WorldState with all countries
- [ ] Build AI decision-making (simple probability-based)
- [ ] Add AI war generation
- [ ] Implement AI alliance formation
- [ ] Create world events (AI wars, coups, etc.)
- [ ] Build world news feed (player sees AI country actions)

#### Deliverables
- World simulation with 195 countries
- AI decision-making system
- Dynamic world events
- World news feed

---

### 3.7 Phase 3 Integration & Balance (Week 38-39)

#### Integration
- [ ] Test all 10 countries end-to-end
- [ ] Verify government templates working correctly
- [ ] Test world simulation with AI actions
- [ ] Ensure diplomacy works across all countries
- [ ] Test separatist mechanics (UK, China, etc.)

#### Balance
- [ ] Balance stat requirements across countries
- [ ] Adjust event frequency for national positions
- [ ] Balance approval impacts
- [ ] Tune AI country behavior

#### Polish
- [ ] Add country flags and assets
- [ ] Polish character creation country selection
- [ ] Refine diplomacy UI
- [ ] Add sound effects for international events

#### Deliverables
- Fully functional 10-country system
- Balanced national politics gameplay
- World simulation running smoothly
- Phase 3 complete build

---

## Phase 4: Warfare & Empire Building (Months 15-19)

### Goal
Implement complete warfare system with territory expansion, military tech, rebellions, and empire-building mechanics.

---

### 4.1 Military & Territory Foundation (Week 40-42)

#### Territory System
```swift
struct Territory: Codable, Identifiable {
    let id: UUID
    let name: String
    var size: Double // square miles
    var population: Int
    var morale: Double // 0.0 to 1.0
    var type: TerritoryType
    var rebellionRisk: Double
    var taxRevenue: Decimal

    enum TerritoryType: String, Codable {
        case core, conquered, purchased, vassal, colony, rebel
    }
}

class TerritoryManager: ObservableObject {
    @Published var controlledTerritories: [Territory] = []

    var totalSize: Double {
        controlledTerritories.reduce(0) { $0 + $1.size }
    }

    var totalPopulation: Int {
        controlledTerritories.reduce(0) { $0 + $1.population }
    }

    func calculateTaxRevenue(taxRate: Double) -> Decimal {
        // Sum revenue from all territories
    }

    func checkRebellions() -> [Territory] {
        // Return territories at risk of rebellion
    }
}
```

#### Military System
```swift
struct MilitaryStats: Codable {
    var strength: Int // Single abstract number
    var manpower: Int // Available recruits
    var recruitmentType: RecruitmentType

    enum RecruitmentType: String, Codable {
        case volunteer, conscription
    }
}

class MilitaryManager: ObservableObject {
    @Published var militaryStats: MilitaryStats
    @Published var technologyLevels: [TechCategory: Int] = [:] // 1-10

    func calculateMilitaryStrength(
        manpower: Int,
        techLevels: [TechCategory: Int],
        budget: Decimal
    ) -> Int {
        // Formula: (Manpower × Training) + (Equipment × Tech) + Budget
    }

    func calculateManpower(population: Int, morale: Double) -> Int {
        return Int(Double(population) * morale * 0.20)
    }
}
```

#### Technology Research
```swift
enum TechCategory: String, Codable, CaseIterable {
    case infantryWeapons, armoredVehicles, navalPower, airSuperiority,
         missileSystems, cyberWarfare, logistics, medicalTech,
         intelligence, nuclearWeapons
}

struct TechResearch: Codable, Identifiable {
    let id: UUID
    let category: TechCategory
    var currentLevel: Int // 1-10
    var isResearching: Bool = false
    var completionDate: Date?
    var cost: Decimal
    var durationMonths: Int

    static func cost(for level: Int) -> Decimal {
        // Level 1 = $500M, Level 10 = $50B (exponential scaling)
        return Decimal(500_000_000) * pow(Decimal(2), level - 1)
    }

    static func duration(for level: Int) -> Int {
        // 3-12 months
        return min(12, 3 + level)
    }
}

class TechnologyManager: ObservableObject {
    @Published var technologies: [TechCategory: TechResearch] = [:]

    func startResearch(category: TechCategory, currentDate: Date) {
        guard var tech = technologies[category] else { return }

        tech.isResearching = true
        tech.completionDate = Calendar.current.date(
            byAdding: .month,
            value: tech.durationMonths,
            to: currentDate
        )

        technologies[category] = tech
    }

    func checkCompletions(currentDate: Date) {
        for (category, var tech) in technologies {
            if tech.isResearching,
               let completionDate = tech.completionDate,
               currentDate >= completionDate {
                tech.currentLevel += 1
                tech.isResearching = false
                tech.completionDate = nil
                technologies[category] = tech
            }
        }
    }
}
```

#### Tasks
- [ ] Implement Territory model and TerritoryManager
- [ ] Create MilitaryStats and MilitaryManager
- [ ] Build TechnologyManager with 10 categories
- [ ] Implement territory map view UI (list-based)
- [ ] Create military & tech view UI
- [ ] Add tech research UI with progress bars
- [ ] Implement manpower calculation
- [ ] Build military strength formula

#### Deliverables
- Territory system with types
- Military stats system
- Technology research with 10 categories
- Territory map UI
- Military & Tech view UI

---

### 4.2 Warfare Engine (Week 42-45)

#### War Models
```swift
struct War: Codable, Identifiable {
    let id: UUID
    let attacker: Country
    let defender: Country
    let startDate: Date
    var endDate: Date?
    var type: WarType
    var justification: WarJustification
    var duration: Int // days
    var attackerStrength: Int
    var defenderStrength: Int
    var casualtiesByCountry: [String: Int] = [:] // country code → casualties
    var costByCountry: [String: Decimal] = [:]
    var isActive: Bool = true
    var winner: Country?

    enum WarType: String, Codable {
        case defensive, offensive, proxy, civil
    }

    enum WarJustification: String, Codable {
        case borderDispute, territorialClaim, defensivePact, noJustification
    }
}
```

#### War Engine
```swift
class WarEngine: ObservableObject {
    @Published var activeWars: [War] = []

    func declareWar(
        attacker: Country,
        defender: Country,
        justification: War.WarJustification,
        playerCharacter: Character
    ) -> War {
        // Create war, apply approval penalties
        let war = War(
            id: UUID(),
            attacker: attacker,
            defender: defender,
            startDate: Date(),
            type: .offensive,
            justification: justification,
            duration: 0,
            attackerStrength: attacker.militaryStrength,
            defenderStrength: defender.militaryStrength
        )

        applyWarDeclarationEffects(war: war, character: playerCharacter)
        activeWars.append(war)
        return war
    }

    func simulateWarDay(war: inout War) {
        war.duration += 1

        // Calculate daily attrition
        let attackerLosses = calculateLosses(strength: war.attackerStrength, opponentStrength: war.defenderStrength)
        let defenderLosses = calculateLosses(strength: war.defenderStrength, opponentStrength: war.attackerStrength)

        war.attackerStrength -= attackerLosses
        war.defenderStrength -= defenderLosses

        war.casualtiesByCountry[war.attacker.code, default: 0] += attackerLosses
        war.casualtiesByCountry[war.defender.code, default: 0] += defenderLosses

        // Check victory conditions
        if war.defenderStrength < war.attackerStrength * 0.2 {
            endWar(war: &war, winner: war.attacker)
        } else if war.attackerStrength < war.defenderStrength * 0.2 {
            endWar(war: &war, winner: war.defender)
        }

        // Average 240 days (8 months), add random chance to end
        if war.duration > 240 && Double.random(in: 0...1) > 0.95 {
            endWar(war: &war, winner: war.attackerStrength > war.defenderStrength ? war.attacker : war.defender)
        }
    }

    func endWar(war: inout War, winner: Country) {
        war.isActive = false
        war.endDate = Date()
        war.winner = winner

        // Calculate spoils
        distributeSpoils(war: war)
    }

    private func calculateLosses(strength: Int, opponentStrength: Int) -> Int {
        // Simplified attrition model
        let ratio = Double(opponentStrength) / Double(strength)
        let baseLoss = Int(Double(strength) * 0.001) // 0.1% per day base
        return max(1, Int(Double(baseLoss) * ratio))
    }

    private func distributeSpoils(war: War) {
        guard let winner = war.winner else { return }

        let loser = winner.code == war.attacker.code ? war.defender : war.attacker

        // Territory gain: 10-40% of loser's territory
        let strengthRatio = Double(winner.militaryStrength) / Double(loser.militaryStrength)
        let territoryGainPercentage = min(0.4, 0.1 + (strengthRatio - 1.0) * 0.15)
        let territorySizeGained = loser.territorySize * territoryGainPercentage

        // Reparations: 10-30% of loser's treasury
        let reparations = loser.governmentBudget.treasury * Decimal(0.1 + strengthRatio * 0.1)

        // Apply gains
        // (Implementation depends on game state structure)
    }
}
```

#### War Events System
```swift
struct WarEvent: Codable, Identifiable {
    let id: UUID
    let war: War
    let title: String
    let description: String
    let choices: [WarChoice]
    let dayOfWar: Int

    struct WarChoice: Codable, Identifiable {
        let id: UUID
        let text: String
        let strategyType: StrategyType
        let effects: [Effect]

        enum StrategyType: String, Codable {
            case aggressive, defensive, attrition, negotiate
        }
    }
}

class WarEventGenerator {
    func generateWarEvent(for war: War) -> WarEvent? {
        // Every 14-28 days (2-4 weeks), generate tactical decision
        guard war.duration % 21 == 0 else { return nil }

        let events = [
            "Enemy counterattack in northern territories",
            "Your forces captured strategic city",
            "Allies request additional funding",
            "Civilian casualties reported - international pressure mounting",
            "Enemy morale breaking - surrender possible"
        ]

        let title = events.randomElement()!
        // Generate appropriate choices based on war state

        return WarEvent(
            id: UUID(),
            war: war,
            title: title,
            description: "Tactical decision required",
            choices: generateChoices(),
            dayOfWar: war.duration
        )
    }

    private func generateChoices() -> [WarEvent.WarChoice] {
        return [
            WarEvent.WarChoice(
                id: UUID(),
                text: "Press the attack",
                strategyType: .aggressive,
                effects: [/* faster victory, higher casualties */]
            ),
            WarEvent.WarChoice(
                id: UUID(),
                text: "Consolidate gains",
                strategyType: .defensive,
                effects: [/* standard pace */]
            ),
            WarEvent.WarChoice(
                id: UUID(),
                text: "Offer peace terms",
                strategyType: .negotiate,
                effects: [/* diplomacy check */]
            )
        ]
    }
}
```

#### Tasks
- [ ] Implement War model
- [ ] Create WarEngine with declaration and simulation
- [ ] Build background war simulation (runs with time progression)
- [ ] Implement attrition and casualty calculations
- [ ] Create victory/defeat condition checking
- [ ] Build WarEventGenerator for periodic decisions
- [ ] Implement war spoils distribution (territory, reparations)
- [ ] Add war weariness (morale decay during war)
- [ ] Test 8-month average duration

#### Deliverables
- Functional war engine with background simulation
- War duration averaging 8 months
- Victory/defeat mechanics
- War events every 2-4 weeks
- Spoils distribution system

---

### 4.3 Peace Negotiation & Diplomacy (Week 45-46)

#### Peace Negotiation System
```swift
class PeaceNegotiator: ObservableObject {
    func initiatePeaceNegotiation(
        war: War,
        initiator: Country,
        playerDiplomacy: Int
    ) -> PeaceTerms {
        // Calculate initial offer based on military strength ratio
        let strengthRatio = Double(war.attackerStrength) / Double(war.defenderStrength)

        var terms = PeaceTerms(war: war)

        // Adjust based on diplomacy stat
        if playerDiplomacy >= 70 {
            terms.demandModifier = 0.7 // -30% to opponent demands
        } else if playerDiplomacy < 40 {
            terms.demandModifier = 1.2 // +20% to opponent demands
        }

        // Calculate terms based on strength ratio
        terms.territoryDemand = calculateTerritoryDemand(ratio: strengthRatio)
        terms.reparations = calculateReparations(ratio: strengthRatio)

        return terms
    }

    private func calculateTerritoryDemand(ratio: Double) -> Double {
        switch ratio {
        case 2.0...: return 0.30 // Dominating: 30-40% territory
        case 1.5..<2.0: return 0.15 // Winning: 15-25%
        case 0.67..<1.5: return 0.0 // Even: white peace
        case 0.5..<0.67: return -0.10 // Losing: give 5-10%
        default: return -0.30 // Defeated: give 20-40%
        }
    }

    private func calculateReparations(ratio: Double) -> Decimal {
        // Similar scaling for financial reparations
        return Decimal(0) // Simplified for example
    }
}

struct PeaceTerms: Codable {
    let war: War
    var territoryDemand: Double // Percentage
    var reparations: Decimal
    var demandModifier: Double = 1.0 // Diplomacy adjustment
    var accepted: Bool = false
}
```

#### Peace Negotiation UI
```swift
struct PeaceNegotiationView: View {
    let war: War
    let terms: PeaceTerms
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack {
            Text("Peace Negotiation")
                .font(.title)

            Text("War with \(war.defender.name)")
            Text("Duration: \(war.duration) days")

            // Terms display
            VStack(alignment: .leading) {
                Text("PEACE TERMS")
                    .font(.headline)

                if terms.territoryDemand > 0 {
                    Text("• Territory Gain: \(Int(terms.territoryDemand * 100))% of enemy land")
                        .foregroundColor(.green)
                } else if terms.territoryDemand < 0 {
                    Text("• Territory Loss: \(Int(abs(terms.territoryDemand) * 100))% of your land")
                        .foregroundColor(.red)
                }

                if terms.reparations > 0 {
                    Text("• Reparations: +$\(terms.reparations)")
                        .foregroundColor(.green)
                } else if terms.reparations < 0 {
                    Text("• Reparations: -$\(abs(terms.reparations))")
                        .foregroundColor(.red)
                }
            }

            HStack {
                Button("Accept Terms") {
                    onAccept()
                }
                .buttonStyle(PrimaryButtonStyle(color: .green))

                Button("Continue War") {
                    onReject()
                }
                .buttonStyle(PrimaryButtonStyle(color: .red))
            }
        }
    }
}
```

#### Tasks
- [ ] Implement PeaceNegotiator with diplomacy checks
- [ ] Create PeaceTerms model
- [ ] Build peace negotiation UI
- [ ] Implement acceptance/rejection logic
- [ ] Add diplomacy stat impact on terms
- [ ] Test various strength ratio scenarios
- [ ] Add AI acceptance probability

#### Deliverables
- Peace negotiation system
- Diplomacy-based term adjustment
- Peace negotiation UI
- AI acceptance logic

---

### 4.4 Rebellion System (Week 46-47)

#### Rebellion Mechanics
```swift
class RebellionManager: ObservableObject {
    @Published var activeRebellions: [Rebellion] = []

    func checkRebellionRisks(territories: [Territory], taxRate: Double, approval: Double) {
        for territory in territories {
            var risk = 0.0

            // Tax rate impact
            if taxRate > 0.60 {
                risk += 0.10 // +10% per year
            }

            // Morale impact
            if territory.morale < 0.30 {
                risk += 0.15 // +15%
            }

            // Approval impact
            if approval < 40 {
                risk += (40 - approval) * 0.005 // +5-20%
            }

            // Conquered territories have higher base risk
            if territory.type == .conquered {
                risk += 0.30 // +30% base
            }

            // Roll for rebellion
            if Double.random(in: 0...1) < risk {
                triggerRebellion(in: territory)
            }
        }
    }

    func triggerRebellion(in territory: Territory) {
        var rebelliousTerritory = territory
        rebelliousTerritory.type = .rebel

        // Create rebel faction
        let rebellion = Rebellion(
            id: UUID(),
            territory: rebelliousTerritory,
            startDate: Date(),
            rebelStrength: calculateRebelStrength(territory: territory)
        )

        activeRebellions.append(rebellion)

        // Trigger civil war
        startCivilWar(rebellion: rebellion)
    }

    private func calculateRebelStrength(territory: Territory) -> Int {
        // 30-60% of government military strength
        let populationFactor = territory.population / 1_000_000
        let moraleFactor = 1.0 - territory.morale
        return Int(Double(populationFactor) * moraleFactor * 50000)
    }

    func suppressRebellion(rebellion: Rebellion, militaryStrength: Int) -> War {
        // Create civil war
        return War(
            id: UUID(),
            attacker: /* government */,
            defender: /* rebel faction */,
            startDate: Date(),
            type: .civil,
            justification: .noJustification,
            duration: 0,
            attackerStrength: militaryStrength,
            defenderStrength: rebellion.rebelStrength
        )
    }
}

struct Rebellion: Codable, Identifiable {
    let id: UUID
    var territory: Territory
    let startDate: Date
    var rebelStrength: Int
    var isActive: Bool = true
}
```

#### Rebellion UI
```swift
struct RebellionAlert: View {
    let rebellion: Rebellion
    let onSuppress: () -> Void
    let onNegotiate: () -> Void

    var body: some View {
        ZStack {
            Color.red.opacity(0.3)
                .ignoresSafeArea()

            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 50))

                Text("REBELLION")
                    .font(.title)
                    .foregroundColor(.red)

                Text("\(rebellion.territory.name) has declared independence!")

                Text("Rebel Strength: \(rebellion.rebelStrength)")

                HStack {
                    Button("Suppress by Force") {
                        onSuppress()
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .red))

                    Button("Negotiate Autonomy") {
                        onNegotiate()
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .blue))
                }
            }
            .padding(30)
            .background(Color.black.opacity(0.9))
            .cornerRadius(16)
        }
    }
}
```

#### Tasks
- [ ] Implement RebellionManager
- [ ] Create rebellion risk calculation
- [ ] Build rebellion trigger system
- [ ] Implement civil war creation from rebellions
- [ ] Create rebellion alert UI
- [ ] Add autonomy negotiation option (high diplomacy)
- [ ] Implement rebellion suppression approval penalty (-10%)
- [ ] Test rebellion triggers with various conditions

#### Deliverables
- Rebellion system with risk calculation
- Civil war from rebellions
- Rebellion alert UI
- Autonomy negotiation option

---

### 4.5 War Room UI (Week 47-48)

#### War Room View
```swift
struct WarRoomView: View {
    @ObservedObject var warEngine: WarEngine
    @ObservedObject var peaceNegotiator: PeaceNegotiator

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Active wars section
                if warEngine.activeWars.isEmpty {
                    Text("No active conflicts")
                        .foregroundColor(.gray)
                } else {
                    ForEach(warEngine.activeWars) { war in
                        WarCard(war: war)
                            .onTapGesture {
                                // Show war detail
                            }
                    }
                }

                // Declare war button (Governor+ only)
                if canDeclareWar {
                    Button("Declare War") {
                        // Show target selection
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .crimson))
                }
            }
        }
        .navigationTitle("War Room")
    }
}

struct WarCard: View {
    let war: War

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sword.crossed")
                    .foregroundColor(.red)

                Text("War with \(war.defender.name)")
                    .font(.headline)

                Spacer()

                StatusBadge(status: warStatus)
            }

            Text("Duration: \(war.duration) days")
                .font(.caption)
                .foregroundColor(.gray)

            // Strength comparison
            VStack(alignment: .leading) {
                HStack {
                    Text("Your Forces: \(war.attackerStrength)")
                    Spacer()
                }
                ProgressBar(
                    value: Double(war.attackerStrength) / Double(war.attackerStrength + war.defenderStrength),
                    color: .green
                )

                HStack {
                    Text("Enemy Forces: \(war.defenderStrength)")
                    Spacer()
                }
                ProgressBar(
                    value: Double(war.defenderStrength) / Double(war.attackerStrength + war.defenderStrength),
                    color: .red
                )
            }

            // Casualties and cost
            HStack {
                Text("Casualties: \(war.casualtiesByCountry[war.attacker.code] ?? 0)")
                    .foregroundColor(.red)
                Spacer()
                Text("Cost: $\(war.costByCountry[war.attacker.code] ?? 0)")
                    .foregroundColor(.orange)
            }
            .font(.caption)

            // Actions
            HStack {
                Button("Negotiate Peace") {
                    // Open peace negotiation
                }
                .buttonStyle(SecondaryButtonStyle())

                Button("War Details") {
                    // Open detail sheet
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(15)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.5), lineWidth: war.isActive ? 2 : 0)
        )
    }

    private var warStatus: String {
        let ratio = Double(war.attackerStrength) / Double(war.defenderStrength)
        if ratio > 1.5 { return "Winning" }
        else if ratio < 0.67 { return "Losing" }
        else { return "Stalemate" }
    }
}
```

#### War Detail Sheet
```swift
struct WarDetailSheet: View {
    let war: War
    @ObservedObject var warEngine: WarEngine

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // War status card
                InfoCard(title: "WAR STATUS") {
                    HStack {
                        Text("Started:")
                        Spacer()
                        Text(war.startDate.formatted())
                    }

                    HStack {
                        Text("Type:")
                        Spacer()
                        Text(war.type.rawValue.capitalized)
                    }

                    HStack {
                        Text("Approval Impact:")
                        Spacer()
                        Text("-30%")
                            .foregroundColor(.red)
                    }
                }

                // Military comparison
                InfoCard(title: "MILITARY COMPARISON") {
                    // Strength bars, tech advantage, terrain
                }

                // War costs
                InfoCard(title: "WAR COSTS") {
                    HStack {
                        Text("Funds Spent:")
                        Spacer()
                        Text("$\(war.costByCountry[war.attacker.code] ?? 0)")
                            .foregroundColor(.orange)
                    }

                    HStack {
                        Text("Monthly Cost:")
                        Spacer()
                        Text("-$2B/month")
                            .foregroundColor(.red)
                    }

                    HStack {
                        Text("Population Lost:")
                        Spacer()
                        Text("\(war.casualtiesByCountry[war.attacker.code] ?? 0) (4%)")
                            .foregroundColor(.red)
                    }
                }

                // Recent events
                InfoCard(title: "RECENT EVENTS") {
                    // War event history
                }

                // Action buttons
                Button("Negotiate Peace") {
                    // Peace negotiation
                }

                Button("Press Attack") {
                    // Change strategy to aggressive
                }

                Button("Defensive Stance") {
                    // Change strategy to defensive
                }
            }
        }
    }
}
```

#### Tasks
- [ ] Build War Room main view
- [ ] Create WarCard component with strength bars
- [ ] Build WarDetailSheet with all war info
- [ ] Add war status indicators (winning/losing/stalemate)
- [ ] Implement declare war target selection UI
- [ ] Add pulsing animation for active wars
- [ ] Create war victory/defeat result screens
- [ ] Polish all war-related UI

#### Deliverables
- Complete War Room view
- War card components
- War detail sheets
- Victory/defeat screens
- Declare war interface

---

### 4.6 Territory Acquisition & Management (Week 48-49)

#### Territory Acquisition
```swift
class TerritoryAcquisitionManager: ObservableObject {
    // Military conquest (automatic from war victories)
    func conqueredTerritory(from war: War, percentage: Double) -> Territory {
        let loser = war.winner!.code == war.attacker.code ? war.defender : war.attacker
        let sizeGained = loser.territorySize * percentage
        let populationGained = Int(Double(loser.population) * percentage)

        return Territory(
            id: UUID(),
            name: "\(loser.name) Territory",
            size: sizeGained,
            population: populationGained,
            morale: 0.45, // Low morale for conquered
            type: .conquered,
            rebellionRisk: 0.30, // 30% base risk
            taxRevenue: 0
        )
    }

    // Diplomatic purchase
    func attemptPurchase(
        territory: Territory,
        offer: Decimal,
        playerDiplomacy: Int
    ) -> Bool {
        let baseSuccessRate = 0.20 // 20% base chance
        let diplomacyBonus = Double(playerDiplomacy) / 100 * 0.4 // Up to +40%
        let successRate = baseSuccessRate + diplomacyBonus

        return Double.random(in: 0...1) < successRate
    }

    // Vassal integration
    func integrateVassal(vassal: Territory, cost: Decimal) -> Territory {
        var integrated = vassal
        integrated.type = .core
        integrated.morale = 0.60
        integrated.rebellionRisk = 0.10
        return integrated
    }
}
```

#### Territory Management UI
```swift
struct TerritoryMapView: View {
    @ObservedObject var territoryManager: TerritoryManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Total overview
                InfoCard(title: "TOTAL CONTROLLED TERRITORY") {
                    Text("\(territoryManager.totalSize / 1_000_000, specifier: "%.2f") Million sq mi")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))

                    HStack {
                        Text("Population:")
                        Spacer()
                        Text("\(territoryManager.totalPopulation / 1_000_000)M")
                    }

                    HStack {
                        Text("Average Morale:")
                        Spacer()
                        Text("\(Int(territoryManager.averageMorale * 100))%")
                            .foregroundColor(moralColor(territoryManager.averageMorale))
                    }
                }

                // Core territory
                SectionHeader(title: "CORE TERRITORY")
                ForEach(territoryManager.coreT erritories) { territory in
                    TerritoryCard(territory: territory)
                }

                // Conquered territories
                if !territoryManager.conqueredTerritories.isEmpty {
                    SectionHeader(title: "CONQUERED TERRITORIES")
                    ForEach(territoryManager.conqueredTerritories) { territory in
                        TerritoryCard(territory: territory)
                    }
                }

                // Vassal states
                if !territoryManager.vassalStates.isEmpty {
                    SectionHeader(title: "VASSAL STATES")
                    ForEach(territoryManager.vassalStates) { territory in
                        TerritoryCard(territory: territory)
                    }
                }
            }
        }
        .navigationTitle("Territory")
    }
}

struct TerritoryCard: View {
    let territory: Territory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))

                VStack(alignment: .leading) {
                    Text(territory.name)
                        .font(.system(size: 15, weight: .bold))

                    Text("\(Int(territory.size / 1000))k sq mi | \(territory.population / 1_000_000)M pop")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                Badge(text: territory.type.rawValue.capitalized, color: typeColor(territory.type))
            }

            // Morale bar
            HStack {
                Text("Morale:")
                    .font(.caption)
                Spacer()
                Text("\(Int(territory.morale * 100))%")
                    .font(.caption)
                    .foregroundColor(moralColor(territory.morale))
            }
            ProgressBar(value: territory.morale, color: moralColor(territory.morale))

            // Tax revenue
            HStack {
                Text("Tax Revenue:")
                    .font(.caption)
                Spacer()
                Text("$\(territory.taxRevenue / 1_000_000_000, specifier: "%.1f")B/yr")
                    .font(.caption)
                    .foregroundColor(.green)
            }

            // Warning if low morale
            if territory.morale < 0.50 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Rebellion Risk: \(Int(territory.rebellionRisk * 100))%")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
        }
        .padding(15)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    private func typeColor(_ type: Territory.TerritoryType) -> Color {
        switch type {
        case .core: return .blue
        case .conquered: return .red
        case .purchased: return .green
        case .vassal: return .purple
        case .colony: return .orange
        case .rebel: return .red
        }
    }

    private func moralColor(_ morale: Double) -> Color {
        if morale >= 0.70 { return .green }
        else if morale >= 0.40 { return .orange }
        else { return .red }
    }
}
```

#### Tasks
- [ ] Implement TerritoryAcquisitionManager
- [ ] Create territory purchase system
- [ ] Build vassal integration mechanics
- [ ] Create TerritoryMapView UI
- [ ] Build TerritoryCard component with morale bars
- [ ] Add territory detail sheets
- [ ] Implement garrison management
- [ ] Add territory purchase UI

#### Deliverables
- Territory acquisition system (conquest, purchase, integration)
- Territory map view UI
- Territory cards with morale visualization
- Territory management features

---

### 4.7 Governor Warfare (Week 49-50)

#### State vs. Federal War
```swift
class StateWarManager: ObservableObject {
    func declareIndependence(
        governor: Character,
        state: Region,
        federalGovernment: Country
    ) -> War {
        // Governor declares independence, triggers civil war
        let civilWar = War(
            id: UUID(),
            attacker: /* state faction */,
            defender: federalGovernment,
            startDate: Date(),
            type: .civil,
            justification: .noJustification,
            duration: 0,
            attackerStrength: calculateStateMilitaryStrength(state),
            defenderStrength: federalGovernment.militaryStrength
        )

        return civilWar
    }

    func formStateAlliance(states: [Region]) -> Coalition {
        // Multiple governors form alliance against federal government
        return Coalition(
            id: UUID(),
            members: states,
            combinedStrength: states.reduce(0) { $0 + calculateStateMilitaryStrength($1) }
        )
    }

    private func calculateStateMilitaryStrength(_ state: Region) -> Int {
        // Based on state population and resources
        return state.population / 10000 // Simplified
    }
}

struct Coalition: Codable, Identifiable {
    let id: UUID
    let members: [Region]
    var combinedStrength: Int
}
```

#### Tasks
- [ ] Implement StateWarManager
- [ ] Create state independence declaration system
- [ ] Build state alliance mechanics (California + Texas vs. Federal)
- [ ] Add governor-level war events
- [ ] Implement federal government response to state rebellion
- [ ] Test civil war scenarios
- [ ] Balance state vs. federal military strength

#### Deliverables
- Governor warfare system
- State independence mechanics
- State alliance system
- Civil war scenarios

---

### 4.8 Phase 4 Integration & Balance (Week 50-52)

#### Integration
- [ ] Connect warfare to time system (daily simulation)
- [ ] Integrate tech research timers
- [ ] Link territory management to taxation
- [ ] Connect rebellions to morale and tax rates
- [ ] Test end-to-end war cycle (declaration → events → victory → spoils)

#### Balance
- [ ] Balance military strength calculations
- [ ] Tune war duration (target 240 days average)
- [ ] Adjust rebellion risk probabilities
- [ ] Balance tech research costs and durations
- [ ] Tune territory morale decay rates
- [ ] Balance war costs and approval penalties

#### Polish
- [ ] Add war sound effects (battle sounds, victory fanfare)
- [ ] Create war notification system (alerts, badges)
- [ ] Polish all warfare UI screens
- [ ] Add victory/defeat cinematics
- [ ] Implement territory conquest animations

#### Testing
- [ ] Test 20+ war scenarios (victory, defeat, peace)
- [ ] Test rebellion triggers and suppression
- [ ] Verify tech research completion timing
- [ ] Test territory acquisition and management
- [ ] Performance test with multiple active wars

#### Deliverables
- Complete warfare system integrated
- Balanced gameplay for empire building
- Polished war UI and effects
- Phase 4 complete build

---

## Phase 5: Polish, Balance & Launch (Months 20-23)

### Goal
Final polish, balancing, monetization, performance optimization, and App Store launch.

---

### 5.1 Comprehensive Balance Pass (Week 53-55)

#### Stat Balance
- [ ] Review and adjust all base attribute impacts
- [ ] Balance approval rating effects across all events
- [ ] Tune campaign fund requirements for each position
- [ ] Adjust stress and health decay rates
- [ ] Balance scandal exposure probabilities

#### Career Progression Balance
- [ ] Review unlock requirements for all 8 positions
- [ ] Ensure smooth difficulty curve from birth to president
- [ ] Balance term lengths and age requirements
- [ ] Tune election difficulty (opponent strength)

#### Economic Balance
- [ ] Balance tax revenue formulas
- [ ] Adjust campaign fundraising rates
- [ ] Tune government budget expenses
- [ ] Balance military spending vs. strength gains
- [ ] Review tech research costs

#### Warfare Balance
- [ ] Fine-tune war duration calculations
- [ ] Balance casualty rates
- [ ] Adjust rebellion probabilities
- [ ] Tune territory morale decay
- [ ] Balance spoils of war

#### Event Balance
- [ ] Review all 300+ events for stat impacts
- [ ] Ensure event variety at each career stage
- [ ] Balance positive vs. negative events
- [ ] Adjust event frequencies
- [ ] Test event chains and delayed effects

#### Country Balance
- [ ] Ensure all 10 countries are equally playable
- [ ] Balance starting stats across countries
- [ ] Review country-specific event pools
- [ ] Test unique mechanics (monarchy, party system, etc.)

#### Deliverables
- Fully balanced game across all systems
- Difficulty curve documentation
- Balance spreadsheet with all formulas

---

### 5.2 UI/UX Polish (Week 55-57)

#### Visual Polish
- [ ] Final UI refinements following UI.md specs
- [ ] Add all animations and transitions
- [ ] Implement stat change number animations
- [ ] Polish all charts and graphs
- [ ] Add loading states and skeletons
- [ ] Refine color scheme and contrast
- [ ] Add micro-interactions (button presses, swipes)

#### Audio Implementation
- [ ] Add background music tracks (5-7 ambient pieces)
- [ ] Implement UI sound effects (buttons, notifications)
- [ ] Add event-specific sounds (applause, boos, alarms)
- [ ] Create war audio (battle ambience, victory fanfare)
- [ ] Add election night sounds
- [ ] Implement volume controls and mute

#### Haptic Feedback
- [ ] Add haptics for important events
- [ ] Haptic feedback for stat changes
- [ ] Election results haptics
- [ ] War declaration/victory haptics
- [ ] Scandal exposure haptics

#### Accessibility
- [ ] VoiceOver support for all screens
- [ ] Dynamic type support
- [ ] Colorblind mode implementation
- [ ] Ensure sufficient contrast ratios
- [ ] Test with accessibility features enabled

#### Onboarding
- [ ] Create tutorial for first-time players
- [ ] Add tooltips for complex mechanics
- [ ] Build help/info system
- [ ] Create "How to Play" guide
- [ ] Add contextual tips

#### Deliverables
- Fully polished UI with animations
- Complete audio implementation
- Accessibility compliance
- Onboarding tutorial system

---

### 5.3 Performance Optimization (Week 57-58)

#### Memory Optimization
- [ ] Profile memory usage with Instruments
- [ ] Fix memory leaks (if any)
- [ ] Optimize image loading (lazy loading, caching)
- [ ] Reduce save file sizes
- [ ] Test with large save files (long careers)

#### CPU Optimization
- [ ] Profile CPU usage for intensive operations
- [ ] Optimize war simulation calculations
- [ ] Improve event trigger performance
- [ ] Optimize world simulation
- [ ] Reduce main thread blocking

#### Battery Optimization
- [ ] Minimize background processing
- [ ] Optimize autosave frequency
- [ ] Reduce unnecessary re-renders
- [ ] Test battery drain during extended play

#### Launch Time
- [ ] Optimize app launch time (< 2 seconds)
- [ ] Lazy load non-critical resources
- [ ] Defer heavy initialization

#### Frame Rate
- [ ] Ensure 60 FPS on all screens
- [ ] Optimize scrolling performance
- [ ] Reduce animation complexity if needed

#### Deliverables
- App running smoothly on all supported devices
- Memory usage < 150 MB
- App launch < 2 seconds
- 60 FPS maintained

---

### 5.4 Monetization Integration (Week 58-59)

#### In-App Purchases
```swift
enum IAPProduct: String, CaseIterable {
    case adRemoval = "com.politiciansim.adremoval"
    case premiumCurrency1000 = "com.politiciansim.premium1000"
    case premiumCurrency5000 = "com.politiciansim.premium5000"
    case careerBoostMayor = "com.politiciansim.boostmayor"
    case themeGold = "com.politiciansim.themegold"
    case themePatriot = "com.politiciansim.themepatriot"
}

class IAPManager: ObservableObject {
    @Published var products: [SKProduct] = []
    @Published var purchasedProducts: Set<String> = []

    func fetchProducts() {
        // Fetch from App Store
    }

    func purchase(product: IAPProduct) {
        // Initiate purchase
    }

    func restorePurchases() {
        // Restore previous purchases
    }
}
```

#### Premium Currency Usage
- Re-roll event outcomes
- Re-run lost elections
- Instant policy effects (skip delay)
- Extra scandal mitigation
- Speed up tech research

#### Cosmetic Themes
- Gold theme (luxury colors)
- Patriot theme (flag colors)
- Dark mode variants
- Custom campaign colors

#### Career Boosts
- Instant promotion to Mayor (skip early game)
- Starting stat boosts
- Extra campaign funds

#### Tasks
- [ ] Implement StoreKit integration
- [ ] Create IAP products in App Store Connect
- [ ] Build in-app store UI
- [ ] Implement purchase flows
- [ ] Add restore purchases functionality
- [ ] Test purchases in sandbox
- [ ] Implement premium currency system
- [ ] Add cosmetic theme system

#### Deliverables
- Full IAP integration
- In-app store UI
- Premium currency mechanics
- Cosmetic themes

---

### 5.5 Testing & QA (Week 59-62)

#### Unit Testing
- [ ] Achieve 80%+ code coverage
- [ ] Test all core game logic
- [ ] Test save/load edge cases
- [ ] Test calculations (taxes, military, approval)
- [ ] Test event effect application

#### Integration Testing
- [ ] Test full career progression (birth → death)
- [ ] Test all 10 countries end-to-end
- [ ] Test war cycles (declaration → resolution)
- [ ] Test rebellion scenarios
- [ ] Test tech research completion

#### UI Testing
- [ ] Automate critical user flows
- [ ] Test character creation
- [ ] Test election flow
- [ ] Test war declaration
- [ ] Test settings and saves

#### Device Testing
- [ ] Test on iPhone SE (smallest screen)
- [ ] Test on iPhone 15 Pro Max (largest screen)
- [ ] Test on iPad (if supported)
- [ ] Test on older devices (performance)

#### Edge Case Testing
- [ ] Test with age 90 (death)
- [ ] Test with 0% approval
- [ ] Test with $0 funds
- [ ] Test with max scandals
- [ ] Test with 100+ active policies
- [ ] Test with multiple concurrent wars

#### Beta Testing
- [ ] TestFlight release to 50-100 beta testers
- [ ] Collect feedback
- [ ] Monitor crash reports
- [ ] Track analytics (session length, retention)
- [ ] Fix critical bugs

#### Deliverables
- Comprehensive test suite
- Beta test feedback incorporated
- Zero critical bugs
- Analytics integration

---

### 5.6 Content Completion (Week 62-64)

#### Event Library
- [ ] Ensure 300+ total events across all stages
- [ ] Review event quality and writing
- [ ] Add event variations for replayability
- [ ] Balance event pools per position

#### Policy Library
- [ ] Complete 75-100 total policies
- [ ] Ensure coverage across 5 categories
- [ ] Review policy effects and balance

#### Country Events
- [ ] Verify 10-15 unique events per country
- [ ] Test country-specific mechanics
- [ ] Review cultural sensitivity

#### Media Headlines
- [ ] Create headline templates (50+)
- [ ] Implement dynamic headline generation
- [ ] Test headline relevance

#### Achievements
- [ ] Implement 30-50 achievements
- [ ] Design achievement icons
- [ ] Test achievement triggers
- [ ] Add achievement notifications

#### Deliverables
- Complete content library
- All events, policies, headlines finalized
- Achievement system implemented

---

### 5.7 App Store Preparation (Week 64-66)

#### App Store Assets
- [ ] App icon (1024x1024)
- [ ] Screenshots for all device sizes
- [ ] Preview video (30 seconds)
- [ ] App Store description
- [ ] Keywords research
- [ ] Privacy policy page
- [ ] Terms of service page

#### Metadata
- [ ] App name: "Politician Sim"
- [ ] Subtitle: "From Birth to the Presidency"
- [ ] Description (4000 characters max)
- [ ] Keywords (100 characters)
- [ ] Category: Games > Simulation
- [ ] Age rating: 13+ (political themes)

#### Legal
- [ ] Privacy policy (data collection disclosure)
- [ ] Terms of service
- [ ] IAP disclosure
- [ ] Copyright notices
- [ ] Third-party licenses (if any)

#### App Store Connect Setup
- [ ] Create app record
- [ ] Upload build
- [ ] Configure IAPs
- [ ] Set pricing
- [ ] Select territories (start with US, expand globally)
- [ ] Submit for review

#### Marketing
- [ ] Create landing page/website
- [ ] Social media accounts (Twitter, Instagram)
- [ ] Press kit
- [ ] Trailer video (YouTube)
- [ ] Contact gaming journalists/influencers

#### Deliverables
- Complete App Store listing
- All assets uploaded
- Marketing materials ready
- App submitted for review

---

### 5.8 Launch & Post-Launch (Week 66-68)

#### Launch Day
- [ ] Monitor App Store approval
- [ ] Prepare launch announcement
- [ ] Social media posts
- [ ] Press release
- [ ] Monitor reviews and ratings
- [ ] Respond to user feedback

#### Post-Launch Support
- [ ] Hot fix critical bugs (if any)
- [ ] Monitor crash reports
- [ ] Track key metrics (downloads, retention, revenue)
- [ ] Respond to user reviews
- [ ] Update FAQ based on questions

#### Analytics Tracking
- [ ] DAU/MAU (daily/monthly active users)
- [ ] Retention rates (D1, D7, D30)
- [ ] Session length
- [ ] Conversion rate (free → paid)
- [ ] ARPU (average revenue per user)
- [ ] Completion rates (reach President)

#### First Update Planning
- [ ] Collect user feedback
- [ ] Prioritize bugs and improvements
- [ ] Plan content additions
- [ ] Schedule v1.1 update (1-2 months post-launch)

#### Deliverables
- Successful App Store launch
- Active user monitoring
- Post-launch support plan
- V1.1 roadmap

---

## Post-Launch: Expansion Roadmap

### Version 1.1 (2-3 months post-launch)
- Bug fixes from launch feedback
- Balance adjustments
- 5-10 new events per position
- Quality of life improvements
- Performance optimizations

### Version 1.2 (4-6 months post-launch)
- Add 5 new countries (Tier 2)
- New achievement set
- UI improvements
- New premium content (themes, boosts)

### Version 2.0 (8-12 months post-launch)
- Multiplayer leaderboards
- Historical Mode (recreate famous elections)
- Dynasty Mode (family succession)
- Major content expansion

---

## Development Resources

### Team Structure (Recommended)
- **1 Lead Developer** (Full-stack iOS, you)
- **1 Game Designer** (Content creation, balancing) - can be you
- **1 UI/UX Designer** (Assets, polishing) - contract/freelance
- **1 QA Tester** (Beta testing phase) - contract
- **1 Sound Designer** (Audio assets) - contract

### Tools & Services
- **IDE:** Xcode 15+
- **Version Control:** Git + GitHub
- **Design:** Figma (UI mockups)
- **Project Management:** Notion or Trello
- **Analytics:** Firebase Analytics
- **Crash Reporting:** Firebase Crashlytics
- **Beta Testing:** TestFlight
- **Monetization:** StoreKit (Apple IAP)

### Estimated Costs
- **Developer Account:** $99/year
- **Freelance Designer:** $2000-5000
- **Sound Assets:** $500-1000
- **Marketing:** $1000-3000
- **Total:** ~$5000-10000

---

## Risk Management

### Technical Risks
- **Save file corruption:** Mitigate with versioning and migration system
- **Performance issues:** Regular profiling and optimization
- **App Store rejection:** Follow guidelines closely, prepare for appeals

### Design Risks
- **Complexity overwhelming:** Implement gradual feature unlocks
- **Balance issues:** Extensive playtesting and tuning
- **Replayability concerns:** Ensure event variety and random outcomes

### Business Risks
- **Low downloads:** Invest in ASO and marketing
- **Poor retention:** Focus on engagement and content depth
- **Low monetization:** Balance free content with premium value

---

## Success Metrics

### Phase 1 Success
- Playable birth to age 18
- 0 critical bugs
- Autosave working reliably

### Phase 2 Success
- Playable career to Mayor
- Election system functional
- Scandal and policy systems working

### Phase 3 Success
- All 10 countries playable
- Career to President achievable
- World simulation running

### Phase 4 Success
- War system complete and balanced
- Empire building functional
- No game-breaking bugs

### Launch Success (6 months)
- 10,000+ downloads
- 4.0+ App Store rating
- 20%+ D7 retention
- Break-even on development costs

---

## Conclusion

This game plan provides a comprehensive roadmap for implementing Politician Sim over approximately 18-23 months. The phased approach ensures incremental delivery of playable builds while managing complexity.

**Key Success Factors:**
1. **Disciplined execution** of each phase
2. **Regular playtesting** and balance adjustments
3. **Code quality** and maintainability
4. **User feedback** integration
5. **Realistic timeline** with buffer for unknowns

**Next Steps:**
1. Review and approve this game plan
2. Set up development environment
3. Begin Phase 1, Week 1: Project Setup & Architecture
4. Commit to regular progress updates and milestone reviews

Good luck building Politician Sim! 🎮🏛️
