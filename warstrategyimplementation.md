# War Strategy Implementation Plan

## 🎯 Overview

Add dynamic war strategy management to active wars, allowing players to adapt their military tactics mid-conflict. Strategy changes take time to implement (transition period) and affect casualty rates, victory speed, war exhaustion, and effectiveness based on strength ratios.

---

## 📋 Design Decisions

### Core Mechanics
- ✅ Players can change strategy **at any time** (no cooldown or cost)
- ✅ Strategy changes have a **transition period** (takes time to mobilize)
- ✅ Transition duration: **30-90 days** depending on strategy complexity
- ✅ During transition, war uses **blended effects** of old and new strategies

### UI/UX
- ✅ Strategy selector appears in **WarDetailsView** (always visible)
- ✅ Shows current strategy with icon + name
- ✅ Tap to open strategy selector sheet
- ❌ No predicted outcomes (future enhancement)
- ❌ No real-time visual feedback indicators (future enhancement)

### AI Behavior
- ✅ AI opponents **can change strategies** during player wars
- ✅ **Notify player** when AI changes strategy
- ✅ AI strategy changes are **visible** (future: hidden until intel reveals)
- ❌ AI does **not** change strategies in AI vs AI wars (simplicity)

### Balance & Effects
- ✅ **Defensive strategy** has slower war exhaustion buildup
- ✅ **Defensive strategy** is more effective when outnumbered
- ✅ Strategy multipliers affect casualty rate, victory speed, and exhaustion
- ❌ No approval rating effects from strategy choice
- ❌ No peace term or post-war outcome effects from strategy

### Tutorial & Help
- ✅ Brief in-game description of each strategy when selecting
- ❌ No recommendation system (future enhancement)
- ❌ No notification system for strategy effectiveness (future enhancement)

### Future Enhancements (Out of Scope)
- War timeline showing historical strategy changes
- Predicted outcome calculator
- Real-time strategy effectiveness indicators
- Intel system to hide AI strategy changes
- Recommendation system based on war state
- Strategy effectiveness notifications
- Post-war outcomes based on strategy used

---

## 🎲 Strategy Balance Design

### Strategy Definitions

Each strategy has unique characteristics that affect multiple war metrics:

#### **Aggressive**
```swift
case aggressive = "Aggressive Assault"
```
**Philosophy**: All-out offensive, maximum pressure, quick victory or defeat

**Effects**:
- Attrition Multiplier: **1.5x** (50% more casualties)
- Speed Multiplier: **1.5x** (50% faster war resolution)
- Exhaustion Rate: **1.2x** (20% faster exhaustion)
- Strength Modifier: **+10%** when attacking, -5% when defending
- Best When: You have overwhelming force advantage (2:1 or better)

**Description**: "Maximum offensive pressure. High casualties but fastest path to victory. Most effective when you have superior forces."

---

#### **Balanced**
```swift
case balanced = "Balanced Warfare"
```
**Philosophy**: Standard military doctrine, no bonuses or penalties

**Effects**:
- Attrition Multiplier: **1.0x** (baseline)
- Speed Multiplier: **1.0x** (baseline)
- Exhaustion Rate: **1.0x** (baseline)
- Strength Modifier: **0%** (neutral)
- Best When: Forces are evenly matched, no clear advantage

**Description**: "Standard military doctrine with balanced offense and defense. Moderate casualties and steady progress."

---

#### **Defensive**
```swift
case defensive = "Defensive Posture"
```
**Philosophy**: Minimize casualties, hold ground, outlast the enemy

**Effects**:
- Attrition Multiplier: **0.6x** (40% fewer casualties)
- Speed Multiplier: **0.7x** (30% slower war resolution)
- Exhaustion Rate: **0.7x** (30% slower exhaustion - KEY BENEFIT)
- Strength Modifier: **+15% when outnumbered** (strength ratio < 0.8)
- Best When: You're outnumbered or facing a stronger enemy

**Description**: "Minimize casualties and hold defensive positions. Slower progress but much lower losses. Very effective when outnumbered."

---

#### **Attrition**
```swift
case attrition = "War of Attrition"
```
**Philosophy**: Grind down the enemy over time, exhaust their resources

**Effects**:
- Attrition Multiplier: **0.8x** (20% fewer casualties)
- Speed Multiplier: **0.9x** (10% slower war resolution)
- Exhaustion Rate: **0.9x** (10% slower exhaustion)
- Strength Modifier: **+10% against enemies with higher exhaustion** (enemy exhaustion > 0.5)
- Best When: You can afford a long war and want to minimize losses

