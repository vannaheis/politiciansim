//
//  EventEngine.swift
//  PoliticianSim
//
//  Event system manager for triggering and handling events
//

import Foundation
import Combine

class EventEngine: ObservableObject {
    @Published var currentEvent: Event?
    @Published var eventHistory: [Event] = []

    private var allEvents: [Event] = []
    private var triggeredEventIds: Set<String> = []

    init() {
        loadEvents()
    }

    // MARK: - Event Loading

    private func loadEvents() {
        // Load sample events for now
        // In Phase 2, this will load from JSON
        allEvents = createSampleEvents()
    }

    // MARK: - Event Checking

    func checkForEvent(character: Character, role: Character.CharacterRole) -> Event? {
        guard currentEvent == nil else { return nil }

        let eligibleEvents = allEvents.filter { event in
            isEventEligible(event: event, character: character, role: role)
        }

        guard !eligibleEvents.isEmpty else { return nil }

        // Random chance to trigger event (30% per day)
        if Double.random(in: 0...1) < 0.3 {
            if let selectedEvent = eligibleEvents.randomElement() {
                currentEvent = selectedEvent
                triggeredEventIds.insert(selectedEvent.eventId)
                return selectedEvent
            }
        }

        return nil
    }

    private func isEventEligible(event: Event, character: Character, role: Character.CharacterRole) -> Bool {
        // Check if already triggered (for one-time events)
        if triggeredEventIds.contains(event.eventId) {
            return false
        }

        // Filter events based on character role
        switch role {
        case .student:
            // Students get education-related events primarily
            guard event.category == .education || event.category == .personal else { return false }
        case .unemployed:
            // Unemployed get broad activities and personal events
            guard event.category != .political && event.category != .education else { return false }
        case .politician:
            // Politicians get political events primarily
            guard event.category == .political || event.category == .scandal || event.category == .personal else { return false }
        }

        // Check age range
        let age = Calendar.current.dateComponents([.year], from: character.birthDate, to: character.currentDate).year ?? 0
        guard event.ageRange.contains(age) else { return false }

        // Check position requirement
        if let requiredPosition = event.requiredPosition {
            guard character.currentPosition?.title == requiredPosition else { return false }
        }

        // Check all triggers
        for trigger in event.triggers {
            if !evaluateTrigger(trigger: trigger, character: character) {
                return false
            }
        }

        return true
    }

    private func evaluateTrigger(trigger: Trigger, character: Character) -> Bool {
        switch trigger.condition {
        case .statMinimum(let stat, let min):
            switch stat.lowercased() {
            case "charisma": return character.charisma >= min
            case "intelligence": return character.intelligence >= min
            case "health": return character.health >= min
            case "reputation": return character.reputation >= min
            default: return false
            }

        case .ageRange(let min, let max):
            let age = Calendar.current.dateComponents([.year], from: character.birthDate, to: character.currentDate).year ?? 0
            return age >= min && age <= max

        case .hasPosition(let title):
            return character.currentPosition?.title == title

        case .approvalMinimum(let min):
            return character.approvalRating >= min
        }
    }

    // MARK: - Event Handling

    func handleChoice(choice: Event.Choice, character: inout Character) {
        guard let event = currentEvent else { return }

        // Apply all effects from the choice
        for effect in choice.effects {
            applyEffect(effect: effect, to: &character)
        }

        // Add to history
        eventHistory.append(event)

        // Clear current event
        currentEvent = nil
    }

    private func applyEffect(effect: Effect, to character: inout Character) {
        switch effect.value {
        case .statChange(let stat, let amount):
            switch stat.lowercased() {
            case "charisma":
                character.charisma = max(0, min(100, character.charisma + amount))
            case "intelligence":
                character.intelligence = max(0, min(100, character.intelligence + amount))
            case "reputation":
                character.reputation = max(0, min(100, character.reputation + amount))
            case "diplomacy":
                character.diplomacy = max(0, min(100, character.diplomacy + amount))
            case "luck":
                character.luck = max(0, min(100, character.luck + amount))
            default:
                break
            }

        case .approvalChange(let amount):
            character.approvalRating = max(0, min(100, character.approvalRating + amount))

        case .fundsChange(let amount):
            character.campaignFunds += amount

        case .healthChange(let amount):
            character.health = max(0, min(100, character.health + amount))

        case .stressChange(let amount):
            character.stress = max(0, min(100, character.stress + amount))

        case .scandalRisk(_, _):
            // Scandal risks will be handled by GameState
            break
        }
    }

