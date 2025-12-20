//
//  GlobalCountryState.swift
//  PoliticianSim
//
//  Global state manager for all countries' territories, GDP, and military strength
//

import Foundation
import Combine

class GlobalCountryState: ObservableObject, Codable {
    @Published var countries: [CountryState] = []

    enum CodingKeys: String, CodingKey {
        case countries
    }

    // MARK: - Country State Model

    struct CountryState: Identifiable, Codable {
        let id: UUID
        let code: String
        let name: String
        var baseTerritory: Double          // Original territory size (sq mi)
        var conqueredTerritory: Double     // Territory gained from wars (sq mi)
        var lostTerritory: Double          // Territory lost to others (sq mi)
        var currentGDP: Double             // Current GDP in USD
        var population: Int                // Current population
        var militaryStrength: Int          // Current military strength

        var totalTerritory: Double {
            baseTerritory + conqueredTerritory - lostTerritory
        }

        var territoryChangePercent: Double {
            guard baseTerritory > 0 else { return 0 }
            return (conqueredTerritory - lostTerritory) / baseTerritory
        }

        init(
            code: String,
            name: String,
            baseTerritory: Double,
            population: Int,
            gdp: Double,
            militaryStrength: Int
        ) {
            self.id = UUID()
            self.code = code
            self.name = name
            self.baseTerritory = baseTerritory
            self.conqueredTerritory = 0.0
            self.lostTerritory = 0.0
            self.currentGDP = gdp
            self.population = population
            self.militaryStrength = militaryStrength
        }
    }

    // MARK: - Initialization

    init() {
        self.countries = Self.initializeDefaultCountries()
    }

