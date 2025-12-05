# Territories & War Progression Plan

## Overview
Implementation of realistic territory tracking, war progression updates, and GDP integration for the political simulation game.

## Recent Updates (Based on User Clarifications)

This plan has been updated to address 12 critical clarifications:

1. **GDP Initialization**: Confirmed GDP data exists in `economicData.worldGDPs`. Need to add 20 missing countries.
2. **Territory/Population/GDP Changes**: Clarified that all three change proportionally (non-linearly) based on war outcomes using `change_percent^0.7` formula.
3. **Reparations Integration**: Reparations will integrate with TreasuryManager, deducted yearly for 10 years.
4. **Territory Aging**: Added annual GDP improvement mechanics for conquered territories (30% → 90% over 4 years).
5. **Territory Ceding Priority**: Loser's conquered territories are ceded first, then core territory. Active rebellions are separate conflicts.
6. **Save/Load**: GlobalCountryState, reparations, war reports, and AI wars will be integrated with SaveManager.
7. **Player Death**: Game ends immediately with popup when player loses war.
8. **Multiple War Popups**: Show 3 separate popups for 3 concurrent wars (not combined).
9. **AI Military Strength**: AI military strength evolves based on GDP/territory changes.
10. **AI War Geography**: No restrictions on AI wars, but neighbors have 3x higher probability (6% vs 2%).
11. **Status Quo Peace**: Returns all territories to pre-war state (no changes).
12. **AI War Notifications**: Player is notified of ALL AI wars via popup, not just major powers.

---

## 1. Territory System

### 1.1 Base Territory for All Countries

**Implementation Location**: `Country.swift` and `RivalCountry` struct

All 40+ countries will have realistic starting territories based on real-world data:

#### Major Powers
- **USA**: 3,800,000 sq mi
- **China**: 3,700,000 sq mi
- **Russia**: 6,600,000 sq mi
- **India**: 1,269,000 sq mi
- **North Korea**: 46,540 sq mi
- **Pakistan**: 307,374 sq mi

#### Regional Powers
- **Iran**: 636,372 sq mi
- **South Korea**: 38,691 sq mi
- **Turkey**: 302,535 sq mi
- **Egypt**: 390,121 sq mi
- **Vietnam**: 127,882 sq mi
- **Myanmar**: 261,228 sq mi
- **Indonesia**: 735,358 sq mi
- **Thailand**: 198,117 sq mi

#### NATO & Allies
- **United Kingdom**: 93,628 sq mi
- **France**: 248,573 sq mi
- **Germany**: 137,988 sq mi
- **Japan**: 145,937 sq mi
- **Italy**: 116,348 sq mi
- **Poland**: 120,733 sq mi

#### Middle East
- **Saudi Arabia**: 830,000 sq mi
- **Israel**: 8,019 sq mi
- **Syria**: 71,498 sq mi
- **Iraq**: 168,754 sq mi

#### Latin America
- **Brazil**: 3,287,956 sq mi
- **Colombia**: 440,831 sq mi
- **Mexico**: 761,610 sq mi
- **Venezuela**: 353,841 sq mi
- **Cuba**: 42,426 sq mi

#### Africa
- **Nigeria**: 356,669 sq mi
- **Ethiopia**: 426,373 sq mi
- **South Africa**: 471,445 sq mi
- **Algeria**: 919,595 sq mi

#### Oceania & Others
- **Australia**: 2,969,907 sq mi
- **Taiwan**: 13,976 sq mi
- **Ukraine**: 233,032 sq mi
- **Afghanistan**: 251,827 sq mi

#### Smaller Nations
- **Belarus**: 80,155 sq mi
- **Kazakhstan**: 1,052,090 sq mi
- **Serbia**: 29,913 sq mi
- **Libya**: 679,362 sq mi

### 1.2 Territory Storage Architecture

**Player Territory**: Derived from `Character.country` → `Country.territorySize` + conquered territories
**Rival Countries**: Create `GlobalCountryState` manager that tracks all countries' current territories

