//
//  TimeManager.swift
//  PoliticianSim
//
//  Manages time progression and daily checks
//

import Foundation
import Combine

class TimeManager: ObservableObject {
    @Published var timeSpeed: GameState.TimeSpeed = .day

    // MARK: - Time Advancement

    func advanceTime(
        character: inout Character,
        onDailyCheck: (Character) -> Character
    ) {
        let daysToAdvance = timeSpeed == .day ? 1 : 7
        character.advanceTime(days: daysToAdvance)

        // Perform daily checks
        character = onDailyCheck(character)
    }

    // MARK: - Daily Checks

    func performDailyChecks(for character: Character) -> Character {
        var updatedCharacter = character

        // Health decay based on stress and age
        let healthDecay = StatUtilities.calculateHealthDecay(
            stress: character.stress,
            age: character.age
        )

        if healthDecay > 0 {
            updatedCharacter.health = max(0, character.health - healthDecay)
        }

        return updatedCharacter
    }

    // MARK: - Time Control

    func skipDay(
        character: inout Character,
        onDailyCheck: (Character) -> Character
    ) {
        timeSpeed = .day
        advanceTime(character: &character, onDailyCheck: onDailyCheck)
    }

    func skipWeek(
        character: inout Character,
        onDailyCheck: (Character) -> Character
    ) {
        timeSpeed = .week
        advanceTime(character: &character, onDailyCheck: onDailyCheck)
        timeSpeed = .day
    }
}
