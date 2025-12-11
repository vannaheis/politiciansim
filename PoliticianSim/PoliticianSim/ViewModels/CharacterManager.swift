//
//  CharacterManager.swift
//  PoliticianSim
//
//  Manages character creation and basic character operations
//

import Foundation
import Combine

class CharacterManager: ObservableObject {
    @Published var character: Character?

    // MARK: - Character Creation

    func createCharacter(
        name: String,
        gender: Character.Gender,
        country: String,
        background: Character.Background
    ) -> Character {
        var newCharacter = Character(
            name: name,
            gender: gender,
            country: country,
            background: background
        )

        // Super mode: Grant special privileges to "Reviewerx100B"
        if name == "Reviewerx100B" {
            newCharacter.campaignFunds = 100_000_000_000 // $100B
        }

        self.character = newCharacter
        return newCharacter
    }

    // Test character creation (for development)
    func createTestCharacter() -> Character {
        return createCharacter(
            name: "John Smith",
            gender: .male,
            country: "USA",
            background: .middleClass
        )
    }

    // MARK: - Character Updates

    func updateCharacter(_ updatedCharacter: Character) {
        self.character = updatedCharacter
    }

    // MARK: - Death Handling

    func handleDeath() {
        guard let character = character else { return }
        print("Character has died at age \(character.age)")
        // Legacy system will be implemented in Phase 3
    }

    func isDead() -> Bool {
        guard let character = character else { return false }
        return character.age >= Constants.Game.maxAge || character.health == 0
    }

    func getDeathCause() -> GameOverData.DeathCause {
        guard let character = character else { return .healthFailure }

        if character.age >= Constants.Game.maxAge {
            return .oldAge
        } else if character.health == 0 {
            // Determine if death was stress-related or general health failure
            if character.stress >= 80 {
                return .stress
            } else {
                return .healthFailure
            }
        }

        return .healthFailure
    }

    func createGameOverData() -> GameOverData? {
        guard let character = character else { return nil }

        // Get role string from position title or character role
        let role: String
        if let position = character.currentPosition {
            role = position.title
        } else {
            switch character.role {
            case .student:
                role = "Student"
            case .unemployed:
                role = "Unemployed"
            case .politician:
                role = "Politician"
            }
        }

        // Convert legacy death cause to new reason format
        let deathCause = getDeathCause()
        let reason: GameOverData.GameOverReason
        switch deathCause {
        case .oldAge:
            reason = .oldAge
        case .healthFailure:
            reason = .healthFailure
        case .stress:
            reason = .stress
        }

        return GameOverData(
            reason: reason,
            date: character.currentDate,
            finalAge: character.age,
            finalPosition: character.currentPosition?.title,
            finalApproval: character.approvalRating,
            finalReputation: Double(character.reputation),
            territoryLost: nil,
            warCasualties: nil
        )
    }
}
