//
//  ElectionsView.swift
//  PoliticianSim
//
//  Elections and voting results view
//

import SwiftUI

struct ElectionsView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            StandardBackgroundView()

            VStack(spacing: 0) {
                // Top header
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameManager.navigationManager.toggleMenu()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Elections")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if let character = gameManager.character {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Upcoming election
                            if let election = gameManager.electionManager.upcomingElection {
                                UpcomingElectionCard(election: election, character: character)

                                // Run election button
                                if election.daysUntilElection <= 0 {
                                    RunElectionButton(election: election)
                                }
                            }

                            // Election history
                            if !gameManager.electionManager.electionHistory.isEmpty {
                                ElectionHistorySection(history: gameManager.electionManager.electionHistory)
                            }

                            // No elections
                            if gameManager.electionManager.upcomingElection == nil && gameManager.electionManager.electionHistory.isEmpty {
                                NoElectionsView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                } else {
                    PlaceholderEmptyState(message: "No character found")
                }
            }

            // Side menu overlay
            SideMenuView(isOpen: $gameManager.navigationManager.isMenuOpen)
        }
    }
}

// MARK: - Upcoming Election Card

struct UpcomingElectionCard: View {
    let election: Election
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Constants.Colors.political.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: "checkmark.ballot")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.political)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Upcoming Election")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(election.position.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // Election date
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)

                if election.daysUntilElection > 0 {
                    Text("\(election.daysUntilElection) days until election day")
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.secondaryText)
                } else {
                    Text("Election Day!")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Constants.Colors.political)
                }
            }

            // Candidates
            VStack(alignment: .leading, spacing: 8) {
                Text("Candidates")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Constants.Colors.secondaryText)

                ForEach(election.candidates) { candidate in
                    CandidateRow(candidate: candidate)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct CandidateRow: View {
    let candidate: Candidate

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: candidate.isPlayer ? "star.fill" : "person.fill")
                .font(.system(size: 12))
                .foregroundColor(candidate.isPlayer ? Constants.Colors.political : Constants.Colors.secondaryText)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(candidate.name)
                    .font(.system(size: 13, weight: candidate.isPlayer ? .bold : .medium))
                    .foregroundColor(.white)

                Text(candidate.party)
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            Spacer()

            if candidate.isPlayer {
                Text("You")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Constants.Colors.political)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Constants.Colors.political.opacity(0.2))
                    )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Run Election Button

struct RunElectionButton: View {
    @EnvironmentObject var gameManager: GameManager
    let election: Election
    @State private var showingResults = false
    @State private var electionResults: ElectionResults?

    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                runElection()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Run Election")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Constants.Colors.political)
                )
            }

            if showingResults, let results = electionResults {
                ElectionResultsCard(results: results, election: election)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func runElection() {
        guard let character = gameManager.character else { return }
        electionResults = gameManager.electionManager.simulateElection(character: character)
        showingResults = true

        // If player won, update position
        if let results = electionResults,
           gameManager.electionManager.wonElection(character: character) {
            var updatedCharacter = character
            updatedCharacter.currentPosition = election.position
            gameManager.characterManager.updateCharacter(updatedCharacter)
        }
    }
}

// MARK: - Election Results Card

struct ElectionResultsCard: View {
    let results: ElectionResults
    let election: Election

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Election Results")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            Divider()
                .background(Color.white.opacity(0.2))

            // Winner announcement
            VStack(alignment: .leading, spacing: 6) {
                Text("Winner")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(results.winnerName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Constants.Colors.positive)

                Text("with \(String(format: "%.1f", results.finalResults[results.winnerId] ?? 0))% of votes")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            // All candidate results
            ForEach(election.candidates) { candidate in
                if let votePercentage = results.finalResults[candidate.id] {
                    ResultRow(candidateName: candidate.name, percentage: votePercentage, isWinner: candidate.id == results.winnerId)
                }
            }

            // Voter turnout
            HStack {
                Text("Voter Turnout:")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text("\(String(format: "%.1f", election.voterTurnout))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Constants.Colors.positive.opacity(0.1))
        )
    }
}

struct ResultRow: View {
    let candidateName: String
    let percentage: Double
    let isWinner: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(candidateName)
                .font(.system(size: 13, weight: isWinner ? .bold : .regular))
                .foregroundColor(.white)

            Spacer()

            Text("\(String(format: "%.1f", percentage))%")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isWinner ? Constants.Colors.positive : .white)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Election History Section

struct ElectionHistorySection: View {
    let history: [Election]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Election History")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.secondaryText)

            VStack(spacing: 8) {
                ForEach(history.suffix(5).reversed()) { election in
                    if let results = election.results {
                        ElectionHistoryRow(election: election, results: results)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct ElectionHistoryRow: View {
    let election: Election
    let results: ElectionResults

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(election.position.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text(formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)
            }

            HStack {
                Text("Winner: \(results.winnerName)")
                    .font(.system(size: 11))
                    .foregroundColor(Constants.Colors.secondaryText)

                Spacer()

                Text("\(String(format: "%.1f", results.finalResults[results.winnerId] ?? 0))%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Constants.Colors.positive)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: election.electionDate)
    }
}

// MARK: - No Elections View

struct NoElectionsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.ballot.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryText)

            Text("No Upcoming Elections")
                .font(.system(size: Constants.Typography.pageTitleSize, weight: .bold))
                .foregroundColor(.white)

            Text("Start a campaign to enter an election")
                .font(.system(size: Constants.Typography.bodyTextSize))
                .foregroundColor(Constants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }
}

#Preview {
    ElectionsView()
        .environmentObject(GameManager.shared)
}
