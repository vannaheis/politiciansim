# Politician Sim: Game Design Document

## Overview
**Title:** Politician Sim  
**Genre:** Life Simulation / Political Strategy  
**Platform:** iOS (Swift, UIKit/SwiftUI-based)  
**Target Audience:** 13+, players interested in life sims, politics, and decision-making  
**Art Style:** Minimalist UI-driven design (similar to BitLife), optional avatars, flat illustration  
**Monetization:** Free-to-play with in-app purchases (premium currency, ad removal, cosmetic perks)

---

## Core Concept
Politician Sim is a text-based life simulation game where players start at **birth** and live a full life with political aspirations. Through education, early-life choices, career decisions, strategy, and reputation management, players work their way up the political ladder—from **community leader** to **mayor**, **governor**, **senator**, and eventually **President**. Each position introduces new gameplay layers, responsibilities, and ethical dilemmas.

The game emphasizes **reputation, policy management, and power dynamics**. Player choices shape not only their career but the world around them. While reaching the presidency is the ultimate goal, players may die of old age before achieving it, making each life a race against time.

---

## Game Loop
1. **Decision Phase:** Player reads a situation/event and makes a choice from 2–4 options.
2. **Outcome Phase:** Consequences affect reputation, public opinion, and finances.
3. **Progression Phase:** Improve stats, unlock new career paths.
4. **Time Advancement:** Player manually advances time using:
   - **Skip Day** button: Advances time by 1 day
   - **Skip Week** button: Advances time by 7 days
   - Buttons located in top-right of main view

This cycle continues throughout the character's lifetime, from birth to death (age 0-90).

---

## Time Progression & Pacing

### Time Advancement
- **Manual control:** Players click **Skip Day** (+1 day) or **Skip Week** (+7 days)
- **Event frequency determines pacing:** Players skip time until next event or milestone

### Recommended Pacing by Life Stage
| Age Range | Stage | Skip Strategy | Events/Year |
|-----------|-------|---------------|-------------|
| 0-4 | Infancy/Toddler | Skip weeks aggressively | 2-3 events total |
| 5-10 | Elementary School | Skip weeks, occasional days | 3-5 events/year |
| 11-13 | Middle School | Mix of weeks/days | 4-6 events/year |
| 14-17 | High School | More granular (days) | 5-7 events/year |
| 18-22 | College (if attended) | Days for choices, weeks between | 8-12 events/year |
| 18+ | Early Career | Primarily days during campaigns | 10-15 events/year |
| Active Political Career | Campaign/Office | Days during critical periods | 15-30 events/year |

### Estimated Playthrough Times
- **Birth to Age 18:** ~10-15 minutes (mostly skipping with strategic choices)
- **College (Ages 18-22):** ~5-10 minutes
- **Early Political Career to Mayor:** ~15-20 minutes
- **Governor to President:** ~20-30 minutes
- **Full playthrough (birth → President → death):** 60-90 minutes

**Note:** Players can replay segments by loading saves at different career stages

---

## Core Gameplay Systems

### 1. **Character Creation & Lifespan**

#### Initial Setup - Character Creation Screen

**Country Selection:**
- **Alphabetical list** of playable countries (initially 10 major countries, expandable)
- Display for each country:
  - Country flag icon
  - Territory size (sq miles)
  - Population (millions)
  - Government type label (Presidential, Parliamentary, Monarchy, Single-Party)
- **World simulation:** All ~195 countries exist in-game, but only select countries are playable
  - Non-playable countries participate in wars, alliances, diplomacy as AI entities

**Playable Countries (Phase 1 - 10 Major Countries):**
1. **United States** - Presidential (3.8M sq mi, 330M pop)
2. **United Kingdom** - Parliamentary (94k sq mi, 67M pop)
3. **China** - Single-Party (3.7M sq mi, 1.4B pop)
4. **Russia** - Presidential (6.6M sq mi, 144M pop)
5. **Germany** - Parliamentary (138k sq mi, 83M pop)
6. **France** - Presidential (213k sq mi, 67M pop)
7. **Japan** - Parliamentary (146k sq mi, 125M pop)
8. **India** - Parliamentary (1.3M sq mi, 1.4B pop)
9. **Brazil** - Presidential (3.3M sq mi, 215M pop)
10. **Saudi Arabia** - Absolute Monarchy (830k sq mi, 36M pop)

**Character Details:**
- **Free-text name input** (no restrictions or validation)
- **Gender selection:** Male, Female, Non-binary (no restrictions by country)
- **Background:** Working-class, Middle-class, Wealthy (affects starting funds only)

**Randomized Base Attributes** (0-100 scale, equal across all countries):
- **Charisma:** Affects public speaking, media appearances, and voter appeal
- **Intelligence:** Influences policy effectiveness and decision outcomes
- **Reputation:** Long-term credibility; determines career unlocks and scandal survival
- **Luck:** Random event outcomes and chance-based scenarios
- **Diplomacy:** Negotiation success and international relations (higher-level positions)

**Attribute Behavior:**
- Cap at 100
- Fluctuate based on player actions, events, and choices
- Subject to minor decay over time (representing aging or loss of public favor)

#### Early Life System (Ages 0-17)
**Automated Milestones:**
- Age 5: Start elementary school
- Age 11: Middle school transition
- Age 14: High school begins
- Age 18: Graduation, college decision

**Gameplay During Early Life:**
- **Passive Progression:** School attendance is automatic (players skip days/weeks through childhood)
- **Random Events:** Triggered at key ages (e.g., age 10: "invited to spelling bee", age 15: "offered leadership role")
- **Interactive Menu Options:**
  - Join clubs (debate team, student government, drama club)
  - Study choices (AP classes, tutoring, skip homework)
  - Social activities (popularity vs. academics trade-offs)
- **Attribute Development:** Early choices shape starting stats for political career
  - Debate club → +Charisma
  - Honor roll → +Intelligence
  - Student council → +Reputation, +Diplomacy

#### College/Higher Education (Ages 18+)
- **Optional** but critical for political success
- Attendance provides significant stat boosts:
  - +15-25 Intelligence (depending on major)
  - +10-15 Charisma (campus involvement)
  - +10-20 Reputation (degree credibility)