```swift
// New: GlobalCountryState.swift
class GlobalCountryState {
    var countryTerritories: [String: Double] = [:]  // Country code -> current territory
    var countryGDP: [String: Double] = [:]          // Country code -> current GDP

    // Initialize with base values from Country data
    // Update when wars end with territory changes
}
```

### 1.3 Country GDP Initialization

**Existing GDP Data Source**: `EconomicData.worldGDPs` array contains GDP and population for countries.

**Current Coverage**: 20 countries have GDP data initialized in `EconomicData.defaultWorldGDPs()`:
- USA, China, Japan, Germany, India, UK, France, Brazil, Italy, Canada
- Russia, South Korea, Australia, Spain, Mexico, Indonesia, Netherlands, Saudi Arabia, Turkey, Switzerland

**Missing GDP Data** (20 countries need to be added):
- North Korea, Pakistan, Iran, Egypt, Vietnam, Myanmar, Thailand, Poland
- Israel, Syria, Iraq, Colombia, Venezuela, Cuba, Nigeria, Ethiopia
- South Africa, Algeria, Taiwan, Ukraine, Afghanistan, Belarus, Kazakhstan, Serbia, Libya

**Implementation**: Add GDP data for remaining 20 countries to `EconomicData.defaultWorldGDPs()` based on 2024 World Bank estimates.

---

## 2. Territory Changes from War

### 2.1 Dual Tracking System

**Total Territory**: Country's base + all conquered - all lost
**Conquered Territories List**: Tracked separately in `TerritoryManager` for rebellion/morale mechanics

### 2.2 Territory Transfer Logic

When war ends:
1. Calculate `territoryConquered` percentage (already in `War.swift`: 10-40% based on victory margin)
2. Deduct from loser's total territory: `loserTerritory -= (loserBaseTerritory * territoryConquered)`
3. Add to winner's total territory: `winnerTerritory += (loserBaseTerritory * territoryConquered)`
4. Create `Territory` object in `TerritoryManager` for conquered land (rebellion tracking)

### 2.3 Proportional Impact on Population and GDP

**Territory changes affect population and GDP non-linearly** based on war outcomes:

**Population Impact**:
- When territory is lost/gained, population changes proportionally to territory change
- Formula: `population_change_percent = territory_change_percent^0.7`
- Example: Lose 30% territory → Lose ~19.8% population

**GDP Impact**:
- GDP changes non-linearly with territory (see Section 3.1 for full formula)
- Conquered territories generate reduced GDP initially (30% → 90% over 4 years)
- Population loss indirectly reduces GDP (fewer workers, consumers)

**Example**:
```
War: USA vs Cuba (30% conquest)
Territory: Cuba loses 12,727 sq mi (30%)
Population: Cuba loses 19.8% population → ~2.2M people
GDP: Cuba loses ~19.8% GDP (if 30% territory lost)
USA gains: 12,727 sq mi, 2.2M people, but only 30% GDP contribution in Year 1
```

### 2.4 Territory Loss Priority

**Which territories are ceded?**:
- Territories owned by the **loser country** are ceded first
- If loser has conquered territories, those are returned to original owners
- If loser has no conquered territories, core territory is ceded
- **Active rebellions are a separate conflict** - not affected by peace terms

**Example**:
```
USA has:
- 3.8M sq mi core territory
- 450K sq mi conquered territories (Cuba, Libya)

USA loses war, must cede 20%:
1. First: Return conquered territories (450K sq mi)
2. If needed: Cede core territory to make up difference
```

### 2.5 Example Calculation
```
War: USA vs Cuba
- Cuba base territory: 42,426 sq mi
- USA wins with 30% conquest
- Territory transferred: 42,426 * 0.30 = 12,727 sq mi
- Population transferred: ~19.8% of Cuba's population (~2.2M)
- Cuba new total: 29,699 sq mi, 8.9M population
- USA new total: 3,800,000 + 12,727 = 3,812,727 sq mi
- Territory object created: "Cuba (Conquered)" - 12,727 sq mi, 2.2M pop, low morale, rebellion risk
```

---

## 3. GDP Impact from Territory Changes

### 3.1 Non-Linear GDP Calculation

**Formula**: `GDP_change = territory_change^0.7 * current_GDP`

