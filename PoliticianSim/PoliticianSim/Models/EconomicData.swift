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

        // Keep only last 100 data points
        if history.count > 100 {
            history.removeFirst(history.count - 100)
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
        gdp: Double = 25_000_000_000_000,
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

    init() {
        self.local = LocalEconomicData(cityName: "New York")
        self.state = StateEconomicData(stateName: "New York")
        self.federal = FederalEconomicData()
        self.worldGDPs = Self.defaultWorldGDPs()
    }

    static func defaultWorldGDPs() -> [WorldCountryGDP] {
        return [
            WorldCountryGDP(countryName: "United States", countryCode: "USA", gdp: 25_000_000_000_000, population: 330_000_000),
            WorldCountryGDP(countryName: "China", countryCode: "CHN", gdp: 18_000_000_000_000, population: 1_400_000_000),
            WorldCountryGDP(countryName: "Japan", countryCode: "JPN", gdp: 5_000_000_000_000, population: 125_000_000),
            WorldCountryGDP(countryName: "Germany", countryCode: "DEU", gdp: 4_200_000_000_000, population: 83_000_000),
            WorldCountryGDP(countryName: "United Kingdom", countryCode: "GBR", gdp: 3_100_000_000_000, population: 67_000_000),
            WorldCountryGDP(countryName: "India", countryCode: "IND", gdp: 3_400_000_000_000, population: 1_400_000_000),
            WorldCountryGDP(countryName: "France", countryCode: "FRA", gdp: 2_900_000_000_000, population: 67_000_000),
            WorldCountryGDP(countryName: "Italy", countryCode: "ITA", gdp: 2_000_000_000_000, population: 60_000_000),
            WorldCountryGDP(countryName: "Canada", countryCode: "CAN", gdp: 2_100_000_000_000, population: 38_000_000),
            WorldCountryGDP(countryName: "South Korea", countryCode: "KOR", gdp: 1_800_000_000_000, population: 51_000_000)
        ].sorted { $0.gdp > $1.gdp }
    }
}