**Description**: "Gradual pressure to wear down the enemy. Lower casualties and steady exhaustion of enemy forces over time."

---

### Strategy Effectiveness Matrix

| Strategy | vs Aggressive | vs Balanced | vs Defensive | vs Attrition |
|----------|---------------|-------------|--------------|--------------|
| **Aggressive** | High casualties both sides | Attacker advantage | Slow breakthrough | Medium advantage |
| **Balanced** | Defender advantage | Even match | Attacker advantage | Slight attacker edge |
| **Defensive** | Massive casualties for attacker | Defender advantage | Stalemate | Slight defender edge |
| **Attrition** | Attacker takes heavy losses | Even match | Slow grind | Very long war |

---

## 🔄 Strategy Transition System

### Transition Mechanics

When a player changes strategy, the war doesn't instantly switch. There's a **transition period** representing military reorganization, redeployment, and doctrinal changes.

#### Transition Duration by Strategy Change

| From → To | Duration (Days) | Rationale |
|-----------|----------------|-----------|
| Balanced → Aggressive | 30 days | Organizing offensive operations |
| Balanced → Defensive | 45 days | Building fortifications, repositioning |
| Balanced → Attrition | 30 days | Reorganizing for long-term operations |
| Aggressive → Balanced | 30 days | Regrouping and stabilizing lines |
| Aggressive → Defensive | 60 days | Major shift, building defenses |
| Aggressive → Attrition | 45 days | Transitioning from blitz to grinding |
| Defensive → Balanced | 30 days | Transitioning to active operations |
| Defensive → Aggressive | 90 days | Longest transition - total reorganization |
| Defensive → Attrition | 30 days | Minor adjustment |
| Attrition → Balanced | 30 days | Standard reorganization |
| Attrition → Aggressive | 60 days | Major shift to offensive |
| Attrition → Defensive | 45 days | Shifting to full defensive posture |

#### Transition Formula

```swift
func getTransitionDuration(from: WarStrategy, to: WarStrategy) -> Int {
    // Base transition time
    let baseTime = 30

    // Difficulty multipliers
    let fromDifficulty = from.transitionDifficulty
    let toDifficulty = to.transitionDifficulty

    // Aggressive ↔ Defensive is hardest (opposite ends of spectrum)
    if (from == .aggressive && to == .defensive) {
        return 90
    } else if (from == .defensive && to == .aggressive) {
        return 90
    }

    // Major shifts (2+ difficulty difference)
    let difficultyDelta = abs(fromDifficulty - toDifficulty)
    if difficultyDelta >= 2 {
        return baseTime + (difficultyDelta * 15)
    }

    // Standard transitions
    return baseTime
}

// Strategy difficulty ratings (for transition calculation)
extension WarStrategy {
    var transitionDifficulty: Int {
        switch self {
        case .aggressive: return 3  // Most complex
        case .balanced: return 1    // Baseline
        case .defensive: return 2   // Moderate
        case .attrition: return 2   // Moderate
        }
    }
}
```

#### Blended Effects During Transition

During the transition period, the war uses **weighted average** of old and new strategy effects:

```swift
// Progress through transition (0.0 = just started, 1.0 = complete)
let transitionProgress = Double(daysSinceTransition) / Double(totalTransitionDays)

// Blended attrition multiplier
let oldMultiplier = oldStrategy.attritionMultiplier
let newMultiplier = newStrategy.attritionMultiplier
let currentMultiplier = oldMultiplier * (1.0 - transitionProgress) + newMultiplier * transitionProgress

// Example: Aggressive (1.5x) → Defensive (0.6x), 50% through transition
// currentMultiplier = 1.5 * 0.5 + 0.6 * 0.5 = 0.75 + 0.3 = 1.05x
```

This creates smooth transitions and prevents exploiting instant strategy switches.

---

## 💻 Technical Implementation

### Phase 1: Data Model Updates

#### 1.1 Update War.swift

**Location**: `PoliticianSim/PoliticianSim/Models/War.swift`

Add transition tracking fields:

