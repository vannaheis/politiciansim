//
//  Constants.swift
//  PoliticianSim
//
//  App-wide constants and configuration
//

import SwiftUI

enum Constants {
    // MARK: - App Info
    enum App {
        static let name = "Politician Sim"
        static let tagline = "From Birth to the Presidency"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.politiciansim.app"
    }

    // MARK: - Colors (following UI.md specifications)
    enum Colors {
        // Primary
        static let background = Color.black
        static let textPrimary = Color.white
        static let textSecondary = Color.gray
        static let accent = Color.blue

        // Semantic Colors
        static let positive = Color.green
        static let negative = Color.red
        static let neutral = Color.blue
        static let warning = Color.orange
        static let achievement = Color.yellow
        static let government = Color(red: 0.3, green: 0.4, blue: 0.6) // Indigo
        static let military = Color(red: 0.8, green: 0.2, blue: 0.2) // Crimson
        static let diplomacy = Color.purple

        // Base Attribute Colors
        static let charisma = Color(red: 0.3, green: 0.6, blue: 1.0) // Light blue
        static let intelligence = Color(red: 0.5, green: 0.3, blue: 0.8) // Purple
        static let reputation = Color(red: 1.0, green: 0.7, blue: 0.0) // Gold
        static let luck = Color(red: 0.2, green: 0.8, blue: 0.3) // Green
        static let diplomacyColor = Color(red: 0.4, green: 0.5, blue: 0.9) // Royal blue

        // UI Elements
        static let cardBackground = Color.gray.opacity(0.3)
        static let cardBackgroundDark = Color(red: 0.12, green: 0.12, blue: 0.12)
        static let overlay = Color.black.opacity(0.6)
    }

    // MARK: - Typography
    enum Typography {
        static let heroNumberSize: CGFloat = 26
        static let pageTitleSize: CGFloat = 25.5
        static let largeDataSize: CGFloat = 18
        static let standardDataSize: CGFloat = 15
        static let bodyTextSize: CGFloat = 15
        static let sectionHeaderSize: CGFloat = 15
        static let sectionLabelSize: CGFloat = 12.75
        static let labelSize: CGFloat = 11.25
        static let captionSize: CGFloat = 12
        static let smallTextSize: CGFloat = 10.5
        static let microLabelSize: CGFloat = 8.8
    }

    // MARK: - Spacing
    enum Spacing {
        static let sectionVertical: CGFloat = 20
        static let cardSpacing: CGFloat = 15
        static let cardPadding: CGFloat = 15
        static let horizontalMargin: CGFloat = 16
        static let dividerVertical: CGFloat = 8
        static let iconTextSpacing: CGFloat = 6
        static let compactRowVertical: CGFloat = 10
        static let standardRowVertical: CGFloat = 14
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let card: CGFloat = 12
        static let button: CGFloat = 10
    }

    // MARK: - Game Settings
    enum Game {
        static let maxAge = 90
        static let maxStatValue = 100
        static let minStatValue = 0
        static let autosaveInterval: TimeInterval = 2.0 // 2 seconds

        // Starting age ranges for random attributes
        static let attributeMinStart = 40
        static let attributeMaxStart = 80
    }

    // MARK: - SF Symbols
    enum Icons {
        // Stats
        static let charisma = "person.fill"
        static let intelligence = "brain.head.profile"
        static let reputation = "star.fill"
        static let luck = "dice.fill"
        static let diplomacy = "bubble.left.and.bubble.right.fill"

        // Career
        static let communityOrganizer = "person.3.fill"
        static let cityCouncil = "building.2.fill"
        static let mayor = "building.fill"
        static let stateRep = "doc.text.fill"
        static let governor = "flag.fill"
        static let senator = "building.columns.fill"
        static let vicePresident = "star.circle.fill"
        static let president = "crown.fill"

        // Navigation
        static let home = "house.fill"
        static let profile = "person.circle.fill"
        static let career = "briefcase.fill"
        static let policies = "doc.text.fill"
        static let budget = "dollarsign.circle.fill"
        static let territory = "map.fill"
        static let military = "shield.fill"
        static let warRoom = "exclamationmark.triangle.fill"
        static let media = "newspaper.fill"
        static let settings = "gear"

        // Time
        static let day = "sun.max.fill"
        static let week = "calendar"

        // Events
        static let earlyLife = "figure.walk"
        static let education = "book.fill"
        static let political = "building.columns.fill"
        static let economic = "dollarsign.circle.fill"
        static let international = "globe"
        static let scandal = "exclamationmark.triangle.fill"
        static let crisis = "flame.fill"
        static let personal = "person.fill"
    }

    // MARK: - Animations
    enum Animation {
        static let springDamping = 0.8
        static let springDuration = 0.4
        static let fadeIn = 0.3
        static let statChange = 0.8
        static let progressBar = 0.5
    }
}
