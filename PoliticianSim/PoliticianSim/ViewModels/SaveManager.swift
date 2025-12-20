//
//  SaveManager.swift
//  PoliticianSim
//
//  Manages game saves with autosave and manual save slots
//

import Foundation
import Combine

class SaveManager: ObservableObject {
    static let shared = SaveManager()

    @Published var saveSlots: [SaveSlotInfo] = []
    @Published var lastAutosaveDate: Date?
    @Published var hasAutosave: Bool = false

    private var autosaveTimer: Timer?
    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // File paths
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var savesDirectory: URL {
        documentsDirectory.appendingPathComponent("Saves", isDirectory: true)
    }

    private func autosaveURL() -> URL {
        savesDirectory.appendingPathComponent("autosave.json")
    }

    private func slotURL(slot: Int) -> URL {
        savesDirectory.appendingPathComponent("slot_\(slot).json")
    }

    private func slotInfoURL() -> URL {
        savesDirectory.appendingPathComponent("slots_info.json")
    }

    init() {
        // Initialize encoder/decoder with date strategies
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        createSavesDirectory()
        loadSlotInfo()
        checkAutosave()
    }

    // MARK: - Setup

    private func createSavesDirectory() {
        let url = savesDirectory
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    // MARK: - Autosave

    func startAutosave(gameManager: GameManager) {
        stopAutosave()

        // Autosave every 1 second
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self, weak gameManager] _ in
            guard let self = self, let gameManager = gameManager else { return }
            self.performAutosave(gameManager: gameManager)
        }
    }

    func stopAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = nil
    }

    private func performAutosave(gameManager: GameManager) {
        // Only autosave if there's a character
        guard gameManager.characterManager.character != nil else {
            print("Autosave skipped: No character")
            return
        }

        let saveGame = SaveGame(gameManager: gameManager)

        do {
            let data = try encoder.encode(saveGame)
            try data.write(to: autosaveURL())
            lastAutosaveDate = Date()
            hasAutosave = true
            // Autosave logging removed for cleaner console output
        } catch {
            print("Autosave failed: \(error)")
        }
    }

    func loadAutosave(to gameManager: GameManager) -> Bool {
        let url = autosaveURL()

        guard fileManager.fileExists(atPath: url.path) else {
            print("No autosave file found")
            return false
        }

        print("Loading autosave from: \(url.path)")

        do {
            let data = try Data(contentsOf: url)
            let saveGame = try decoder.decode(SaveGame.self, from: data)
            saveGame.restore(to: gameManager)
            print("Autosave loaded successfully: \(saveGame.characterName) at \(saveGame.currentPosition)")
            return true
        } catch {
            print("Load autosave failed: \(error)")
            // Delete corrupted autosave
            try? fileManager.removeItem(at: url)
            hasAutosave = false
            lastAutosaveDate = nil
            return false
        }
    }

    private func checkAutosave() {
        let url = autosaveURL()
        hasAutosave = fileManager.fileExists(atPath: url.path)

        if hasAutosave {
            if let attributes = try? fileManager.attributesOfItem(atPath: url.path),
               let modificationDate = attributes[.modificationDate] as? Date {
                lastAutosaveDate = modificationDate
            }
        }
    }

    func deleteAutosave() {
        let url = autosaveURL()
        try? fileManager.removeItem(at: url)
        hasAutosave = false
        lastAutosaveDate = nil
    }

    // MARK: - Manual Save Slots

    func saveToSlot(_ slot: Int, gameManager: GameManager) -> Bool {
        guard slot >= 1 && slot <= 4 else { return false }
        guard gameManager.characterManager.character != nil else { return false }

        let saveGame = SaveGame(gameManager: gameManager)

        do {
            let data = try encoder.encode(saveGame)
            try data.write(to: slotURL(slot: slot))

            // Update slot info
            updateSlotInfo(slot: slot, saveGame: saveGame)

            return true
        } catch {
            print("Save to slot \(slot) failed: \(error.localizedDescription)")
            return false
        }
    }

    func loadFromSlot(_ slot: Int, to gameManager: GameManager) -> Bool {
        guard slot >= 1 && slot <= 4 else { return false }

        let url = slotURL(slot: slot)

        guard fileManager.fileExists(atPath: url.path) else {
            return false
        }

        do {
            let data = try Data(contentsOf: url)
            let saveGame = try decoder.decode(SaveGame.self, from: data)
            saveGame.restore(to: gameManager)
            return true
        } catch {
            print("Load from slot \(slot) failed: \(error)")
            return false
        }
    }

    func deleteSlot(_ slot: Int) -> Bool {
        guard slot >= 1 && slot <= 4 else { return false }

        let url = slotURL(slot: slot)
        try? fileManager.removeItem(at: url)

        // Update slot info
        if let index = saveSlots.firstIndex(where: { $0.slotNumber == slot }) {
            saveSlots[index] = SaveSlotInfo.empty(slot: slot)
            saveSlotInfo()
        }

        return true
    }

    // MARK: - Slot Info Management

    private func updateSlotInfo(slot: Int, saveGame: SaveGame) {
        let info = SaveSlotInfo(slot: slot, saveGame: saveGame)

        if let index = saveSlots.firstIndex(where: { $0.slotNumber == slot }) {
            saveSlots[index] = info
        } else {
            saveSlots.append(info)
            saveSlots.sort { $0.slotNumber < $1.slotNumber }
        }

        saveSlotInfo()
    }

    private func loadSlotInfo() {
        let url = slotInfoURL()

        // Initialize with empty slots if file doesn't exist
        if !fileManager.fileExists(atPath: url.path) {
            saveSlots = (1...4).map { SaveSlotInfo.empty(slot: $0) }
            return
        }

        do {
            let data = try Data(contentsOf: url)
            saveSlots = try decoder.decode([SaveSlotInfo].self, from: data)

            // Ensure we have all 4 slots
            for slot in 1...4 {
                if !saveSlots.contains(where: { $0.slotNumber == slot }) {
                    saveSlots.append(SaveSlotInfo.empty(slot: slot))
                }
            }
            saveSlots.sort { $0.slotNumber < $1.slotNumber }
        } catch {
            print("Load slot info failed: \(error)")
            // Delete corrupted file and start fresh
            try? fileManager.removeItem(at: url)
            saveSlots = (1...4).map { SaveSlotInfo.empty(slot: $0) }
            saveSlotInfo() // Save fresh slot info
        }
    }

    private func saveSlotInfo() {
        let url = slotInfoURL()

        do {
            let data = try encoder.encode(saveSlots)
            try data.write(to: url)
        } catch {
            print("Save slot info failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Queries

    func getSlotInfo(_ slot: Int) -> SaveSlotInfo? {
        return saveSlots.first { $0.slotNumber == slot }
    }

    func hasCharacter(gameManager: GameManager) -> Bool {
        return gameManager.characterManager.character != nil
    }

    // MARK: - Cleanup

    func deleteAllSaves() {
        deleteAutosave()

        for slot in 1...4 {
            _ = deleteSlot(slot)
        }

        saveSlots = (1...4).map { SaveSlotInfo.empty(slot: $0) }
    }

    func clearAllSaveData() {
        // Delete all save files including corrupted ones
        deleteAutosave()

        // Delete all slot files
        for slot in 1...4 {
            let url = slotURL(slot: slot)
            try? fileManager.removeItem(at: url)
        }

        // Delete slot info file
        let slotInfoUrl = slotInfoURL()
        try? fileManager.removeItem(at: slotInfoUrl)

        // Recreate fresh slots
        saveSlots = (1...4).map { SaveSlotInfo.empty(slot: $0) }
        saveSlotInfo()
    }
}