- **Without college:** Players face -20% approval penalty in early campaigns and steeper funding requirements
- Duration: 4 years (ages 18-22 typical)

#### Lifespan & Death
- **Hard cap:** Age 90 (natural death, unavoidable)
- **Time pressure:** Minimum age for President is 35; players have ~55 years max to achieve goal
- **Early death possible:** Extreme stress + poor health can cause death before 90
- Health management extends lifespan potential within natural limits

### 2. **Secondary Stats System**

#### Personal Stats
| Stat | Description | Effect |
|------|--------------|--------|
| Approval Rating | Public opinion of current performance | Affects re-election and career advancement |
| Campaign Funds | Personal political war chest | Used for ads, staff, events, crisis management |
| Age | Current character age | Determines eligibility and time remaining |
| Health | Physical/mental condition | Deteriorates with stress; affects lifespan |
| Stress | Workload and pressure indicator | High stress damages health and increases scandal risk |

**Note:** Reputation is now a core base attribute (see Character Creation)

#### Nation/Government Stats (Unlocked at Governor+)
| Stat | Description | Effect |
|------|--------------|--------|
| Territory Size | Total land controlled (sq miles) | Determines tax revenue base and strategic power |
| Population | Total citizens | Affects manpower, tax revenue, and approval dynamics |
| Population Morale | Citizen loyalty (0-100%) | Affects manpower availability and rebellion risk |
| Government Treasury | Tax-funded budget pool | Separate from campaign funds; used for military, infrastructure, social programs |
| Military Strength | Combined armed forces power | Determines war outcomes and deterrence |
| Technology Level | Average military tech (1-10) | Flat bonuses to military effectiveness |
| Manpower | Available military recruits | Population × Morale × 20% |

### 3. **Government Systems & Career Progression**

All government types use **simplified election mechanics**: compete against 2-4 AI opponents to win office.

---

#### **Template A: Presidential System**
*Countries: United States, Russia, France, Brazil*

| Level | Title | Term Length | Min. Age | Unlock Requirements | Unlocks |
|-------|-------|-------------|----------|---------------------|---------|
| 1 | Community Organizer | 2 years | 18 | Base stats + apply | Local influence, small projects |
| 2 | City Council Member | 2 years | 21 | Approval 40%, Reputation 30, Funds $10k | Local budgets, media exposure |
| 3 | Mayor | 4 years | 25 | Approval 50%, Reputation 45, Funds $50k | City budget, taxation, crisis response |
| 4 | State/Regional Representative | 2 years | 25 | Approval 55%, Reputation 50, Funds $100k | Regional legislation |
| 5 | Governor/Regional Leader | 4 years | 30 | Approval 60%, Reputation 60, Funds $500k | Regional military, territory management |
| 6 | Senator/National Legislature | 6 years | 30 | Approval 65%, Reputation 70, Funds $1M | National lawmaking, diplomacy |
| 7 | Vice President | 4 years | 35 | Approval 70%, Reputation 80, Funds $5M | National influence |
| 8 | **President** | 4 years | 35 | Approval 75%, Reputation 85, Funds $10M | Full executive control, warfare, legacy |

**Localized Titles:**
- **USA:** President, Vice President, Senator, Governor, State Representative
- **Russia:** President, Prime Minister (VP equivalent), Federation Council Member, Governor, Deputy
- **France:** President, Prime Minister, Senator, Regional President, Deputy
- **Brazil:** President, Vice President, Senator, Governor, Deputy

---

#### **Template B: Parliamentary System**
*Countries: United Kingdom, Germany, Japan, India*

| Level | Title | Term Length | Min. Age | Unlock Requirements | Unlocks |
|-------|-------|-------------|----------|---------------------|---------|
| 1 | Community Organizer | 2 years | 18 | Base stats + apply | Local influence |
| 2 | Local Councillor | 4 years | 21 | Approval 40%, Reputation 30, Funds $10k | Local budgets |
| 3 | Mayor/City Leader | 4 years | 25 | Approval 50%, Reputation 45, Funds $50k | City management, taxation |
| 4 | Regional Assembly Member | 4 years | 25 | Approval 55%, Reputation 50, Funds $100k | Regional legislation |
| 5 | First Minister/Regional Leader | 4 years | 30 | Approval 60%, Reputation 60, Funds $500k | Regional governance, territory |
| 6 | Member of Parliament (MP) | 5 years | 30 | Approval 65%, Reputation 70, Funds $1M | National legislation |
| 7 | Cabinet Minister | 5 years | 35 | Approval 70%, Reputation 80, Funds $5M | Executive department control |
| 8 | **Prime Minister/Chancellor** | 5 years | 35 | Approval 75%, Reputation 85, Funds $10M | Full government control, warfare |

**Localized Titles:**
- **UK:** Prime Minister, Cabinet Minister, MP, First Minister (Scotland/Wales/NI), Mayor, Councillor
- **Germany:** Chancellor, Federal Minister, Bundestag Member, Minister-President (state), Mayor
- **Japan:** Prime Minister, Cabinet Minister, Diet Member, Governor, Mayor
- **India:** Prime Minister, Cabinet Minister, MP, Chief Minister (state), Mayor

**UK-Specific Regions:**
- England (130k sq mi, 56M pop) - No devolved government
- Scotland (30k sq mi, 5.5M pop) - Scottish Parliament, First Minister
- Wales (8k sq mi, 3M pop) - Welsh Assembly, First Minister
- Northern Ireland (5k sq mi, 1.9M pop) - NI Assembly, First Minister

**Separatist Mechanics:**
- Scotland, Wales, NI have independence referendum risks (based on approval, morale)
- Player can campaign for/against independence as regional leader

---

#### **Template C: Single-Party System**
*Countries: China*