```swift
struct War: Codable, Identifiable {
    // ... existing fields ...

    var currentStrategy: WarStrategy

    // NEW: Strategy transition tracking
    var targetStrategy: WarStrategy?           // Strategy we're transitioning to
    var transitionStartDate: Date?             // When transition began
    var transitionDurationDays: Int?           // How long transition takes
    var strategyHistory: [StrategyChange] = [] // Historical strategy changes

    // ... rest of existing code ...
}

// NEW: Track historical strategy changes
struct StrategyChange: Codable {
    let id: UUID
    let date: Date
    let fromStrategy: War.WarStrategy
    let toStrategy: War.WarStrategy
    let dayOfWar: Int  // Which day of the war this change occurred

    init(date: Date, from: War.WarStrategy, to: War.WarStrategy, dayOfWar: Int) {
        self.id = UUID()
        self.date = date
        self.fromStrategy = from
        self.toStrategy = to
        self.dayOfWar = dayOfWar
    }
}
```

Add transition calculation methods:

```swift
extension War {
    /// Check if war is currently transitioning between strategies
    var isTransitioning: Bool {
        return targetStrategy != nil && transitionStartDate != nil
    }

    /// Get transition progress (0.0 to 1.0)
    func transitionProgress(currentDate: Date) -> Double {
        guard let startDate = transitionStartDate,
              let duration = transitionDurationDays else {
            return 1.0  // No transition, fully using current strategy
        }

        let daysPassed = Calendar.current.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
        return min(1.0, Double(daysPassed) / Double(duration))
    }

    /// Get the effective strategy multipliers (blended during transition)
    func effectiveStrategyMultipliers(currentDate: Date) -> (attrition: Double, speed: Double, exhaustion: Double) {
        if !isTransitioning {
            return (
                attrition: currentStrategy.attritionMultiplier,
                speed: currentStrategy.speedMultiplier,
                exhaustion: currentStrategy.exhaustionMultiplier
            )
        }

        guard let target = targetStrategy else {
            return (
                attrition: currentStrategy.attritionMultiplier,
                speed: currentStrategy.speedMultiplier,
                exhaustion: currentStrategy.exhaustionMultiplier
            )
        }

        let progress = transitionProgress(currentDate: currentDate)

        // Blend old and new strategy effects
        let oldAttrition = currentStrategy.attritionMultiplier
        let newAttrition = target.attritionMultiplier
        let blendedAttrition = oldAttrition * (1.0 - progress) + newAttrition * progress

        let oldSpeed = currentStrategy.speedMultiplier
        let newSpeed = target.speedMultiplier
        let blendedSpeed = oldSpeed * (1.0 - progress) + newSpeed * progress

        let oldExhaustion = currentStrategy.exhaustionMultiplier
        let newExhaustion = target.exhaustionMultiplier
        let blendedExhaustion = oldExhaustion * (1.0 - progress) + newExhaustion * progress

        return (attrition: blendedAttrition, speed: blendedSpeed, exhaustion: blendedExhaustion)
    }

    /// Finalize a strategy transition
    mutating func completeTransition() {
        guard let target = targetStrategy else { return }

        // Record the change in history
        if let startDate = transitionStartDate {
            let change = StrategyChange(
                date: startDate,
                from: currentStrategy,
                to: target,
                dayOfWar: daysSinceStart
            )
            strategyHistory.append(change)
        }

        // Apply new strategy
        currentStrategy = target

        // Clear transition state
        targetStrategy = nil
        transitionStartDate = nil
        transitionDurationDays = nil
    }
}
```

Update WarStrategy enum with new properties:

```swift
extension War.WarStrategy {
    var attritionMultiplier: Double {
        switch self {
        case .aggressive: return 1.5
        case .balanced: return 1.0
        case .defensive: return 0.6
        case .attrition: return 0.8
        }
    }

    var speedMultiplier: Double {
        switch self {
        case .aggressive: return 1.5
        case .balanced: return 1.0
        case .defensive: return 0.7
        case .attrition: return 0.9
        }
    }

    // NEW: Exhaustion rate multiplier
    var exhaustionMultiplier: Double {
        switch self {
        case .aggressive: return 1.2  // Faster exhaustion
        case .balanced: return 1.0    // Normal
        case .defensive: return 0.7   // Much slower exhaustion
        case .attrition: return 0.9   // Slightly slower
        }
    }

    // NEW: Strength modifier based on situation
    func strengthModifier(strengthRatio: Double, enemyExhaustion: Double) -> Double {
        switch self {
        case .aggressive:
            // +10% when attacking (you're the aggressor)
            return 1.1

        case .balanced:
            // No modifier
            return 1.0

        case .defensive:
            // +15% when outnumbered (ratio < 0.8)
            if strengthRatio < 0.8 {
                return 1.15
            }
            return 1.0

        case .attrition:
            // +10% when enemy is exhausted (> 0.5)
            if enemyExhaustion > 0.5 {
                return 1.1
            }
            return 1.0
        }
    }

    var description: String {
        switch self {
        case .aggressive:
            return "Maximum offensive pressure. High casualties but fastest path to victory. Most effective when you have superior forces."
        case .balanced:
            return "Standard military doctrine with balanced offense and defense. Moderate casualties and steady progress."
        case .defensive:
            return "Minimize casualties and hold defensive positions. Slower progress but much lower losses. Very effective when outnumbered."
        case .attrition:
            return "Gradual pressure to wear down the enemy. Lower casualties and steady exhaustion of enemy forces over time."
        }
    }

    // For transition duration calculation
    var transitionDifficulty: Int {
        switch self {
        case .aggressive: return 3
        case .balanced: return 1
        case .defensive: return 2
        case .attrition: return 2
        }
    }
}
```

#### 1.2 Update War Simulation Logic

**Location**: `PoliticianSim/PoliticianSim/Models/War.swift` - `simulateDay()` method

Update the daily simulation to use blended strategy effects:

```swift
mutating func simulateDay() {
    guard isActive else { return }

    daysSinceStart += 1

    // NEW: Check if transition is complete
    if isTransitioning {
        let progress = transitionProgress(currentDate: Date())
        if progress >= 1.0 {
            completeTransition()
        }
    }

    // Get effective strategy multipliers (blended if transitioning)
    let effectiveMultipliers = effectiveStrategyMultipliers(currentDate: Date())

    // Update war exhaustion with strategy-modified rate
    updateWarExhaustion(exhaustionMultiplier: effectiveMultipliers.exhaustion)

    // Safely calculate daily attrition with zero-strength protection
    guard attackerStrength > 0 && defenderStrength > 0 else {
        if attackerStrength <= 0 {
            resolveWar(outcome: .defenderVictory)
        } else {
            resolveWar(outcome: .attackerVictory)
        }
        return
    }

    // Calculate base strength ratio
    let baseStrengthRatio = Double(attackerStrength) / Double(defenderStrength)

    // Apply strategy modifiers
    let attackerStrategyMod = currentStrategy.strengthModifier(
        strengthRatio: baseStrengthRatio,
        enemyExhaustion: defenderAttrition
    )

    // Note: Defender uses balanced strategy for now (AI strategy coming later)
    let defenderStrategyMod = 1.0

    let adjustedAttackerStrength = Double(attackerStrength) * attackerStrategyMod
    let adjustedDefenderStrength = Double(defenderStrength) * defenderStrategyMod
    let adjustedRatio = adjustedAttackerStrength / adjustedDefenderStrength

    // Calculate daily attrition with strategy multipliers
    let baseAttrition = 0.001 // 0.1% per day baseline

    // Attacker takes more losses when weaker, less when stronger
    // Now modified by strategy
    let attackerDailyAttrition = baseAttrition * effectiveMultipliers.attrition * (2.0 - adjustedRatio)
    let defenderDailyAttrition = baseAttrition * 1.0 * adjustedRatio  // Defender uses balanced

    // ... rest of existing simulation code ...
}
```

Update war exhaustion calculation:

```swift
mutating func updateWarExhaustion(exhaustionMultiplier: Double = 1.0) {
    // Duration component
    let daysInYear: Double = 365.0
    let durationFactor = min(1.0, Double(daysSinceStart) / daysInYear)

    // Casualty component
    let attackerCasualties = Double(casualtiesByCountry[attacker] ?? 0)
    let defenderCasualties = Double(casualtiesByCountry[defender] ?? 0)
    let totalInitialStrength = Double(attackerStrength + defenderStrength)
    let totalCasualties = attackerCasualties + defenderCasualties
    let casualtyFactor = min(1.0, totalCasualties / (totalInitialStrength * 0.5))

    // Cost component
    let attackerCost = Double(truncating: (costByCountry[attacker] ?? 0) as NSNumber)
    let defenderCost = Double(truncating: (costByCountry[defender] ?? 0) as NSNumber)
    let totalCost = attackerCost + defenderCost
    let costFactor = min(1.0, totalCost / 500_000_000_000.0)

    // Apply strategy exhaustion multiplier
    let baseExhaustion = (durationFactor * 0.5) + (casualtyFactor * 0.35) + (costFactor * 0.15)
    warExhaustion = min(1.0, max(0.0, baseExhaustion * exhaustionMultiplier))
}
```