This creates diminishing returns:
- Lose 10% territory → Lose ~6.3% GDP
- Lose 20% territory → Lose ~12.9% GDP
- Lose 30% territory → Lose ~19.8% GDP
- Lose 40% territory → Lose ~27.3% GDP

### 3.2 Conquered Territory GDP Generation

Newly conquered territories generate **reduced GDP initially**:
- **Year 1**: 30% of normal GDP contribution (instability, resistance)
- **Year 2**: 50% (pacification ongoing)
- **Year 3**: 70% (integration progressing)
- **Year 4+**: 90% (fully integrated if morale > 0.5)

If territory is annexed (requires morale ≥ 0.5), GDP contribution increases to 100%.

### 3.5 Conquered Territory GDP Aging Mechanics

**Annual GDP Improvement**: Conquered territories automatically improve their GDP contribution each year.

**Implementation**:
```swift
struct Territory {
    let conquestDate: Date
    var yearsSinceConquest: Int {
        Calendar.current.dateComponents([.year], from: conquestDate, to: Date()).year ?? 0
    }

    var gdpContributionMultiplier: Double {
        switch yearsSinceConquest {
        case 0: return 0.30  // Year 1
        case 1: return 0.50  // Year 2
        case 2: return 0.70  // Year 3
        case 3...: return morale >= 0.5 ? 0.90 : 0.70  // Year 4+
        default: return 0.30
        }
    }
}
```

**Annual Update Trigger**:
- Add `processAnnualTerritoryGrowth()` to `TerritoryManager`
- Call from `GameManager.processDaily()` when calendar year changes
- Recalculate GDP contribution for all conquered territories
- Notify player if any territories reach 90% integration

### 3.3 GDP Update Timing

**Immediate**: GDP recalculation happens when war ends and peace terms are set.
- No reconstruction delay - territory loss immediately impacts GDP
- Conquered territory GDP bonus applies immediately (at 30% rate)
- GDP updates propagate to budget calculations next fiscal cycle

### 3.4 Implementation Location

Update `EconomicDataManager.swift`:
```swift
func applyTerritoryGDPImpact(
    countryCode: String,
    territoryChangePercent: Double,
    isGain: Bool
) {
    let exponent = 0.7
    let gdpChangePercent = pow(abs(territoryChangePercent), exponent)

    if isGain {
        // New territory at 30% productivity
        gdp += currentGDP * gdpChangePercent * 0.30
    } else {
        // Lost territory reduces GDP
        gdp -= currentGDP * gdpChangePercent
    }
}
```

---

## 4. Monthly War Progress Popups

### 4.1 Popup Implementation

**Type**: SwiftUI Alert-style popups (`.alert()` modifier)
**Trigger**: Check on calendar month boundaries (1st of every month)

### 4.2 Monthly War Update Content

**Multiple Concurrent Wars**: If player is engaged in multiple wars (e.g., 3 wars), show **3 separate popups** sequentially.

**Popup Behavior**:
- Player must dismiss first popup before seeing second
- All popups for current month shown in sequence
- No stacking or combining of war updates

```
┌─────────────────────────────────────┐
│  WAR UPDATE: USA vs China (1 of 3)   │
│  Month 3 - March 2025                │
├─────────────────────────────────────┤
│                                      │
│  CASUALTIES                          │
│  USA: 12,450 killed                  │
│  China: 18,920 killed                │
│                                      │
│  WAR COSTS TO DATE                   │
│  USA: $45.2B                         │
│  China: $67.8B                       │
│                                      │
│  ATTRITION                           │
│  USA Forces: 8.4% depleted           │
│  China Forces: 14.2% depleted        │
│                                      │
│  STATUS: Stalemate                   │
│                                      │
│         [Dismiss]  [War Details]     │
└─────────────────────────────────────┘

[After dismissal, second popup appears]

┌─────────────────────────────────────┐
│  WAR UPDATE: USA vs Russia (2 of 3)  │
│  Month 1 - March 2025                │
├─────────────────────────────────────┤
│  ...                                 │
└─────────────────────────────────────┘
```

### 4.3 War Conclusion Popup

Appears when war ends with outcome.

