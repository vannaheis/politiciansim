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

    enum NavigationView: String {
        case home = "home"
        case profile = "profile"
        case career = "career"
        case policies = "policies"
        case budget = "budget"
        case territory = "territory"
        case military = "military"
        case warRoom = "warRoom"
        case media = "media"
        case elections = "elections"
        case settings = "settings"
    }

    // MARK: - Navigation

    func navigateTo(_ view: NavigationView) {
        currentView = view
    }

    func navigateToHome() {
        currentView = .home
    }

    func goBack() {
        // Will implement navigation stack in Phase 2
        currentView = .home
    }
}