---

### Phase 2: WarEngine Integration

**Location**: `PoliticianSim/PoliticianSim/ViewModels/WarEngine.swift`

Add strategy change method:

```swift
func changeStrategy(
    warId: UUID,
    newStrategy: War.WarStrategy,
    currentDate: Date
) -> Bool {
    guard let index = activeWars.firstIndex(where: { $0.id == warId }) else {
        return false
    }

    let currentStrategy = activeWars[index].currentStrategy

    // Don't change if already using this strategy
    guard newStrategy != currentStrategy else {
        return false
    }

    // Don't change if already transitioning to this strategy
    if activeWars[index].targetStrategy == newStrategy {
        return false
    }

    // Calculate transition duration
    let transitionDays = getTransitionDuration(from: currentStrategy, to: newStrategy)

    // Start transition
    activeWars[index].targetStrategy = newStrategy
    activeWars[index].transitionStartDate = currentDate
    activeWars[index].transitionDurationDays = transitionDays

    print("🔄 Strategy change initiated: \(currentStrategy.rawValue) → \(newStrategy.rawValue)")
    print("   Transition will take \(transitionDays) days")

    return true
}

private func getTransitionDuration(from: War.WarStrategy, to: War.WarStrategy) -> Int {
    // Aggressive ↔ Defensive is hardest
    if (from == .aggressive && to == .defensive) || (from == .defensive && to == .aggressive) {
        return 90
    }

    // Major shifts based on difficulty
    let fromDiff = from.transitionDifficulty
    let toDiff = to.transitionDifficulty
    let delta = abs(fromDiff - toDiff)

    if delta >= 2 {
        return 30 + (delta * 15)
    }

    // Standard transition
    return 30
}
```

---

### Phase 3: UI Implementation

#### 3.1 Update WarDetailsView

**Location**: `PoliticianSim/PoliticianSim/Views/WarRoom/WarDetailsView.swift`

Add strategy section to the war details:

```swift
struct WarDetailsView: View {
    @EnvironmentObject var gameManager: GameManager
    let war: War
    @State private var showStrategySelector = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ... existing war info sections ...

                // NEW: Current Strategy Section
                CurrentStrategySection(
                    war: war,
                    onTapChangeStrategy: {
                        showStrategySelector = true
                    }
                )

                // ... rest of existing sections ...
            }
        }
        .sheet(isPresented: $showStrategySelector) {
            StrategySelectionSheet(war: war)
                .environmentObject(gameManager)
        }
    }
}
```

#### 3.2 Create CurrentStrategySection Component

```swift
struct CurrentStrategySection: View {
    let war: War
    let onTapChangeStrategy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CURRENT STRATEGY")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Constants.Colors.secondaryText)

            Button(action: onTapChangeStrategy) {
                HStack(spacing: 12) {
                    Image(systemName: war.currentStrategy.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Constants.Colors.buttonPrimary)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(war.currentStrategy.rawValue)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            if war.isTransitioning {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)

                                Text(war.targetStrategy?.rawValue ?? "")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                        }

                        if war.isTransitioning, let target = war.targetStrategy {
                            let progress = war.transitionProgress(currentDate: Date())
                            Text("Transitioning... \(Int(progress * 100))% complete")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        } else {
                            Text(war.currentStrategy.description)
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.secondaryText)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
                .padding(16)
                .background(Color(red: 0.15, green: 0.17, blue: 0.22))
                .cornerRadius(12)
            }

            // Transition progress bar (if transitioning)
            if war.isTransitioning {
                let progress = war.transitionProgress(currentDate: Date())
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Transition Progress")
                            .font(.system(size: 11))
                            .foregroundColor(Constants.Colors.secondaryText)

                        Spacer()

                        if let days = war.transitionDurationDays {
                            let daysRemaining = days - Int(Double(days) * progress)
                            Text("\(daysRemaining) days remaining")
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                        }
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                                .cornerRadius(3)

                            Rectangle()
                                .fill(.orange)
                                .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.17, blue: 0.22).opacity(0.5))
        .cornerRadius(12)
    }
}
```

#### 3.3 Create StrategySelectionSheet

