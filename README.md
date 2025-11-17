# PoliticianSim

A comprehensive political life simulation game built with SwiftUI where players navigate the complexities of a political career, from education through various government positions up to presidency.

## 🎮 Game Overview

PoliticianSim is a deep simulation game that models political life, economic systems, and government management. Players start by creating a character, pursuing education, building a career, and managing complex systems including budgets, policies, elections, and international relations.

### Core Gameplay Loop

1. **Character Creation** - Customize your politician with unique attributes
2. **Education** - Pursue degrees to unlock career opportunities
3. **Career Progression** - Climb the political ladder from local to federal positions
4. **Policy Making** - Enact policies that impact GDP, government performance, and public opinion
5. **Budget Management** - Allocate funds across government departments
6. **Campaign & Elections** - Build support and win elections
7. **Economic Management** - Navigate fiscal policy, GDP growth, and debt
8. **Survival** - Maintain health and manage stress to avoid game over

## ✨ Key Features

### Character System
- **Attributes**: Charisma, Intelligence, Reputation, Luck, Diplomacy, Health, Stress
- **Dynamic Aging**: Character ages in real-time with health consequences
- **Death System**: Game over from old age (≥90), health failure, or stress
- **Warnings**: Critical alerts when health ≤30 or stress ≥80

### Education System
- **Multiple Degrees**: High School, Bachelor's, Master's, Ph.D., Law Degree, MBA
- **Student Loans**: Realistic debt system with interest rates
- **Weekly Progression**: Degrees take realistic time to complete
- **Requirements**: Position advancement tied to educational achievements

### Career & Positions
- **Progressive Ladder**: Student → Local Official → State Rep → Governor → Senator → President
- **Position Requirements**: Education and experience thresholds
- **Salary System**: Income increases with position level
- **Approval Ratings**: Public opinion affects career advancement

### Policy System (13 Policies)
Policies have realistic economic impacts modeled on real-world effects:

#### Economy
- **Small Business Tax Relief** - $5B cost, +0.3% GDP growth
- **Raise Minimum Wage** - -0.2% GDP short-term, +10 welfare score

#### Healthcare
- **Universal Healthcare** - $200B annual cost, +0.5% GDP (healthier workforce), +25 healthcare score
- **Mental Health Initiative** - $15B cost, +0.2% GDP (productivity), +12 healthcare score

#### Education
- **Free Community College** - $60B cost, +0.8% GDP (skilled workforce), +18 education score
- **Teacher Salary Increase** - $25B cost, +0.4% GDP, +15 education score

#### Environment
- **Green Energy Initiative** - $100B investment, +0.6% GDP (new jobs), +10 infrastructure, +8 science
- **Carbon Tax** - $80B revenue, -0.3% GDP (business costs)

#### Infrastructure
- **Public Transit Expansion** - $75B investment, +0.7% GDP (reduced congestion), +20 infrastructure
- **Affordable Housing** - $120B investment, +0.4% GDP, +15 infrastructure, +12 welfare

#### Social Welfare
- **Universal Basic Income** - $150B cost, +0.3% GDP (consumer spending), +20 welfare
- **Child Care Subsidy** - $40B cost, +0.5% GDP (more workers), +15 welfare

#### Justice
- **Criminal Justice Reform** - $20B cost, +0.2% GDP (workforce), +12 justice
- **Police Accountability Act** - $10B cost, +0.1% GDP (reduced unrest), +10 justice

#### Taxation
- **Progressive Tax Reform** - $120B revenue, +0.1% GDP (middle class spending)

### Budget System
**10 Government Departments** with per-capita spending targets:
- Education ($2,000/person = 100 score)
- Healthcare ($2,500/person = 100 score)
- Public Safety ($800/person = 100 score)
- Infrastructure ($1,000/person = 100 score)
- Social Welfare ($1,500/person = 100 score)
- Environment ($300/person = 100 score)
- Justice ($400/person = 100 score)
- Science & Research ($500/person = 100 score)
- Arts & Culture ($200/person = 100 score)
- Administration ($300/person = 100 score)

