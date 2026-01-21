# Military Recruitment System Implementation Plan

## Overview
This document outlines the implementation plan for adding a military recruitment and mobilization system to PoliticianSim. The system will allow players to recruit and demobilize military personnel based on their country's population, with various mobilization levels and economic/political consequences.

---

## Core Features

### 1. Population-Based Recruitment
- **Max Manpower Calculation**: `population × mobilizationLevel × recruitmentTypeMultiplier`
- **Country Population**: Use existing `Country.population` (e.g., USA: 330,000,000)
- **Initial Default**: Start at 0.3% mobilization (peacetime)

### 2. Mobilization Levels

| Level | % of Population | Approval Impact | Description |
|-------|----------------|-----------------|-------------|
| **Peacetime** | 0.3% | 0% | Normal volunteer force |
| **Raised Readiness** | 1.0% | -2% monthly | Increased recruitment |
| **Partial Mobilization** | 2.0% | -5% monthly | Significant buildup |
| **Full Mobilization** | 5.0% | -10% monthly | Wartime mobilization |
| **Total War** | 10.0% | -20% monthly | Complete national mobilization |

### 3. Recruitment Types (Existing)
- **Volunteer Force**:
  - Multiplier: 1.0x
  - Cost: $80,000/soldier/year
  - No approval penalty

- **Conscription**:
  - Multiplier: 2.5x (can recruit more from population)
  - Cost: $40,000/soldier/year
  - Approval Impact: -5% monthly

### 4. Recruitment Mechanics

#### Manual Recruitment
- **Input Field**: Enter number of soldiers to recruit
- **Instant Cost**: Upfront recruitment cost per soldier
  - Volunteer: $10,000/soldier (equipment, training, signing bonus)
  - Conscription: $5,000/soldier (equipment, basic training)
- **Training Time**: Optional delay before soldiers become active
  - Basic Training: 90 days (no combat effectiveness)
  - After Training: Full combat effectiveness
- **Treasury Deduction**: Costs pulled from military cash reserves

#### Demobilization
- **Discharge Soldiers**: Return soldiers to civilian life
- **Cost Savings**: Reduce ongoing personnel costs
- **Immediate Effect**: Reduces manpower and strength instantly
- **Severance Cost**: $5,000 per discharged volunteer (not conscripts)

### 5. Economic Integration

#### Daily Treasury Processing
Already implemented in `MilitaryTreasury.processDay()`:
```swift
personnelCosts = Decimal(manpower) * 200 // $200/day per soldier (~$73k/year)
```

#### Recruitment Costs (New)
- Deducted from `militaryStats.treasury.cashReserves`
- One-time upfront cost when recruiting
- Insufficient funds → show alert, prevent recruitment

---

## Implementation Phases

### Phase 1: Basic Recruitment UI ✅ PRIORITY
**Goal**: Add simple recruit/demobilize functionality to existing UI

**Files to Modify**:
1. `MilitaryOverviewView.swift`
   - Add "Recruit" and "Demobilize" buttons
   - Add input fields for soldier count
   - Show current manpower vs. max based on mobilization
   - Display recruitment costs

2. `MilitaryManager.swift`
   - Add `func recruit(militaryStats: inout MilitaryStats, soldiers: Int) -> Decimal`
   - Add `func demobilize(militaryStats: inout MilitaryStats, soldiers: Int)`
   - Add `func calculateMaxManpower(population: Int, mobilizationLevel: Double, recruitmentType: RecruitmentType) -> Int`

3. `MilitaryStats.swift`
   - Add `var mobilizationLevel: Double = 0.003` (0.3% default)
   - No other changes needed

**UI Components**:
- Current Manpower: `100,000 / 990,000` (formatted)
- Mobilization Level: `0.3% (Peacetime)`
- Input field for number of soldiers
- "Recruit X Soldiers" button → shows cost confirmation
- "Demobilize X Soldiers" button → shows confirmation
- Alerts for insufficient funds

### Phase 2: Mobilization Level System
**Goal**: Allow players to change mobilization levels with political consequences