**Player Victory**:
```
┌─────────────────────────────────────┐
│  WAR CONCLUDED: USA vs China         │
│  Victory - March 15, 2025            │
├─────────────────────────────────────┤
│                                      │
│  FINAL CASUALTIES                    │
│  USA: 45,230 killed                  │
│  China: 152,450 killed               │
│                                      │
│  TOTAL COST                          │
│  USA: $234.5B                        │
│  China: $412.8B                      │
│                                      │
│  TERRITORY                           │
│  Gained: 1.1M sq mi (30% of China)   │
│                                      │
│  ⚠️ Select Peace Terms               │
│                                      │
│    [Choose Terms]     [Dismiss]      │
└─────────────────────────────────────┘
```

**Player Defeat (Death)**:
```
┌─────────────────────────────────────┐
│  WAR LOST: USA vs China              │
│  Defeat - March 15, 2025             │
├─────────────────────────────────────┤
│                                      │
│  YOUR CHARACTER HAS DIED             │
│                                      │
│  You have been removed from office   │
│  due to the catastrophic war defeat. │
│                                      │
│  FINAL CASUALTIES                    │
│  USA: 245,230 killed                 │
│  China: 52,450 killed                │
│                                      │
│  TERRITORY LOST                      │
│  Lost: 1.5M sq mi (40% of USA)       │
│                                      │
│        GAME OVER                     │
│                                      │
│       [Return to Menu]               │
└─────────────────────────────────────┘
```

**Game Immediately Ends**: No option to continue, player returns to main menu.

### 4.4 Implementation Location

`GameManager.swift` - Add to `skipDay()` and `skipWeek()`:
```swift
func checkForMonthlyWarUpdate(character: Character) {
    let calendar = Calendar.current
    let currentMonth = calendar.component(.month, from: character.currentDate)

    if lastWarUpdateMonth != currentMonth {
        lastWarUpdateMonth = currentMonth

        for war in warEngine.activeWars {
            showWarProgressPopup(war: war)
        }
    }
}
```

New state: `@Published var activeWarUpdate: WarUpdate?` to trigger popup

---

## 5. Peace Terms & War Conclusions

### 5.1 Peace Term Options

When player wins:
1. **Full Conquest** (30-40% territory)
   - Reputation: -35
   - Territory: Maximum gain
   - Approval: -20

2. **Partial Territory** (15-25% territory)
   - Reputation: -15
   - Territory: Moderate gain
   - Approval: -8

3. **Reparations** (0% territory)
   - Reputation: -5
   - Territory: 0
   - Monetary: $50B - $500B (based on enemy GDP)
   - Approval: +5

4. **Status Quo Ante Bellum** (0% territory)
   - Reputation: +10 (merciful)
   - Territory: 0
   - Approval: +2

### 5.2 AI-Selected Peace Terms (Player Loses)

AI selection based on defeat margin:

| Victory Margin | AI Selection | Territory Lost | Reparations |
|----------------|--------------|----------------|-------------|
| Crushing (>60% attrition) | Full Conquest | 35-40% | $200B+ |
| Decisive (40-60%) | Partial Territory | 20-30% | $100B |
| Narrow (20-40%) | Limited | 10-15% | $50B |
| Pyrrhic (<20%) | Status Quo | 0% | $0 |

### 5.3 Status Quo Peace Terms

**Status Quo Ante Bellum** (Return to pre-war state):
- **Territory**: All territories return to pre-war ownership
- **No changes**: GDP, population, and territory are restored to pre-war levels
- **Casualties/Costs**: Both sides keep war casualties and costs incurred
- **Reputation Impact**: +10 for winner (merciful), -5 for loser (failed war)
- **Approval**: +2 for winner, -5 for loser

**When Selected**:
- Player wins and chooses Status Quo peace term
- AI selects if pyrrhic victory (attrition difference < 20%)
- Automatic stalemate after 365 days (neither side reaches 80% attrition)

**Implementation**:
```swift
func applyStatusQuoPeace(war: War) {
    // Restore all territory changes to pre-war state
    // Return conquered territories to original owners
    // No GDP changes applied
    // No population transfers
}
```