```swift
struct StrategySelectionSheet: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    let war: War

    var body: some View {
        NavigationView {
            ZStack {
                StandardBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select War Strategy")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("Choose your military approach for this conflict")
                                .font(.system(size: 14))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Strategy options
                        ForEach([War.WarStrategy.aggressive, .balanced, .defensive, .attrition], id: \.self) { strategy in
                            StrategyOptionCard(
                                strategy: strategy,
                                isCurrentStrategy: strategy == war.currentStrategy,
                                isTargetStrategy: strategy == war.targetStrategy,
                                isTransitioning: war.isTransitioning,
                                onSelect: {
                                    selectStrategy(strategy)
                                }
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.buttonPrimary)
                }
            }
        }
    }

    private func selectStrategy(_ strategy: War.WarStrategy) {
        guard let character = gameManager.character else { return }

        let success = gameManager.warEngine.changeStrategy(
            warId: war.id,
            newStrategy: strategy,
            currentDate: character.currentDate
        )

        if success {
            dismiss()
        }
    }
}

struct StrategyOptionCard: View {
    let strategy: War.WarStrategy
    let isCurrentStrategy: Bool
    let isTargetStrategy: Bool
    let isTransitioning: Bool
    let onSelect: () -> Void

    var isDisabled: Bool {
        isCurrentStrategy || isTargetStrategy
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: strategy.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isCurrentStrategy ? Constants.Colors.buttonPrimary : .white)

                    Text(strategy.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    if isCurrentStrategy {
                        Text("ACTIVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.buttonPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Constants.Colors.buttonPrimary.opacity(0.2))
                            .cornerRadius(4)
                    } else if isTargetStrategy {
                        Text("TRANSITIONING")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                }

                Text(strategy.description)
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .lineLimit(3)

                // Strategy stats
                HStack(spacing: 16) {
                    StrategyStatPill(
                        icon: "person.2.slash",
                        label: "Casualties",
                        value: formatMultiplier(strategy.attritionMultiplier)
                    )

                    StrategyStatPill(
                        icon: "clock",
                        label: "Speed",
                        value: formatMultiplier(strategy.speedMultiplier)
                    )

                    StrategyStatPill(
                        icon: "battery.25",
                        label: "Exhaustion",
                        value: formatMultiplier(strategy.exhaustionMultiplier)
                    )
                }
            }
            .padding(16)
            .background(
                isCurrentStrategy
                    ? Constants.Colors.buttonPrimary.opacity(0.15)
                    : Color(red: 0.15, green: 0.17, blue: 0.22)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isCurrentStrategy ? Constants.Colors.buttonPrimary : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .disabled(isDisabled)
        .padding(.horizontal, 20)
    }

    private func formatMultiplier(_ value: Double) -> String {
        if value > 1.0 {
            return "+\(Int((value - 1.0) * 100))%"
        } else if value < 1.0 {
            return "\(Int((value - 1.0) * 100))%"
        } else {
            return "±0%"
        }
    }
}

struct StrategyStatPill: View {
    let icon: String
    let label: String
    let value: String

    var color: Color {
        if value.hasPrefix("+") {
            return Constants.Colors.negative
        } else if value.hasPrefix("-") {
            return Constants.Colors.positive
        } else {
            return Constants.Colors.secondaryText
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.secondaryText)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Constants.Colors.secondaryText)

            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(red: 0.2, green: 0.22, blue: 0.27))
        .cornerRadius(8)
    }
}
```

---

### Phase 4: AI Strategy Changes

#### 4.1 Add AI Strategy Change Logic

**Location**: `PoliticianSim/PoliticianSim/ViewModels/WarEngine.swift`

Add AI strategy evaluation (called during daily war simulation):

