//
//  Character.swift
//  PoliticianSim
//
//  Core character model representing the player's politician
//

import Foundation

struct Character: Codable, Identifiable {
    let id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var country: String // Country code (e.g., "USA")
    var background: Background

    // Base Attributes (0-100)
    var charisma: Int
    var intelligence: Int
    var reputation: Int
    var luck: Int
    var diplomacy: Int

    // Secondary Stats
    var approvalRating: Double // 0.0 to 100.0
    var campaignFunds: Decimal
    var health: Int // 0-100
    var stress: Int // 0-100

    // Career
    var currentPosition: Position?
    var careerHistory: [CareerEntry]

    // Military (only available for Presidents)
    var militaryStats: MilitaryStats?

    // Dates
    var birthDate: Date
    var currentDate: Date

    // Computed property for character role
    var role: CharacterRole {
        if currentPosition != nil {
            return .politician
        }
        // Check if enrolled in education (will be checked by EducationManager)
        return .unemployed
    }

    enum CharacterRole {
        case student
        case unemployed
        case politician
    }

    // Calculated properties
    var daysSinceBirth: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: currentDate).day ?? 0
    }

    enum Gender: String, Codable, CaseIterable {
        case male = "male"
        case female = "female"
        case other = "other"
    }

    enum Background: String, Codable, CaseIterable {
        case workingClass = "workingClass"
        case middleClass = "middleClass"
        case upperClass = "upperClass"

        var startingFunds: Decimal {
            switch self {
            case .workingClass: return 1_000
            case .middleClass: return 5_000
            case .upperClass: return 50_000
            }
        }
    }

    // Initialize new character with random attributes
    init(
        name: String,
        gender: Gender,
        country: String,
        background: Background
    ) {
        self.id = UUID()
        self.name = name
        self.age = 18 // Starting age
        self.gender = gender
        self.country = country
        self.background = background

        // Randomize base attributes (40-80 range for balanced start)
        self.charisma = Int.random(in: 40...80)
        self.intelligence = Int.random(in: 40...80)
        self.reputation = Int.random(in: 40...80)
        self.luck = Int.random(in: 40...80)
        self.diplomacy = Int.random(in: 40...80)

        // Initialize secondary stats
        self.approvalRating = 50.0
        self.campaignFunds = background.startingFunds
        self.health = 100
        self.stress = 10

        // Career
        self.currentPosition = nil
        self.careerHistory = []

        // Military
        self.militaryStats = nil

        // Dates (18 years old)
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -18, to: Date()) ?? Date()
        self.birthDate = birthDate
        self.currentDate = Date()
    }

    // Initialize new character with custom attributes
    init(
        name: String,
        gender: Gender,
        country: String,
        background: Background,
        charisma: Int,
        intelligence: Int,
        reputation: Int,
        luck: Int,
        diplomacy: Int
    ) {
        self.id = UUID()
        self.name = name
        self.age = 18 // Starting age
        self.gender = gender
        self.country = country
        self.background = background

        // Use provided attributes
        self.charisma = max(0, min(100, charisma))
        self.intelligence = max(0, min(100, intelligence))
        self.reputation = max(0, min(100, reputation))
        self.luck = max(0, min(100, luck))
        self.diplomacy = max(0, min(100, diplomacy))

        // Initialize secondary stats
        self.approvalRating = 50.0
        self.campaignFunds = background.startingFunds
        self.health = 100
        self.stress = 10

        // Career
        self.currentPosition = nil
        self.careerHistory = []

        // Military
        self.militaryStats = nil

        // Dates (18 years old)
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -18, to: Date()) ?? Date()
        self.birthDate = birthDate
        self.currentDate = Date()
    }

    // Modify attributes (with cap at 100)
    mutating func modifyCharisma(by amount: Int) {
        charisma = min(100, max(0, charisma + amount))
    }

    mutating func modifyIntelligence(by amount: Int) {
        intelligence = min(100, max(0, intelligence + amount))
    }

    mutating func modifyReputation(by amount: Int) {
        reputation = min(100, max(0, reputation + amount))
    }

    mutating func modifyLuck(by amount: Int) {
        luck = min(100, max(0, luck + amount))
    }

    mutating func modifyDiplomacy(by amount: Int) {
        diplomacy = min(100, max(0, diplomacy + amount))
    }

    // Modify approval rating
    mutating func modifyApproval(by amount: Double) {
        approvalRating = min(100.0, max(0.0, approvalRating + amount))
    }

    // Modify funds
    mutating func addFunds(_ amount: Decimal) {
        campaignFunds += amount
    }

    mutating func spendFunds(_ amount: Decimal) throws {
        guard campaignFunds >= amount else {
            throw CharacterError.insufficientFunds
        }
        campaignFunds -= amount
    }

    // Age the character
    mutating func advanceTime(days: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) else {
            return
        }
        currentDate = newDate
        age = Calendar.current.dateComponents([.year], from: birthDate, to: currentDate).year ?? 0
    }
}

// Position structure
struct Position: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let level: Int
    let termLengthYears: Int
    let minAge: Int
    let requirements: Requirements

    struct Requirements: Codable, Equatable {
        let approvalRating: Double?
        let reputation: Int?
        let funds: Decimal?
        let age: Int?
    }

    init(
        title: String,
        level: Int,
        termLengthYears: Int,
        minAge: Int,
        approvalRating: Double? = nil,
        reputation: Int? = nil,
        funds: Decimal? = nil,
        age: Int? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.level = level
        self.termLengthYears = termLengthYears
        self.minAge = minAge
        self.requirements = Requirements(
            approvalRating: approvalRating,
            reputation: reputation,
            funds: funds,
            age: age
        )
    }
}

// Career entry for history
struct CareerEntry: Codable, Identifiable {
    let id: UUID
    let position: Position
    let startDate: Date
    var endDate: Date?
    var finalApproval: Double?
    var achievements: [String]

    init(position: Position, startDate: Date) {
        self.id = UUID()
        self.position = position
        self.startDate = startDate
        self.endDate = nil
        self.finalApproval = nil
        self.achievements = []
    }
}

// Errors
enum CharacterError: Error {
    case insufficientFunds
    case requirementsNotMet
}
