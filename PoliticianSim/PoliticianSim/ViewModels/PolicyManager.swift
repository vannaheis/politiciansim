//
//  PolicyManager.swift
//  PoliticianSim
//
//  Manages policy proposals, enactment, and effects
//

import Foundation
import Combine

class PolicyManager: ObservableObject {
    @Published var availablePolicies: [Policy] = []
    @Published var enactedPolicies: [Policy] = []
    @Published var proposedPolicies: [Policy] = []

    init() {
        loadAvailablePolicies()
    }

    // MARK: - Policy Management

    func loadAvailablePolicies() {
        availablePolicies = Policy.getAvailablePolicies()
    }

    func proposePolicy(_ policy: Policy, character: Character) -> (success: Bool, message: String) {
        // Check requirements
        guard meetsRequirements(policy: policy, character: character) else {
            return (false, "You don't meet the requirements for this policy.")
        }

        // Check if already proposed or enacted
        if proposedPolicies.contains(where: { $0.id == policy.id }) {
            return (false, "This policy has already been proposed.")
        }

        if enactedPolicies.contains(where: { $0.id == policy.id }) {
            return (false, "This policy is already enacted.")
        }

        var proposedPolicy = policy
        proposedPolicy.status = .proposed
        proposedPolicies.append(proposedPolicy)

        return (true, "Policy proposed successfully!")
    }

    func enactPolicy(_ policyId: UUID, character: inout Character) -> (success: Bool, message: String) {
        guard let index = proposedPolicies.firstIndex(where: { $0.id == policyId }) else {
            return (false, "Policy not found in proposals.")
        }

        var policy = proposedPolicies[index]

        // Check if player has enough funds
        if character.campaignFunds < policy.requirements.costToEnact {
            return (false, "Insufficient funds to enact this policy.")
        }

        // Check requirements again
        guard meetsRequirements(policy: policy, character: character) else {
            return (false, "Requirements no longer met for this policy.")
        }

        // Apply effects
        applyPolicyEffects(policy: policy, character: &character)

        // Move to enacted
        policy.status = .enacted
        policy.enactedDate = character.currentDate
        enactedPolicies.append(policy)
        proposedPolicies.remove(at: index)

        return (true, "\(policy.title) has been enacted!")
    }

    func repealPolicy(_ policyId: UUID, character: inout Character) -> (success: Bool, message: String) {
        guard let index = enactedPolicies.firstIndex(where: { $0.id == policyId }) else {
            return (false, "Policy not found in enacted policies.")
        }

        var policy = enactedPolicies[index]

        // Reverse effects (half the original impact)
        var reversedEffects = policy.effects
        reversedEffects.approvalChange = -(policy.effects.approvalChange / 2.0)
        reversedEffects.economicImpact = -(policy.effects.economicImpact / 2.0)
        reversedEffects.reputationChange = -(policy.effects.reputationChange / 2)
        reversedEffects.stressChange = 8 // Repealing causes stress
        reversedEffects.fundsChange = 0

        let tempPolicy = Policy(
            title: policy.title,
            description: policy.description,
            category: policy.category,
            effects: reversedEffects,
            requirements: policy.requirements
        )

        applyPolicyEffects(policy: tempPolicy, character: &character)

        // Remove from enacted
        policy.status = .repealed
        enactedPolicies.remove(at: index)

        return (true, "\(policy.title) has been repealed.")
    }

    // MARK: - Helper Methods

    func meetsRequirements(policy: Policy, character: Character) -> Bool {
        // Check position level
        guard let position = character.currentPosition else {
            return policy.requirements.minPosition <= 1
        }

        if position.level < policy.requirements.minPosition {
            return false
        }

        // Check approval
        if character.approvalRating < policy.requirements.minApproval {
            return false
        }

        // Check reputation
        if character.reputation < policy.requirements.minReputation {
            return false
        }

        return true
    }

    private func applyPolicyEffects(policy: Policy, character: inout Character) {
        // Apply approval change
        character.approvalRating = max(0, min(100, character.approvalRating + policy.effects.approvalChange))

        // Apply reputation change
        character.reputation = max(0, min(100, character.reputation + policy.effects.reputationChange))

        // Apply stress change
        character.stress = max(0, min(100, character.stress + policy.effects.stressChange))

        // Apply funds change
        character.campaignFunds -= policy.requirements.costToEnact
        character.campaignFunds += policy.effects.fundsChange
    }

    func getAvailablePolicies(for character: Character) -> [Policy] {
        // Filter out already proposed and enacted policies
        let unavailableIds = Set(proposedPolicies.map { $0.id } + enactedPolicies.map { $0.id })
        return availablePolicies.filter { !unavailableIds.contains($0.id) }
    }

    func getPoliciesByCategory(_ category: Policy.PolicyCategory) -> [Policy] {
        return availablePolicies.filter { $0.category == category }
    }

    func getRequirementStatus(policy: Policy, character: Character) -> [String] {
        var status: [String] = []

        // Position requirement
        if let position = character.currentPosition {
            if position.level < policy.requirements.minPosition {
                status.append("❌ Position Level \(policy.requirements.minPosition) required")
            } else {
                status.append("✓ Position requirement met")
            }
        } else if policy.requirements.minPosition > 1 {
            status.append("❌ Position required")
        }

        // Approval requirement
        if character.approvalRating < policy.requirements.minApproval {
            status.append("❌ \(Int(policy.requirements.minApproval))% approval required")
        } else if policy.requirements.minApproval > 0 {
            status.append("✓ Approval requirement met")
        }

        // Reputation requirement
        if character.reputation < policy.requirements.minReputation {
            status.append("❌ \(policy.requirements.minReputation) reputation required")
        } else if policy.requirements.minReputation > 0 {
            status.append("✓ Reputation requirement met")
        }

        // Funds requirement
        if character.campaignFunds < policy.requirements.costToEnact {
            status.append("❌ Insufficient funds")
        } else if policy.requirements.costToEnact > 0 {
            status.append("✓ Funds available")
        }

        return status
    }

    func canEnactPolicy(policy: Policy, character: Character) -> Bool {
        return meetsRequirements(policy: policy, character: character) &&
               character.campaignFunds >= policy.requirements.costToEnact
    }
}
