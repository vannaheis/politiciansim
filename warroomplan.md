# War Room Implementation Plan

## 🎯 Overview

The War Room is a strategic command center feature where players manage crises, coordinate emergency responses, and make critical decisions under time pressure. It combines crisis management, strategic planning, and executive decision-making into a high-stakes gameplay system.

---

## 📋 Complete Implementation Phases

### **Phase 1: Core Data Models**

#### 1.1 Create `Crisis.swift`
**Location**: `PoliticianSim/PoliticianSim/Models/Crisis.swift`

```swift
//
//  Crisis.swift
//  PoliticianSim
//
//  Crisis model for War Room system
//

import Foundation

struct Crisis: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var category: CrisisCategory
    var severity: CrisisSeverity
    var startDate: Date
    var expiryDate: Date?  // Deadline for action (nil = no deadline)
    var status: CrisisStatus
    var affectedDepartments: [Department.DepartmentCategory]
    var potentialImpacts: CrisisImpacts
    var availableResponses: [CrisisResponse]
    var chosenResponse: CrisisResponse?
    var responseStartDate: Date?
    var progressPercentage: Double  // 0-100 (for active responses)

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: CrisisCategory,
        severity: CrisisSeverity,
        startDate: Date,
        expiryDate: Date? = nil,
        status: CrisisStatus = .developing,
        affectedDepartments: [Department.DepartmentCategory],
        potentialImpacts: CrisisImpacts,
        availableResponses: [CrisisResponse],
        chosenResponse: CrisisResponse? = nil,
        responseStartDate: Date? = nil,
        progressPercentage: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.severity = severity
        self.startDate = startDate
        self.expiryDate = expiryDate
        self.status = status
        self.affectedDepartments = affectedDepartments
        self.potentialImpacts = potentialImpacts
        self.availableResponses = availableResponses
        self.chosenResponse = chosenResponse
        self.responseStartDate = responseStartDate
        self.progressPercentage = progressPercentage
    }

    enum CrisisCategory: String, Codable, CaseIterable {
        case economic = "Economic"
        case health = "Health"
        case natural = "Natural Disaster"
        case security = "Security"
        case diplomatic = "Diplomatic"
        case social = "Social"
        case environmental = "Environmental"
        case infrastructure = "Infrastructure"

        var icon: String {
            switch self {
            case .economic: return "chart.line.downtrend.xyaxis"
            case .health: return "cross.case.fill"
            case .natural: return "cloud.bolt.rain.fill"
            case .security: return "shield.slash.fill"
            case .diplomatic: return "globe.americas.fill"
            case .social: return "person.3.fill"
            case .environmental: return "leaf.fill"
            case .infrastructure: return "building.2.fill"
            }
        }

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .economic: return (1.0, 0.3, 0.3)
            case .health: return (1.0, 0.3, 0.3)
            case .natural: return (0.3, 0.6, 1.0)
            case .security: return (0.7, 0.2, 0.2)
            case .diplomatic: return (0.6, 0.4, 0.8)
            case .social: return (1.0, 0.6, 0.8)
            case .environmental: return (0.2, 0.8, 0.2)
            case .infrastructure: return (0.8, 0.5, 0.2)
            }
        }
    }

    enum CrisisSeverity: String, Codable {
        case minor = "Minor"
        case moderate = "Moderate"
        case severe = "Severe"
        case critical = "Critical"

        var icon: String {
            switch self {
            case .minor: return "exclamationmark.circle.fill"
            case .moderate: return "exclamationmark.triangle.fill"
            case .severe: return "exclamationmark.octagon.fill"
            case .critical: return "exclamationmark.shield.fill"
            }
        }

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .minor: return (0.9, 0.9, 0.2)      // Yellow
            case .moderate: return (1.0, 0.6, 0.0)   // Orange
            case .severe: return (1.0, 0.3, 0.3)     // Red
            case .critical: return (0.6, 0.0, 0.0)   // Dark Red
            }
        }
    }

    enum CrisisStatus: String, Codable {
        case developing = "Developing"
        case active = "Active Response"
        case contained = "Contained"
        case resolved = "Resolved"
        case failed = "Failed"
    }
}

struct CrisisImpacts: Codable {
    var gdpImpact: Double              // Negative percentage (e.g., -0.05 = -5%)
    var approvalImpact: Double         // Negative points (e.g., -15)
    var departmentImpacts: [Department.DepartmentCategory: Double]  // Score changes
    var casualties: Int?               // For severe crises (deaths)
    var economicCost: Decimal          // Dollar cost in billions
    var internationalRelationsImpact: Double  // -20 to 0
}

struct CrisisResponse: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var requiredFunds: Decimal         // Implementation cost
    var requiredDepartments: [Department.DepartmentCategory]
    var executionTime: Int             // Days to complete
    var baseProbability: Double        // Base success rate (0-1)
    var outcomes: ResponseOutcomes

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        requiredFunds: Decimal,
        requiredDepartments: [Department.DepartmentCategory],
        executionTime: Int,
        baseProbability: Double,
        outcomes: ResponseOutcomes
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.requiredFunds = requiredFunds
        self.requiredDepartments = requiredDepartments
        self.executionTime = executionTime
        self.baseProbability = baseProbability
        self.outcomes = outcomes
    }

    struct ResponseOutcomes: Codable {
        var bestCase: OutcomeEffects
        var expectedCase: OutcomeEffects
        var worstCase: OutcomeEffects
    }
}

struct OutcomeEffects: Codable {
    var approvalChange: Double
    var reputationChange: Int
    var gdpImpact: Double
    var stressChange: Int
    var fundsChange: Decimal
    var departmentImpacts: [Department.DepartmentCategory: Double]
    var casualties: Int  // Lives saved/lost
}
```

