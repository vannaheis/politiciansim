//
//  NavigationManager.swift
//  PoliticianSim
//
//  Manages view navigation state
//

import Foundation
import Combine

class NavigationManager: ObservableObject {
    @Published var currentView: NavigationView = .home
    @Published var isMenuOpen: Bool = false

    enum NavigationView: String, CaseIterable {
        case home = "Home"

        // Character
        case profile = "Profile"
        case stats = "Stats"

        // Political Career
        case position = "Position"
        case elections = "Elections"
        case campaigns = "Campaigns"

        // Governance
        case policies = "Policies"
        case budget = "Budget"
        case laws = "Laws"

        // Relations
        case diplomacy = "Diplomacy"
        case publicOpinion = "Public Opinion"

        // Settings
        case settings = "Settings"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .profile: return "person.fill"
            case .stats: return "chart.bar.fill"
            case .position: return "star.fill"
            case .elections: return "checkmark.seal.fill"
            case .campaigns: return "megaphone.fill"
            case .policies: return "doc.text.fill"
            case .budget: return "dollarsign.circle.fill"
            case .laws: return "book.closed.fill"
            case .diplomacy: return "globe.americas.fill"
            case .publicOpinion: return "chart.line.uptrend.xyaxis"
            case .settings: return "gearshape.fill"
            }
        }

        var section: MenuSection {
            switch self {
            case .home: return .none
            case .profile, .stats: return .character
            case .position, .elections, .campaigns: return .career
            case .policies, .budget, .laws: return .governance
            case .diplomacy, .publicOpinion: return .relations
            case .settings: return .settings
            }
        }
    }

    enum MenuSection: String {
        case none = "NONE"
        case character = "CHARACTER"
        case career = "POLITICAL CAREER"
        case governance = "GOVERNANCE"
        case relations = "RELATIONS"
        case settings = "SETTINGS"
    }

    // MARK: - Navigation

    func navigateTo(_ view: NavigationView) {
        currentView = view
        isMenuOpen = false // Close menu when navigating
    }

    func navigateToHome() {
        currentView = .home
        isMenuOpen = false
    }

    func toggleMenu() {
        isMenuOpen.toggle()
    }

    func closeMenu() {
        isMenuOpen = false
    }

    func goBack() {
        // Will implement navigation stack in Phase 2
        currentView = .home
    }

    // Get menu items grouped by section
    func getMenuItems() -> [(MenuSection, [NavigationView])] {
        var grouped: [MenuSection: [NavigationView]] = [:]

        for view in NavigationView.allCases where view != .home {
            let section = view.section
            if grouped[section] == nil {
                grouped[section] = []
            }
            grouped[section]?.append(view)
        }

        // Return in desired order
        let order: [MenuSection] = [.character, .career, .governance, .relations, .settings]
        return order.compactMap { section in
            guard let items = grouped[section], !items.isEmpty else { return nil }
            return (section, items)
        }
    }
}
