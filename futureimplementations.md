# Future Implementations

This document outlines planned features and enhancements for PoliticianSim, organized by system and priority.

---

## 🎖️ Phase 8A: War System Enhancements (High Priority)

Building on the completed Phase 7 (AI Wars & War Archive), these features deepen the military conflict system.

### 1. War Alliances & Defensive Pacts
**Description**: Countries can form mutual defense agreements that trigger automatic war declarations when an ally is attacked.

**Implementation**:
- New `Alliance` model with member countries and formation date
- Alliance manager to track active pacts
- Automatic war declaration when ally attacked
- Alliance UI in Diplomacy view
- Reputation/approval impacts for forming/breaking alliances

**Gameplay Impact**: Creates realistic coalition dynamics and makes wars more complex and strategic.

---

### 2. Coalition Wars
**Description**: Multiple countries can jointly attack a single target or form defensive coalitions.

**Implementation**:
- Extend `War` model to support multiple attackers/defenders
- Combined military strength calculations
- Proportional casualty distribution
- Coalition peace terms (territory/reparations split)
- Coalition management UI

**Gameplay Impact**: Mirrors real-world conflicts like WWI/WWII dynamics.

---

### 3. War Exhaustion System
**Description**: Prolonged wars reduce public approval and economic output.

**Implementation**:
- War exhaustion score based on duration and casualties
- Weekly approval penalty during active wars
- GDP impact from war exhaustion (reduced productivity)
- "War fatigue" warnings at high exhaustion levels
- Peace pressure from public when exhaustion is critical

**Gameplay Impact**: Makes endless wars costly, encourages strategic peace negotiations.

---

### 4. War Economy Effects
**Description**: Active wars impact GDP, trade, and government budgets.

**Implementation**:
- GDP penalties during war (labor diverted to military)
- Increased military spending requirements
- Trade disruption with warring nations
- War bonds system (borrow from citizens)
- Post-war economic recovery period

**Gameplay Impact**: Wars have realistic economic consequences beyond just monetary cost.

---

### 5. Territory Rebellion System
**Description**: Conquered territories can revolt against occupiers, especially if culturally distinct or recently conquered.

**Implementation**:
- Rebellion probability based on:
  - Time since conquest (higher when recent)
  - Cultural/ethnic differences
  - Occupier's military strength
  - Economic conditions
- Rebellion events trigger mini-wars
- Suppression costs or independence outcomes
- Territory loyalty system

**Gameplay Impact**: Makes territorial conquest a long-term management challenge, not just a one-time gain.

---

### 6. Reparation Payment Processing
**Description**: Reparations are paid monthly/annually and show in treasury, affecting both payer and recipient economies.

**Implementation**:
- Monthly reparation payments deducted from payer
- Payments credited to recipient's treasury
- Payment tracking in TreasuryView
- Economic impact (GDP drag for payer, boost for recipient)
- Default mechanics if payer can't afford payments

**Gameplay Impact**: Creates ongoing economic relationships post-war.

---

### 7. AI Declares War on Player
**Description**: AI countries can target the player's nation for conquest.

**Implementation**:
- Remove player exclusion from `findSuitableTarget`
- Add player defense decision event
- Defensive war notifications
- Surrender option for player
- Loss conditions (territory loss, regime change)

**Gameplay Impact**: Makes player vulnerable to AI aggression, increases stakes.

---

## 🌍 Phase 8B: Economic Expansion (Medium Priority)

Deepening international economic systems.

### 1. Trade Wars & Tariff System
**Description**: Countries can impose tariffs on imports/exports, affecting trade relationships and GDP.

**Implementation**:
- Tariff rates per country pair
- GDP impact from reduced trade
- Retaliation mechanics
- Trade war escalation system
- Trade balance tracking

**Gameplay Impact**: Adds economic warfare as alternative to military conflict.

---

### 2. Economic Sanctions
**Description**: Diplomatic pressure through trade restrictions and asset freezes.

**Implementation**:
- Sanction types (trade embargo, asset freeze, travel ban)
- Economic impact on target (GDP penalty, budget reduction)
- International support/condemnation
- Sanction evasion mechanics
- Duration and removal conditions

**Gameplay Impact**: Non-military diplomatic tool with real consequences.

---

### 3. International Aid & Foreign Assistance
**Description**: Send financial/humanitarian aid to other countries, affecting relations and economics.

**Implementation**:
- Aid budget allocation
- Recipient relationship improvement
- Aid effectiveness based on governance
- International reputation bonus
- Emergency aid during disasters

**Gameplay Impact**: Soft power projection through economic generosity.

---

### 4. Currency Exchange & Forex
**Description**: Multi-currency system with exchange rates affecting international transactions.