| Level | Title | Term Length | Min. Age | Unlock Requirements | Unlocks |
|-------|-------|-------------|----------|---------------------|---------|
| 1 | Party Member | 2 years | 18 | Base stats + apply | Local party work |
| 2 | Local Party Secretary | 3 years | 21 | Approval 40%, Reputation 30, Funds $10k | Local governance |
| 3 | Mayor/City Secretary | 4 years | 25 | Approval 50%, Reputation 45, Funds $50k | City budget, taxation |
| 4 | Provincial Deputy | 3 years | 25 | Approval 55%, Reputation 50, Funds $100k | Provincial legislation |
| 5 | Provincial Governor/Secretary | 5 years | 30 | Approval 60%, Reputation 60, Funds $500k | Provincial military, territory |
| 6 | National People's Congress Member | 5 years | 30 | Approval 65%, Reputation 70, Funds $1M | National policy |
| 7 | Politburo Member | 5 years | 35 | Approval 70%, Reputation 80, Funds $5M | Central Committee influence |
| 8 | **General Secretary/President** | 5 years | 35 | Approval 75%, Reputation 85, Funds $10M | Supreme authority, warfare |

**Election Mechanics:**
- Compete in **party elections** against 2-4 internal candidates
- "Approval Rating" represents **party loyalty** rather than public opinion
- Still uses election voting system (party delegates vote)

**Localized Titles:**
- **China:** General Secretary, Politburo Standing Committee, NPC Member, Provincial Secretary

**China-Specific Regions:**
- 23 Provinces + 5 Autonomous Regions (Tibet, Xinjiang, Inner Mongolia, Guangxi, Ningxia)
- 2 Special Administrative Regions: Hong Kong (427 sq mi, 7.5M pop), Macau (12 sq mi, 680k pop)
- **Separatist Risks:** Tibet, Xinjiang, Hong Kong (high rebellion chance if low approval/morale)

---

#### **Template D: Absolute Monarchy**
*Countries: Saudi Arabia*

| Level | Title | Term Length | Min. Age | Unlock Requirements | Unlocks |
|-------|-------|-------------|----------|---------------------|---------|
| 1 | Royal Family Member | Hereditary | 18 | Born into royal family | Court influence |
| 2 | Local Governor (Appointed) | 3 years | 21 | Approval 40%, Reputation 30 | Provincial governance |
| 3 | Mayor/City Governor | 4 years | 25 | Approval 50%, Reputation 45, Funds $50k | City management |
| 4 | Regional Emir | 5 years | 25 | Approval 55%, Reputation 50, Funds $100k | Regional control |
| 5 | Provincial Governor | 5 years | 30 | Approval 60%, Reputation 60, Funds $500k | Provincial military |
| 6 | Minister of State | 5 years | 30 | Approval 65%, Reputation 70, Funds $1M | National policy |
| 7 | Crown Prince | Life | 35 | Approval 70%, Reputation 80, Funds $5M | Succession rights |
| 8 | **King/Sultan** | Life | 35 | Inherit or coup | Absolute power, warfare |

**Unique Mechanics:**
- **No direct elections** for King - must inherit via succession or seize power (special event)
- Lower positions use **appointed selection** with competition (King chooses from candidates)
- "Approval Rating" = Royal Court favor + public support
- **Succession Crisis Events:** Compete with siblings/cousins for throne

**Localized Titles:**
- **Saudi Arabia:** King, Crown Prince, Minister, Provincial Governor, Emir

---

### **Universal Career Progression Rules**

**Election System:**
- All positions (except monarchy inheritance) require **winning elections**
- Compete against **2-4 AI opponents** with randomized stats/platforms
- Victory based on: Approval Rating, Campaign Funds, Charisma, Luck, and event outcomes

**Advancement Requirements:**
- Meet **stat thresholds** from previous term performance
- **Position skipping allowed:** Jump levels if stats/funds exceed requirements
- **Election failure:** Can re-run for same position or try different positions

**Term Limits:**
- No artificial term limits (can serve indefinitely if re-elected)
- No special benefits/drawbacks for extended service

### 4. **Election System**
- **Campaign Phase:** Manage funds, speeches, ads, debates.
- **Public Opinion Tracker:** Shows shifting voter sentiment.
- **Events:** Scandals, endorsements, and debates can swing votes.
- **Voting Simulation:** Weighted based on popularity, charisma, campaign success.

### 5. **Event System**
Events trigger based on current position, age, and context. Each career level has a unique event pool.

**Event Frequency:**
- Early Life (0-17): ~5 events per year (education, family, social)
- Community Organizer: ~8-10 events per term
- City Council/Mayor: ~12-15 events per term
- State Rep/Governor: ~15-20 events per term
- Senator/VP: ~20-25 events per term
- President: ~25-30 events per term

**Event Types:**
- **Public Speeches:** Affect charisma and approval rating
- **Scandals:** Corruption, affairs, mismanagement (risk based on Reputation stat)
- **Policy Proposals:** Long-term consequences for economy, crime, environment
- **Media Interviews:** Shape public perception
- **Crises:** Natural disasters (contextual to location), protests, pandemics, economic downturns
- **Personal Events:** Family matters, health issues, unexpected opportunities
- **International Events:** Border disputes, trade negotiations, alliance requests (national level only)

**Contextual Events by Geography:**
- Coastal regions: hurricanes, port trade issues
- Agricultural states: droughts, farm subsidies
- Urban areas: crime, housing crises
- Border states: immigration debates

**Country-Specific Event Pools:**
Each of the 10 playable countries has **unique events** reflecting their political/cultural context:

- **USA:** Gun control debates, immigration policy, Supreme Court appointments, tech regulation
- **UK:** Brexit-style referendums, Scottish independence votes, NHS funding crises, royal scandals
- **China:** Hong Kong protests, Taiwan relations, Xinjiang policies, economic planning, Tiananmen-style events
- **Russia:** Oligarch relations, Crimea-style annexations, energy diplomacy, opposition protests
- **Germany:** EU leadership decisions, refugee crises, reunification legacies, industrial policy
- **France:** Labor strikes, colonial legacy issues, secularism debates, pension reform protests
- **Japan:** Aging population, earthquake/tsunami disasters, US alliance questions, Yasukuni controversies
- **India:** Caste politics, Kashmir conflicts, climate disasters, tech boom policies
- **Brazil:** Amazon deforestation, favela violence, corruption scandals (Lava Jato-style), Carnival culture
- **Saudi Arabia:** Oil price shocks, Hajj management, women's rights reforms, Yemen conflicts, succession crises

Player responses modify base attributes, approval rating, funds, and stress.

### 6. **Policy System**
Policies have **immediate** and **delayed effects** based on their nature.

