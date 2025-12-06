//
//  EconomicData.swift
//  PoliticianSim
//
//  Economic data models for GDP, unemployment, inflation, and interest rates
//

import Foundation

// MARK: - Economic Data Point

struct EconomicDataPoint: Codable, Identifiable {
    let id: UUID
    let date: Date
    let value: Double

    init(date: Date, value: Double) {
        self.id = UUID()
        self.date = date
        self.value = value
    }
}

// MARK: - Economic Indicator

struct EconomicIndicator: Codable {
    var current: Double
    var history: [EconomicDataPoint]

    init(current: Double, history: [EconomicDataPoint] = []) {
        self.current = current
        self.history = history
    }

    mutating func addDataPoint(date: Date, value: Double) {
        let point = EconomicDataPoint(date: date, value: value)
        history.append(point)
        current = value

        // Keep only last 520 data points (10 years of weekly data)
        if history.count > 520 {
            history.removeFirst(history.count - 520)
        }
    }
}

// MARK: - Local Economic Data

struct LocalEconomicData: Codable {
    var gdp: EconomicIndicator
    var unemploymentRate: EconomicIndicator
    var cityName: String

    init(cityName: String, gdp: Double = 5_000_000_000, unemploymentRate: Double = 4.5) {
        self.cityName = cityName
        self.gdp = EconomicIndicator(current: gdp)
        self.unemploymentRate = EconomicIndicator(current: unemploymentRate)
    }
}

// MARK: - State Economic Data

struct StateEconomicData: Codable {
    var gdp: EconomicIndicator
    var unemploymentRate: EconomicIndicator
    var stateName: String

    init(stateName: String, gdp: Double = 500_000_000_000, unemploymentRate: Double = 4.2) {
        self.stateName = stateName
        self.gdp = EconomicIndicator(current: gdp)
        self.unemploymentRate = EconomicIndicator(current: unemploymentRate)
    }
}

// MARK: - Federal Economic Data

struct FederalEconomicData: Codable {
    var gdp: EconomicIndicator
    var unemploymentRate: EconomicIndicator
    var inflationRate: EconomicIndicator
    var federalInterestRate: EconomicIndicator

    init(
        gdp: Double = 27_360_000_000_000,
        unemploymentRate: Double = 3.8,
        inflationRate: Double = 2.5,
        federalInterestRate: Double = 5.0
    ) {
        self.gdp = EconomicIndicator(current: gdp)
        self.unemploymentRate = EconomicIndicator(current: unemploymentRate)
        self.inflationRate = EconomicIndicator(current: inflationRate)
        self.federalInterestRate = EconomicIndicator(current: federalInterestRate)
    }
}

// MARK: - World Country GDP

struct WorldCountryGDP: Codable, Identifiable {
    let id: UUID
    let countryName: String
    let countryCode: String
    var gdp: Double
    var population: Int

    var gdpPerCapita: Double {
        gdp / Double(population)
    }

    init(countryName: String, countryCode: String, gdp: Double, population: Int) {
        self.id = UUID()
        self.countryName = countryName
        self.countryCode = countryCode
        self.gdp = gdp
        self.population = population
    }
}

// MARK: - Complete Economic Data

struct EconomicData: Codable {
    var local: LocalEconomicData
    var state: StateEconomicData
    var federal: FederalEconomicData
    var worldGDPs: [WorldCountryGDP]
    var lastDepreciationDate: Date? // Track when last annual depreciation was applied

    init() {
        self.local = LocalEconomicData(cityName: "New York")
        self.state = StateEconomicData(stateName: "New York")
        self.federal = FederalEconomicData()
        self.worldGDPs = Self.defaultWorldGDPs()
        self.lastDepreciationDate = nil
    }