### 5.4 Stalemate Resolution (Automatic Status Quo)

If neither side reaches 80% attrition after 365 days:
- Automatic stalemate outcome
- Status quo peace terms applied (territories return to pre-war state)
- Both sides keep casualties/costs
- Small approval penalty for both (-5)

### 5.5 Reparations Integration with TreasuryManager

**Reparations** are monetary payments from loser to winner over time.

**Payment Schedule**:
- **Amount**: $50B - $500B based on loser's GDP (5-10% of annual GDP)
- **Duration**: Paid over 10 years
- **Frequency**: Annual deduction on fiscal year anniversary
- **Currency**: Deducted from loser's treasury, added to winner's treasury

**Implementation**:
```swift
struct ReparationAgreement: Codable, Identifiable {
    let id: UUID
    let payerCountry: String
    let recipientCountry: String
    let totalAmount: Decimal
    let yearlyPayment: Decimal
    let startDate: Date
    var yearsPaid: Int
    let totalYears: Int = 10

    var isComplete: Bool {
        yearsPaid >= totalYears
    }

    var remainingAmount: Decimal {
        totalAmount - (yearlyPayment * Decimal(yearsPaid))
    }
}
```

**TreasuryManager Integration**:
```swift
class TreasuryManager {
    @Published var activeReparations: [ReparationAgreement] = []

    func processAnnualReparations(currentDate: Date) {
        for i in 0..<activeReparations.count {
            var agreement = activeReparations[i]

            // Deduct from payer
            deductFunds(amount: agreement.yearlyPayment, reason: "War Reparations")

            // Add to recipient (if player)
            if agreement.recipientCountry == playerCountry {
                addRevenue(amount: agreement.yearlyPayment, category: .reparations)
            }

            // Increment years paid
            agreement.yearsPaid += 1

            // Remove if complete
            if agreement.isComplete {
                activeReparations.remove(at: i)
            } else {
                activeReparations[i] = agreement
            }
        }
    }
}
```

**Annual Trigger**: Called from `GameManager.processDaily()` when fiscal year changes (calendar year anniversary).

### 5.6 Implementation Location

New view: `PeaceTermsView.swift` - Appears as sheet when player wins war

```swift
struct PeaceTermsView: View {
    let war: War
    let defenderCountry: String

    var availableTerms: [PeaceTerm] {
        // Calculate based on war outcome
    }
}
```

---

## 6. Territory Display UI

### 6.1 New War Room Tab: "Territories"

Add to `WarRoomView.swift` tab selection:
```
[Overview] [Active Wars] [Territories] [Tech Research]
```

### 6.2 Territories View Layout

**Global Territory Rankings**

```
┌─────────────────────────────────────────────────┐
│  GLOBAL TERRITORY RANKINGS                       │
├─────────────────────────────────────────────────┤
│                                                  │
│  1. Russia        6.6M sq mi                     │
│  2. USA           4.25M sq mi (+ 450K)           │
│  3. China         3.7M sq mi                     │
│  4. Brazil        3.28M sq mi                    │
│  ...                                             │
│                                                  │
│  YOUR TERRITORIES                                │
│  ├─ Core:           3.80M sq mi                  │
│  └─ Conquered:      450K sq mi                   │
│                                                  │
│  Conquered Territories (3)                       │
│  ├─ Cuba (Conquered)      12.7K sq mi  ⚠️ High Risk │
│  ├─ Syria (Annexed)       45K sq mi    ✓ Stable  │
│  └─ Libya (Puppet)        180K sq mi   ⚠️ Unrest  │
│                                                  │
└─────────────────────────────────────────────────┘
```

### 6.3 Individual Territory Details

Tap on conquered territory to see:
- Size, population
- Morale status
- Rebellion risk
- Days since conquest
- GDP contribution
- Actions: [Invest] [Annex] [Grant Autonomy] [Grant Independence]

### 6.4 Implementation Files

Create new file: `TerritoriesOverviewView.swift`

---

## 7. Global Country State & AI Wars

### 7.1 Country State Tracking

Create `GlobalCountryState.swift`:

```swift
class GlobalCountryState: ObservableObject {
    @Published var countries: [CountryState] = []

    struct CountryState: Identifiable {
        let id: UUID
        let code: String
        let name: String
        var baseTerritory: Double
        var conqueredTerritory: Double
        var lostTerritory: Double
        var currentGDP: Double

        var totalTerritory: Double {
            baseTerritory + conqueredTerritory - lostTerritory
        }
    }

    // Initialize with all 40 countries from RivalCountry.allRivals
    func initializeCountries() { ... }

    // Apply war outcome to both attacker and defender
    func applyWarOutcome(war: War, outcome: WarOutcome, terms: PeaceTerm) { ... }
}
```

### 7.2 AI vs AI Wars

**Frequency**: Low probability check every month
- 2% chance per month that two AI countries declare war
- **No geographic restrictions** - any two countries can war
- **Neighbor preference**: Countries close to each other have 3x higher chance (6% vs 2%)
- Simulated in background (no detailed tracking, just outcome after 3-6 months)

**Neighbor/Rival Pairs** (higher war probability):
- Russia ↔ Ukraine, China ↔ Taiwan, India ↔ Pakistan
- Iran ↔ Israel, North Korea ↔ South Korea
- Saudi Arabia ↔ Iran, Turkey ↔ Syria
- Ethiopia ↔ Egypt, Algeria ↔ Libya

**Impact on Player**:
- Territory changes reflected in global rankings
- Can affect global GDP, trade, alliances (future feature)
- **Player is notified of ALL AI wars** via popup notification

**AI War Notification**:
```
┌─────────────────────────────────────┐
│  GLOBAL WAR ALERT                    │
│  March 2025                          │
├─────────────────────────────────────┤
│                                      │
│  China has declared war on Taiwan    │
│                                      │
│  Justification: Territorial Dispute  │
│  Chinese Forces: 2.0M                │
│  Taiwan Forces: 150K                 │
│                                      │
│  This war does not involve the USA.  │
│                                      │
│            [Acknowledge]             │
└─────────────────────────────────────┘
```

**Simulation**:
```swift
func simulateAIWar() {
    // Pick two countries (3x weight for neighbors/rivals)
    // Determine outcome based on strength difference
    // Apply territory changes (10-30% range)
    // Update GlobalCountryState (territory, population, GDP)
    // Notify player of war start with popup
    // Simulate 3-6 months, then notify war conclusion
}
```

### 7.3 AI War Frequency Control

Maximum simultaneous AI wars: 3 globally
Cooldown: Country can't declare war again for 12 months after war ends

### 7.4 AI Military Strength Evolution

**AI countries' military strength changes over time** based on:
- **GDP Growth**: +2% strength per year if GDP grows > 3%
- **GDP Decline**: -2% strength per year if GDP shrinks
- **Territory Gains**: +5% strength per 10% territory gained
- **Territory Losses**: -5% strength per 10% territory lost
- **Random Events**: ±1-3% strength variation annually

**Implementation**:
```swift
func updateAIMilitaryStrength(countryCode: String, yearsPassed: Int) {
    let country = globalCountryState.getCountry(code: countryCode)
    let gdpGrowth = (country.currentGDP - country.previousYearGDP) / country.previousYearGDP
    let territoryChange = (country.totalTerritory - country.baseTerritory) / country.baseTerritory

    var strengthChange = 1.0

    // GDP impact
    if gdpGrowth > 0.03 {
        strengthChange *= 1.02
    } else if gdpGrowth < 0 {
        strengthChange *= 0.98
    }

    // Territory impact
    strengthChange *= (1.0 + territoryChange * 0.5)

    // Random variation
    strengthChange *= Double.random(in: 0.97...1.03)

    country.militaryStrength = Int(Double(country.militaryStrength) * strengthChange)
}
```

**Annual Update Trigger**: Called from `GameManager.processAnnualUpdates()` for all AI countries.

---

## 8. Save/Load Integration

### 8.1 GlobalCountryState Persistence

**SaveManager Integration**: All territory and war data must be saved and loaded properly.