**Policy Categories:**
- **Economic:** Tax policy, business regulation, trade agreements
- **Social:** Education funding, healthcare, welfare programs
- **Environmental:** Climate initiatives, conservation, pollution control
- **Criminal Justice:** Policing, sentencing reform, drug policy
- **Foreign:** Diplomatic relations, trade, military action (President only)

**Effect Timeline Examples:**
- Tax changes: Immediate fund impact, approval shift within 1 month
- Education funding: Approval bump in 6 months, intelligence/reputation boost in 2-4 years
- Infrastructure projects: Approval drop initially (costs), major boost after 3-5 years (completion)
- Crime reduction policies: Results visible in 1-2 years
- Environmental policies: Long-term effects (5-10 years), divisive short-term approval

**Policy Memory:**
- Citizens remember policies enacted during tenure
- Past decisions influence future elections and approval ratings
- Negative policies can resurface as scandals or campaign attacks

### 7. **Relationship System** (Minimal NPC Focus)
While individual NPCs are **not a core mechanic**, the game tracks relationships with **groups and factions**:

- **Political Party Alignment:** Affects funding and endorsements
- **Donor Networks:** Corporate, union, grassroots (fund sources vary by alignment)
- **Media Favorability:** Positive coverage increases approval; negative coverage raises scandal risk
- **Voter Blocs:** Track approval across demographics (age, income, geography)

Named NPCs appear only in **critical story events** (rivals in elections, major donors, family members). Most interactions are systemic rather than character-driven.

### 8. **Scandal & Media System**
**Scandal Mechanics:**
- Each unethical choice has a **hidden scandal risk value** (0-100%)
- Risk of exposure depends on **Reputation stat**:
  - High Reputation (70+): -30% scandal exposure chance
  - Medium Reputation (40-69): Standard exposure chance
  - Low Reputation (<40): +50% scandal exposure chance, higher severity
- Scandals can break weeks, months, or even years after the action

**Scandal Types:**
- Minor: Brief approval drop (-5-15%), increases stress
- Major: Significant approval/reputation loss (-20-40%), campaign fund penalties
- Career-Ending: Forced resignation from current position (if Reputation <20)

**Scandal Response Options:**
1. **Deny:** Low risk if false accusations, high risk if true (gamble on Luck stat)
2. **Apologize:** Moderate approval loss, faster recovery, +Reputation over time
3. **Spin/Deflect:** Uses Charisma check; success minimizes damage
4. **Resign:** Avoid further damage, step down from position

**Survival:**
- Players with high Reputation (60+) can survive most scandals
- Low Reputation (<30) makes even minor scandals career-threatening
- Scandals increase stress, which affects health

### 9. **Economy & Fund Management**
**Income Sources:**
- Donations (based on approval rating, party alignment, donor networks)
- Fundraising events (player-initiated, costs stress/time)
- Personal wealth (starting background affects initial funds)

**Expenses:**
- Campaign advertising (required for competitive elections)
- Staff salaries (higher positions = more staff needed)
- Crisis management (scandal cleanup, disaster response)
- Events and public appearances

**Fund Thresholds:**
- Running for higher office requires substantial campaign funds (see Career Progression table)
- Insufficient funds = cannot run for election
- Excess funds can be saved for future campaigns or used for approval-boosting initiatives

### 10. **Taxation & Government Budget System**
Available at Mayor level and above. Separate from campaign funds.

#### Tax System
**Tax Rate Control:**
- **Simple slider:** 0% to 100% (practical range: 10-60%)
- **Immediate approval impact:** Higher taxes = immediate approval drop
- **Revenue calculation:** Tax Rate × Territory Size × Population = Annual Revenue

**Tax Rates by Position:**
- **Mayor:** Property/local taxes (affects city budget)
- **Governor:** State income/sales taxes (affects state budget)
- **President:** Federal taxes + tariffs + territory tributes (affects national budget)

**Approval Impact Formula:**
- Tax Rate 0-20%: +5% approval (low taxes, popular)
- Tax Rate 21-40%: No change (moderate taxes)
- Tax Rate 41-60%: -10% approval (high taxes, unpopular)
- Tax Rate 61-100%: -25% approval + rebellion risk (extreme taxes)

#### Government Budget Categories
**Revenue Sources:**
- Tax revenue (based on territory, population, tax rate)
- Trade tariffs (President only)
- Territory tributes (from vassal states)
- Natural resource income (from controlled territories)

**Spending Categories:**
1. **Military:** Defense spending, troop maintenance, R&D
2. **Infrastructure:** Roads, utilities, public works
3. **Social Programs:** Healthcare, education, welfare
4. **Debt Payments:** Interest on national debt (if applicable)
5. **Administration:** Government salaries, operations

**Budget Management:**
- Player allocates budget percentages to each category
- Underfunding Military → decreased Military Strength
- Underfunding Social Programs → approval drops
- Underfunding Infrastructure → economic penalties

**Separation from Campaign Funds:**
- Government budget and campaign funds are **completely separate**
- Illegally transferring government funds to campaign = major scandal (60-80% scandal risk)
- No legitimate interaction between the two pools

---

### 11. **Warfare & Territory Management System**
Unlocked at **Governor** and **President** levels. Core endgame mechanic.

#### Nation/Territory Stats (New)
| Stat | Description | Range/Example |
|------|-------------|---------------|
| Territory Size | Total land controlled (square miles) | 0 - 196.9M (world max) |
| Population | Total citizens under control | Millions (e.g., 330M for USA) |
| Population Morale | Citizen satisfaction and loyalty | 0-100% |
| Military Strength | Combined armed forces power | 0-999,999+ |
| Technology Level | Military tech advancement | 1-10 |
| Manpower | Available military recruits | % of population based on morale |

#### Starting Territories by Country

When reaching top leadership (President/PM/King/General Secretary), players inherit their country's **real-world territory:**

**Playable Countries (Phase 1):**

