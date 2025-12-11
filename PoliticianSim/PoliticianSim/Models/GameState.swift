//
//  GameState.swift
//  PoliticianSim
//
//  Game state model managing the entire game session
//

import Foundation
import Combine

class GameState: ObservableObject, Codable {
    @Published var character: Character?
    @Published var eventQueue: [Event] = []
    @Published var activeEvent: Event?
    @Published var policies: [Policy] = []
    @Published var scandalRisks: [ScandalRisk] = []

    // Time management
    @Published var isPaused: Bool = false
    @Published var timeSpeed: TimeSpeed = .day

    // Game progress
    @Published var hasCompletedTutorial: Bool = false

    // Death and warnings
    @Published var gameOverData: GameOverData?
    @Published var healthWarningShown: Bool = false
    @Published var stressWarningShown: Bool = false

    enum TimeSpeed: String, Codable {
        case day = "Day"
        case week = "Week"
    }

    // MARK: - Codable Implementation

    enum CodingKeys: String, CodingKey {
        case character
        case eventQueue
        case activeEvent
        case policies
        case scandalRisks
        case isPaused
        case timeSpeed
        case hasCompletedTutorial
        case healthWarningShown
        case stressWarningShown
    }

    init() {
        self.character = nil
        self.eventQueue = []
        self.activeEvent = nil
        self.policies = []
        self.scandalRisks = []
        self.isPaused = false
        self.timeSpeed = .day
        self.hasCompletedTutorial = false
        self.gameOverData = nil
        self.healthWarningShown = false
        self.stressWarningShown = false
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        character = try container.decodeIfPresent(Character.self, forKey: .character)
        eventQueue = try container.decode([Event].self, forKey: .eventQueue)
        activeEvent = try container.decodeIfPresent(Event.self, forKey: .activeEvent)
        policies = try container.decode([Policy].self, forKey: .policies)
        scandalRisks = try container.decode([ScandalRisk].self, forKey: .scandalRisks)
        isPaused = try container.decode(Bool.self, forKey: .isPaused)
        timeSpeed = try container.decode(TimeSpeed.self, forKey: .timeSpeed)
        hasCompletedTutorial = try container.decode(Bool.self, forKey: .hasCompletedTutorial)
        gameOverData = nil
        healthWarningShown = try container.decodeIfPresent(Bool.self, forKey: .healthWarningShown) ?? false
        stressWarningShown = try container.decodeIfPresent(Bool.self, forKey: .stressWarningShown) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(character, forKey: .character)
        try container.encode(eventQueue, forKey: .eventQueue)
        try container.encodeIfPresent(activeEvent, forKey: .activeEvent)
        try container.encode(policies, forKey: .policies)
        try container.encode(scandalRisks, forKey: .scandalRisks)
        try container.encode(isPaused, forKey: .isPaused)
        try container.encode(timeSpeed, forKey: .timeSpeed)
        try container.encode(hasCompletedTutorial, forKey: .hasCompletedTutorial)
        try container.encode(healthWarningShown, forKey: .healthWarningShown)
        try container.encode(stressWarningShown, forKey: .stressWarningShown)
    }

    // MARK: - Game Actions

    func createCharacter(name: String, gender: Character.Gender, country: String, background: Character.Background) {
        self.character = Character(
            name: name,
            gender: gender,
            country: country,
            background: background
        )
    }

    func advanceTime() {
        guard let character = character else { return }

        let daysToAdvance = timeSpeed == .day ? 1 : 7

        var updatedCharacter = character
        updatedCharacter.advanceTime(days: daysToAdvance)

        self.character = updatedCharacter

        // Check for events after time advancement
        checkForEvents()
    }

    private func checkForEvents() {
        // Event checking logic will be implemented in EventEngine
        // For now, placeholder
    }

    func addPolicy(_ policy: Policy) {
        policies.append(policy)
    }

    func addScandalRisk(_ risk: ScandalRisk) {
        scandalRisks.append(risk)
    }
}

// MARK: - Game Over Data

struct GameOverData {
    let reason: GameOverReason
    let date: Date
    let finalAge: Int
    let finalPosition: String?
    let finalApproval: Double
    let finalReputation: Double
    let territoryLost: String?  // For war defeat
    let warCasualties: Int?     // For war defeat

    // Legacy support for old death causes
    var deathCause: DeathCause? {
        switch reason {
        case .oldAge: return .oldAge
        case .healthFailure: return .healthFailure
        case .stress: return .stress
        default: return nil
        }
    }

    var age: Int { finalAge }
    var role: String { finalPosition ?? "Unknown" }
    var characterName: String { "Character" }  // TODO: Get from character

    enum GameOverReason {
        case oldAge
        case healthFailure
        case stress
        case warDefeat

        var title: String {
            switch self {
            case .oldAge: return "Natural Causes"
            case .healthFailure: return "Health Failure"
            case .stress: return "Fatal Stress"
            case .warDefeat: return "War Defeat"
            }
        }

        var message: String {
            switch self {
            case .oldAge:
                return "lived a full life and passed away peacefully from natural causes."
            case .healthFailure:
                return "succumbed to severe health complications. Their health had deteriorated beyond recovery."
            case .stress:
                return "suffered a fatal stress-related incident. The pressures of their position proved too much to bear."
            case .warDefeat:
                return "was removed from office due to catastrophic war defeat. The nation could not survive such losses."
            }
        }

        var icon: String {
            switch self {
            case .oldAge: return "clock.fill"
            case .healthFailure: return "heart.fill"
            case .stress: return "exclamationmark.triangle.fill"
            case .warDefeat: return "exclamationmark.octagon.fill"
            }
        }
    }

    // Legacy DeathCause for compatibility
    enum DeathCause {
        case oldAge
        case healthFailure
        case stress

        var title: String {
            switch self {
            case .oldAge: return "Natural Causes"
            case .healthFailure: return "Health Failure"
            case .stress: return "Fatal Stress"
            }
        }

        var message: String {
            switch self {
            case .oldAge:
                return "lived a full life and passed away peacefully from natural causes."
            case .healthFailure:
                return "succumbed to severe health complications. Their health had deteriorated beyond recovery."
            case .stress:
                return "suffered a fatal stress-related incident. The pressures of their position proved too much to bear."
            }
        }

        var icon: String {
            switch self {
            case .oldAge: return "clock.fill"
            case .healthFailure: return "heart.fill"
            case .stress: return "exclamationmark.triangle.fill"
            }
        }
    }
}

// MARK: - Scandal Risk Model

struct ScandalRisk: Codable, Identifiable {
    let id: UUID
    let action: String
    let date: Date
    let riskPercentage: Double
    var hasExposed: Bool
    let severity: ScandalSeverity

    enum ScandalSeverity: String, Codable {
        case minor = "Minor"
        case major = "Major"
        case careerEnding = "Career-Ending"
    }

    init(action: String, date: Date, riskPercentage: Double, severity: ScandalSeverity) {
        self.id = UUID()
        self.action = action
        self.date = date
        self.riskPercentage = riskPercentage
        self.hasExposed = false
        self.severity = severity
    }
}
