//
//  Country.swift
//  PoliticianSim
//
//  Country model for multi-country system
//

import Foundation

struct Country: Codable, Identifiable {
    let id: UUID
    let name: String
    let code: String // ISO country code (USA, GBR, CHN, etc.)
    let flag: String // SF Symbol or asset name
    let territorySize: Double // Square miles
    let population: Int
    let governmentType: GovernmentType
    var positions: [Position]

    enum GovernmentType: String, Codable {
        case presidential = "Presidential"
        case parliamentary = "Parliamentary"
        case singleParty = "Single-Party"
        case absoluteMonarchy = "Absolute Monarchy"

        var description: String {
            self.rawValue
        }
    }

    init(
        name: String,
        code: String,
        flag: String,
        territorySize: Double,
        population: Int,
        governmentType: GovernmentType,
        positions: [Position]
    ) {
        self.id = UUID()
        self.name = name
        self.code = code
        self.flag = flag
        self.territorySize = territorySize
        self.population = population
        self.governmentType = governmentType
        self.positions = positions
    }

    // Formatted territory size
    var formattedTerritorySize: String {
        if territorySize >= 1_000_000 {
            return String(format: "%.1fM sq mi", territorySize / 1_000_000)
        } else {
            return String(format: "%.0fk sq mi", territorySize / 1000)
        }
    }

    // Formatted population
    var formattedPopulation: String {
        if population >= 1_000_000_000 {
            return String(format: "%.1fB", Double(population) / 1_000_000_000)
        } else if population >= 1_000_000 {
            return String(format: "%.0fM", Double(population) / 1_000_000)
        } else {
            return String(format: "%.0fk", Double(population) / 1000)
        }
    }
}

// MARK: - Predefined Countries (Phase 1: USA only)

extension Country {
    static let usa = Country(
        name: "United States",
        code: "USA",
        flag: "flag.fill", // Will use SF Symbol for now
        territorySize: 3_800_000,
        population: 330_000_000,
        governmentType: .presidential,
        positions: usaPositions
    )

    private static let usaPositions: [Position] = [
        Position(
            title: "Mayor",
            level: 1,
            termLengthYears: 4,
            minAge: 21,
            approvalRating: 40,
            reputation: 35,
            funds: 25_000,
            age: 21
        ),
        Position(
            title: "Governor",
            level: 2,
            termLengthYears: 4,
            minAge: 30,
            approvalRating: 55,
            reputation: 55,
            funds: 250_000,
            age: 30
        ),
        Position(
            title: "U.S. Senator",
            level: 3,
            termLengthYears: 6,
            minAge: 30,
            approvalRating: 60,
            reputation: 65,
            funds: 750_000,
            age: 30
        ),
        Position(
            title: "Vice President",
            level: 4,
            termLengthYears: 4,
            minAge: 35,
            approvalRating: 70,
            reputation: 75,
            funds: 3_000_000,
            age: 35
        ),
        Position(
            title: "President",
            level: 5,
            termLengthYears: 4,
            minAge: 35,
            approvalRating: 75,
            reputation: 85,
            funds: 10_000_000,
            age: 35
        )
    ]

    // Get all playable countries (Phase 1: USA only, Phase 3: all 10)
    static var playableCountries: [Country] {
        return [usa]
    }
}