```swift
/// AI evaluates and potentially changes strategy based on war state
func evaluateAIStrategyChange(war: War, currentDate: Date) -> War.WarStrategy? {
    // Only for wars involving the player
    guard let playerCountry = GameManager.shared.character?.country else { return nil }
    guard war.attacker == playerCountry || war.defender == playerCountry else { return nil }

    // Don't change if already transitioning
    guard !war.isTransitioning else { return nil }

    // Check every 30 days
    guard war.daysSinceStart % 30 == 0 else { return nil }

    // Determine AI's side
    let isAIAttacker = war.attacker != playerCountry
    let aiStrength = isAIAttacker ? war.attackerStrength : war.defenderStrength
    let playerStrength = isAIAttacker ? war.defenderStrength : war.attackerStrength
    let strengthRatio = Double(aiStrength) / Double(max(1, playerStrength))

    let aiCasualties = war.casualtiesByCountry[isAIAttacker ? war.attacker : war.defender] ?? 0
    let initialStrength = isAIAttacker ? war.attackerStrength : war.defenderStrength
    let casualtyRate = Double(aiCasualties) / Double(max(1, initialStrength))

    let warExhaustion = war.warExhaustion

    // AI decision logic
    var newStrategy: War.WarStrategy?

    // If winning decisively (2:1 advantage), go aggressive
    if strengthRatio >= 2.0 && casualtyRate < 0.3 {
        newStrategy = .aggressive
    }
    // If losing badly (1:2 disadvantage), go defensive
    else if strengthRatio <= 0.5 {
        newStrategy = .defensive
    }
    // If high exhaustion or casualties, switch to attrition
    else if warExhaustion >= 0.6 || casualtyRate >= 0.4 {
        newStrategy = .attrition
    }
    // If evenly matched, use balanced
    else if strengthRatio >= 0.8 && strengthRatio <= 1.2 {
        newStrategy = .balanced
    }

    // Only change if different from current
    if let new = newStrategy, new != war.currentStrategy {
        return new
    }

    return nil
}
```

#### 4.2 Integrate AI Strategy Changes into War Simulation

Update `simulateDay()` in WarEngine:

```swift
func simulateDay() {
    for i in 0..<activeWars.count {
        activeWars[i].simulateDay()

        // Check if AI should change strategy
        if let newStrategy = evaluateAIStrategyChange(
            war: activeWars[i],
            currentDate: Date()
        ) {
            let success = changeStrategy(
                warId: activeWars[i].id,
                newStrategy: newStrategy,
                currentDate: Date()
            )

            if success {
                // Create notification for player
                notifyPlayerOfAIStrategyChange(war: activeWars[i], newStrategy: newStrategy)
            }
        }

        // Rest of war simulation...
    }
}
```

#### 4.3 Create AI Strategy Change Notification

**Location**: Create new file `PoliticianSim/PoliticianSim/Models/AIStrategyChangeNotification.swift`

```swift
import Foundation

struct AIStrategyChangeNotification: Identifiable {
    let id = UUID()
    let war: War
    let enemyCountryName: String
    let oldStrategy: War.WarStrategy
    let newStrategy: War.WarStrategy

    var title: String {
        "\(enemyCountryName) Changed Strategy"
    }

    var message: String {
        "Enemy forces have shifted from \(oldStrategy.rawValue) to \(newStrategy.rawValue)."
    }

    var icon: String {
        "arrow.triangle.2.circlepath"
    }
}
```

Add to GameManager:

```swift
@Published var pendingAIStrategyChangeNotifications: [AIStrategyChangeNotification] = []
```

---

## 📝 Implementation Checklist

### Phase 1: Data Models ✅
- [ ] Update `War.swift` with transition tracking fields
- [ ] Add `StrategyChange` struct for history
- [ ] Add `isTransitioning` computed property
- [ ] Add `transitionProgress()` method
- [ ] Add `effectiveStrategyMultipliers()` method
- [ ] Add `completeTransition()` method
- [ ] Add `exhaustionMultiplier` to WarStrategy enum
- [ ] Add `strengthModifier()` to WarStrategy enum
- [ ] Add `description` property to WarStrategy enum
- [ ] Add `transitionDifficulty` property to WarStrategy enum

### Phase 2: War Simulation ✅
- [ ] Update `War.simulateDay()` to use blended multipliers
- [ ] Update `War.updateWarExhaustion()` to accept exhaustion multiplier
- [ ] Add transition completion check in daily simulation
- [ ] Apply strategy strength modifiers to combat calculations

### Phase 3: WarEngine Integration ✅
- [ ] Add `changeStrategy()` method to WarEngine
- [ ] Add `getTransitionDuration()` helper method
- [ ] Test strategy changes in active wars

### Phase 4: UI Implementation ✅
- [ ] Create `CurrentStrategySection` component
- [ ] Add strategy section to WarDetailsView
- [ ] Create `StrategySelectionSheet` view
- [ ] Create `StrategyOptionCard` component
- [ ] Create `StrategyStatPill` component
- [ ] Add sheet presentation logic to WarDetailsView
- [ ] Test UI flow end-to-end