    static func defaultWorldGDPs() -> [WorldCountryGDP] {
        // 2024 GDP data (nominal, in USD) and population estimates
        return [
            // Existing 20 countries
            WorldCountryGDP(countryName: "United States", countryCode: "USA", gdp: 27_360_000_000_000, population: 335_000_000),
            WorldCountryGDP(countryName: "China", countryCode: "CHN", gdp: 17_960_000_000_000, population: 1_425_000_000),
            WorldCountryGDP(countryName: "Japan", countryCode: "JPN", gdp: 4_210_000_000_000, population: 123_000_000),
            WorldCountryGDP(countryName: "Germany", countryCode: "DEU", gdp: 4_430_000_000_000, population: 84_000_000),
            WorldCountryGDP(countryName: "India", countryCode: "IND", gdp: 3_890_000_000_000, population: 1_428_000_000),
            WorldCountryGDP(countryName: "United Kingdom", countryCode: "GBR", gdp: 3_340_000_000_000, population: 68_000_000),
            WorldCountryGDP(countryName: "France", countryCode: "FRA", gdp: 3_050_000_000_000, population: 68_000_000),
            WorldCountryGDP(countryName: "Brazil", countryCode: "BRA", gdp: 2_330_000_000_000, population: 216_000_000),
            WorldCountryGDP(countryName: "Italy", countryCode: "ITA", gdp: 2_190_000_000_000, population: 59_000_000),
            WorldCountryGDP(countryName: "Canada", countryCode: "CAN", gdp: 2_140_000_000_000, population: 39_000_000),
            WorldCountryGDP(countryName: "Russia", countryCode: "RUS", gdp: 2_060_000_000_000, population: 144_000_000),
            WorldCountryGDP(countryName: "South Korea", countryCode: "KOR", gdp: 1_710_000_000_000, population: 51_000_000),
            WorldCountryGDP(countryName: "Australia", countryCode: "AUS", gdp: 1_690_000_000_000, population: 26_000_000),
            WorldCountryGDP(countryName: "Spain", countryCode: "ESP", gdp: 1_580_000_000_000, population: 47_000_000),
            WorldCountryGDP(countryName: "Mexico", countryCode: "MEX", gdp: 1_460_000_000_000, population: 128_000_000),
            WorldCountryGDP(countryName: "Indonesia", countryCode: "IDN", gdp: 1_390_000_000_000, population: 277_000_000),
            WorldCountryGDP(countryName: "Netherlands", countryCode: "NLD", gdp: 1_120_000_000_000, population: 17_000_000),
            WorldCountryGDP(countryName: "Saudi Arabia", countryCode: "SAU", gdp: 1_070_000_000_000, population: 36_000_000),
            WorldCountryGDP(countryName: "Turkey", countryCode: "TUR", gdp: 1_030_000_000_000, population: 85_000_000),
            WorldCountryGDP(countryName: "Switzerland", countryCode: "CHE", gdp: 905_000_000_000, population: 9_000_000),

            // NEW: 20 additional countries for territory system
            WorldCountryGDP(countryName: "Taiwan", countryCode: "TWN", gdp: 790_000_000_000, population: 23_000_000),
            WorldCountryGDP(countryName: "Poland", countryCode: "POL", gdp: 688_000_000_000, population: 38_000_000),
            WorldCountryGDP(countryName: "Israel", countryCode: "ISR", gdp: 525_000_000_000, population: 9_500_000),
            WorldCountryGDP(countryName: "Thailand", countryCode: "THA", gdp: 514_000_000_000, population: 71_000_000),
            WorldCountryGDP(countryName: "Nigeria", countryCode: "NGA", gdp: 477_000_000_000, population: 223_000_000),
            WorldCountryGDP(countryName: "Egypt", countryCode: "EGY", gdp: 476_000_000_000, population: 112_000_000),
            WorldCountryGDP(countryName: "Vietnam", countryCode: "VNM", gdp: 430_000_000_000, population: 98_000_000),
            WorldCountryGDP(countryName: "Iran", countryCode: "IRN", gdp: 413_000_000_000, population: 89_000_000),
            WorldCountryGDP(countryName: "South Africa", countryCode: "ZAF", gdp: 380_000_000_000, population: 60_000_000),
            WorldCountryGDP(countryName: "Colombia", countryCode: "COL", gdp: 363_000_000_000, population: 52_000_000),
            WorldCountryGDP(countryName: "Pakistan", countryCode: "PAK", gdp: 338_000_000_000, population: 240_000_000),
            WorldCountryGDP(countryName: "Iraq", countryCode: "IRQ", gdp: 250_000_000_000, population: 44_000_000),
            WorldCountryGDP(countryName: "Kazakhstan", countryCode: "KAZ", gdp: 225_000_000_000, population: 20_000_000),
            WorldCountryGDP(countryName: "Algeria", countryCode: "DZA", gdp: 195_000_000_000, population: 45_000_000),
            WorldCountryGDP(countryName: "Ukraine", countryCode: "UKR", gdp: 160_000_000_000, population: 37_000_000),
            WorldCountryGDP(countryName: "Ethiopia", countryCode: "ETH", gdp: 156_000_000_000, population: 126_000_000),
            WorldCountryGDP(countryName: "Cuba", countryCode: "CUB", gdp: 107_000_000_000, population: 11_000_000),
            WorldCountryGDP(countryName: "Venezuela", countryCode: "VEN", gdp: 97_000_000_000, population: 28_000_000),
            WorldCountryGDP(countryName: "Belarus", countryCode: "BLR", gdp: 72_000_000_000, population: 9_000_000),
            WorldCountryGDP(countryName: "Serbia", countryCode: "SRB", gdp: 68_000_000_000, population: 7_000_000),
            WorldCountryGDP(countryName: "Myanmar", countryCode: "MMR", gdp: 65_000_000_000, population: 54_000_000),
            WorldCountryGDP(countryName: "Libya", countryCode: "LBY", gdp: 45_000_000_000, population: 7_000_000),
            WorldCountryGDP(countryName: "North Korea", countryCode: "PRK", gdp: 28_000_000_000, population: 26_000_000),
            WorldCountryGDP(countryName: "Afghanistan", countryCode: "AFG", gdp: 20_000_000_000, population: 42_000_000),
            WorldCountryGDP(countryName: "Syria", countryCode: "SYR", gdp: 9_000_000_000, population: 23_000_000)
        ].sorted { $0.gdp > $1.gdp }
    }
}