    // MARK: - Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countries = try container.decode([CountryState].self, forKey: .countries)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countries, forKey: .countries)
    }

    // MARK: - Default Country Initialization

    static func initializeDefaultCountries() -> [CountryState] {
        return [
            // Major Powers
            CountryState(code: "USA", name: "United States", baseTerritory: 3_800_000, population: 335_000_000, gdp: 27_360_000_000_000, militaryStrength: 1_390_000),
            CountryState(code: "CHN", name: "China", baseTerritory: 3_700_000, population: 1_425_000_000, gdp: 17_960_000_000_000, militaryStrength: 2_035_000),
            CountryState(code: "RUS", name: "Russia", baseTerritory: 6_600_000, population: 144_000_000, gdp: 2_060_000_000_000, militaryStrength: 1_150_000),
            CountryState(code: "IND", name: "India", baseTerritory: 1_269_000, population: 1_428_000_000, gdp: 3_890_000_000_000, militaryStrength: 1_450_000),
            CountryState(code: "PRK", name: "North Korea", baseTerritory: 46_540, population: 26_000_000, gdp: 28_000_000_000, militaryStrength: 1_280_000),
            CountryState(code: "PAK", name: "Pakistan", baseTerritory: 307_374, population: 240_000_000, gdp: 338_000_000_000, militaryStrength: 654_000),

            // Regional Powers
            CountryState(code: "IRN", name: "Iran", baseTerritory: 636_372, population: 89_000_000, gdp: 413_000_000_000, militaryStrength: 610_000),
            CountryState(code: "KOR", name: "South Korea", baseTerritory: 38_691, population: 51_000_000, gdp: 1_710_000_000_000, militaryStrength: 555_000),
            CountryState(code: "TUR", name: "Turkey", baseTerritory: 302_535, population: 85_000_000, gdp: 1_030_000_000_000, militaryStrength: 355_000),
            CountryState(code: "EGY", name: "Egypt", baseTerritory: 390_121, population: 112_000_000, gdp: 476_000_000_000, militaryStrength: 440_000),
            CountryState(code: "VNM", name: "Vietnam", baseTerritory: 127_882, population: 98_000_000, gdp: 430_000_000_000, militaryStrength: 482_000),
            CountryState(code: "MMR", name: "Myanmar", baseTerritory: 261_228, population: 54_000_000, gdp: 65_000_000_000, militaryStrength: 406_000),
            CountryState(code: "IDN", name: "Indonesia", baseTerritory: 735_358, population: 277_000_000, gdp: 1_390_000_000_000, militaryStrength: 400_000),
            CountryState(code: "THA", name: "Thailand", baseTerritory: 198_117, population: 71_000_000, gdp: 514_000_000_000, militaryStrength: 361_000),

            // NATO & Allies
            CountryState(code: "GBR", name: "United Kingdom", baseTerritory: 93_628, population: 68_000_000, gdp: 3_340_000_000_000, militaryStrength: 148_000),
            CountryState(code: "FRA", name: "France", baseTerritory: 248_573, population: 68_000_000, gdp: 3_050_000_000_000, militaryStrength: 203_000),
            CountryState(code: "DEU", name: "Germany", baseTerritory: 137_988, population: 84_000_000, gdp: 4_430_000_000_000, militaryStrength: 183_000),
            CountryState(code: "JPN", name: "Japan", baseTerritory: 145_937, population: 123_000_000, gdp: 4_210_000_000_000, militaryStrength: 247_000),
            CountryState(code: "ITA", name: "Italy", baseTerritory: 116_348, population: 59_000_000, gdp: 2_190_000_000_000, militaryStrength: 165_000),
            CountryState(code: "POL", name: "Poland", baseTerritory: 120_733, population: 38_000_000, gdp: 688_000_000_000, militaryStrength: 114_000),

            // Middle East
            CountryState(code: "SAU", name: "Saudi Arabia", baseTerritory: 830_000, population: 36_000_000, gdp: 1_070_000_000_000, militaryStrength: 257_000),
            CountryState(code: "ISR", name: "Israel", baseTerritory: 8_019, population: 9_500_000, gdp: 525_000_000_000, militaryStrength: 170_000),
            CountryState(code: "SYR", name: "Syria", baseTerritory: 71_498, population: 23_000_000, gdp: 9_000_000_000, militaryStrength: 169_000),
            CountryState(code: "IRQ", name: "Iraq", baseTerritory: 168_754, population: 44_000_000, gdp: 250_000_000_000, militaryStrength: 193_000),

            // Latin America
            CountryState(code: "BRA", name: "Brazil", baseTerritory: 3_287_956, population: 216_000_000, gdp: 2_330_000_000_000, militaryStrength: 360_000),
            CountryState(code: "COL", name: "Colombia", baseTerritory: 440_831, population: 52_000_000, gdp: 363_000_000_000, militaryStrength: 293_000),
            CountryState(code: "MEX", name: "Mexico", baseTerritory: 761_610, population: 128_000_000, gdp: 1_460_000_000_000, militaryStrength: 277_000),
            CountryState(code: "VEN", name: "Venezuela", baseTerritory: 353_841, population: 28_000_000, gdp: 97_000_000_000, militaryStrength: 123_000),
            CountryState(code: "CUB", name: "Cuba", baseTerritory: 42_426, population: 11_000_000, gdp: 107_000_000_000, militaryStrength: 49_000),

            // Africa
            CountryState(code: "NGA", name: "Nigeria", baseTerritory: 356_669, population: 223_000_000, gdp: 477_000_000_000, militaryStrength: 143_000),
            CountryState(code: "ETH", name: "Ethiopia", baseTerritory: 426_373, population: 126_000_000, gdp: 156_000_000_000, militaryStrength: 162_000),
            CountryState(code: "ZAF", name: "South Africa", baseTerritory: 471_445, population: 60_000_000, gdp: 380_000_000_000, militaryStrength: 73_000),
            CountryState(code: "DZA", name: "Algeria", baseTerritory: 919_595, population: 45_000_000, gdp: 195_000_000_000, militaryStrength: 130_000),

            // Oceania & Others
            CountryState(code: "AUS", name: "Australia", baseTerritory: 2_969_907, population: 26_000_000, gdp: 1_690_000_000_000, militaryStrength: 60_000),
            CountryState(code: "TWN", name: "Taiwan", baseTerritory: 13_976, population: 23_000_000, gdp: 790_000_000_000, militaryStrength: 169_000),
            CountryState(code: "UKR", name: "Ukraine", baseTerritory: 233_032, population: 37_000_000, gdp: 160_000_000_000, militaryStrength: 700_000),
            CountryState(code: "AFG", name: "Afghanistan", baseTerritory: 251_827, population: 42_000_000, gdp: 20_000_000_000, militaryStrength: 175_000),

            // Smaller Nations
            CountryState(code: "BLR", name: "Belarus", baseTerritory: 80_155, population: 9_000_000, gdp: 72_000_000_000, militaryStrength: 48_000),
            CountryState(code: "KAZ", name: "Kazakhstan", baseTerritory: 1_052_090, population: 20_000_000, gdp: 225_000_000_000, militaryStrength: 39_000),
            CountryState(code: "SRB", name: "Serbia", baseTerritory: 29_913, population: 7_000_000, gdp: 68_000_000_000, militaryStrength: 28_000),
            CountryState(code: "LBY", name: "Libya", baseTerritory: 679_362, population: 7_000_000, gdp: 45_000_000_000, militaryStrength: 32_000)
        ]
    }

    // MARK: - Query Methods

    func getCountry(code: String) -> CountryState? {
        return countries.first { $0.code == code }
    }

    func updateCountry(_ country: CountryState) {
        if let index = countries.firstIndex(where: { $0.id == country.id }) {
            countries[index] = country
        }
    }

    func getRankedByTerritory() -> [CountryState] {
        return countries.sorted { $0.totalTerritory > $1.totalTerritory }
    }

    func getRankedByGDP() -> [CountryState] {
        return countries.sorted { $0.currentGDP > $1.currentGDP }
    }

    // MARK: - War Outcome Application

    func applyWarOutcome(
        attackerCode: String,
        defenderCode: String,
        territoryPercentConquered: Double
    ) {
        // NOTE: Parameter names are misleading for historical reasons
        // attackerCode = winner (gains territory)
        // defenderCode = loser (loses territory)
        guard var winner = getCountry(code: attackerCode),
              var loser = getCountry(code: defenderCode) else {
            return
        }

        // Calculate territory transfer
        let territoryTransferred = loser.baseTerritory * territoryPercentConquered

        // Calculate population transfer (non-linear)
        let populationPercentChange = pow(territoryPercentConquered, 0.7)
        let populationTransferred = Int(Double(loser.population) * populationPercentChange)

        // Update winner (gains territory)
        winner.conqueredTerritory += territoryTransferred
        winner.population += populationTransferred

        // Update loser (loses territory)
        loser.lostTerritory += territoryTransferred
        loser.population -= populationTransferred

        // Apply non-linear GDP impact
        let gdpPercentChange = pow(territoryPercentConquered, 0.7)
        let gdpTransferred = loser.currentGDP * gdpPercentChange

        // Loser loses GDP
        loser.currentGDP -= gdpTransferred

        // Winner gains GDP at reduced rate (30% initially for conquered territory)
        winner.currentGDP += gdpTransferred * 0.3

        // Save changes
        updateCountry(winner)
        updateCountry(loser)
    }

    // MARK: - AI Military Strength Evolution

    func updateMilitaryStrength(countryCode: String, previousYearGDP: Double) {
        guard var country = getCountry(code: countryCode) else { return }

        let gdpGrowth = (country.currentGDP - previousYearGDP) / previousYearGDP
        let territoryChange = country.territoryChangePercent

        var strengthChange = 1.0

        // GDP impact
        if gdpGrowth > 0.03 {
            strengthChange *= 1.02  // +2% if GDP growing > 3%
        } else if gdpGrowth < 0 {
            strengthChange *= 0.98  // -2% if GDP declining
        }

        // Territory impact
        strengthChange *= (1.0 + territoryChange * 0.5)

        // Random variation
        strengthChange *= Double.random(in: 0.97...1.03)

        country.militaryStrength = Int(Double(country.militaryStrength) * strengthChange)

        updateCountry(country)
    }
}