| Country | Territory Size | Population | Internal Regions | Notes |
|---------|---------------|------------|------------------|-------|
| **United States** | 3.8M sq mi | 330M | 50 states | Governors control individual states |
| **United Kingdom** | 94k sq mi | 67M | England, Scotland, Wales, NI | Devolution, separatist risks (Scotland, NI) |
| **China** | 3.7M sq mi | 1.4B | 23 provinces, 5 autonomous regions, 2 SARs | High separatist risk (Tibet, Xinjiang, Hong Kong) |
| **Russia** | 6.6M sq mi | 144M | 46 oblasts, 22 republics | Largest territory, regional autonomy |
| **Germany** | 138k sq mi | 83M | 16 federal states (Länder) | Strong regional governments |
| **France** | 213k sq mi | 67M | 13 metropolitan regions + overseas territories | Overseas territories (Guiana, Réunion, etc.) |
| **Japan** | 146k sq mi | 125M | 47 prefectures | Island nation, limited expansion potential |
| **India** | 1.3M sq mi | 1.4B | 28 states, 8 union territories | Diverse regions, high population |
| **Brazil** | 3.3M sq mi | 215M | 26 states + federal district | Amazon territory, resource-rich |
| **Saudi Arabia** | 830k sq mi | 36M | 13 provinces | Desert kingdom, oil-dependent economy |

**Regional Leaders (Governor/First Minister equivalent):**
- Control **individual regions** within their country
- Can wage war against federal government (civil war)
- Can form alliances with other regional leaders

---

#### World Simulation

**All ~195 countries exist** as independent AI-controlled nations:
- **No pre-existing alliances** (no EU, NATO, UN, etc. at game start)
- **All alliances/enemies** formed dynamically through gameplay
- Non-playable countries can:
  - Declare wars on each other or player
  - Form alliances, trade agreements
  - Be conquered by player or other AI nations
  - Experience internal rebellions, coups
- **Example non-playable countries:** Canada, Mexico, Australia, South Korea, Italy, Spain, Egypt, South Africa, Argentina, etc.

**Dynamic World:**
- Country borders change based on wars/conquests
- AI nations have simplified stats (Military Strength, Territory, Population, Tech Level)
- Player can conquer and absorb non-playable countries

#### Territory Types
1. **Core Territory:** Your primary nation (starting land)
2. **Conquered Territory:** Land gained through successful warfare
3. **Purchased Territory:** Land acquired via diplomatic purchase
4. **Vassal States:** Semi-independent allies who pay tribute (5-15% of their tax revenue)
5. **Colonies:** Fully controlled overseas territories (require garrisons, -10% approval domestically)
6. **Rebel Zones:** Territories in active rebellion (no revenue, military cost to reclaim)

