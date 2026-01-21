//
//  MobilizationLevel.swift
//  PoliticianSim
//
//  Mobilization levels for military recruitment
//

import Foundation

enum MobilizationLevel: String, Codable, CaseIterable {
    case peacetime = "Peacetime"
    case raisedReadiness = "Raised Readiness"
    case partialMobilization = "Partial Mobilization"
    case fullMobilization = "Full Mobilization"
    case totalWar = "Total War"

    var percentage: Double {
        switch self {
        case .peacetime: return 0.003           // 0.3%
        case .raisedReadiness: return 0.01      // 1.0%
        case .partialMobilization: return 0.02  // 2.0%
        case .fullMobilization: return 0.05     // 5.0%
        case .totalWar: return 0.10             // 10.0%
        }
    }

    var approvalImpactYearly: Double {
        switch self {
        case .peacetime: return 0.0
        case .raisedReadiness: return -2.0
        case .partialMobilization: return -5.0
        case .fullMobilization: return -10.0
        case .totalWar: return -20.0
        }
    }

    var approvalImpactDaily: Double {
        approvalImpactYearly / 365.0
    }

    var description: String {
        switch self {
        case .peacetime:
            return "Normal volunteer force with minimal mobilization"
        case .raisedReadiness:
            return "Increased recruitment and readiness posture"
        case .partialMobilization:
            return "Significant military buildup and expansion"
        case .fullMobilization:
            return "Wartime mobilization of national resources"
        case .totalWar:
            return "Complete national mobilization for total war"
        }
    }

    var icon: String {
        switch self {
        case .peacetime: return "shield"
        case .raisedReadiness: return "shield.fill"
        case .partialMobilization: return "exclamationmark.shield"
        case .fullMobilization: return "exclamationmark.shield.fill"
        case .totalWar: return "flame.fill"
        }
    }
}
