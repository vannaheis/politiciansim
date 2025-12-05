# Territories & War Progression Plan

## Overview
Implementation of realistic territory tracking, war progression updates, and GDP integration for the political simulation game.

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

### 2.3 Example Calculation
```
War: USA vs Cuba
- Cuba base territory: 42,426 sq mi
- USA wins with 30% conquest
- Territory transferred: 42,426 * 0.30 = 12,727 sq mi
- Cuba new total: 29,699 sq mi
- USA new total: 3,800,000 + 12,727 = 3,812,727 sq mi
- Territory object created: "Cuba (Conquered)" - 12,727 sq mi, low morale, rebellion risk
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

```
┌─────────────────────────────────────┐
│  WAR UPDATE: USA vs China           │
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
```

### 4.3 War Conclusion Popup

Appears when war ends with outcome:

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

### 5.3 Stalemate Resolution

If neither side reaches 80% attrition after 365 days:
- Automatic stalemate
- No territory changes
- Both sides keep casualties/costs
- Small approval penalty for both (-5)

### 5.4 Implementation Location

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
- 2% chance per month that two random AI countries declare war
- Restricted to countries with bordering territories or historical rivalries
- Simulated in background (no detailed tracking, just outcome after 3-6 months)

**Impact on Player**:
- Territory changes reflected in global rankings
- Can affect global GDP, trade, alliances (future feature)
- Player can see AI wars in "Global Conflicts" section

**Simulation**:
```swift
func simulateAIWar() {
    // Pick two rival countries
    // Determine outcome based on strength difference
    // Apply territory changes (10-30% range)
    // Update GlobalCountryState
    // Post notification to player if major power involved
}
```

### 7.3 AI War Frequency Control

Maximum simultaneous AI wars: 3 globally
Cooldown: Country can't declare war again for 12 months after war ends

---

## 8. Monthly Update Timing & War Reports

### 8.1 Calendar Month Boundaries

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

### 8.2 Update Stacking Behavior

**Only show most recent**: If player skips multiple months, only show update for current month
- Previous months' data is recorded but not shown as popup
- Full history available in War Report view

### 8.3 War Report View

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

### 8.4 War Report Data Model

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

## Implementation Order

1. **Phase 1**: Territory Data
   - Add territory sizes to Country model
   - Create GlobalCountryState manager
   - Initialize all 40 countries with real territory

2. **Phase 2**: Territory Transfer Logic
   - Update WarEngine.resolveWar() to transfer territory
   - Implement GlobalCountryState.applyWarOutcome()
   - Update TerritoryManager to create Territory objects

3. **Phase 3**: GDP Integration
   - Implement non-linear GDP impact formula in EconomicDataManager
   - Add conquered territory GDP tracking (30% → 90% over time)
   - Connect territory changes to budget/revenue updates

4. **Phase 4**: Monthly War Updates
   - Add monthly check to GameManager
   - Create WarUpdate popup model
   - Implement popup UI with war statistics

5. **Phase 5**: Peace Terms
   - Create PeaceTermsView with 4 options
   - Implement AI peace term selection logic
   - Add reputation/approval impacts

6. **Phase 6**: Territories UI Tab
   - Create TerritoriesOverviewView
   - Add global rankings display
   - Add conquered territories list with details
   - Implement territory management actions

7. **Phase 7**: War Reports
   - Create WarReport model
   - Add monthly snapshot generation
   - Create WarReportsView to browse history

8. **Phase 8**: AI Wars (Optional/Future)
   - Implement AI vs AI war logic
   - Add background war simulation
   - Update global territories automatically

---

## Files to Create/Modify

### New Files
- `GlobalCountryState.swift` - Track all countries' territories and GDP
- `TerritoriesOverviewView.swift` - Main territories tab UI
- `PeaceTermsView.swift` - Peace negotiation interface
- `WarReportsView.swift` - Historical war report browser
- `WarUpdate.swift` - Monthly war update model

### Modified Files
- `Country.swift` - Add territory data for all countries
- `RivalCountry` (in ActiveWarsView.swift) - Add territory property
- `WarEngine.swift` - Add territory transfer logic, war reports
- `War.swift` - Add peace terms enum
- `EconomicDataManager.swift` - Add GDP impact from territory
- `GameManager.swift` - Add monthly war update checks
- `TerritoryManager.swift` - Enhanced territory tracking
- `WarRoomView.swift` - Add Territories tab

---

## Success Metrics

✅ All 40 countries have realistic territory data
✅ Territory transfers correctly on war conclusion
✅ GDP updates non-linearly with territory changes
✅ Monthly popups appear on 1st of each month during active wars
✅ Player can choose peace terms with reputation impacts
✅ Territories tab shows global rankings and player territories
✅ War reports archive all monthly war data
✅ AI wars occasionally occur in background (optional)