**Implementation**:
- Currency strength based on GDP, debt, stability
- Exchange rate fluctuations
- Trade settlement in different currencies
- Currency reserves
- Inflation modeling

**Gameplay Impact**: Adds macroeconomic complexity and realism.

---

## 🤝 Phase 8C: Diplomacy Deep Dive (Medium Priority)

Expanding international relations beyond war.

### 1. Treaty System
**Description**: Formalized agreements with specific terms and expiration dates.

**Implementation**:
- Treaty types:
  - Trade agreements (tariff reductions)
  - Defense pacts (mutual protection)
  - Peace treaties (end wars formally)
  - Non-aggression pacts
  - Research cooperation
- Treaty negotiation UI
- Terms and conditions
- Breach consequences (reputation loss)
- Treaty renewal mechanics

**Gameplay Impact**: Creates binding diplomatic framework.

---

### 2. Espionage & Intelligence
**Description**: Covert operations to gather intelligence or sabotage rivals.

**Implementation**:
- Intelligence agency budget
- Spy recruitment and training
- Operations:
  - Gather intelligence (reveal military strength, plans)
  - Economic sabotage (damage GDP)
  - Political interference (reduce approval)
  - Steal technology (gain research progress)
- Success/failure probabilities
- Detection consequences (diplomatic incident)

**Gameplay Impact**: Adds covert dimension to international competition.

---

### 3. United Nations / International Bodies
**Description**: Global governance organization for conflict resolution and cooperation.

**Implementation**:
- UN membership and voting power
- Security Council mechanics
- Resolutions (sanctions, peacekeeping, humanitarian)
- Voting blocs and diplomacy
- Veto power for major nations
- Peacekeeping missions

**Gameplay Impact**: Multilateral diplomacy and global governance simulation.

---

### 4. Cultural Influence & Soft Power
**Description**: Spread cultural influence to improve relations and increase global standing.

**Implementation**:
- Cultural influence score per country
- Influence methods:
  - Media exports (movies, music)
  - Education exchanges (student visas)
  - Tourism
  - Language spread
- Influence effects:
  - Improved relations
  - Easier diplomacy
  - Trade benefits
  - Reduced rebellion in culturally similar territories

**Gameplay Impact**: Non-military path to global influence.

---

## 🏛️ Phase 8D: Domestic Political Expansion (High Priority)

Deepening internal political simulation.

### 1. Political Party System
**Description**: Multiple parties with ideologies, platforms, and internal politics.

**Implementation**:
- Party affiliation for player and NPCs
- Party platforms (policy preferences)
- Primary elections within party
- Party support affects approval
- Coalition building for legislation
- Party loyalty vs. personal popularity

**Gameplay Impact**: Adds factional politics and coalition-building challenges.

---

### 2. Media System & Press Relations
**Description**: News media reports on player actions, shaping public perception.

**Implementation**:
- Media outlets with political leanings
- News stories generated from player actions
- Press conferences and statements
- Media approval rating (separate from public)
- Scandal coverage
- Media manipulation (propaganda budget)

**Gameplay Impact**: Public perception shaped by media narrative, not just raw stats.

---

### 3. Scandals & Investigations
**Description**: Random or consequence-based scandals that threaten political career.

**Implementation**:
- Scandal types:
  - Financial (corruption, tax evasion)
  - Personal (affairs, misconduct)
  - Political (conflicts of interest)
  - Legal (criminal charges)
- Investigation mechanics
- Approval/reputation damage
- Resignation/impeachment risk
- Cover-up options (risky)
- Scandal recovery over time

**Gameplay Impact**: Adds risk and drama, consequences for poor decisions.

---

### 4. Cabinet Management
**Description**: Appoint and manage department heads with individual stats and loyalty.

**Implementation**:
- Cabinet positions (Secretary of State, Defense, Treasury, etc.)
- NPC cabinet members with attributes
- Appointment process (Senate confirmation if applicable)
- Cabinet meetings and advice
- Loyalty and competence affect outcomes
- Scandals can affect cabinet members
- Resignations and replacements

**Gameplay Impact**: Delegation mechanics and personnel management.

---

## 🎯 Quick Polish Items (Immediate)

Small enhancements to complete existing systems before starting Phase 8.

### 1. ✅ Reparation Payment Processing
**Status**: Partially implemented (agreements exist but no actual payments)

**Todo**:
- Add monthly payment processing in GameManager
- Deduct from payer's treasury
- Credit to recipient's treasury
- Show in TreasuryView as income/expense line item
- Handle payment defaults

---

### 2. ✅ Territory Rebellion System
**Status**: Territory model exists but no rebellion mechanics

**Todo**:
- Add rebellion probability calculation
- Monthly rebellion checks for occupied territories
- Rebellion event notifications
- Suppression costs or independence options
- Update territory ownership on successful rebellion