**Scoring System**:
- Uses sigmoid curve to prevent linear scaling with GDP
- Rich nations operating on surplus not penalized
- Score = 100 × (spending / (spending + threshold))
- Overall score affects approval rating

### Economic Simulation

#### Fiscal Capital Stock System
Government spending builds capital that persists and depreciates over time:

**Time Lags**:
- Medium-term (1-2 years): Infrastructure, Healthcare
- Long-term (3-5 years): Education, Science & Research

**Depreciation Rates** (annual):
- Infrastructure: 10%
- Education: 5%
- Science: 8%
- Healthcare: 12%

**Flow Effects** (with decay):
- Tax Effects: 50% decay/year
- Crowding Out: 20% decay/year (large deficits reduce private investment)
- Debt Drag: 5% decay/year

**GDP Impact Calculation**:
```
GDP Impact =
  + Capital Stock Effects (infrastructure, education, science, healthcare)
  + Tax Policy Effects (with decay)
  - Crowding Out Effects (deficit > 3% GDP)
  - Debt Drag (debt-to-GDP > 60%)
```

#### Economic Data Tracking
- **Real-time GDP**: Updated weekly with historical chart (10 years of data)
- **Debt-to-GDP Ratio**: Sustainability thresholds at 60% and 90%
- **Deficit Tracking**: Annual deficit calculations
- **Federal Budget**: Revenue and expenditure modeling

### Elections & Campaigns
- **Campaign System**: Fundraising and public outreach
- **Election Cycles**: Regular elections for positions
- **Public Opinion**: Affected by policies, performance, and events
- **Approval Ratings**: Dynamic feedback on leadership

### Diplomacy & International Relations
- **Diplomatic Actions**: Build relationships with other nations
- **International Events**: Global events requiring responses
- **Trade Agreements**: Economic impacts from international deals

### Laws System
- **Legislation**: Propose and pass laws
- **Legal Framework**: Build governing structures
- **Constitutional Changes**: Major reforms requiring high thresholds

### Event System
- **Random Events**: Dynamic situations requiring decisions
- **Multiple Choices**: Branching outcomes affecting stats
- **Event Dialog**: Immersive decision-making interface

### Government Statistics
- **Performance Tracking**: Monitor department effectiveness
- **Score Labels**: Excellent (≥80), Good (≥60), Fair (≥40), Poor (≥20), Critical (<20)
- **Approval Impact**:
  - Excellent: +2.0 approval/week
  - Good: +1.0 approval/week
  - Fair: 0.0 (neutral)
  - Poor: -1.0 approval/week
  - Critical: -3.0 approval/week

### Save/Load System
- **Automatic Saving**: Game state persisted automatically
- **Full State Preservation**: All managers, data, and progress saved
- **Continue Game**: Resume from last save on app launch

## 🏗️ Architecture

### Design Pattern
**MVVM (Model-View-ViewModel)** with manager-based coordination