#### Population & Manpower Mechanics
**Population Growth:**
- **Natural Growth:** +0.5% to 2% per year (based on social program funding)
- **Immigration:** Boosted by high approval, low taxes, peace
- **War Losses:** -1% to -10% during active wars (depending on intensity)
- **Territory Loss:** Permanent population reduction (lost land's population removed)
- **Recovery:** Can regain population via conquest, immigration, natural growth

**Manpower Pool:**
- **Calculation:** Population × Population Morale × 0.20 = Available Manpower
- Example: 330M pop × 70% morale = 231M × 20% = **46.2M potential soldiers**
- **Conscription vs. Volunteer:**
  - Volunteer army: No approval penalty, slower recruitment
  - Conscription: -15% approval, rapid mobilization

**Population Morale:**
- Affected by: Tax rates, war weariness, approval rating, social spending
- Low morale (<40%) → Rebellion risk, reduced manpower
- High morale (70+%) → Maximum military potential, civic stability

#### Military System
**Military Strength Calculation:**
- Base: (Manpower × Training) + (Equipment × Tech Level) + (Defense Spending)
- **Single abstract number** (e.g., Military Strength: 450,000)

**Technology Research (10 Categories):**
1. **Infantry Weapons:** Small arms, body armor
2. **Armored Vehicles:** Tanks, APCs
3. **Naval Power:** Ships, submarines
4. **Air Superiority:** Fighters, bombers
5. **Missile Systems:** Rockets, ICBMs
6. **Cyber Warfare:** Digital attack/defense
7. **Logistics:** Supply chains, mobilization speed
8. **Medical Tech:** Reduce casualties, morale boost
9. **Intelligence:** Espionage, reconnaissance
10. **Nuclear Weapons:** Ultimate deterrent (scandal risk if used)

**Research Mechanics:**
- **Time-based:** Invest funds → Wait X months for completion (3-12 months per level)
- **Cost scaling:** Level 1 = $500M, Level 10 = $50B
- **Tech Bonuses:** Each level adds +10% to Military Strength (flat bonus)
- Example: Level 5 Infantry Weapons = +50% to ground forces effectiveness

#### Warfare Mechanics

**Declaring War:**
- **Governors:** Can declare war on federal government or allied states
  - Forms state alliances (e.g., California + Texas vs. Federal Government)
  - High rebellion/civil war risk
- **Presidents:** Can declare war on any nation
  - **Justified wars** (defensive, border disputes): -5% approval
  - **Unjustified wars** (pure aggression): -30% approval, -20 Diplomacy

**War Duration:**
- **Average:** 8 months (240 days)
- **Factors affecting length:**
  - Military Strength difference (evenly matched = longer)
  - Technology gap (high tech = faster victory)
  - Defender terrain bonuses
  - Diplomacy stat (high Diplomacy = faster negotiations)

**War Resolution (Background Simulation):**
- Runs automatically as player skips days/weeks
- **Periodic war events** (every 2-4 weeks):
  - "Enemy counterattack in northern territories"
  - "Your forces captured strategic city"
  - "Allies request additional funding"
  - Player makes tactical decisions (2-4 choices per event)

**War Outcome Mechanics:**
- **Victory Conditions:**
  - Opponent's Military Strength reduced to <20%
  - Opponent runs out of funds
  - Opponent's population morale <10% (mass desertion)
  - Diplomatic surrender (Diplomacy check)

- **Defeat Conditions:**
  - Your Military Strength <20%
  - Government funds = $0
  - Population morale <10%
  - Forced to sue for peace

**Peace Negotiations (Diplomacy-based):**
Players can initiate peace talks mid-war using Diplomacy stat.

**Diplomacy Check Success:**
- Diplomacy 70+: -30% to opponent's demands
- Diplomacy 40-69: Standard negotiation
- Diplomacy <40: +20% to opponent's demands

**Peace Terms (based on Military Strength ratio):**

| Your Strength vs. Enemy | Peace Options |
|-------------------------|---------------|
| 2:1 or better (Dominating) | Demand territory + reparations |
| 1.5:1 (Winning) | Partial territory gain, modest reparations |
| 1:1 (Evenly Matched) | White peace (status quo, no changes) |
| 1:1.5 (Losing) | Pay tribute ($5-10B), minor territory loss (5-10%) |
| 1:2 or worse (Defeated) | Major territory loss (20-40%), heavy reparations ($20-50B) |

**Victory Spoils (Automatic):**
Winning wars grant rewards based on:
- **Enemy Territory Size:** Conquer 10-40% of their land (depends on dominance)
- **War Speed:** Faster victories = larger territorial gains
- **Reparations:** 10-30% of enemy's government treasury
- **Approval Boost:** +10-25% approval (defensive wars higher)

**War Consequences:**
- **Funds Depletion:** -$500M to -$10B per month (based on military size)
- **Manpower Drain:** -2% to -15% population casualties
- **War Weariness:** Each month of war = -2% population morale
- **Scandal Risk:** Unethical tactics (targeting civilians, war crimes) = 40-70% scandal chance

#### Rebellion System
**Triggers:**
- Tax Rate >60%: +10% rebellion risk per year
- War Weariness (morale <30%): +15% rebellion risk
- Low approval in specific territories: +5-20% rebellion risk
- Combination of above: Cumulative risk

**Rebellion Mechanics:**
- **Territory declares independence** → Triggers civil war
- **Rebel faction stats:**
  - Territory: Rebelling region's size
  - Population: Region's population
  - Military Strength: 30-60% of your strength (depends on morale)

**Suppressing Rebellions:**
- Treated as standard war (8-month average duration)
- **Victory:** Reclaim territory, -10% approval (brutal suppression)
- **Defeat:** Territory becomes independent nation permanently
- **Negotiation:** High Diplomacy can grant autonomy (vassal state) instead of war

#### Territory Acquisition
**Methods:**
1. **Military Conquest:** Win wars → automatic territorial gains
2. **Diplomatic Purchase:** Spend funds + Diplomacy check
   - Example: Offer $50B + Diplomacy 70+ to buy 200k sq miles
   - Success rate: 20-60% (depends on target nation's financial need)
3. **Vassal Integration:** Convert vassal states to full territories (costs funds, approval)

**Territory Benefits:**
- **Tax Revenue:** (Territory Size × Population Density × Tax Rate) / 12 = Monthly Income
- **Resources:** Some territories provide bonuses (oil, minerals, farmland)
- **Manpower:** Larger population = larger military potential

**Territory Costs:**
- **Garrison Maintenance:** -$10M to -$500M per month (based on size)
- **Colonial Approval Penalty:** -5% approval per overseas colony
- **Rebellion Risk:** Newly conquered territories have 30% rebellion chance (first 2 years)

---

### 12. **Legacy System (Endgame)**
When a character dies or retires, their **political legacy** is calculated and saved.

**Legacy Components:**
- **Highest Office Achieved:** President, Senator, Governor, etc.
- **Historical Approval Rating:** Average approval across entire career
- **Major Accomplishments:** Policies enacted, crises resolved, reforms passed, wars won
- **Territory Controlled:** Final empire size (if applicable)
- **Scandals & Controversies:** Permanent record of ethical failures
- **Moral Alignment:**
  - Saint (Reputation 80+, low scandal count)
  - Pragmatist (Balanced stats, moderate scandals)
  - Opportunist (High success, questionable ethics)
  - Corrupt (Low reputation, high scandal count)
  - **Conqueror** (Controlled 50%+ of world territory)
  - **Peacemaker** (High Diplomacy, minimal wars)

**Legacy Benefits:**
- Unlocks starting bonuses for future playthroughs
- Achievements/milestones tracked across all careers
- Hall of Fame leaderboard (local, not cloud-based)
- Special starting scenarios unlock based on past achievements

---

## UI/UX Design

### Main Screen Layout
- **Top Bar:**
  - Character name, age, current position
  - **Skip Day** and **Skip Week** buttons (top-right)
- **Stats Display:**
  - **Base Attributes** (exact numbers shown, e.g., "67/100"):
    - Charisma, Intelligence, Reputation, Luck, Diplomacy
  - **Secondary Stats** (exact values visible):
    - Approval Rating (percentage), Funds (dollar amount), Health (0-100), Stress (0-100)
  - **Hidden Values** (not displayed to player):
    - Scandal risk percentages for past unethical actions
- **Event Panel:** Center screen
  - Event title and description
  - 2-4 choice buttons with brief outcome previews
- **Activity Log:** Bottom drawer (collapsible)
  - Recent events, stat changes, news headlines

### Navigation Tabs
- **Profile:** Full stat breakdown, career history, achievements
- **Policies:** Active policies, pending proposals, policy history
- **Finances (Campaign):** Campaign fund income/expense tracker, donation history, fundraising options
- **Government Budget:** *(Unlocked at Mayor+)* Tax rates, revenue, spending allocation, treasury balance
- **Media:** News feed showing recent headlines about player's actions
- **Career:** Unlock tree showing available positions and requirements
- **Territory Map:** *(Unlocked at Governor+)* Simple list view of controlled territories with stats (size, population, morale, rebellion risk)
- **War Room:** *(Unlocked at Governor+, active during wars)* Ongoing conflicts, military strength, war events, peace negotiation
- **Military & Tech:** *(Unlocked at Governor+)* Military strength overview, technology research menu, manpower status
- **Settings:** Save/load, autosave toggle (default: every 2 seconds), audio, difficulty

### War Room Screen (Dedicated Interface)
**Activated when at war:**
- **Current War Status:**
  - Enemy nation name
  - War duration (days elapsed)
  - Your Military Strength vs. Enemy Military Strength
  - Territory control map (simple visual or percentage bars)
  - Casualties and fund expenditure tracker
- **Action Buttons:**
  - Continue War (return to main game)
  - Negotiate Peace (opens Diplomacy check interface)
  - War Strategy Options (aggressive, defensive, attrition)
- **War Events Panel:**
  - Recent battle results
  - Strategic decisions (player choices)
  - Ally requests
- **Victory/Defeat Tracker:**
  - Progress bar showing relative strength
  - Estimated time to victory/defeat

### Alert/Notification System
**Pop-up notifications for:**
- War declared (by you or against you)
- Territory lost/gained
- Rebellion started
- Technology research completed
- Major war event (critical battle, enemy surrender offer)
- Peace treaty signed
- Government budget crisis (funds <$0)

---

## Art & Audio
**Style:** Minimalist UI, color-coded stats, simple icons. Optional avatars.
**Audio:** Subtle ambient tracks (city hall, rallies, debates), button click sounds, applause/boo reactions.

---

## Technical Overview
- **Language:** Swift 5+
- **Framework:** SwiftUI for UI, Combine for reactivity
- **Data Persistence:**
  - Local save files using Codable JSON
  - Multiple career save slots supported
  - Autosave every 2 seconds (configurable)
  - Manual save/load functionality
  - No cloud sync
- **Random Events Engine:**
  - Weighted RNG with dynamic probability adjustment based on stats
  - Event pools categorized by career level, age, and geography
  - Contextual event triggering (location, current crises, past decisions)
- **State Management:**
  - GameManager singleton with ObservableObjects
  - Character state (stats, age, position, country)
  - Event queue and history
  - Policy tracker with delayed effect system
  - Scandal risk accumulator
  - **Country configuration system:**
    - Government type templates (Presidential, Parliamentary, Single-Party, Monarchy)
    - Localized position titles per country
    - Country-specific event pools
    - Internal regional structures (states, provinces, etc.)
  - **Nation state management** (Governor/President):
    - Territory collection (size, population, morale per territory)
    - Military strength calculator
    - Technology research queue with completion timers
    - Active war tracker (multiple concurrent wars supported)
    - Rebellion risk monitor
    - Government budget allocator
  - **World simulation:**
    - ~195 AI country entities with stats
    - Dynamic alliance/enemy tracking
    - AI war declarations and diplomacy
    - Country conquest/absorption system
- **Warfare Engine:**
  - Background war simulation (strength calculations, attrition modeling)
  - War event generator (contextual tactical decisions every 2-4 weeks)
  - Peace negotiation resolver (Diplomacy checks)
  - Victory/defeat condition evaluator
  - Territory transfer system
  - Population casualty calculator
- **Time System:**
  - Manual progression via Skip Day/Skip Week buttons
  - Age advancement with natural lifespan limits
  - Health decay system tied to stress and age
  - **War duration tracking** (concurrent with regular time progression)
  - **Technology research timers** (countdown to completion)

---

## Monetization
- **Free-to-play base**
- **In-app purchases:**
  - Premium currency for re-rolling events or elections
  - Cosmetic themes (dark mode, luxury suit packs, custom campaign colors)
  - Ad removal
  - Career boost (e.g., instant promotion to mayor)

---

## Expansion Ideas

### Future Country Additions (Post-Launch DLC)
**Tier 2 Countries (~20-30 additional playable countries):**
- **Europe:** Italy, Spain, Poland, Netherlands, Sweden, Turkey
- **Asia:** South Korea, Indonesia, Thailand, Vietnam, Pakistan, Iran
- **Americas:** Canada, Mexico, Argentina, Colombia, Venezuela
- **Africa:** Egypt, Nigeria, South Africa, Kenya, Ethiopia
- **Oceania:** Australia, New Zealand
- Each uses existing government templates with unique event pools

### Gameplay Expansions
- **Multiplayer Leaderboards:** Compare legacies across all players
- **Historical Mode:** Recreate famous elections (JFK 1960, Thatcher 1979, Mandela 1994)
- **Corruption Challenge Mode:** Stay in power despite maximum scandals
- **Dynasty Mode:** Family succession across multiple generations
- **Cold War Scenario:** Superpowers compete for global influence (USA vs. China/Russia)
- **Achievement System:** Unlock special badges and bonuses for completing challenges
  - Examples: "Clean Sweep" (reach top office with 0 scandals)
  - "Comeback Kid" (win election after previous loss)
  - "World Domination" (control 80%+ of world territory)
  - "Peaceful Unifier" (unite 3+ countries via diplomacy without war)
  - "Revolutionary" (win monarchy via coup in Saudi Arabia)
  - "Iron Fist" (suppress 5+ rebellions successfully)

---

## Example Event Flow

### Event 1: Corporate Donation
**Context:** Player is Mayor, Reputation: 55

**Event Text:**
"MegaCorp Industries offers a $200,000 donation to your campaign in exchange for relaxing environmental regulations on their new factory."

**Choices:**
1. **Accept privately** → Funds +$200k, Reputation -15, Scandal Risk +40%, Stress +10
2. **Publicly reject** → Approval +8%, Reputation +5, Funds -$50k (lost donor confidence)
3. **Negotiate compromise** → Funds +$100k, Reputation -5, Scandal Risk +15%, uses Diplomacy check
4. **Report the bribe** → Reputation +20, Approval +15%, investigation event triggers next week

**Outcome (if Accept privately):**
- Immediate fund boost allows player to run for Governor
- Hidden scandal timer starts (60% chance to break in next 6-24 months)
- Environmental policy shifted negatively (long-term approval consequences)
- Media headline (if caught): "Mayor Accused of Pay-to-Play Scheme"

### Event 2: Education Crisis (Delayed Policy Effect)
**Context:** Player previously cut education funding as City Council Member 3 years ago

**Event Text:**
"Test scores have plummeted since education cuts. Parents are protesting outside your office."

**Choices:**
1. **Restore funding** → Funds -$500k, Approval +5% (slow recovery)
2. **Blame predecessor** → Charisma check; success = no penalty, failure = Reputation -10
3. **Ignore and deflect** → Approval -15%, Stress +20
4. **Launch investigation** → Reveals mismanagement, Reputation +10 if not involved

**Outcome demonstrates:**
- Past policy decisions resurface
- Players cannot escape consequences of earlier choices

---

### Event 3: War Declaration (Governor/President Level)
**Context:** Player is President, neighboring nation has border dispute

**Event Text:**
"The Republic of Cascadia has mobilized troops along your northern border, demanding territorial concessions. Intelligence reports suggest an imminent invasion."

**Choices:**
1. **Declare preemptive war** → War begins (unjustified), Approval -30%, Diplomacy -20, Military mobilization
2. **Fortify borders and wait** → Defensive stance, if attacked = justified war (Approval -5%)
3. **Negotiate territorial concession** → Diplomacy check; success = lose 50k sq miles but avoid war, failure = war declared on you
4. **Offer economic incentive** → Pay $10B, Approval +10% (peaceful resolution), Diplomacy +5

**Outcome (if declare preemptive war):**
- War begins immediately
- Your Military Strength: 450,000 vs. Cascadia: 320,000 (favorable)
- War Room unlocked
- War events begin triggering every 2 weeks
- Government treasury drains -$2B/month
- Population morale begins declining (-2% per month war weariness)

**War Event Example (3 weeks later):**
"Your forces have pushed deep into Cascadian territory. Enemy morale is breaking, but casualties are mounting."

**War Choices:**
1. **Press the attack** → Faster victory (4 months total), higher casualties (-8% population)
2. **Consolidate gains** → Standard pace (8 months), moderate casualties (-4% population)
3. **Offer peace terms** → Diplomacy check to end war early, territorial gains based on current advantage
4. **Use nuclear weapons** → Instant victory, 80% scandal risk, -50% approval, international condemnation

**Final Outcome (if victory after 5 months):**
- Conquered 120k sq miles of Cascadia (40% of their territory)
- Gained $15B in reparations
- Population: 330M → 318M (war casualties)
- Approval: 45% → 60% (victory boost)
- Military Strength: 450k → 380k (needs rebuilding)
- Territory: 3.8M → 3.92M sq miles
- Annual tax revenue increased by $5B (new territory)

---

## Development Roadmap

### Phase 1: Core Framework & Early Life (MVP)
**Timeline:** 3-4 months
**Goals:**
- SwiftUI base architecture with navigation
- **Character creation flow:**
  - Country selection screen (10 playable countries, alphabetical list)
  - Name input (free text), gender selection, background choice
  - Display country info (flag, territory, population, government type)
- Early life events (ages 0-17: education, family, social)
- Time system (Skip Day/Week buttons, age advancement)
- Base attribute system (5 core stats with fluctuation)
- Save/load system (multiple slots, autosave every 2 seconds)
- Basic event engine (random selection, choice consequences)
- **Initial country:** USA only (other 9 countries added in Phase 3)

**Deliverable:** Playable early life simulation from birth to age 18 (USA only)

### Phase 2: Local Politics & Career System
**Timeline:** 3-4 months
**Goals:**
- Career progression system (Community Organizer → Mayor)
- Election mechanics (campaign phase, voting simulation)
- Approval rating and campaign fund management
- Taxation system (tax slider, government budget)
- Expanded event pool (10-15 events per position)
- Policy system with immediate effects
- Scandal mechanics (risk accumulation, exposure, responses)
- Basic UI polish (stat bars, event cards, media feed)

**Deliverable:** Full local political career path with taxation and meaningful choices

### Phase 3: National Politics & Multi-Country Expansion
**Timeline:** 5-6 months
**Goals:**
- State Representative and Governor positions
- U.S. Senator, Vice President, President positions
- National-level events (diplomacy, foreign policy, national crises)
- Policy delayed effects system (timeline-based consequences)
- Contextual events (geographic, position-based)
- **Implement remaining 9 countries:**
  - UK (Parliamentary system, devolution, separatist events)
  - China (Single-party system, provincial governance)
  - Russia (Presidential system, regional republics)
  - Germany, France, Japan, India, Brazil (Templates A/B)
  - Saudi Arabia (Monarchy system)
- **Government system templates:**
  - Template A: Presidential (4 countries)
  - Template B: Parliamentary (4 countries)
  - Template C: Single-Party (1 country)
  - Template D: Absolute Monarchy (1 country)
- **Country-specific event pools** (10-15 unique events per country)
- **Localized position titles** for all countries
- **Territory system basics:**
  - Territory size and population tracking
  - Population morale and growth mechanics
  - Internal regional breakdown (states, provinces, etc.)
- **Military foundations:**
  - Military strength stat
  - Basic technology research system (10 categories)
  - Manpower calculations
- **World simulation foundation:**
  - ~195 AI-controlled countries
  - No pre-existing alliances (all formed dynamically)
- Legacy system (endgame evaluation, unlockables)
- Health/stress/death system

**Deliverable:** Complete career path to top office in all 10 countries with territory/military foundations and world simulation

### Phase 4: Warfare & Empire Building (Endgame Content)
**Timeline:** 4-5 months
**Goals:**
- **Full warfare system:**
  - War declaration mechanics (justified vs. unjustified)
  - Background war simulation (8-month average duration)
  - War events (periodic tactical decisions)
  - Victory/defeat conditions
  - Peace negotiation system (Diplomacy-based)
- **Territory management:**
  - Territory map UI (simple list view)
  - Territory types (core, conquered, vassal, colony, rebel)
  - Territory acquisition (conquest, purchase, vassal integration)
  - Rebellion system with civil war mechanics
- **War Room interface:**
  - Dedicated war screen
  - Military strength comparisons
  - War progress tracking
  - Strategic decision events
- **Military & Tech menu:**
  - Technology research completion and upgrades
  - Military strength breakdown
  - Manpower recruitment (volunteer vs. conscription)
- **Governor warfare:**
  - State vs. federal government conflicts
  - State alliance system
- **Alert/notification system** for wars, rebellions, territory changes
- **Legacy updates:** Conqueror and Peacemaker alignments

**Deliverable:** Complete warfare and territory expansion mechanics

### Phase 5: Polish, Balance & Launch
**Timeline:** 3-4 months
**Goals:**
- Event balancing (difficulty tuning, stat impact refinement)
- **Warfare balancing:**
  - Military strength calculations
  - War duration and outcome tuning
  - Technology research cost/time optimization
  - Territory revenue/cost balancing
- UI/UX improvements (animations, transitions, visual feedback)
- Audio implementation (ambient tracks, sound effects, war audio)
- Monetization integration (IAP, ad removal, cosmetics)
- Extensive playtesting (especially warfare loops)
- Performance optimization
- App Store submission and marketing prep

**Deliverable:** Production-ready iOS app with full warfare system

---

## Tagline
> "From community meetings to the Oval Office — every decision shapes your legacy."