### Phase 5: AI Strategy Changes ✅
- [x] Add `evaluateAIStrategyChange()` to WarEngine
- [x] Integrate AI strategy evaluation into daily simulation
- [x] Create `AIStrategyChangeNotification` model
- [x] Create `AIStrategyChangeNotificationPopup` view
- [x] Add notification handling to GameManager
- [x] Add notification display to ContentView
- [ ] Test AI strategy changes with various war scenarios

### Phase 6: Testing & Polish ✅
- [ ] Test all strategy transitions (12 combinations)
- [ ] Verify blended multipliers work correctly
- [ ] Test transition completion
- [ ] Test AI strategy changes
- [ ] Test notification system
- [ ] Verify strategy history tracking
- [ ] Test with multiple simultaneous wars
- [ ] Balance check: verify strategies feel distinct

---

## 🎨 Visual Design Notes

### Color Coding
- **Aggressive**: Red/Orange (danger, high risk)
- **Balanced**: Blue (neutral, standard)
- **Defensive**: Green (safe, protective)
- **Attrition**: Purple (patient, grinding)

### Icons
```swift
extension War.WarStrategy {
    var icon: String {
        switch self {
        case .aggressive: return "bolt.fill"
        case .balanced: return "equal.circle.fill"
        case .defensive: return "shield.fill"
        case .attrition: return "clock.fill"
        }
    }
}
```

### Transition Indicator
When transitioning, show:
```
Current Strategy → Target Strategy
[Progress Bar] XX% complete
"Transitioning... 15 days remaining"
```

---

## 🧪 Testing Scenarios

### Manual Test Cases

1. **Basic Strategy Change**
   - Start a war with Balanced strategy
   - Change to Aggressive
   - Verify transition starts
   - Wait for transition to complete
   - Verify strategy is now Aggressive

2. **Transition Blending**
   - Change from Aggressive (1.5x attrition) to Defensive (0.6x)
   - Check casualties at 0%, 50%, 100% transition progress
   - Verify smooth interpolation

3. **AI Strategy Response**
   - Start a war with 2:1 strength advantage
   - Verify AI uses Balanced initially
   - Lose troops until 1:1 ratio
   - Verify AI switches to Defensive or Attrition

4. **Multiple Wars**
   - Have 2+ active wars
   - Change strategy in War #1
   - Verify War #2 is unaffected

5. **Exhaustion Rates**
   - Run 100-day war with Defensive strategy
   - Compare exhaustion to same war with Aggressive
   - Verify Defensive has 30% lower exhaustion

6. **Save/Load**
   - Start strategy transition
   - Save game at 50% progress
   - Load game
   - Verify transition continues correctly

---

## 🚀 Future Enhancements (Post-MVP)

These features are out of scope for the initial implementation but documented for future work:

### 1. War Timeline
- Visual timeline showing all strategy changes
- Event markers for key war moments
- Click to see detailed war history

### 2. Predicted Outcomes
- Calculator showing "if you switch to X, you'll likely..."
- Victory probability percentages
- Estimated casualties and duration

### 3. Real-time Indicators
- Live dashboard showing strategy effectiveness
- "Your aggressive strategy is working! +20% territory gain"
- Warnings when strategy isn't working well

### 4. Intelligence System
- Hide enemy strategy unless you have intel
- Spend resources to reveal enemy plans
- Counter-intelligence to hide your strategy

### 5. Recommendation Engine
- AI-powered suggestions: "Consider switching to Defensive"
- Context-aware tips based on war state
- Learning system that adapts to player style

### 6. Strategy Effectiveness Notifications
- Weekly reports on strategy performance
- Alerts when casualties are too high
- Suggestions when to negotiate peace

### 7. Post-War Analysis
- Strategy used affects peace terms
- Aggressive victories = more harsh terms
- Defensive victories = more merciful terms

### 8. Combined Arms Bonuses
- Tech level affects strategy effectiveness
- Air Superiority tech boosts Aggressive
- Logistics tech boosts Attrition

---

## 📚 References

- War.swift: Lines 73-104 (WarStrategy enum)
- WarEngine.swift: Lines 63-66 (changeStrategy stub)
- War.simulateDay(): Lines 316-372 (daily war simulation)
- WarDetailsView.swift: Main war detail UI

---

**Document Version**: 1.0
**Last Updated**: 2026-01-02
**Status**: Ready for Implementation
