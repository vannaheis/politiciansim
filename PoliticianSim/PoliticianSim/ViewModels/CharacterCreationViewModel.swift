//
//  CharacterCreationViewModel.swift
//  PoliticianSim
//
//  Manages character creation flow state
//

import Foundation
import Combine

class CharacterCreationViewModel: ObservableObject {
    @Published var currentStep: CharacterCreationStep = .country
    @Published var selectedCountry: String = "USA"
    @Published var name: String = ""
    @Published var gender: Character.Gender = .male
    @Published var background: Character.Background = .middleClass

    // Generated attributes
    @Published var charisma: Int = 0
    @Published var intelligence: Int = 0
    @Published var reputation: Int = 0
    @Published var luck: Int = 0
    @Published var diplomacy: Int = 0

    enum CharacterCreationStep {
        case country
        case details
        case attributes
        case summary
    }

    // MARK: - Validation

    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canProceedFromCountry: Bool {
        !selectedCountry.isEmpty
    }

    var canProceedFromDetails: Bool {
        isNameValid
    }

    var canProceedFromAttributes: Bool {
        charisma > 0 && intelligence > 0 && reputation > 0 && luck > 0 && diplomacy > 0
    }

    // MARK: - Navigation

    func nextStep() {
        switch currentStep {
        case .country:
            currentStep = .details
        case .details:
            currentStep = .attributes
            if charisma == 0 {
                generateAttributes()
            }
        case .attributes:
            currentStep = .summary
        case .summary:
            break
        }
    }

    func previousStep() {
        switch currentStep {
        case .country:
            break
        case .details:
            currentStep = .country
        case .attributes:
            currentStep = .details
        case .summary:
            currentStep = .attributes
        }
    }

    // MARK: - Attribute Generation

    func generateAttributes() {
        charisma = Int.random(in: Constants.CharacterCreation.attributeMinStart...Constants.CharacterCreation.attributeMaxStart)
        intelligence = Int.random(in: Constants.CharacterCreation.attributeMinStart...Constants.CharacterCreation.attributeMaxStart)
        reputation = Int.random(in: Constants.CharacterCreation.attributeMinStart...Constants.CharacterCreation.attributeMaxStart)
        luck = Int.random(in: Constants.CharacterCreation.attributeMinStart...Constants.CharacterCreation.attributeMaxStart)
        diplomacy = Int.random(in: Constants.CharacterCreation.attributeMinStart...Constants.CharacterCreation.attributeMaxStart)
    }

    func rerollAttributes() {
        generateAttributes()
    }

    // MARK: - Character Creation

    func createCharacter() -> Character {
        return Character(
            name: name.trimmingCharacters(in: .whitespaces),
            gender: gender,
            country: selectedCountry,
            background: background,
            charisma: charisma,
            intelligence: intelligence,
            reputation: reputation,
            luck: luck,
            diplomacy: diplomacy
        )
    }

    // MARK: - Reset

    func reset() {
        currentStep = .country
        selectedCountry = "USA"
        name = ""
        gender = .male
        background = .middleClass
        charisma = 0
        intelligence = 0
        reputation = 0
        luck = 0
        diplomacy = 0
    }
}
