# Politician Sim - UI Design Document

## Design Philosophy
A minimalist, dark-themed political simulation interface inspired by InvestSim's proven design system. Focus on clarity, readability, and instant visual feedback through color-coding and iconography.

---

## Overall Architecture

### Navigation Structure
- **Single NavigationView** with StackNavigationViewStyle()
- **View routing:** String-based navigation (gameManager.currentView)
- **Left-side slide-out menu** (250px width) with dark overlay
- **Sheet presentations** for detail views and modals
- **Tab bar** for primary navigation (Home, Profile, Career, Territory, War Room)

### Background System
- **Background image:** BackgroundView with .fill aspect ratio across all views
- **Dark overlay:** Black at 0.3 opacity for text readability
- **Gradient overlays:** Blue-purple tones in specific sections (political theme)
- **Consistency:** StandardBackgroundView() component used everywhere

---

## Color Palette & Design Tokens

### Primary Colors
| Color | Usage | Value |
|-------|-------|-------|
| Background | Base layer | Black with image overlay + 30% black opacity |
| Text Primary | Main text | White |
| Text Secondary | Labels, metadata | Gray (#888888) |
| Accent | Interactive elements | Blue (#007AFF) |

### Semantic Colors
| Color | Usage | Context |
|-------|-------|---------|
| **Green** | Positive stats | Approval rating gains, fund increases, reputation boosts |
| **Red** | Negative stats | Approval drops, scandals, health decline |
| **Blue** | Neutral/Info | Campaign events, policy proposals |
| **Purple** | Diplomacy | International relations, alliances |
| **Orange** | Warnings | Stress, scandal risk, rebellion warnings |
| **Gold** | Achievements | Legacy milestones, awards |
| **Indigo** | Government | Budget, taxation, treasury |
| **Crimson** | Military | Wars, conflicts, casualties |

### Stat-Specific Colors
```swift
// Base Attributes
Charisma: rgb(0.3, 0.6, 1.0)      // Light blue
Intelligence: rgb(0.5, 0.3, 0.8)  // Purple
Reputation: rgb(1.0, 0.7, 0.0)    // Gold
Luck: rgb(0.2, 0.8, 0.3)          // Green
Diplomacy: rgb(0.4, 0.5, 0.9)     // Royal blue

// Career Stats
Approval Rating: Green (high) / Red (low) gradient
Campaign Funds: rgb(0.2, 0.7, 0.4) // Money green
Government Treasury: rgb(0.3, 0.4, 0.6) // Dark blue

// Nation Stats
Military Strength: rgb(0.8, 0.2, 0.2) // Crimson
Territory Size: rgb(0.5, 0.4, 0.3)    // Earth brown
Population Morale: Green/Orange/Red gradient
```

### Typography
| Style | Size | Weight | Color |
|-------|------|--------|-------|
| Hero Number | 26pt | Bold | White |
| Page Title | 25.5pt | Bold | White |
| Large Data | 18pt | Bold | White |
| Standard Data | 15pt | Bold | White |
| Body Text | 15pt | Regular | White |
| Section Header | 15pt | Medium | White |
| Section Label | 12.75pt | Semibold | Gray |
| Label | 11.25pt | Regular | Gray |
| Caption | 12pt | Regular | Gray |
| Small Text | 10.5pt | Regular | Gray |
| Micro Label | 8.8pt | Regular | Gray |

---

## Side Menu Design

### Layout
- **Width:** 250px
- **Animation:** Slide-in from left with spring animation
- **Background:** Black 85% opacity with blue-purple gradient overlay
- **Scrollable:** Full-height content

### Header Section
```
Top padding: 90px (accounts for status bar)
┌─────────────────────────────┐
│ [Avatar Icon] Character Name│  14.5pt semibold white
│ Age 45 | Nov 10, 2025       │  12.75pt gray
│ President of United States  │  13pt gray
│                             │
│ Net Worth: $5.2M            │  14.5pt semibold green
│ Approval: 67%               │  13pt green
└─────────────────────────────┘
Light gray background (0.1 opacity), 12px corners
```

### Menu Items
**Grouped sections with uppercase gray headers (12pt):**

**OVERVIEW**
- Home (house icon)
- Profile (person icon)
- Legacy (star icon)

**POLITICAL**
- Career Path (briefcase icon)
- Policies (doc.text icon)
- Elections (checkmark.circle icon)

**GOVERNMENT**
- Budget (dollarsign.circle icon)
- Territory (map icon)
- Military & Tech (shield icon)

**DIPLOMACY**
- War Room (exclamationmark.triangle icon)
- Alliances (person.3 icon)

**INFORMATION**
- Media (newspaper icon)
- Events (calendar icon)
- Settings (gear icon)

**Item styling:**
- Icon (18pt SF Symbol) + Title (16pt)
- Vertical padding: 14px
- Horizontal padding: 20px
- No background (tap feedback via iOS standard)

### Footer
- Version text: Centered, gray, 11pt
- Bottom padding: 20px

---

## Home View Structure

### Top Bar
```
[Certificate Badge]        Character Name        [Day] [Week]
                          Age 45, Nov 10
```

**Left:** Certificate icon (28px) - shows education level
**Center:** Name + age/date (vertically stacked)
**Right:** Day/Week buttons with play icon

### Day/Week Buttons
- **Style:** Play icon (8pt) + text (13pt)
- **Selected state:** White text, blue background (0.5 opacity)
- **Unselected:** Gray text, clear background
- **Corners:** 5px rounded
- **Padding:** Compact (8px horizontal, 6px vertical)

### Character Overview Card
```
┌─────────────────────────────────────────┐
│ [Icon] Character Name                   │
│        Age 45, November 10, 2025        │
│                                         │
│ President of United States              │  18pt bold
│ Term 2 | 3 years in office              │  12pt gray
│                                         │
│ ┌─────────────────────────┐            │
│ │ Approval Rating: 67%    │            │  26pt bold green
│ │ [Line chart 200px]      │            │
│ └─────────────────────────┘            │
└─────────────────────────────────────────┘
```

**Background:** Gray 0.3 opacity, 12px corners
**Padding:** 15px internal
**Chart:** 200px height, gray background 0.2 opacity, gradient stroke (blue to green)

### Stats Breakdown Section
**Horizontal scroll of stat cards:**

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ [Icon]       │  │ [Icon]       │  │ [Icon]       │
│ Charisma     │  │ Intelligence │  │ Reputation   │
│ 67/100       │  │ 82/100       │  │ 54/100       │
└──────────────┘  └──────────────┘  └──────────────┘
```

Each card:
- Circular colored icon (28px diameter, 0.2 opacity fill)
- Icon inside circle (12pt bold)
- Label (12pt gray)
- Value (18pt bold, colored)
- 140px width, 100px height

### Current Events Section
```
┌─────────────────────────────────────────┐
│ [Newspaper] Latest Events   [3] View All│
│ ─────────────────────────────────────── │
│ [•] Immigration Bill Vote Tomorrow      │  13pt
│     2 days ago                          │  11pt gray
│ ─────────────────────────────────────── │
│ [•] Trade Dispute with China            │
│     1 week ago                          │
│ ─────────────────────────────────────── │
│ [•] Approval Rating Drops 5%            │
│     3 weeks ago                         │
└─────────────────────────────────────────┘
```

**Background:** Gray 0.3 opacity, 12px corners
**Padding:** 15px
**Event rows:**
- Category color dot (10px circle)
- Headline (13pt, truncated to 1 line)
- Date (11pt gray, right aligned)
- Dividers: Gray 0.3 opacity

**Empty state:** Centered gray text "No recent events"

### Quick Actions Grid
**Title:** "Quick Actions" (15pt medium white)

**Layout:**
```
Row 1: [Budget] [Policies] [Campaign] [Territory] [Military]
Row 2: [Elections] [Media] [Diplomacy] [Economy] [Settings]
```

Each action:
- Circular icon background (38px, colored 0.2 opacity)
- SF Symbol icon (16pt) centered
- Label below (8.8pt gray)
- 55px fixed width
- 6px spacing between icon and text

**Icon/Color mapping:**
- Budget: dollarsign.circle / indigo
- Policies: doc.text / blue
- Campaign: megaphone / orange
- Territory: map / brown
- Military: shield / crimson
- Elections: checkmark.circle / blue
- Media: newspaper / gray
- Diplomacy: globe / purple
- Economy: chart.line.uptrend.xyaxis / green
- Settings: gear / gray

### Active Policies Overview
**Conditional:** Only shown if player has enacted policies

```
┌─────────────────────────────────────────┐
│ Active Policies                    [3] →│
│ ─────────────────────────────────────── │
│ [Icon] Tax Reform Act                   │
│        In effect: 6 months              │
│        Impact: +$2B revenue/year        │
│ ─────────────────────────────────────── │
│ [Icon] Healthcare Expansion             │
│        In effect: 2 years               │
│        Impact: +8% approval             │
└─────────────────────────────────────────┘
```

**Background:** Dark (rgb(0.12, 0.12, 0.12))
**Border:** Blue 0.5 opacity
**Padding:** 15px

---

## Profile View Structure

### Top Section
```
[Back]                  Profile                    [Edit]

┌─────────────────────────────────────────┐
│         [Large Avatar Circle]           │  80px
│                                         │
│         Character Name                  │  20pt bold
│    Age 45 | Nov 10, 2025               │  13pt gray
│                                         │
│    President of United States          │  16pt medium
│         Term 2 of 2                     │  12pt gray
└─────────────────────────────────────────┘
```

### Base Attributes Card
```
┌─────────────────────────────────────────┐
│ BASE ATTRIBUTES                         │  12.75pt gray
│                                         │
│ Charisma                       67/100   │
│ [═══════════════▒▒▒▒▒] (67%)           │  Progress bar
│                                         │
│ Intelligence                   82/100   │
│ [═══════════════════▒] (82%)           │
│                                         │
│ Reputation                     54/100   │
│ [═══════════▒▒▒▒▒▒▒▒▒] (54%)           │
│                                         │
│ Luck                          45/100    │
│ [═════════▒▒▒▒▒▒▒▒▒▒▒] (45%)           │
│                                         │
│ Diplomacy                     71/100    │
│ [══════════════▒▒▒▒▒▒] (71%)           │
└─────────────────────────────────────────┘
```

**Progress bars:**
- Filled: Colored gradient (attribute-specific color)
- Unfilled: Gray 0.3 opacity
- Height: 8px
- Corners: 4px rounded

### Secondary Stats Cards
**Grid layout (2 columns):**

```
┌──────────────────┐  ┌──────────────────┐
│ Approval Rating  │  │ Campaign Funds   │
│     67%          │  │    $5.2M         │
│   ↑ +3%          │  │  ↑ +$200k        │
└──────────────────┘  └──────────────────┘

┌──────────────────┐  ┌──────────────────┐
│ Health           │  │ Stress           │
│   85/100         │  │   42/100         │
│   ↓ -2           │  │  ↑ +8            │
└──────────────────┘  └──────────────────┘
```

Each card:
- Gray background (0.2 opacity)
- 12px corners
- 20px padding
- Label (12pt gray)
- Value (22pt bold, colored)
- Change indicator (13pt with arrow)

### Career History Section
```
┌─────────────────────────────────────────┐
│ CAREER HISTORY                          │
│                                         │
│ [Icon] President                        │  15pt bold
│        United States | 3 years          │  12pt gray
│        Approval: 67% | $10M funds       │  11pt
│                                         │
│ [Icon] U.S. Senator                     │
│        New York | 6 years               │
│        Approval: 72% | $1.5M funds      │
│                                         │
│ [Icon] Governor                         │
│        New York | 4 years               │
│        Approval: 68% | $600k funds      │
└─────────────────────────────────────────┘
```

**Timeline view:**
- Vertical line connecting positions (gray 0.5 opacity)
- Circular icons for each position
- Most recent at top
- Scrollable if history is long

---

## Career View Structure

### Career Path Tree
```
[Back]            Career Path                [Info]

┌─────────────────────────────────────────┐
│ CURRENT POSITION                        │
│                                         │
│         [Large Icon]                    │
│         President                       │  20pt bold
│    Elected: Nov 2024 | Term: 4 years   │  12pt gray
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ AVAILABLE POSITIONS                     │
│                                         │
│ [Filter: All | Presidential | Parl...]  │
└─────────────────────────────────────────┘
```

### Position Cards (Scrollable List)
```
┌─────────────────────────────────────────┐
│ [Icon] President                   🔒   │
│                                         │
│ Requirements:              [LOCKED]     │
│ • Approval: 75% (You: 67%)        ✗    │  Red
│ • Reputation: 85 (You: 54)        ✗    │
│ • Funds: $10M (You: $5.2M)        ✗    │
│ • Age: 35+ (You: 45)              ✓    │  Green
│                                         │
│ Term: 4 years | Min. Age: 35           │
└─────────────────────────────────────────┘
```

**Card states:**
- **Locked:** Red badge, gray icon, requirements shown
- **Available:** Green badge, colored icon, "Run for Office" button
- **Current:** Gold badge, highlighted border

---

## Government Budget View

### Budget Overview Card
```
┌─────────────────────────────────────────┐
│ GOVERNMENT TREASURY                     │
│                                         │
│ $45.3 Billion                          │  26pt bold indigo
│ Monthly Revenue: $8.2B                  │  13pt green
│ Monthly Expenses: $7.1B                 │  13pt red
│ Net: +$1.1B/month                      │  15pt bold green
└─────────────────────────────────────────┘
```

### Tax Rate Slider
```
┌─────────────────────────────────────────┐
│ TAX RATE                                │
│                                         │
│ Federal Income Tax: 32%                 │  18pt bold
│ [━━━━━━━━●━━━━━━━━━] 0% ←→ 100%       │
│                                         │
│ Annual Revenue: $95.4B                  │  13pt
│ Approval Impact: No change              │  13pt (colored)
└─────────────────────────────────────────┘
```

**Slider design:**
- Track: Gray 0.3 opacity
- Filled track: Gradient (green → orange → red based on rate)
- Thumb: 24px circle, white with shadow
- Live approval impact preview

### Budget Allocation Section
```
┌─────────────────────────────────────────┐
│ BUDGET ALLOCATION                       │
│                                         │
│ Military                          35%   │  15pt bold crimson
│ [═══════▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒] $28.2B   │
│                                         │
│ Social Programs                   28%   │  15pt bold blue
│ [═══════▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒] $22.5B   │
│                                         │
│ Infrastructure                    20%   │  15pt bold green
│ [══════▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒] $16.1B   │
│                                         │
│ Administration                    12%   │  15pt bold gray
│ [════▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒] $9.7B    │
│                                         │
│ Debt Payments                      5%   │  15pt bold orange
│ [══▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒] $4.0B    │
│                                         │
│ [Adjust Allocation →]                   │  Blue button
└─────────────────────────────────────────┘
```

**Each category:**
- Color-coded label
- Percentage (15pt bold)
- Progress bar showing allocation
- Dollar amount (13pt)
- Tap to adjust

---

## Territory Map View

### Territory Overview
```
[Back]           Territory                  [Map]

┌─────────────────────────────────────────┐
│ TOTAL CONTROLLED TERRITORY              │
│                                         │
│ 3.92 Million sq mi                     │  26pt bold brown
│ Population: 318M                        │  15pt
│ Morale: 72%                            │  15pt (colored)
└─────────────────────────────────────────┘
```

### Territory List
```
┌─────────────────────────────────────────┐
│ CORE TERRITORY                     [→]  │
│ ─────────────────────────────────────── │
│ [Icon] United States                    │
│        3.8M sq mi | 318M pop            │
│        Morale: 72% | Tax: $95.4B/yr    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ CONQUERED TERRITORIES              [→]  │
│ ─────────────────────────────────────── │
│ [Icon] Cascadia Region                  │
│        120k sq mi | 8M pop              │
│        Morale: 45% ⚠️ | Tax: $5.2B/yr  │
│        Rebellion Risk: 30%              │  Orange warning
└─────────────────────────────────────────┘
```

**Territory card:**
- Flag/region icon (40px)
- Name (15pt bold)
- Size + population (12pt gray)
- Morale bar (gradient: red → orange → green)
- Tax revenue (12pt green)
- Warning indicators if morale < 50%

### Territory Detail Sheet
```
[Close]          Cascadia Region

┌─────────────────────────────────────────┐
│         [Large Region Icon]             │
│                                         │
│ Territory: 120,000 sq mi                │
│ Population: 8.2 million                 │
│ Acquired: 6 months ago                  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ STATISTICS                              │
│                                         │
│ Population Morale        45%      ⚠️    │
│ [████████▒▒▒▒▒▒▒▒▒▒▒▒]                 │  Orange bar
│                                         │
│ Tax Revenue           $5.2B/year        │
│ Garrison Cost        -$200M/month       │
│ Net Income           +$5.0B/year        │
│                                         │
│ Rebellion Risk              30%         │  Orange
│ Manpower Available         820k         │
└─────────────────────────────────────────┘

[Grant Autonomy] [Increase Garrison] [Manage]
```

---

## War Room View

### Active Wars Section
```
[Back]            War Room                 [+]

┌─────────────────────────────────────────┐
│ ACTIVE CONFLICTS                   [1]  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ [⚔️] War with Cascadia Republic         │
│                                         │
│ Duration: 89 days                       │  12pt gray
│ Status: Winning                         │  13pt green
│                                         │
│ Your Strength: 450,000                  │
│ [████████████████▒▒▒▒]                 │  Green bar
│                                         │
│ Enemy Strength: 180,000                 │
│ [████████▒▒▒▒▒▒▒▒▒▒▒▒]                 │  Red bar
│                                         │
│ Casualties: 12,000 (↑ 4%)             │  Red
│ Cost: $8.2B spent                       │  Orange
│                                         │
│ [Negotiate Peace] [War Details →]      │
└─────────────────────────────────────────┘
```

**War card styling:**
- Crimson border (0.5 opacity) if active
- Gray border if concluded
- Pulsing animation on active wars
- Status badge (winning/losing/stalemate)

### War Detail Sheet
```
[Close]       War with Cascadia

┌─────────────────────────────────────────┐
│ WAR STATUS                              │
│                                         │
│ Started: 89 days ago                    │
│ Type: Offensive (Unjustified)          │  Orange badge
│ Approval Impact: -30%                   │  Red
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ MILITARY COMPARISON                     │
│                                         │
│ Your Forces                   450,000   │
│ [████████████████▒▒▒▒]                 │
│                                         │
│ Enemy Forces                  180,000   │
│ [████████▒▒▒▒▒▒▒▒▒▒▒▒]                 │
│                                         │
│ Technology Advantage:    +2 levels      │  Green
│ Terrain Bonus:            Neutral       │  Gray
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ WAR COSTS                               │
│                                         │
│ Funds Spent             $8.2 Billion    │  Orange
│ Monthly Cost            -$2B/month      │  Red
│ Population Lost         12,000 (4%)     │  Red
│ Morale Impact           -15%            │  Orange
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ RECENT EVENTS                           │
│                                         │
│ • Major victory at Cascadian border     │
│   3 days ago                            │
│                                         │
│ • Enemy counterattack repelled          │
│   1 week ago                            │
└─────────────────────────────────────────┘

[Negotiate Peace] [Press Attack] [Defensive Stance]
```

### Military & Tech View
```
[Back]        Military & Tech              [Info]

┌─────────────────────────────────────────┐
│ MILITARY OVERVIEW                       │
│                                         │
│ Military Strength         450,000       │  26pt bold crimson
│ Available Manpower        46.2M         │  15pt
│ Recruitment: Volunteer                  │  13pt gray
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ TECHNOLOGY RESEARCH                     │
│                                         │
│ [Icon] Infantry Weapons      Level 5    │
│        Bonus: +50% effectiveness        │
│        [Upgrade to 6: $2.5B, 6 months] │
│                                         │
│ [Icon] Naval Power           Level 3    │
│        Bonus: +30% effectiveness        │
│        [Upgrade to 4: $5B, 8 months]   │
│                                         │
│ [Icon] Cyber Warfare         Level 7    │
│        Bonus: +70% effectiveness        │
│        [Researching Level 8...] 45%     │
│        [████████▒▒▒▒▒▒▒▒] 4 months left │
└─────────────────────────────────────────┘
```

**Tech cards:**
- Icon + name + current level
- Progress bar if researching
- "Upgrade" button if available
- Cost + time estimate
- Green checkmark if maxed (Level 10)

---

## Event System

### Event Notification
**Pop-up overlay:**
```
┌─────────────────────────────────────────┐
│              [Event Icon]               │
│                                         │
│         Immigration Bill Vote           │  18pt bold
│                                         │
│ Congress is voting on your proposed     │
│ immigration reform bill. The outcome    │
│ will significantly impact your          │
│ approval rating among various groups.   │  14pt regular
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Support the Bill                    │ │  Blue button
│ │ Approval +10%, Reputation +5        │ │  12pt preview
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Oppose the Bill                     │ │  Red button
│ │ Approval -5%, Funds +$500k          │ │  12pt preview
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Abstain from Voting                 │ │  Gray button
│ │ No change, Stress -5                │ │  12pt preview
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Overlay styling:**
- Semi-transparent black background (0.6 opacity)
- White card (0.95 opacity) with slight blur
- 20px padding
- 16px corner radius
- Shadow for depth

**Choice buttons:**
- Full width
- 15px vertical padding
- Icon + text + preview
- Color-coded border (0.5 opacity)
- Tap animation

### Event History List
```
[Back]           Event History             [Filter]

[All] [Political] [Economic] [International]

┌─────────────────────────────────────────┐
│ [•] Immigration Bill Vote               │
│     Political | 2 days ago              │
│     Outcome: +10% approval              │  Green
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ [•] Trade Dispute with China            │
│     International | 1 week ago          │
│     Outcome: -5% approval               │  Red
└─────────────────────────────────────────┘
```

---

## Media & News View

### Media Feed
```
[Back]              Media                  [Sources]

┌─────────────────────────────────────────┐
│ MEDIA FAVORABILITY                      │
│                                         │
│ Overall: 62% Favorable                  │  18pt green
│ [████████████▒▒▒▒▒▒▒▒]                 │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ LATEST HEADLINES                        │
│                                         │
│ [📰] President Announces New Policy     │
│      The Washington Post | 2 hours ago  │
│      Sentiment: Positive 😊             │  Green
│                                         │
│ [📰] Approval Rating Drops Amid Scandal │
│      CNN | 1 day ago                    │
│      Sentiment: Negative 😟             │  Red
│                                         │
│ [📰] Economic Growth Continues          │
│      Bloomberg | 3 days ago             │
│      Sentiment: Neutral 😐              │  Gray
└─────────────────────────────────────────┘
```

**Headline cards:**
- Publication icon
- Headline (14pt bold)
- Source + time (11pt gray)
- Sentiment badge with emoji
- Tap to read full article

---

## Policies View

### Active Policies
```
[Back]            Policies                 [Propose]

┌─────────────────────────────────────────┐
│ ACTIVE POLICIES                    [3]  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ [Icon] Tax Reform Act                   │
│        Economic Policy                  │  Blue badge
│                                         │
│ Enacted: 6 months ago                   │  12pt gray
│                                         │
│ IMMEDIATE EFFECTS                       │
│ • Revenue: +$2B/year           ↑        │  Green
│ • Approval: -3%                ↓        │  Red
│                                         │
│ DELAYED EFFECTS (in 18 months)          │
│ • Economic growth: +5%                  │  Green
│                                         │
│ [View Details →]                        │
└─────────────────────────────────────────┘
```

### Propose Policy Sheet
```
[Close]        Propose New Policy

[Economic] [Social] [Environmental] [Foreign]

┌─────────────────────────────────────────┐
│ [Icon] Healthcare Expansion             │
│                                         │
│ Expand government healthcare coverage   │
│ to include dental and vision care.     │
│                                         │
│ IMMEDIATE IMPACT                        │
│ • Cost: -$5B/year              ↓        │  Red
│ • Approval: +8%                ↑        │  Green
│ • Stress: +10                  ↑        │  Orange
│                                         │
│ DELAYED IMPACT (6 months)               │
│ • Population health: +15%               │  Green
│ • Approval: +5%                         │  Green
│                                         │
│ REQUIREMENTS                            │
│ • Intelligence: 60+ (You: 82)  ✓        │  Green
│ • Approval: 50%+ (You: 67%)    ✓        │  Green
│ • Funds: $2B (You: $5.2M)      ✗        │  Red
│                                         │
│ [Propose Policy]                        │  Disabled (gray)
└─────────────────────────────────────────┘
```

---

## Elections View

### Election Overview
```
[Back]           Elections                [History]

┌─────────────────────────────────────────┐
│ NEXT ELECTION                           │
│                                         │
│ U.S. Presidential Election              │  18pt bold
│ November 2028 (in 1,094 days)          │  13pt gray
│                                         │
│ Your Approval: 67%                      │  15pt green
│ Funds Raised: $5.2M                     │  15pt green
│ Polling: Leading by 12%                 │  15pt bold green
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ OPPONENTS                               │
│                                         │
│ [Avatar] John Smith                     │  15pt bold
│          Republican Party               │  12pt
│          Polling: 35%                   │  13pt gray
│          Funds: $8.1M                   │  13pt
│                                         │
│ [Avatar] Jane Doe                       │
│          Independent                    │
│          Polling: 18%                   │
│          Funds: $2.3M                   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ CAMPAIGN ACTIONS                        │
│                                         │
│ [📢] Run Ad Campaign      -$500k        │
│ [🎤] Hold Rally           -$100k        │
│ [💰] Fundraising Event    -$50k         │
│ [📺] Schedule Debate       Free         │
└─────────────────────────────────────────┘
```

**Opponent cards:**
- Avatar (40px circle)
- Name + party
- Polling percentage (with bar)
- Campaign funds
- Tap to view full profile

---

## Settings View

### Settings Menu
```
[Back]            Settings

┌─────────────────────────────────────────┐
│ GAME SETTINGS                           │
│                                         │
│ Autosave                          [On]  │  Toggle
│ Autosave Interval              2 sec    │  13pt gray
│                                         │
│ Difficulty                     Normal    │  → Disclosure
│                                         │
│ Time Controls                           │
│ • Day/Week buttons in top bar           │  13pt gray
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ DISPLAY                                 │
│                                         │
│ Theme                            Dark    │  → Disclosure
│ Text Size                      Medium    │  → Disclosure
│ Colorblind Mode                  [Off]  │  Toggle
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ AUDIO                                   │
│                                         │
│ Music Volume          [═════════▒▒▒]    │  Slider
│ Sound Effects         [████████▒▒▒]    │  Slider
│ Mute                             [Off]  │  Toggle
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ ACCOUNT                                 │
│                                         │
│ Save Game                          [→]  │
│ Load Game                          [→]  │
│ New Game                           [→]  │
│ Delete Save                        [→]  │  Red text
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ ABOUT                                   │
│                                         │
│ Version 1.0.0                           │  13pt gray
│ © 2025 Politician Sim                   │  11pt gray
│                                         │
│ Privacy Policy                     [→]  │
│ Terms of Service                   [→]  │
│ Credits                            [→]  │
└─────────────────────────────────────────┘
```

---

## List/Detail View Patterns

### Standard List View
```
[← Back]          Page Title              [Action]

[Context Badge: Personal]

[Filter Chips: All | Category 1 | Category 2 ...]

┌─────────────────────────────────────────┐
│ [Icon] Primary Text                     │
│        Secondary text                   │
│                                     $5M │  Right metadata
└─────────────────────────────────────────┘
```

**Back button:** Blue chevron + "Back" (16pt)
**Title:** 25.5pt bold white
**Context badge:** 10.5pt bold, colored background 0.2 opacity, 6px corners

### List Row Pattern
- **Icon:** 40px circle, colored 0.2 opacity background
- **Content area:**
  - Primary text (12pt bold white)
  - Secondary text (10.5pt gray)
- **Metadata:** Right aligned (13pt)
- **Tap:** Opens detail sheet

### Detail Sheet Pattern
- **Presentation:** Full sheet
- **Background:** Same background system
- **Close button:** Top-right (X icon)
- **Content:** Scrollable cards/sections

---

## Card/Section Components

### Info Card
```
┌─────────────────────────────────────────┐
│ SECTION TITLE               12.75pt gray│
│                                         │
│ Label                          Value    │  11.25pt gray / 15pt bold
│ ───────────────────────────────────────│  Divider
│ Label 2                        Value 2  │
│ ───────────────────────────────────────│
│ Label 3                        Value 3  │
└─────────────────────────────────────────┘
```

**Styling:**
- Gray background (0.2 opacity)
- 12px corner radius
- 15-20px internal padding
- Dividers: Gray 0.5 opacity

### Badge/Pill Component
**Small status indicator:**
- Text: 9-10.5pt
- Padding: 8-10px horizontal, 2-5px vertical
- Background: Colored 0.2 opacity
- Text: Colored matching background
- Corners: 4-8px radius

**Usage:**
- APR rates
- Context indicators (Personal/Business)
- Status labels (Winning/Losing, Active/Completed)
- Position requirements (Locked/Available)

---

## Interactive Elements

### Primary Button
- **Background:** Blue (or semantic color)
- **Text:** White, medium weight
- **Corners:** 10px rounded
- **Padding:** 12px vertical, 20px horizontal
- **Shadow:** Subtle depth
- **Disabled state:** Gray 0.3 opacity

### Filter Button
- **Style:** Icon + text
- **Background:** Clear (unselected), colored 0.3 (selected)
- **Compact:** 8px padding
- **Container:** Horizontal scroll

### Action Buttons (Quick Actions)
- **Icon-first design**
- **SF Symbols** for all icons
- **Circular containers** with colored backgrounds (38-40px)
- **Consistent sizing**

---

## Spacing & Layout Rules

| Element | Spacing |
|---------|---------|
| Section vertical spacing | 20px |
| Card spacing | 15px between cards |
| Internal card padding | 15-20px |
| Horizontal margins | 16px (.padding(.horizontal)) |
| Divider vertical padding | 8-10px |
| Icon-text spacing | 4-8px |
| Compact row vertical | 8-10px |
| Standard row vertical | 14px |

---

## Animations & Transitions

| Element | Animation |
|---------|-----------|
| Side menu | Spring animation (0.4s, damping 0.8) |
| Tab selection | Color transition (0.2s ease) |
| Sheet presentations | Standard iOS modal |
| Context switches | State-based fade (0.3s) |
| Progress bars | Linear fill (0.5s) |
| Stat changes | Number count-up (0.8s) |
| Event notifications | Slide from top (0.3s) |
| War alerts | Pulsing border (2s loop) |

---

## Key UI Patterns to Replicate

1. **Consistent backgrounds:** Always use image + dark overlay
2. **Color semantics:** Strict color-coding (green=good, red=bad, blue=neutral)
3. **Icon-first design:** Every action/category has a circular icon
4. **Card-based layouts:** Information grouped in rounded, semi-transparent cards
5. **Contextual views:** Single codebase handles different contexts with badges
6. **Minimal borders:** Rely on backgrounds and spacing, not heavy borders
7. **SF Symbols:** Exclusively use San Francisco Symbols for all icons
8. **Hierarchical spacing:** Clear visual grouping through spacing alone
9. **Sheet-based details:** Main list → sheet for details pattern
10. **Navigation clarity:** Always show back button, current context, and clear title
11. **Live feedback:** Show stat changes immediately with animated indicators
12. **Progressive disclosure:** Summary on main view, details in sheets

---

## Platform-Specific Considerations

### iOS Safe Areas
- Respect top safe area (status bar, notch)
- Respect bottom safe area (home indicator)
- Side menu header accounts for top inset (90px padding)

### Dark Mode
- Primary design is dark-themed
- Light mode NOT supported (political/serious theme)
- Ensure sufficient contrast for accessibility

### Accessibility
- Minimum font size: 11pt
- Color alone not sole indicator (use icons + text)
- VoiceOver labels on all interactive elements
- Dynamic type support for text scaling

### Performance
- Lazy loading for long lists
- Image caching for avatars/flags
- Debounced slider updates
- Background loading for chart data

---

## Component Reusability

### Reusable Components to Build
1. **StandardBackgroundView** - Background + overlay
2. **StatCard** - Circular icon + label + value
3. **InfoCard** - Title + data rows + dividers
4. **ProgressBar** - Filled/unfilled with colors
5. **Badge** - Colored pill with text
6. **ListRow** - Icon + primary/secondary text + metadata
7. **FilterChip** - Selectable filter button
8. **ActionButton** - Circular icon + label
9. **EventCard** - Event with choices
10. **WarCard** - War status with bars
11. **TerritoryCard** - Territory with morale bar
12. **PolicyCard** - Policy with effects
13. **NewsCard** - Headline with sentiment

---

## Design System Summary

This UI design creates a **modern, dark-themed political simulation interface** with:
- **Excellent readability** through consistent backgrounds and typography
- **Clear information hierarchy** via spacing and card grouping
- **Instant visual feedback** through color-coding and animations
- **Consistent interaction patterns** across all views
- **Depth and dimension** via semi-transparent cards over consistent backgrounds

The design is optimized for:
- **Long play sessions** (dark theme reduces eye strain)
- **Complex information display** (card-based grouping)
- **Quick decision-making** (color-coded stats, clear choices)
- **Political gravitas** (serious color palette, minimal decoration)