**Data to Persist**:
```swift
struct GameSaveData: Codable {
    // Existing data
    var character: Character
    var economicData: EconomicData
    var treasuryManager: TreasuryManager
    // ... other existing data

    // NEW: Territory system data
    var globalCountryState: GlobalCountryState
    var conqueredTerritories: [Territory]
    var activeReparations: [ReparationAgreement]
    var warReports: [WarReport]
    var aiWars: [War]  // Background AI vs AI wars
}
```

**SaveManager Modifications**:
```swift
class SaveManager {
    func saveGame(
        character: Character,
        economicData: EconomicData,
        treasuryManager: TreasuryManager,
        globalCountryState: GlobalCountryState,  // NEW
        conqueredTerritories: [Territory],       // NEW
        activeReparations: [ReparationAgreement], // NEW
        warReports: [WarReport],                 // NEW
        aiWars: [War]                            // NEW
    ) {
        let saveData = GameSaveData(...)
        // Encode and save to disk
    }

    func loadGame() -> GameSaveData? {
        // Load from disk and decode
        // Initialize GlobalCountryState if missing (for old saves)
    }
}
```

**Backwards Compatibility**:
- If loading old save without GlobalCountryState: Initialize with default values
- If loading old save without reparations: Initialize empty array
- Migrate existing character.country territory data to GlobalCountryState

### 8.2 Save Frequency

**Auto-save Triggers**:
- After war conclusion (territory changes applied)
- After peace terms selected
- After monthly war update
- After AI war conclusion
- Standard auto-save on day skip

---

## 9. Monthly Update Timing & War Reports

### 9.1 Calendar Month Boundaries

**Trigger**: Check on `skipDay()` if day of month == 1
**Tracking**: `lastWarUpdateMonth` in GameManager

```swift
func checkMonthlyUpdates(character: Character) {
    let calendar = Calendar.current
    let day = calendar.component(.day, from: character.currentDate)
    let month = calendar.component(.month, from: character.currentDate)

    if day == 1 && lastWarUpdateMonth != month {
        lastWarUpdateMonth = month
        generateMonthlyWarUpdates()
    }
}
```

### 9.2 Update Stacking Behavior

**Only show most recent**: If player skips multiple months, only show update for current month
- Previous months' data is recorded but not shown as popup
- Full history available in War Report view

### 9.3 War Report View

New section in War Room: "War Reports"

**Monthly Reports List**:
```
┌────────────────────────────────────┐
│  WAR REPORTS                        │
├────────────────────────────────────┤
│  March 2025 - Active Wars (2)       │
│  ├─ USA vs China (Month 3)          │
│  └─ USA vs Russia (Month 1)         │
│                                     │
│  February 2025 - Active Wars (1)    │
│  └─ USA vs China (Month 2)          │
│                                     │
│  January 2025 - Completed (1)       │
│  └─ USA vs Cuba - Victory ✓         │
│                                     │
└────────────────────────────────────┘
```

**Tap to view detailed monthly stats**

### 9.4 War Report Data Model

```swift
struct WarReport: Codable, Identifiable {
    let id: UUID
    let warId: UUID
    let month: Int
    let year: Int
    let date: Date

    // Snapshot data
    let usaCasualties: Int
    let enemyCasualties: Int
    let usaCosts: Decimal
    let enemyCosts: Decimal
    let usaAttrition: Double
    let enemyAttrition: Double
    let status: String  // "Winning", "Losing", "Stalemate"
}
```

Store in `WarEngine`: `@Published var warReports: [WarReport] = []`

---

## 10. Implementation Order

1. **Phase 1**: Territory Data & GDP Initialization
   - Add territory sizes to Country model
   - Create GlobalCountryState manager
   - Initialize all 40 countries with real territory
   - **Add missing GDP data for 20 countries** to EconomicData.defaultWorldGDPs()

2. **Phase 2**: Territory Transfer Logic
   - Update WarEngine.resolveWar() to transfer territory
   - Implement GlobalCountryState.applyWarOutcome()
   - Update TerritoryManager to create Territory objects
   - **Add territory loss priority logic** (conquered territories ceded first)
   - **Add proportional population/GDP impact** (non-linear formula)