### Core Structure
```
PoliticianSim/
├── App/
│   ├── PoliticianSimApp.swift        # App entry point
│   └── ContentView.swift             # Root view with game over overlay
│
├── Models/
│   ├── Character.swift               # Player character data
│   ├── Education.swift               # Degree and loan models
│   ├── Policy.swift                  # 13 policy templates
│   ├── Budget.swift                  # Department budgets
│   ├── EconomicData.swift            # GDP, debt, federal budget
│   ├── FiscalCapitalStock.swift      # Capital stock with time lags
│   ├── GovernmentStats.swift         # Department performance scores
│   ├── GameState.swift               # Game state & game over data
│   ├── Country.swift                 # Nation data
│   ├── Campaign.swift                # Campaign activities
│   ├── Diplomacy.swift               # International relations
│   ├── Law.swift                     # Legislative system
│   ├── PublicOpinion.swift           # Opinion polling
│   ├── Event.swift                   # Dynamic events
│   └── SaveGame.swift                # Serialization model
│
├── ViewModels/
│   ├── GameManager.swift             # Main coordinator (singleton)
│   ├── CharacterManager.swift        # Character lifecycle & death
│   ├── EducationManager.swift        # Enrollment, loans, degrees
│   ├── PolicyManager.swift           # Policy proposal & enactment
│   ├── BudgetManager.swift           # Budget allocation & balancing
│   ├── EconomicDataManager.swift     # Economic simulation & capital stock
│   ├── GovernmentStatsManager.swift  # Department scoring
│   ├── ElectionManager.swift         # Election cycles
│   ├── DiplomacyManager.swift        # International relations
│   ├── LawsManager.swift             # Legislative system
│   ├── PublicOpinionManager.swift    # Opinion tracking
│   ├── EventEngine.swift             # Event generation
│   ├── TimeManager.swift             # Game time progression
│   ├── SaveManager.swift             # Save/load operations
│   ├── NavigationManager.swift       # UI navigation state
│   └── FiscalImpactCalculator.swift  # Capital stock calculations
│
└── Views/
    ├── CharacterCreation/            # Onboarding flow
    │   ├── CountrySelectionView.swift
    │   ├── CharacterDetailsView.swift
    │   ├── AttributeGenerationView.swift
    │   └── CharacterSummaryView.swift
    │
    ├── Home/
    │   └── NewHomeView.swift         # Main dashboard with stats
    │
    ├── Education/
    │   ├── EducationView.swift       # Current enrollment & loans
    │   └── EnrollmentSheet.swift     # Degree selection
    │
    ├── Career/
    │   └── PositionView.swift        # Position advancement
    │
    ├── Policies/
    │   └── PoliciesView.swift        # Policy browser & enactment
    │
    ├── Budget/
    │   └── BudgetView.swift          # Department allocation
    │
    ├── GovernmentStats/
    │   └── GovernmentStatsView.swift # Performance dashboard
    │
    ├── Economy/
    │   ├── EconomicDataView.swift    # GDP, debt, deficit
    │   └── IndicatorDetailView.swift # Economic charts
    │
    ├── Elections/
    │   └── ElectionsView.swift       # Campaign & voting
    │
    ├── Campaign/
    │   └── CampaignView.swift        # Fundraising & outreach
    │
    ├── Diplomacy/
    │   └── DiplomacyView.swift       # International relations
    │
    ├── Laws/
    │   └── LawsView.swift            # Legislative system
    │
    ├── PublicOpinion/
    │   └── PublicOpinionView.swift   # Opinion polls
    │
    ├── GameOverView.swift            # Death screen with restart
    │
    └── Components/                   # Reusable UI components
        ├── StandardBackgroundView.swift
        ├── SideMenuView.swift
        ├── EventDialog.swift
        ├── CustomAlert.swift
        └── LineChartView.swift
```

## 🎯 Game Systems Deep Dive

### Character Death System
**Death Causes**:
1. **Old Age**: Character reaches age 90
2. **Health Failure**: Health drops to 0 (stress < 80)
3. **Stress Death**: Health drops to 0 while stress ≥ 80

**Warning System**:
- Health warning triggers once when health ≤ 30
- Stress warning triggers once when stress ≥ 80
- Alerts help player take corrective action

**Game Over Screen**:
- Shows death cause with appropriate icon
- Displays final age and role
- Character name and epitaph
- "Start New Game" button to restart

### Economic Simulation Details

#### GDP Growth Formula
```swift
baseGrowth = 0.025 // 2.5% annual baseline

// Capital stock contributions
infrastructureGrowth = infrastructureStock * 0.00002
educationGrowth = educationStock * 0.00004
scienceGrowth = scienceStock * 0.00003
healthcareGrowth = healthcareStock * 0.00001

// Policy effects
taxEffect (decays 50%/year)
crowdingOut (decays 20%/year) - triggered when deficit > 3% GDP
debtDrag (decays 5%/year) - triggered when debt-to-GDP > 60%

totalGrowth = baseGrowth + capitalStockEffects + flowEffects
weeklyGrowth = totalGrowth / 52
```

#### Budget-to-GDP Scoring
Prevents wealthy nations from having unfairly high scores by using per-capita thresholds:

Example: United States
- Population: 335M
- Healthcare threshold: $2,500/person
- Target budget: $837.5B for score of 50
- For score of 90: ~$3.8T (ratio = 9.0)