    func dismissEvent() {
        if let event = currentEvent {
            eventHistory.append(event)
        }
        currentEvent = nil
    }

    // MARK: - Sample Events

    private func createSampleEvents() -> [Event] {
        return [
            // Early Life Events
            Event(
                eventId: "early_life_001",
                title: "Student Council Opportunity",
                description: "Your school is holding elections for student council president. Running would give you early political experience, but it would take time away from your studies.",
                category: .earlyLife,
                choices: [
                    Event.Choice(
                        text: "Run for student council president",
                        outcomePreview: "Gain charisma and reputation, but stress increases",
                        effects: [
                            Effect(type: .statChange, value: .statChange(stat: "charisma", amount: 5)),
                            Effect(type: .stressChange, value: .stressChange(amount: 10)),
                            Effect(type: .approvalChange, value: .approvalChange(amount: 5))
                        ]
                    ),
                    Event.Choice(
                        text: "Focus on academics instead",
                        outcomePreview: "Improve intelligence with less stress",
                        effects: [
                            Effect(type: .statChange, value: .statChange(stat: "intelligence", amount: 5)),
                            Effect(type: .stressChange, value: .stressChange(amount: -5))
                        ]
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 14, max: 18)
            ),

            Event(
                eventId: "early_life_002",
                title: "Community Service Day",
                description: "Your school is organizing a community service day. Participating could build your reputation in the community.",
                category: .earlyLife,
                choices: [
                    Event.Choice(
                        text: "Volunteer enthusiastically",
                        outcomePreview: "Gain approval and reduce stress",
                        effects: [
                            Effect(type: .approvalChange, value: .approvalChange(amount: 3)),
                            Effect(type: .stressChange, value: .stressChange(amount: -5))
                        ]
                    ),
                    Event.Choice(
                        text: "Skip it to work on other priorities",
                        outcomePreview: "No change",
                        effects: []
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 14, max: 18)
            ),

            // Community Organizer Events
            Event(
                eventId: "organizer_001",
                title: "Neighborhood Meeting Conflict",
                description: "Two factions in your neighborhood are at odds over a proposed development project. How you handle this could affect your reputation.",
                category: .political,
                choices: [
                    Event.Choice(
                        text: "Mediate and find compromise",
                        outcomePreview: "Gain charisma and approval, but high stress",
                        effects: [
                            Effect(type: .statChange, value: .statChange(stat: "charisma", amount: 3)),
                            Effect(type: .approvalChange, value: .approvalChange(amount: 8)),
                            Effect(type: .stressChange, value: .stressChange(amount: 15))
                        ]
                    ),
                    Event.Choice(
                        text: "Side with pro-development faction",
                        outcomePreview: "Gain some approval but lose trust with others",
                        effects: [
                            Effect(type: .approvalChange, value: .approvalChange(amount: 5)),
                            Effect(type: .fundsChange, value: .fundsChange(amount: 5000))
                        ]
                    ),
                    Event.Choice(
                        text: "Stay neutral and avoid conflict",
                        outcomePreview: "No major changes, slight approval loss",
                        effects: [
                            Effect(type: .approvalChange, value: .approvalChange(amount: -2))
                        ]
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 18, max: 100),
                requiredPosition: "Community Organizer"
            ),

            // City Council Events
            Event(
                eventId: "council_001",
                title: "Budget Allocation Decision",
                description: "The city has surplus funds. Council members are divided between investing in education, infrastructure, or public safety.",
                category: .political,
                choices: [
                    Event.Choice(
                        text: "Support education funding",
                        outcomePreview: "Popular with families, gain approval",
                        effects: [
                            Effect(type: .approvalChange, value: .approvalChange(amount: 7)),
                            Effect(type: .statChange, value: .statChange(stat: "intelligence", amount: 2))
                        ]
                    ),
                    Event.Choice(
                        text: "Support infrastructure projects",
                        outcomePreview: "Appeal to business interests, gain funds",
                        effects: [
                            Effect(type: .fundsChange, value: .fundsChange(amount: 15000)),
                            Effect(type: .approvalChange, value: .approvalChange(amount: 5))
                        ]
                    ),
                    Event.Choice(
                        text: "Support public safety",
                        outcomePreview: "Build strong law enforcement relationships",
                        effects: [
                            Effect(type: .approvalChange, value: .approvalChange(amount: 6)),
                            Effect(type: .statChange, value: .statChange(stat: "strength", amount: 2))
                        ]
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 21, max: 100),
                requiredPosition: "City Council Member"
            ),

            // Student Events
            Event(
                eventId: "student_001",
                title: "Study Group Invitation",
                description: "Classmates invite you to join their study group. It could help your grades but will take up free time.",
                category: .education,
                choices: [
                    Event.Choice(
                        text: "Join the study group",
                        outcomePreview: "Better understanding, improved intelligence",
                        effects: [
                            Effect(type: .statChange, value: .statChange(stat: "intelligence", amount: 3)),
                            Effect(type: .stressChange, value: .stressChange(amount: 5))
                        ]
                    ),
                    Event.Choice(
                        text: "Study alone",
                        outcomePreview: "Less stress, maintain current pace",
                        effects: [
                            Effect(type: .stressChange, value: .stressChange(amount: -2))
                        ]
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 18, max: 30)
            ),

            Event(
                eventId: "student_002",
                title: "Campus Organization Leadership",
                description: "You're nominated to lead a student organization. It's great for your resume but demands significant time.",
                category: .education,
                choices: [
                    Event.Choice(
                        text: "Accept the leadership role",
                        outcomePreview: "Gain charisma and reputation, but increased stress",
                        effects: [
                            Effect(type: .statChange, value: .statChange(stat: "charisma", amount: 5)),
                            Effect(type: .statChange, value: .statChange(stat: "reputation", amount: 3)),
                            Effect(type: .stressChange, value: .stressChange(amount: 10))
                        ]
                    ),
                    Event.Choice(
                        text: "Decline and focus on academics",
                        outcomePreview: "More time for studies, less stress",
                        effects: [
                            Effect(type: .statChange, value: .statChange(stat: "intelligence", amount: 2)),
                            Effect(type: .stressChange, value: .stressChange(amount: -5))
                        ]
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 18, max: 30)
            ),

            Event(
                eventId: "student_003",
                title: "Part-Time Job Offer",
                description: "A local business offers you part-time work. The income would help with expenses, but it may affect your studies.",
                category: .education,
                choices: [
                    Event.Choice(
                        text: "Take the job",
                        outcomePreview: "Earn money but increase stress",
                        effects: [
                            Effect(type: .fundsChange, value: .fundsChange(amount: 2000)),
                            Effect(type: .stressChange, value: .stressChange(amount: 10)),
                            Effect(type: .statChange, value: .statChange(stat: "intelligence", amount: -2))
                        ]
                    ),
                    Event.Choice(
                        text: "Focus on school full-time",
                        outcomePreview: "Better grades, less money",
                        effects: [
                            Effect(type: .statChange, value: .statChange(stat: "intelligence", amount: 3)),
                            Effect(type: .stressChange, value: .stressChange(amount: -3))
                        ]
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 18, max: 30)
            ),

            Event(
                eventId: "student_004",
                title: "Academic Internship Opportunity",
                description: "A professor offers you a research internship. It's unpaid but could boost your reputation and knowledge.",
                category: .education,
                choices: [
                    Event.Choice(
                        text: "Accept the internship",
                        outcomePreview: "Gain intelligence and reputation",
                        effects: [
                            Effect(type: .statChange, value: .statChange(stat: "intelligence", amount: 5)),
                            Effect(type: .statChange, value: .statChange(stat: "reputation", amount: 5)),
                            Effect(type: .stressChange, value: .stressChange(amount: 8))
                        ]
                    ),
                    Event.Choice(
                        text: "Decline politely",
                        outcomePreview: "Keep current workload manageable",
                        effects: [
                            Effect(type: .stressChange, value: .stressChange(amount: -3))
                        ]
                    )
                ],
                triggers: [
                    Trigger(type: .stat, condition: .statMinimum(stat: "intelligence", min: 60))
                ],
                ageRange: Event.AgeRange(min: 18, max: 30)
            ),

            // Personal Events
            Event(
                eventId: "personal_001",
                title: "Health Scare",
                description: "You've been feeling unwell lately. A doctor recommends taking time off to rest and recover.",
                category: .personal,
                choices: [
                    Event.Choice(
                        text: "Take a week off to recover",
                        outcomePreview: "Improve health significantly, reduce stress",
                        effects: [
                            Effect(type: .healthChange, value: .healthChange(amount: 20)),
                            Effect(type: .stressChange, value: .stressChange(amount: -20)),
                            Effect(type: .approvalChange, value: .approvalChange(amount: -3))
                        ]
                    ),
                    Event.Choice(
                        text: "Push through and keep working",
                        outcomePreview: "Maintain approval but risk worsening health",
                        effects: [
                            Effect(type: .healthChange, value: .healthChange(amount: -5)),
                            Effect(type: .stressChange, value: .stressChange(amount: 10))
                        ]
                    )
                ],
                triggers: [
                    Trigger(type: .stat, condition: .statMinimum(stat: "health", min: 30))
                ],
                ageRange: Event.AgeRange(min: 18, max: 100)
            ),

            // Economic Events
            Event(
                eventId: "economic_001",
                title: "Investment Opportunity",
                description: "A local business owner offers you a chance to invest in their growing company. It could be profitable, but there's risk involved.",
                category: .economic,
                choices: [
                    Event.Choice(
                        text: "Invest $10,000",
                        outcomePreview: "Potential for high returns, but risky",
                        effects: [
                            Effect(type: .fundsChange, value: .fundsChange(amount: -10000)),
                            Effect(type: .approvalChange, value: .approvalChange(amount: 3))
                        ]
                    ),
                    Event.Choice(
                        text: "Politely decline",
                        outcomePreview: "Keep your funds safe",
                        effects: []
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 25, max: 100)
            ),

            // Crisis Events
            Event(
                eventId: "crisis_001",
                title: "Local Emergency Response",
                description: "A severe storm has caused damage in your district. Residents are looking to you for leadership and support.",
                category: .crisis,
                choices: [
                    Event.Choice(
                        text: "Personally organize relief efforts",
                        outcomePreview: "Major approval gain, but very stressful",
                        effects: [
                            Effect(type: .approvalChange, value: .approvalChange(amount: 15)),
                            Effect(type: .stressChange, value: .stressChange(amount: 25)),
                            Effect(type: .statChange, value: .statChange(stat: "charisma", amount: 3))
                        ]
                    ),
                    Event.Choice(
                        text: "Delegate to emergency services",
                        outcomePreview: "Moderate approval gain, less stress",
                        effects: [
                            Effect(type: .approvalChange, value: .approvalChange(amount: 5)),
                            Effect(type: .stressChange, value: .stressChange(amount: 10))
                        ]
                    ),
                    Event.Choice(
                        text: "Issue statement but avoid direct involvement",
                        outcomePreview: "Minimal impact, possible approval loss",
                        effects: [
                            Effect(type: .approvalChange, value: .approvalChange(amount: -5))
                        ]
                    )
                ],
                triggers: [],
                ageRange: Event.AgeRange(min: 21, max: 100)
            )
        ]
    }
}
