//
//  Event.swift
//  PoliticianSim
//
//  Event system model for game events and choices
//

import Foundation

struct Event: Codable, Identifiable {
    let id: UUID
    let eventId: String // Unique identifier for event type (e.g., "early_life_001")
    let title: String
    let description: String
    let category: EventCategory
    let choices: [Choice]
    let triggers: [Trigger]
    let ageRange: AgeRange
    let requiredPosition: String? // Position title or nil

    enum EventCategory: String, Codable {
        case earlyLife = "Early Life"
        case education = "Education"
        case political = "Political"
        case economic = "Economic"
        case international = "International"
        case scandal = "Scandal"
        case crisis = "Crisis"
        case personal = "Personal"

        var iconName: String {
            switch self {
            case .earlyLife: return "figure.walk"
            case .education: return "book.fill"
            case .political: return "building.columns.fill"
            case .economic: return "dollarsign.circle.fill"
            case .international: return "globe"
            case .scandal: return "exclamationmark.triangle.fill"
            case .crisis: return "flame.fill"
            case .personal: return "person.fill"
            }
        }
    }

    struct AgeRange: Codable {
        let min: Int
        let max: Int

        func contains(_ age: Int) -> Bool {
            return age >= min && age <= max
        }
    }

    init(
        eventId: String,
        title: String,
        description: String,
        category: EventCategory,
        choices: [Choice],
        triggers: [Trigger] = [],
        ageRange: AgeRange,
        requiredPosition: String? = nil
    ) {
        self.id = UUID()
        self.eventId = eventId
        self.title = title
        self.description = description
        self.category = category
        self.choices = choices
        self.triggers = triggers
        self.ageRange = ageRange
        self.requiredPosition = requiredPosition
    }
}

// MARK: - Choice Model

extension Event {
    struct Choice: Codable, Identifiable {
        let id: UUID
        let text: String
        let outcomePreview: String
        let effects: [Effect]

        init(text: String, outcomePreview: String, effects: [Effect]) {
            self.id = UUID()
            self.text = text
            self.outcomePreview = outcomePreview
            self.effects = effects
        }
    }
}

// MARK: - Effect Model

struct Effect: Codable {
    let type: EffectType
    let value: EffectValue

    enum EffectType: String, Codable {
        case statChange = "stat_change"
        case approvalChange = "approval_change"
        case fundsChange = "funds_change"
        case healthChange = "health_change"
        case stressChange = "stress_change"
        case scandalRisk = "scandal_risk"
        case policyEnact = "policy_enact"
    }

    enum EffectValue: Codable {
        case statChange(stat: String, amount: Int)
        case approvalChange(amount: Double)
        case fundsChange(amount: Decimal)
        case healthChange(amount: Int)
        case stressChange(amount: Int)
        case scandalRisk(percentage: Double, severity: ScandalRisk.ScandalSeverity)

        // Codable implementation
        enum CodingKeys: String, CodingKey {
            case type
            case stat, amount, percentage, severity
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "stat_change":
                let stat = try container.decode(String.self, forKey: .stat)
                let amount = try container.decode(Int.self, forKey: .amount)
                self = .statChange(stat: stat, amount: amount)
            case "approval_change":
                let amount = try container.decode(Double.self, forKey: .amount)
                self = .approvalChange(amount: amount)
            case "funds_change":
                let amount = try container.decode(Decimal.self, forKey: .amount)
                self = .fundsChange(amount: amount)
            case "health_change":
                let amount = try container.decode(Int.self, forKey: .amount)
                self = .healthChange(amount: amount)
            case "stress_change":
                let amount = try container.decode(Int.self, forKey: .amount)
                self = .stressChange(amount: amount)
            case "scandal_risk":
                let percentage = try container.decode(Double.self, forKey: .percentage)
                let severity = try container.decode(ScandalRisk.ScandalSeverity.self, forKey: .severity)
                self = .scandalRisk(percentage: percentage, severity: severity)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown effect value type"
                )
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .statChange(let stat, let amount):
                try container.encode("stat_change", forKey: .type)
                try container.encode(stat, forKey: .stat)
                try container.encode(amount, forKey: .amount)
            case .approvalChange(let amount):
                try container.encode("approval_change", forKey: .type)
                try container.encode(amount, forKey: .amount)
            case .fundsChange(let amount):
                try container.encode("funds_change", forKey: .type)
                try container.encode(amount, forKey: .amount)
            case .healthChange(let amount):
                try container.encode("health_change", forKey: .type)
                try container.encode(amount, forKey: .amount)
            case .stressChange(let amount):
                try container.encode("stress_change", forKey: .type)
                try container.encode(amount, forKey: .amount)
            case .scandalRisk(let percentage, let severity):
                try container.encode("scandal_risk", forKey: .type)
                try container.encode(percentage, forKey: .percentage)
                try container.encode(severity, forKey: .severity)
            }
        }
    }
}

// MARK: - Trigger Model

struct Trigger: Codable {
    let type: TriggerType
    let condition: TriggerCondition

    enum TriggerType: String, Codable {
        case stat = "stat"
        case age = "age"
        case position = "position"
        case approval = "approval"
    }

    enum TriggerCondition: Codable {
        case statMinimum(stat: String, min: Int)
        case ageRange(min: Int, max: Int)
        case hasPosition(title: String)
        case approvalMinimum(min: Double)

        // Codable implementation
        enum CodingKeys: String, CodingKey {
            case type
            case stat, min, max, title
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "stat_minimum":
                let stat = try container.decode(String.self, forKey: .stat)
                let min = try container.decode(Int.self, forKey: .min)
                self = .statMinimum(stat: stat, min: min)
            case "age_range":
                let min = try container.decode(Int.self, forKey: .min)
                let max = try container.decode(Int.self, forKey: .max)
                self = .ageRange(min: min, max: max)
            case "has_position":
                let title = try container.decode(String.self, forKey: .title)
                self = .hasPosition(title: title)
            case "approval_minimum":
                let min = try container.decode(Double.self, forKey: .min)
                self = .approvalMinimum(min: min)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown trigger condition type"
                )
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .statMinimum(let stat, let min):
                try container.encode("stat_minimum", forKey: .type)
                try container.encode(stat, forKey: .stat)
                try container.encode(min, forKey: .min)
            case .ageRange(let min, let max):
                try container.encode("age_range", forKey: .type)
                try container.encode(min, forKey: .min)
                try container.encode(max, forKey: .max)
            case .hasPosition(let title):
                try container.encode("has_position", forKey: .type)
                try container.encode(title, forKey: .title)
            case .approvalMinimum(let min):
                try container.encode("approval_minimum", forKey: .type)
                try container.encode(min, forKey: .min)
            }
        }
    }
}