#### 1.2 Create `WarRoomState.swift`
**Location**: `PoliticianSim/PoliticianSim/Models/WarRoomState.swift`

```swift
//
//  WarRoomState.swift
//  PoliticianSim
//
//  War Room state tracking
//

import Foundation

struct WarRoomState: Codable {
    var activeCrises: [Crisis] = []
    var resolvedCrises: [Crisis] = []
    var failedCrises: [Crisis] = []
    var totalCrisesHandled: Int = 0
    var successfulResolutions: Int = 0
    var lastCrisisDate: Date?

    // Alert levels
    var nationalThreatLevel: ThreatLevel = .green

    var successRate: Double {
        guard totalCrisesHandled > 0 else { return 0.0 }
        return (Double(successfulResolutions) / Double(totalCrisesHandled)) * 100.0
    }

    enum ThreatLevel: String, Codable {
        case green = "Normal"
        case yellow = "Elevated"
        case orange = "High"
        case red = "Severe"
        case black = "Critical"

        var icon: String {
            switch self {
            case .green: return "checkmark.shield.fill"
            case .yellow: return "exclamationmark.shield.fill"
            case .orange: return "exclamationmark.triangle.fill"
            case .red: return "exclamationmark.octagon.fill"
            case .black: return "xmark.shield.fill"
            }
        }

        var color: (red: Double, green: Double, blue: Double) {
            switch self {
            case .green: return (0.2, 0.8, 0.2)
            case .yellow: return (0.9, 0.9, 0.2)
            case .orange: return (1.0, 0.6, 0.0)
            case .red: return (1.0, 0.3, 0.3)
            case .black: return (0.6, 0.0, 0.0)
            }
        }
    }
}
```

---

### **Phase 2: Business Logic Manager**

#### 2.1 Create `WarRoomManager.swift`
**Location**: `PoliticianSim/PoliticianSim/ViewModels/WarRoomManager.swift`

**Key Responsibilities**:
- Generate crises based on position level and game state
- Manage crisis lifecycle (developing → active → resolved/failed)
- Calculate success probabilities based on character attributes
- Apply crisis effects to game systems
- Track threat levels

**Implementation Details**:

```swift
//
//  WarRoomManager.swift
//  PoliticianSim
//
//  Manages crisis generation, responses, and resolution
//

import Foundation
import Combine

class WarRoomManager: ObservableObject {
    @Published var warRoomState: WarRoomState

    init() {
        self.warRoomState = WarRoomState()
    }

    // MARK: - Crisis Generation

    /// Checks if a crisis should be generated based on position and time
    func checkForCrisisOpportunity(character: Character) -> Crisis? {
        // Crisis frequency based on position level
        let crisisChance = getCrisisChance(position: character.currentPosition)

        // Random check
        if Double.random(in: 0...1) > crisisChance {
            return nil
        }

        // Generate random crisis
        return generateRandomCrisis(character: character)
    }

    private func getCrisisChance(position: Position?) -> Double {
        guard let position = position else { return 0.001 } // Very low for non-officials

        // Weekly crisis probability by position level
        switch position.level {
        case 1: return 0.01  // ~1 crisis per 2 years (local)
        case 2: return 0.02  // ~1 crisis per year (local)
        case 3: return 0.04  // ~2 crises per year (state)
        case 4: return 0.08  // ~4 crises per year (governor)
        case 5: return 0.12  // ~6 crises per year (senator)
        case 6: return 0.20  // ~10 crises per year (president)
        default: return 0.05
        }
    }

    func generateRandomCrisis(character: Character) -> Crisis {
        // Randomly select severity (weighted)
        let severity = randomSeverity()
        let category = Crisis.CrisisCategory.allCases.randomElement()!

        // Get template based on category and severity
        let template = getCrisisTemplate(category: category, severity: severity)

        // Set start date and expiry based on severity
        let startDate = character.currentDate
        let expiryDate = getExpiryDate(severity: severity, startDate: startDate)

        return Crisis(
            title: template.title,
            description: template.description,
            category: category,
            severity: severity,
            startDate: startDate,
            expiryDate: expiryDate,
            affectedDepartments: template.affectedDepartments,
            potentialImpacts: template.potentialImpacts,
            availableResponses: template.availableResponses
        )
    }

    private func randomSeverity() -> Crisis.CrisisSeverity {
        let rand = Double.random(in: 0...1)
        if rand < 0.60 {
            return .minor
        } else if rand < 0.85 {
            return .moderate
        } else if rand < 0.97 {
            return .severe
        } else {
            return .critical
        }
    }

    private func getExpiryDate(severity: Crisis.CrisisSeverity, startDate: Date) -> Date? {
        let calendar = Calendar.current

        switch severity {
        case .minor:
            return nil  // No deadline
        case .moderate:
            return calendar.date(byAdding: .day, value: 21, to: startDate)  // 3 weeks
        case .severe:
            return calendar.date(byAdding: .day, value: 5, to: startDate)  // 5 days
        case .critical:
            return calendar.date(byAdding: .day, value: 2, to: startDate)  // 2 days
        }
    }

    // MARK: - Crisis Management

    func activateCrisis(_ crisis: Crisis) {
        var newCrisis = crisis
        newCrisis.status = .developing
        warRoomState.activeCrises.append(newCrisis)
        warRoomState.lastCrisisDate = crisis.startDate
        updateThreatLevel()
    }

    func respondToCrisis(
        crisisId: UUID,
        response: CrisisResponse,
        character: inout Character
    ) -> (success: Bool, message: String) {
        guard let index = warRoomState.activeCrises.firstIndex(where: { $0.id == crisisId }) else {
            return (false, "Crisis not found.")
        }

        var crisis = warRoomState.activeCrises[index]

        // Check if player has enough funds
        if character.campaignFunds < response.requiredFunds {
            return (false, "Insufficient funds for this response.")
        }

        // Deduct funds
        character.campaignFunds -= response.requiredFunds

        // Set response as chosen
        crisis.chosenResponse = response
        crisis.responseStartDate = character.currentDate
        crisis.status = .active
        crisis.progressPercentage = 0.0

        warRoomState.activeCrises[index] = crisis

        return (true, "Response initiated: \(response.title)")
    }

    func updateCrisisProgress(character: Character, currentDate: Date) {
        for i in 0..<warRoomState.activeCrises.count {
            var crisis = warRoomState.activeCrises[i]

            // Check if crisis has expired without response
            if crisis.status == .developing, let expiryDate = crisis.expiryDate {
                if currentDate >= expiryDate {
                    failCrisis(index: i, character: character)
                    continue
                }
            }

            // Update progress for active responses
            if crisis.status == .active,
               let response = crisis.chosenResponse,
               let startDate = crisis.responseStartDate {

                let daysElapsed = Calendar.current.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
                let progress = (Double(daysElapsed) / Double(response.executionTime)) * 100.0
                crisis.progressPercentage = min(100.0, progress)

                // Check if response is complete
                if daysElapsed >= response.executionTime {
                    resolveCrisis(index: i, character: character)
                } else {
                    warRoomState.activeCrises[i] = crisis
                }
            }
        }

        updateThreatLevel()
    }

    private func resolveCrisis(index: Int, character: Character) {
        guard index < warRoomState.activeCrises.count else { return }

        var crisis = warRoomState.activeCrises[index]
        guard let response = crisis.chosenResponse else { return }

        // Calculate success based on probability
        let successProb = calculateSuccessProbability(response: response, character: character, crisis: crisis)
        let roll = Double.random(in: 0...1)

        let outcome: OutcomeEffects
        if roll < successProb * 0.3 {
            // Best case (30% of success range)
            outcome = response.outcomes.bestCase
            crisis.status = .resolved
        } else if roll < successProb {
            // Expected case (rest of success range)
            outcome = response.outcomes.expectedCase
            crisis.status = .resolved
        } else {
            // Worst case (failure)
            outcome = response.outcomes.worstCase
            crisis.status = .failed
        }

        // Apply outcome effects (will be handled by GameManager)
        // For now, just update crisis status

        if crisis.status == .resolved {
            warRoomState.successfulResolutions += 1
            warRoomState.resolvedCrises.append(crisis)
        } else {
            warRoomState.failedCrises.append(crisis)
        }

        warRoomState.totalCrisesHandled += 1
        warRoomState.activeCrises.remove(at: index)
    }

    private func failCrisis(index: Int, character: Character) {
        guard index < warRoomState.activeCrises.count else { return }

        var crisis = warRoomState.activeCrises[index]
        crisis.status = .failed

        // Apply full negative impacts
        // (will be handled by GameManager)

        warRoomState.failedCrises.append(crisis)
        warRoomState.totalCrisesHandled += 1
        warRoomState.activeCrises.remove(at: index)
    }

    // MARK: - Success Probability

    func calculateSuccessProbability(
        response: CrisisResponse,
        character: Character,
        crisis: Crisis
    ) -> Double {
        var probability = response.baseProbability

        // Character attribute bonuses
        let intelligenceBonus = Double(character.intelligence) * 0.002  // +0.2 at 100
        let charismaBonus = Double(character.charisma) * 0.001         // +0.1 at 100
        let diplomacyBonus = Double(character.diplomacy) * 0.001       // +0.1 at 100

        // Stress penalty
        let stressPenalty = Double(character.stress) * -0.001  // -0.1 at 100 stress

        probability += intelligenceBonus + charismaBonus + diplomacyBonus + stressPenalty

        // Clamp between 5% and 95%
        return min(0.95, max(0.05, probability))
    }

    // MARK: - Threat Level

    func updateThreatLevel() {
        let activeCrises = warRoomState.activeCrises

        if activeCrises.isEmpty {
            warRoomState.nationalThreatLevel = .green
            return
        }

        // Count crises by severity
        let criticalCount = activeCrises.filter { $0.severity == .critical }.count
        let severeCount = activeCrises.filter { $0.severity == .severe }.count
        let moderateCount = activeCrises.filter { $0.severity == .moderate }.count

        // Determine threat level
        if criticalCount >= 1 || severeCount >= 3 {
            warRoomState.nationalThreatLevel = .black
        } else if severeCount >= 2 || moderateCount >= 4 {
            warRoomState.nationalThreatLevel = .red
        } else if severeCount >= 1 || moderateCount >= 2 {
            warRoomState.nationalThreatLevel = .orange
        } else if moderateCount >= 1 || activeCrises.count >= 3 {
            warRoomState.nationalThreatLevel = .yellow
        } else {
            warRoomState.nationalThreatLevel = .green
        }
    }

    // MARK: - Crisis Templates (stub - will implement in Phase 5)

    private func getCrisisTemplate(category: Crisis.CrisisCategory, severity: Crisis.CrisisSeverity) -> Crisis {
        // Placeholder - will be populated with real templates
        return Crisis(
            title: "Sample \(severity.rawValue) \(category.rawValue) Crisis",
            description: "This is a placeholder crisis.",
            category: category,
            severity: severity,
            startDate: Date(),
            affectedDepartments: [.infrastructure],
            potentialImpacts: CrisisImpacts(
                gdpImpact: -0.01,
                approvalImpact: -5,
                departmentImpacts: [:],
                casualties: nil,
                economicCost: 10_000_000_000,
                internationalRelationsImpact: 0
            ),
            availableResponses: []
        )
    }
}
```