**Files to Modify**:
1. Create `MobilizationLevel.swift`
   - Enum with cases: `.peacetime`, `.raisedReadiness`, `.partialMobilization`, `.fullMobilization`, `.totalWar`
   - Properties: `percentage`, `approvalImpact`, `displayName`, `description`

2. `MilitaryStats.swift`
   - Replace `mobilizationLevel: Double` with `mobilizationLevel: MobilizationLevel`

3. Create `MobilizationView.swift` (new view)
   - Display all mobilization levels as cards
   - Show current level highlighted
   - Button to change level with confirmation
   - Warning about approval impacts
   - Show new max manpower after change

4. `MilitaryManager.swift`
   - Add `func changeMobilizationLevel(militaryStats: inout MilitaryStats, to: MobilizationLevel)`
   - Apply approval penalty in daily processing

5. `WarRoomView.swift`
   - Add navigation link to MobilizationView

**Daily Processing**:
- Apply mobilization approval penalty monthly
- Auto-demobilize if exceeding new max after lowering mobilization

### Phase 3: Training & Readiness (Optional Enhancement)
**Goal**: Add realism with training delays and readiness levels

**New Concepts**:
- **Recruits**: Soldiers in training (don't count toward strength)
- **Active Duty**: Fully trained soldiers (count toward strength)
- **Training Duration**: 90 days default
- **Training Costs**: Included in recruitment cost

**Files to Modify**:
1. `MilitaryStats.swift`
   - Add `var recruitsInTraining: Int = 0`
   - Separate `manpower` (active) from total (active + training)

2. Create `TrainingQueue.swift`
   - Track cohorts of recruits with completion dates
   - Advance training on daily processing

3. `MilitaryManager.swift`
   - Modify recruitment to add to training queue
   - Process training completion in daily update
   - Only count active soldiers in strength calculation

4. `MilitaryOverviewView.swift`
   - Show "Active: X | In Training: Y | Total: Z"

---

## UI/UX Design

### Recruitment Flow
1. User opens Military Overview
2. Sees current manpower vs max
3. Enters soldier count in input field
4. Taps "Recruit Soldiers"
5. Alert shows:
   ```
   Recruit 50,000 soldiers?

   Upfront Cost: $500M
   Annual Personnel Cost: +$4.0B
   Training Time: 90 days

   Military Cash Reserves: $45.2B
   ```
6. User confirms → funds deducted, manpower increases

### Demobilization Flow
1. User enters soldier count
2. Taps "Demobilize"
3. Alert shows:
   ```
   Discharge 20,000 soldiers?

   Severance Cost: $100M
   Annual Savings: $1.6B

   This will reduce military strength.
   ```
4. User confirms → manpower decreases

### Mobilization Flow (Phase 2)
1. User navigates to Mobilization view
2. Sees cards for each mobilization level
3. Current level highlighted in green
4. Taps "Partial Mobilization"
5. Alert shows:
   ```
   Change to Partial Mobilization?

   New Max Manpower: 6,600,000
   Approval Impact: -5% per month

   This is a significant escalation.
   Are you sure?
   ```
6. User confirms → level changes, max manpower updated

---

## Data Flow

### Recruitment Process
```
User Input (soldier count)
    ↓
MilitaryManager.recruit()
    ↓
Calculate cost (upfront + severance if replacing)
    ↓
Check treasury.cashReserves >= cost
    ↓
If YES:
    - Deduct from cashReserves
    - Increase manpower
    - Recalculate strength
    - Update character
If NO:
    - Show insufficient funds alert
```

### Daily Processing Integration
```
GameManager.advanceDay()
    ↓
MilitaryTreasury.processDay()
    ↓
Calculate personnelCosts (manpower × $200/day)
    ↓
Deduct from cashReserves
    ↓
Apply mobilization approval penalty (monthly)
```

---

## Edge Cases & Constraints

### 1. Maximum Recruitment Limits
- **Hard Cap**: Cannot exceed `maxManpower` calculated from mobilization level
- **Alert**: "Cannot recruit more than X soldiers at current mobilization level (Y%)"
- **Suggestion**: "Increase mobilization level to recruit more"

### 2. Insufficient Funds
- **Check Before Recruiting**: `treasury.cashReserves >= totalCost`
- **Alert**: "Insufficient military funds. Need $X, have $Y"
- **Option**: Link to budget adjustment or wait for daily revenue

### 3. Demobilization Below Current Wars
- **Check Active Wars**: If in active war, warn before demobilizing below safe threshold
- **Alert**: "Warning: Demobilizing during active war may weaken your position"
- **Minimum**: Don't allow demobilizing to 0 if in war

### 4. Mobilization Level Changes
- **Downgrade**: If lowering mobilization, auto-demobilize excess soldiers
  - Alert: "Lowering mobilization will discharge X soldiers exceeding new limit"
- **Upgrade**: Allow recruiting up to new limit immediately
- **Approval Cascade**: Changing multiple levels quickly compounds approval loss

### 5. Recruitment Type Changes
- **Volunteer → Conscription**:
  - Immediately increases max manpower (2.5x multiplier)
  - Reduces personnel costs
  - Applies -5% monthly approval penalty
- **Conscription → Volunteer**:
  - May exceed new max (need to demobilize)
  - Increases personnel costs
  - Removes conscription penalty

---

## Testing Checklist

### Phase 1 Testing
- [ ] Recruit soldiers with sufficient funds
- [ ] Recruitment blocked when exceeding mobilization limit
- [ ] Recruitment blocked with insufficient funds
- [ ] Demobilization reduces manpower and costs
- [ ] Military strength recalculated correctly after recruitment
- [ ] Treasury deducted correctly
- [ ] Manpower persists after save/load
- [ ] Game reset properly reinitializes recruitment values

### Phase 2 Testing
- [ ] Mobilization level changes apply new limits
- [ ] Approval penalties applied monthly
- [ ] Auto-demobilization when lowering mobilization
- [ ] Multiple mobilization changes compound approval loss
- [ ] Mobilization level persists after save/load

### Phase 3 Testing (if implemented)
- [ ] Recruits enter training queue
- [ ] Training completes after 90 days
- [ ] Strength only counts active soldiers
- [ ] Training UI displays correctly

---

## Implementation Decisions (FINALIZED)

### 1. **Implementation Scope**
✅ Full system with Phases 1-3 (recruitment + mobilization + training)

### 2. **Training System**
✅ 90-day training delay implemented - recruits enter training queue, become active after 90 days

### 3. **Mobilization Restrictions**
✅ No peacetime restrictions - players can freely mobilize at any level

### 4. **Economic Balance**
✅ Costs confirmed:
  - Upfront: $10k volunteer, $5k conscript
  - Annual: $80k volunteer, $40k conscript (already implemented in daily processing)

### 5. **UI Location**
✅ Separate `RecruitmentView` accessible via button in MilitaryOverviewView

### 6. **Approval Impact**
✅ Changed from monthly to yearly penalties (divided by 12):
  - Mobilization penalties: -5% yearly (not monthly)
  - Conscription: -5% yearly
  - Example: Total War + Conscription = -25% approval per year

### 7. **Population Access**
✅ Use `Character.country` (string code) to lookup `Country.population`

### 8. **Demobilization Restrictions**
✅ No minimum manpower requirement - can demobilize to 0

---

## Next Steps

1. **User Review**: Address open questions above
2. **Phase 1 Implementation**:
   - Modify `MilitaryManager.swift` with recruit/demobilize functions
   - Update `MilitaryOverviewView.swift` with recruitment UI
   - Add alerts and validation
3. **Testing**: Verify all Phase 1 checklist items
4. **Phase 2 (Optional)**: Implement mobilization level system if desired
5. **Documentation**: Update procedures.md and structure.md with new recruitment system

---

## Related Files

- `MilitaryManager.swift` - Core recruitment logic
- `MilitaryStats.swift` - Data model for military state
- `MilitaryOverviewView.swift` - UI for military management
- `MilitaryTreasury` - Economic integration
- `Country.swift` - Population data source
- `GameManager.swift` - Daily processing integration
- `CharacterManager.swift` - State persistence

---

**Document Status**: Draft - Awaiting user feedback on open questions
**Last Updated**: 2026-01-20
**Author**: Claude Code Assistant