---

### 3. ✅ Player Defensive Wars
**Status**: AI currently excluded from attacking player

**Todo**:
- Allow player as target in `findSuitableTarget`
- Add defensive war notification
- Implement surrender option
- Define loss conditions for player
- Peace negotiation when player loses

---

### 4. ✅ War Exhaustion Display
**Status**: War exhaustion not calculated or displayed

**Todo**:
- Calculate exhaustion score (duration + casualties)
- Display exhaustion in ActiveWarsView
- Apply weekly approval penalties
- Add "War Fatigue" warnings
- Show public pressure for peace

---

## 📚 Documentation Items

### 1. Procedures.md
**Purpose**: Document repeatable implementation patterns for common tasks.

**Sections Needed**:
- Adding a new country
- Creating a new manager system
- Implementing a new view with navigation
- Adding a new stat/attribute
- Creating event types
- Policy implementation pattern
- Save/load integration checklist

---

### 2. Structure.md
**Purpose**: Complete file tree with descriptions.

**Todo**:
- List all files in Models/, ViewModels/, Views/
- Brief description of each file's purpose
- Architectural relationships
- Data flow diagrams
- Manager dependency map

---

## 🔮 Long-Term Vision (Phase 9+)

Ambitious features for future consideration.

### 1. Multiplayer / Competitive Mode
- Multiple players controlling different countries
- Real-time or turn-based
- Competitive rankings
- Diplomatic negotiations between real players

---

### 2. Historical Scenarios
- Start in specific historical periods (1950s, 1980s, etc.)
- Historical events and crises
- Country-specific campaigns
- Historical figures as characters

---

### 3. Climate Change Modeling
- Carbon emissions tracking
- Climate disasters (hurricanes, droughts, floods)
- Green energy transition mechanics
- International climate agreements
- Climate refugee crises

---

### 4. Pandemic Response System
- Disease outbreak mechanics
- Public health response options
- Economic impact from lockdowns
- Vaccine development
- International cooperation/competition

---

### 5. Supreme Court / Judicial Branch
- Court appointments
- Constitutional challenges to policies
- Judicial ideology affecting rulings
- Impeachment trials

---

### 6. Advanced Event System
- Branching event chains
- Multiple-choice consequences
- Character-specific events
- Dynamic event generation based on game state

---

### 7. More Playable Countries
- Expand beyond ~20 current countries
- Country-specific mechanics (parliamentary vs. presidential)
- Regional conflicts and alliances
- Different government types (democracy, autocracy, monarchy)

---

## 🎮 Gameplay Balance Considerations

As features are added, maintain balance through:

1. **Time Pressure**: More systems = more to manage
2. **Resource Constraints**: Limited budgets force prioritization
3. **Opportunity Costs**: Choosing one path closes others
4. **Risk/Reward**: High-reward actions should carry risk
5. **Difficulty Scaling**: Early game approachable, late game complex

---

## 📊 Implementation Priority Matrix

### High Priority (Phase 8A + 8D)
- War exhaustion system
- Political party system
- Reparation payments
- Territory rebellions
- Cabinet management
- Media system

### Medium Priority (Phase 8B + 8C)
- Trade wars
- Treaties
- Economic sanctions
- Espionage
- UN/International bodies

### Low Priority (Phase 9+)
- Multiplayer
- Historical scenarios
- Climate modeling
- Advanced events

---

## ✅ Completed Phases

### Phase 1-6: Core Systems ✓
- Character system with death mechanics
- Education system with loans
- Career progression
- Policy system (13 policies)
- Budget management
- Economic simulation with fiscal capital stock
- Government statistics
- Save/load system

### Phase 7: Military & War System ✓
- Military strength modeling
- War declarations and justifications
- War simulation with attrition
- Peace terms and outcomes
- Territory conquest system
- Reparation agreements
- **AI Wars** - Monthly AI war evaluation
- **War Archive** - Historical war records view
- **AI War Notifications** - Popup alerts for AI war conclusions
- **Military Strength Evolution** - Annual strength updates based on GDP

---

## 🚀 Next Recommended Steps

1. **Complete Quick Polish Items** (1-2 days)
   - Reparation payment processing
   - Territory rebellion mechanics
   - Player defensive wars
   - War exhaustion display

2. **Implement Phase 8A** (1 week)
   - War alliances & defensive pacts
   - War exhaustion system with approval impact
   - War economy effects

3. **Implement Phase 8D** (1 week)
   - Political party system
   - Media system
   - Scandal mechanics

4. **Documentation** (Ongoing)
   - Create procedures.md
   - Create structure.md
   - Update README.md with new features

---

*Last Updated: December 21, 2024*
*Current Phase: Completed Phase 7*
*Next Phase: Polish Items → Phase 8A (War Enhancements)*