---

### **Phase 3: UI Components**

#### 3.1 Create `WarRoomView.swift`
**Location**: `PoliticianSim/PoliticianSim/Views/WarRoom/WarRoomView.swift`

**Layout**:
- Header with threat level indicator
- Tab selector (Active / Resolved / Failed)
- Crisis cards list with:
  - Severity badge
  - Category icon
  - Title and brief description
  - Impact preview
  - Countdown timer (if deadline exists)
  - Action buttons
- Statistics summary

#### 3.2 Create `CrisisDetailView.swift`
**Location**: `PoliticianSim/PoliticianSim/Views/WarRoom/CrisisDetailView.swift`

**Layout**:
- Full crisis description
- Affected departments list
- Potential impacts breakdown
- Countdown timer (prominent)
- Response options with:
  - Cost
  - Execution time
  - Success probability
  - Outcome scenarios (best/expected/worst)
  - Execute button
- Ignore option (risk warning)

#### 3.3 Create `CrisisCard.swift` (Reusable Component)
**Location**: `PoliticianSim/PoliticianSim/Views/WarRoom/CrisisCard.swift`

Compact card showing crisis summary for list views.

#### 3.4 Create `CrisisProgressView.swift`
**Location**: `PoliticianSim/PoliticianSim/Views/WarRoom/CrisisProgressView.swift`