3. **Phase 3**: GDP Integration & Aging
   - Implement non-linear GDP impact formula in EconomicDataManager
   - Add conquered territory GDP tracking (30% → 90% over time)
   - **Add annual territory aging mechanics** (processAnnualTerritoryGrowth)
   - Connect territory changes to budget/revenue updates

4. **Phase 4**: Monthly War Updates
   - Add monthly check to GameManager
   - Create WarUpdate popup model
   - Implement popup UI with war statistics
   - **Support multiple concurrent war popups** (3 separate popups for 3 wars)

5. **Phase 5**: Peace Terms & Reparations
   - Create PeaceTermsView with 4 options
   - Implement AI peace term selection logic
   - Add reputation/approval impacts
   - **Implement reparations integration with TreasuryManager** (yearly deductions)
   - **Add status quo peace term** (restore pre-war state)
   - **Add player death on war loss** (game over popup)

6. **Phase 6**: Territories UI Tab
   - Create TerritoriesOverviewView
   - Add global rankings display
   - Add conquered territories list with details
   - Implement territory management actions

7. **Phase 7**: War Reports
   - Create WarReport model
   - Add monthly snapshot generation
   - Create WarReportsView to browse history

8. **Phase 8**: AI Wars & Military Strength Evolution
   - Implement AI vs AI war logic
   - Add background war simulation
   - Update global territories automatically
   - **Add AI military strength evolution** (based on GDP/territory)
   - **Add neighbor war preference** (3x probability for rivals)
   - **Notify player of ALL AI wars** (popup notifications)

9. **Phase 9**: Save/Load Integration
   - **Add GlobalCountryState to SaveManager**
   - **Add reparations, war reports, AI wars to save data**
   - Implement backwards compatibility for old saves
   - Add auto-save triggers for territory changes

---

## 11. Files to Create/Modify

### New Files
- `GlobalCountryState.swift` - Track all countries' territories, GDP, and military strength
- `TerritoriesOverviewView.swift` - Main territories tab UI
- `PeaceTermsView.swift` - Peace negotiation interface
- `WarReportsView.swift` - Historical war report browser
- `WarUpdate.swift` - Monthly war update model
- `ReparationAgreement.swift` - Reparations payment tracking (or add to existing file)

### Modified Files
- `Country.swift` - Add territory data for all countries
- `RivalCountry` (in ActiveWarsView.swift) - Add territory property
- `WarEngine.swift` - Add territory transfer logic, war reports, AI war simulation
- `War.swift` - Add peace terms enum, status quo outcome
- `EconomicData.swift` - **Add GDP data for 20 missing countries**
- `EconomicDataManager.swift` - Add GDP impact from territory (non-linear formula)
- `GameManager.swift` - Add monthly war update checks, annual territory aging, AI military strength updates
- `TerritoryManager.swift` - Enhanced territory tracking, annual GDP improvement, reparations processing
- `TreasuryManager.swift` - **Add reparations payment processing**
- `WarRoomView.swift` - Add Territories tab
- `SaveManager.swift` - **Add GlobalCountryState, reparations, AI wars to save data**

---

## 12. Success Metrics

✅ All 40 countries have realistic territory data
✅ **All 40 countries have GDP data initialized** (added 20 missing countries)
✅ Territory transfers correctly on war conclusion
✅ **Territory/population/GDP change proportionally (non-linear)** on war outcomes
✅ **Conquered territories ceded first** when losing wars
✅ GDP updates non-linearly with territory changes
✅ **Conquered territory GDP improves annually** (30% → 90% over 4 years)
✅ Monthly popups appear on 1st of each month during active wars
✅ **Multiple concurrent wars show separate popups** (3 wars = 3 popups)
✅ Player can choose peace terms with reputation impacts
✅ **Reparations are deducted yearly from treasury** for 10 years
✅ **Status quo peace term restores pre-war state**
✅ **Player death on war loss triggers game over**
✅ Territories tab shows global rankings and player territories
✅ War reports archive all monthly war data
✅ AI wars occur in background with **neighbor preference**
✅ **AI military strength evolves** based on GDP/territory
✅ **Player notified of ALL AI wars** via popup
✅ **All territory data persists** via SaveManager integration