This ensures scoring reflects service quality, not just absolute spending.

### Time System
- **Weekly Progression**: Game time advances by weeks
- **Skip Day**: Advance 1 day
- **Skip Week**: Advance 7 days
- **Economic Updates**: GDP recalculated weekly
- **Depreciation**: Applied annually (365-day intervals)

### Policy Enactment Flow
1. Player selects policy from available list
2. Check requirements (position, approval, reputation, funds)
3. Propose policy (moves to proposed list)
4. Enact policy (pays implementation cost)
5. Apply immediate effects:
   - Approval rating change
   - Reputation change
   - Stress increase
   - Campaign funds adjustment
   - GDP growth impact (applied to fiscal capital stock)
   - Government stats improvements
6. Policy moves to enacted list
7. Repealing reverses 50% of effects

### Budget Management Flow
1. View current allocations by department
2. Adjust funding with sliders
3. System calculates:
   - Total expenditure
   - Deficit/surplus
   - Debt-to-GDP ratio
   - Per-capita spending per department
   - Department performance scores
4. Apply changes weekly:
   - Update department scores
   - Affect approval rating based on overall performance
   - Contribute to fiscal capital stock
   - Apply crowding out if deficit > 3% GDP
   - Apply debt drag if debt-to-GDP > 60%

## 🎨 Visual Design

### Color System
- **Primary Background**: Dark gradient (modern political theme)
- **Cards**: Semi-transparent white overlays
- **Attributes**: Color-coded (charisma=purple, intelligence=blue, reputation=gold)
- **Economic Indicators**: Green (positive), Red (negative), Yellow (warning)
- **Department Icons**: Color-coded by category

### UI Components
- **Line Charts**: Historical GDP and economic data
- **Progress Bars**: Visual feedback for budgets and stats
- **Cards**: Consistent card-based layout
- **Badges**: Status indicators for achievements
- **Alerts**: Custom alert system for warnings and events

## 🧪 Technical Implementation

### SwiftUI & Combine
- **@Published Properties**: Reactive state management
- **@EnvironmentObject**: Shared managers across views
- **ObservableObject**: Manager classes for business logic
- **@State & @Binding**: Local and passed state

### Data Persistence
- **Codable Protocol**: JSON serialization
- **UserDefaults**: Save game storage
- **FileManager**: Document directory access
- **Automatic Saves**: Triggered on time skip and position changes

### Performance Optimizations
- **Lazy Loading**: Views load data on demand
- **Computed Properties**: Cached calculations
- **History Limits**: 520 data points (10 years) for charts
- **Depreciation Intervals**: Annual checks instead of weekly

## 🚀 Getting Started

### Requirements
- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

### Building
1. Clone the repository
2. Open `PoliticianSim.xcodeproj` in Xcode
3. Select target device or simulator
4. Build and run (Cmd+R)

### First Launch
1. Create your character (name, country, attributes)
2. Tutorial guides you through basic systems
3. Start with education or jump into politics
4. Save automatically persists your progress

## 📊 Game Balance

### Difficulty Curve
- **Early Game**: Focus on education and building reputation
- **Mid Game**: Navigate local/state politics and policy decisions
- **Late Game**: Manage complex federal budgets and international relations

### Challenge Systems
- **Health/Stress Management**: Constant pressure to maintain wellness
- **Budget Constraints**: Limited funds force prioritization
- **Public Opinion**: Approval ratings affect career progression
- **Economic Cycles**: GDP fluctuations create dynamic challenges
- **Time Pressure**: Events and elections create urgency

## 🔮 Future Features (Potential)

This is a living project. Potential future additions could include:
- Multiplayer/competitive modes
- More countries with unique systems
- Expanded event library
- Political party system
- Media/press relations
- Scandals and investigations
- Cabinet management
- Supreme Court appointments
- International conflicts
- Climate change modeling
- Pandemic response events

## 📝 Credits

Built with SwiftUI for iOS by plee.

This simulation is for educational and entertainment purposes and does not reflect real political systems with complete accuracy.

## 📄 License

All rights reserved. This is a personal project.