Shows active crisis response progress with:
- Progress bar
- ETA to completion
- Current status updates

---

### **Phase 4: Integration**

#### 4.1 Update `NavigationManager.swift`

Add to `NavigationView` enum:
```swift
case warRoom = "War Room"
```

Update icon mapping:
```swift
case .warRoom: return "exclamationmark.triangle.fill"
```

Update section mapping:
```swift
case .warRoom: return .governance
```

#### 4.2 Update `GameManager.swift`

1. Add property:
```swift
@Published var warRoomManager = WarRoomManager()
```

2. Add to `setupObjectWillChangeForwarding()`:
```swift
warRoomManager.objectWillChange
    .sink { [weak self] _ in
        self?.objectWillChange.send()
    }
    .store(in: &cancellables)
```

3. Add crisis checks to `skipDay()` and `skipWeek()`:
```swift
// Check for new crisis
if let newCrisis = self.warRoomManager.checkForCrisisOpportunity(character: updatedChar) {
    self.warRoomManager.activateCrisis(newCrisis)
}

// Update crisis progress
self.warRoomManager.updateCrisisProgress(character: updatedChar, currentDate: updatedChar.currentDate)
```

4. Add to `newGame()`:
```swift
warRoomManager = WarRoomManager()
```

#### 4.3 Update `ContentView.swift`

Add case to router:
```swift
case .warRoom:
    WarRoomView()
```

#### 4.4 Update `SaveGame.swift`

Add property:
```swift
var warRoomState: WarRoomState
```

Update encoding/decoding and GameManager integration.

---

### **Phase 5: Crisis Templates Library**

Create 30+ crisis templates across all categories with realistic impacts and response options.

**Economic Crises** (5 templates):
1. Stock Market Crash
2. Banking System Failure
3. Currency Crisis
4. Trade War Escalation
5. Recession Onset

**Health Crises** (4 templates):
1. Pandemic Outbreak
2. Food Contamination Event
3. Hospital System Overload
4. Drug Shortage Emergency

**Natural Disasters** (5 templates):
1. Category 4+ Hurricane
2. Major Earthquake
3. Widespread Wildfire
4. Severe Flooding
5. Prolonged Drought

**Security Crises** (4 templates):
1. Terrorist Attack
2. Cyber Attack on Critical Infrastructure
3. Border Security Breach
4. Domestic Terrorism Threat

**Diplomatic Crises** (4 templates):
1. International Armed Conflict
2. Hostage Situation Abroad
3. Trade Embargo
4. Alliance Breakdown

**Social Crises** (4 templates):
1. Mass Civil Protests
2. Urban Riots
3. National Strike
4. Civil Unrest

**Environmental Crises** (3 templates):
1. Major Oil Spill
2. Nuclear Facility Accident
3. Toxic Waste Leak

**Infrastructure Crises** (3 templates):
1. Bridge/Dam Collapse
2. National Power Grid Failure
3. Water System Contamination

