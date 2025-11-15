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
}
