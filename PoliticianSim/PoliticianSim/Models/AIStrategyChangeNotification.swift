//
//  AIStrategyChangeNotification.swift
//  PoliticianSim
//
//  Notification when AI opponent changes war strategy
//

import Foundation

struct AIStrategyChangeNotification: Identifiable {
    let id = UUID()
    let war: War
    let enemyCountryName: String
    let oldStrategy: War.WarStrategy
    let newStrategy: War.WarStrategy

    var title: String {
        "\(enemyCountryName) Changed Strategy"
    }

    var message: String {
        "Enemy forces have shifted from \(oldStrategy.rawValue) to \(newStrategy.rawValue)."
    }

    var icon: String {
        "arrow.triangle.2.circlepath"
    }
}