Each template includes:
- 2-4 response options
- Realistic dollar costs ($10B - $500B depending on severity)
- Character-based success probabilities
- Multiple outcome scenarios
- Department impacts

---

### **Phase 6: Polish & Features**

#### Visual Design
- **Severity color coding**: Yellow (minor) → Orange (moderate) → Red (severe) → Dark Red (critical)
- **Animated threat level indicator** with pulsing effect for high alerts
- **Category icons** for quick identification
- **Progress bars** with smooth animations
- **Countdown timers** with urgency color shifts

#### Sound & Haptics
- Alert sound when new crisis appears
- Haptic feedback for crisis severity
- Success/failure audio feedback

#### Statistics Dashboard
- Total crises handled
- Success rate percentage
- Crises by category breakdown
- Average resolution time

#### Tutorial System
- First-time War Room tutorial
- Contextual help for crisis responses
- Tips for maximizing success probability

---

## 🎮 Gameplay Balance Parameters

### Crisis Frequency by Position

| Position Level | Position Name | Weekly Probability | Yearly Expected | Max Simultaneous |
|---------------|---------------|-------------------|----------------|------------------|
| 1 | City Council | 1% | 0.5 | 1 |
| 2 | Mayor | 2% | 1 | 1 |
| 3 | State Rep | 4% | 2 | 2 |
| 4 | Governor | 8% | 4 | 3 |
| 5 | Senator | 12% | 6 | 3 |
| 6 | President | 20% | 10 | 5 |

### Severity Distribution
- **Minor**: 60% (Yellow)
- **Moderate**: 25% (Orange)
- **Severe**: 12% (Red)
- **Critical**: 3% (Dark Red)

### Impact Ranges by Severity

| Severity | GDP Impact | Approval Impact | Cost Range | Casualties | Deadline |
|----------|-----------|----------------|------------|------------|----------|
| Minor | -0.1% to -0.5% | -3 to -5 | $5B - $20B | 0 | None |
| Moderate | -0.5% to -2% | -5 to -12 | $20B - $100B | 0-100 | 2-4 weeks |
| Severe | -2% to -5% | -12 to -25 | $100B - $300B | 100-1000 | 3-7 days |
| Critical | -5% to -10% | -25 to -50 | $300B - $1T | 1000+ | 1-3 days |

### Response Success Probability Formula

```
Base Probability (from response template): 0.4 - 0.8

Character Bonuses:
+ Intelligence × 0.002 (max +0.20 at 100)
+ Charisma × 0.001 (max +0.10 at 100)
+ Diplomacy × 0.001 (max +0.10 at 100)

Character Penalties:
- Stress × 0.001 (max -0.10 at 100)

Department Bonus (future):
+ (Department Score / 100) × 0.05 per required department

Final Probability: Clamp(0.05, 0.95, Total)
```

Example:
- Base: 0.60
- Intelligence 80: +0.16
- Charisma 70: +0.07
- Diplomacy 60: +0.06
- Stress 50: -0.05
- **Total: 0.84 (84% success chance)**

---

## 🔄 System Integration Map

### War Room Interactions with Existing Systems

1. **Budget System**
   - Crisis responses cost money from campaign funds
   - Department funding affects success probability (future enhancement)

2. **Government Stats**
   - Affected departments suffer score decreases during crisis
   - Successful resolution can boost department scores

3. **Policy System**
   - Certain policies can prevent crisis types
   - Policies can provide bonuses to crisis responses

4. **Approval Rating**
   - Crisis mishandling damages approval
   - Successful resolution boosts approval

5. **Economic Simulation**
   - Crises directly impact GDP
   - Crisis costs added to national debt
   - Capital stock can be damaged

6. **Event System**
   - Some events can escalate into crises
   - Crisis resolution can trigger follow-up events

7. **Diplomacy**
   - International crises affect diplomatic relations
   - Diplomatic stats influence crisis success

8. **Character Health/Stress**
   - Crisis management increases stress
   - Failed crises cause major stress damage

---

## 📁 Complete File Structure

```
PoliticianSim/PoliticianSim/
├── Models/
│   ├── Crisis.swift                    (NEW - Phase 1)
│   └── WarRoomState.swift              (NEW - Phase 1)
│
├── ViewModels/
│   └── WarRoomManager.swift            (NEW - Phase 2)
│
├── Views/
│   └── WarRoom/
│       ├── WarRoomView.swift           (NEW - Phase 3)
│       ├── CrisisDetailView.swift      (NEW - Phase 3)
│       ├── CrisisCard.swift            (NEW - Phase 3)
│       └── CrisisProgressView.swift    (NEW - Phase 3)
│
└── Updated Files:
    ├── NavigationManager.swift         (MODIFY - Phase 4)
    ├── GameManager.swift               (MODIFY - Phase 4)
    ├── ContentView.swift               (MODIFY - Phase 4)
    └── SaveGame.swift                  (MODIFY - Phase 4)
```

---

## ✅ Implementation Checklist

### Phase 1: Models ☐
- [ ] Create `Crisis.swift` with all enums and structs
- [ ] Create `WarRoomState.swift`
- [ ] Test model serialization (Codable)

### Phase 2: Manager ☐
- [ ] Create `WarRoomManager.swift`
- [ ] Implement crisis generation logic
- [ ] Implement crisis lifecycle management
- [ ] Implement success probability calculation
- [ ] Implement threat level system
- [ ] Test all manager methods

### Phase 3: UI ☐
- [ ] Create `WarRoomView.swift` (main view)
- [ ] Create `CrisisCard.swift` (reusable component)
- [ ] Create `CrisisDetailView.swift`
- [ ] Create `CrisisProgressView.swift`
- [ ] Implement countdown timers
- [ ] Implement severity color coding
- [ ] Test UI on different screen sizes

### Phase 4: Integration ☐
- [ ] Update `NavigationManager.swift`
- [ ] Update `GameManager.swift` (add manager, crisis checks)
- [ ] Update `ContentView.swift` (routing)
- [ ] Update `SaveGame.swift` (serialization)
- [ ] Test save/load with War Room data
- [ ] Test crisis generation during gameplay

### Phase 5: Content ☐
- [ ] Create 5 economic crisis templates
- [ ] Create 4 health crisis templates
- [ ] Create 5 natural disaster templates
- [ ] Create 4 security crisis templates
- [ ] Create 4 diplomatic crisis templates
- [ ] Create 4 social crisis templates
- [ ] Create 3 environmental crisis templates
- [ ] Create 3 infrastructure crisis templates
- [ ] Test all crisis templates

### Phase 6: Polish ☐
- [ ] Implement visual animations
- [ ] Add sound effects (if desired)
- [ ] Create tutorial/help system
- [ ] Implement statistics tracking
- [ ] Add achievements (optional)
- [ ] Final balance testing
- [ ] Bug fixes and optimization

---

## 🎯 Success Metrics

After implementation, the War Room should:

1. ✅ Generate crises at appropriate frequency for position level
2. ✅ Provide meaningful strategic choices with risk/reward tradeoffs
3. ✅ Create time pressure and urgency through deadlines
4. ✅ Reward good governance (high department scores, character attributes)
5. ✅ Integrate seamlessly with existing economic and approval systems
6. ✅ Add replayability through varied crisis scenarios
7. ✅ Feel impactful on overall game progression

---

## 📝 Notes for Implementation

1. **Start with Phase 1-2** to get core functionality working
2. **Phase 3 UI can be iterative** - start simple, add polish later
3. **Phase 4 integration is critical** - test thoroughly
4. **Phase 5 content** can be added gradually (start with 5-10 templates)
5. **Phase 6 polish** can be done after core gameplay is validated

**Estimated Implementation Time**:
- Phase 1-2: 4-6 hours
- Phase 3: 6-8 hours
- Phase 4: 2-3 hours
- Phase 5: 8-12 hours (content creation)
- Phase 6: 4-6 hours
- **Total: 24-35 hours**

---

## 🚀 Future Enhancements (Post-Launch)

1. **Multi-stage crises** that evolve over time
2. **Crisis chains** where one crisis triggers another
3. **Regional variations** (state-specific crises)
4. **International coalition responses** (for diplomatic crises)
5. **Media coverage system** affecting public perception
6. **Expert advisors** providing recommendations
7. **Historical crisis database** for reference
8. **Crisis preparedness** system (prevention policies)
9. **Emergency powers** temporary authority during critical crises
10. **Post-crisis recovery tracking**

---

This implementation plan provides a complete roadmap for building the War Room feature from scratch, with detailed specifications, integration points, and realistic time estimates.
