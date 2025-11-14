//
//  Education.swift
//  PoliticianSim
//
//  Education system with colleges, universities, and degrees
//

import Foundation

// MARK: - Education Level

enum EducationLevel: String, Codable, CaseIterable {
    case highSchool = "High School Diploma"
    case associates = "Associate's Degree"
    case bachelors = "Bachelor's Degree"
    case masters = "Master's Degree"
    case doctorate = "Doctorate"
    case professional = "Professional Degree"

    var yearsRequired: Int {
        switch self {
        case .highSchool: return 0 // Already completed
        case .associates: return 2
        case .bachelors: return 4
        case .masters: return 2
        case .doctorate: return 4
        case .professional: return 3
        }
    }

    var prerequisite: EducationLevel? {
        switch self {
        case .highSchool: return nil
        case .associates: return .highSchool
        case .bachelors: return .highSchool
        case .masters: return .bachelors
        case .doctorate: return .masters
        case .professional: return .bachelors
        }
    }

    var reputationBonus: Int {
        switch self {
        case .highSchool: return 0
        case .associates: return 5
        case .bachelors: return 10
        case .masters: return 15
        case .doctorate: return 25
        case .professional: return 20
        }
    }

    var intelligenceBonus: Int {
        switch self {
        case .highSchool: return 0
        case .associates: return 3
        case .bachelors: return 5
        case .masters: return 8
        case .doctorate: return 12
        case .professional: return 10
        }
    }
}

// MARK: - Field of Study

enum FieldOfStudy: String, Codable, CaseIterable {
    // Political & Social Sciences
    case politicalScience = "Political Science"
    case publicPolicy = "Public Policy"
    case internationalRelations = "International Relations"
    case sociology = "Sociology"
    case psychology = "Psychology"

    // Law & Justice
    case law = "Law"
    case criminalJustice = "Criminal Justice"

    // Business & Economics
    case economics = "Economics"
    case business = "Business Administration"
    case finance = "Finance"
    case accounting = "Accounting"

    // Communication & Media
    case communications = "Communications"
    case journalism = "Journalism"
    case publicRelations = "Public Relations"

    // STEM
    case engineering = "Engineering"
    case computerScience = "Computer Science"
    case mathematics = "Mathematics"
    case biology = "Biology"
    case chemistry = "Chemistry"
    case physics = "Physics"

    // Humanities
    case history = "History"
    case philosophy = "Philosophy"
    case english = "English Literature"
    case languages = "Foreign Languages"

    // Medicine & Health
    case medicine = "Medicine"
    case publicHealth = "Public Health"
    case nursing = "Nursing"

    // Education
    case education = "Education"

    var statBonus: (charisma: Int, intelligence: Int, diplomacy: Int) {
        switch self {
        case .politicalScience: return (5, 3, 5)
        case .publicPolicy: return (3, 5, 4)
        case .internationalRelations: return (3, 4, 6)
        case .sociology, .psychology: return (4, 4, 3)
        case .law: return (5, 5, 4)
        case .criminalJustice: return (3, 3, 3)
        case .economics, .finance: return (2, 6, 2)
        case .business, .accounting: return (4, 4, 2)
        case .communications, .journalism, .publicRelations: return (6, 2, 4)
        case .engineering, .computerScience, .mathematics: return (1, 7, 1)
        case .biology, .chemistry, .physics: return (2, 6, 2)
        case .history, .philosophy: return (3, 5, 3)
        case .english, .languages: return (4, 4, 4)
        case .medicine, .publicHealth: return (3, 6, 3)
        case .nursing: return (4, 4, 3)
        case .education: return (5, 3, 4)
        }
    }

    var politicalRelevance: Double {
        switch self {
        case .politicalScience, .publicPolicy: return 1.0
        case .law, .internationalRelations: return 0.9
        case .economics, .business: return 0.8
        case .communications, .journalism: return 0.7
        case .sociology, .psychology, .history: return 0.6
        case .publicHealth, .education: return 0.5
        default: return 0.3
        }
    }
}

// MARK: - Institution Type

enum InstitutionType: String, Codable {
    case communityCollege = "Community College"
    case stateUniversity = "State University"
    case privateUniversity = "Private University"
    case ivyLeague = "Ivy League"
    case lawSchool = "Law School"
    case medicalSchool = "Medical School"
    case businessSchool = "Business School"

    var prestigeLevel: Int {
        switch self {
        case .communityCollege: return 1
        case .stateUniversity: return 2
        case .privateUniversity: return 3
        case .ivyLeague: return 5
        case .lawSchool, .medicalSchool, .businessSchool: return 4
        }
    }

    var baseCostPerYear: Decimal {
        switch self {
        case .communityCollege: return 5000
        case .stateUniversity: return 15000
        case .privateUniversity: return 40000
        case .ivyLeague: return 60000
        case .lawSchool: return 50000
        case .medicalSchool: return 55000
        case .businessSchool: return 45000
        }
    }

    var reputationMultiplier: Double {
        switch self {
        case .communityCollege: return 1.0
        case .stateUniversity: return 1.3
        case .privateUniversity: return 1.5
        case .ivyLeague: return 2.0
        case .lawSchool, .medicalSchool, .businessSchool: return 1.7
        }
    }

    var availableDegrees: [EducationLevel] {
        switch self {
        case .communityCollege:
            return [.associates]
        case .stateUniversity, .privateUniversity, .ivyLeague:
            return [.bachelors, .masters, .doctorate]
        case .lawSchool:
            return [.professional] // JD
        case .medicalSchool:
            return [.professional] // MD
        case .businessSchool:
            return [.masters] // MBA
        }
    }
}

// MARK: - Educational Institution

struct EducationalInstitution: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let type: InstitutionType
    let location: String
    let prestige: Int // 1-10 scale

    init(name: String, type: InstitutionType, location: String, prestige: Int) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.location = location
        self.prestige = min(10, max(1, prestige))
    }

    static func == (lhs: EducationalInstitution, rhs: EducationalInstitution) -> Bool {
        return lhs.id == rhs.id
    }

    func costPerYear() -> Decimal {
        let baseCost = type.baseCostPerYear
        let prestigeMultiplier = 1.0 + (Double(prestige) / 10.0)
        return baseCost * Decimal(prestigeMultiplier)
    }

    func acceptanceChance(intelligence: Int, reputation: Int) -> Double {
        let baseChance = 0.7
        let intelligenceBonus = Double(intelligence - 50) / 200.0 // -0.25 to +0.25
        let reputationBonus = Double(reputation - 50) / 400.0 // -0.125 to +0.125
        let prestigePenalty = Double(prestige) / 50.0 // 0.02 to 0.2

        return max(0.1, min(0.95, baseChance + intelligenceBonus + reputationBonus - prestigePenalty))
    }
}

// MARK: - Degree

struct Degree: Codable, Identifiable {
    let id: UUID
    let level: EducationLevel
    let field: FieldOfStudy
    let institution: EducationalInstitution
    let startDate: Date
    var completionDate: Date?
    var isCompleted: Bool
    var currentYear: Int
    var gpa: Double // 0.0 - 4.0

    init(level: EducationLevel, field: FieldOfStudy, institution: EducationalInstitution, startDate: Date) {
        self.id = UUID()
        self.level = level
        self.field = field
        self.institution = institution
        self.startDate = startDate
        self.completionDate = nil
        self.isCompleted = false
        self.currentYear = 1
        self.gpa = 0.0
    }

    var totalCost: Decimal {
        return institution.costPerYear() * Decimal(level.yearsRequired)
    }

    var displayName: String {
        return "\(level.rawValue) in \(field.rawValue)"
    }

    var fullDisplayName: String {
        return "\(displayName) from \(institution.name)"
    }
}

// MARK: - Enrollment Status

struct EnrollmentStatus: Codable {
    var isEnrolled: Bool
    var currentDegree: Degree?
    var completedDegrees: [Degree]
    var totalCostPaid: Decimal
    var scholarshipAmount: Decimal
    var studentLoanDebt: Decimal
    var lastLoanPaymentDate: Date?

    init() {
        self.isEnrolled = false
        self.currentDegree = nil
        self.completedDegrees = []
        self.totalCostPaid = 0
        self.scholarshipAmount = 0
        self.studentLoanDebt = 0
        self.lastLoanPaymentDate = nil
    }

    func highestEducationLevel() -> EducationLevel {
        if let current = currentDegree, current.isCompleted {
            return current.level
        }

        if let highest = completedDegrees.max(by: { $0.level.yearsRequired < $1.level.yearsRequired }) {
            return highest.level
        }

        return .highSchool
    }

    func hasPrerequisite(for level: EducationLevel) -> Bool {
        guard let prereq = level.prerequisite else { return true }

        let currentLevel = highestEducationLevel()
        return currentLevel.yearsRequired >= prereq.yearsRequired
    }

    func getTotalReputationBonus() -> Int {
        var total = 0
        for degree in completedDegrees {
            total += degree.level.reputationBonus
            total += Int(Double(degree.institution.prestige) * degree.institution.type.reputationMultiplier)
        }
        return total
    }

    func getTotalIntelligenceBonus() -> Int {
        var total = 0
        for degree in completedDegrees {
            total += degree.level.intelligenceBonus
            total += degree.field.statBonus.intelligence
        }
        return total
    }

    func getTotalCharismaBonus() -> Int {
        var total = 0
        for degree in completedDegrees {
            total += degree.field.statBonus.charisma
        }
        return total
    }

    func getTotalDiplomacyBonus() -> Int {
        var total = 0
        for degree in completedDegrees {
            total += degree.field.statBonus.diplomacy
        }
        return total
    }
}

// MARK: - Pre-defined Institutions

extension EducationalInstitution {
    static func getAllInstitutions() -> [EducationalInstitution] {
        return [
            // Ivy League
            EducationalInstitution(name: "Harvard University", type: .ivyLeague, location: "Cambridge, MA", prestige: 10),
            EducationalInstitution(name: "Yale University", type: .ivyLeague, location: "New Haven, CT", prestige: 10),
            EducationalInstitution(name: "Princeton University", type: .ivyLeague, location: "Princeton, NJ", prestige: 10),
            EducationalInstitution(name: "Columbia University", type: .ivyLeague, location: "New York, NY", prestige: 9),
            EducationalInstitution(name: "University of Pennsylvania", type: .ivyLeague, location: "Philadelphia, PA", prestige: 9),

            // Top Private Universities
            EducationalInstitution(name: "Stanford University", type: .privateUniversity, location: "Stanford, CA", prestige: 10),
            EducationalInstitution(name: "MIT", type: .privateUniversity, location: "Cambridge, MA", prestige: 10),
            EducationalInstitution(name: "Duke University", type: .privateUniversity, location: "Durham, NC", prestige: 8),
            EducationalInstitution(name: "Northwestern University", type: .privateUniversity, location: "Evanston, IL", prestige: 8),
            EducationalInstitution(name: "Georgetown University", type: .privateUniversity, location: "Washington, DC", prestige: 8),

            // State Universities
            EducationalInstitution(name: "University of California, Berkeley", type: .stateUniversity, location: "Berkeley, CA", prestige: 9),
            EducationalInstitution(name: "University of Michigan", type: .stateUniversity, location: "Ann Arbor, MI", prestige: 8),
            EducationalInstitution(name: "University of Virginia", type: .stateUniversity, location: "Charlottesville, VA", prestige: 8),
            EducationalInstitution(name: "University of Texas at Austin", type: .stateUniversity, location: "Austin, TX", prestige: 7),
            EducationalInstitution(name: "Ohio State University", type: .stateUniversity, location: "Columbus, OH", prestige: 6),
            EducationalInstitution(name: "Penn State University", type: .stateUniversity, location: "University Park, PA", prestige: 6),

            // Community Colleges
            EducationalInstitution(name: "Northern Virginia Community College", type: .communityCollege, location: "Annandale, VA", prestige: 4),
            EducationalInstitution(name: "Santa Monica College", type: .communityCollege, location: "Santa Monica, CA", prestige: 5),
            EducationalInstitution(name: "Miami Dade College", type: .communityCollege, location: "Miami, FL", prestige: 4),

            // Professional Schools
            EducationalInstitution(name: "Harvard Law School", type: .lawSchool, location: "Cambridge, MA", prestige: 10),
            EducationalInstitution(name: "Yale Law School", type: .lawSchool, location: "New Haven, CT", prestige: 10),
            EducationalInstitution(name: "Stanford Law School", type: .lawSchool, location: "Stanford, CA", prestige: 9),

            EducationalInstitution(name: "Harvard Medical School", type: .medicalSchool, location: "Boston, MA", prestige: 10),
            EducationalInstitution(name: "Johns Hopkins School of Medicine", type: .medicalSchool, location: "Baltimore, MD", prestige: 10),

            EducationalInstitution(name: "Harvard Business School", type: .businessSchool, location: "Boston, MA", prestige: 10),
            EducationalInstitution(name: "Wharton School", type: .businessSchool, location: "Philadelphia, PA", prestige: 10),
            EducationalInstitution(name: "Stanford Graduate School of Business", type: .businessSchool, location: "Stanford, CA", prestige: 10),
        ]
    }

    static func getInstitutions(ofType type: InstitutionType) -> [EducationalInstitution] {
        return getAllInstitutions().filter { $0.type == type }
    }

    static func getInstitutions(forDegree level: EducationLevel) -> [EducationalInstitution] {
        return getAllInstitutions().filter { $0.type.availableDegrees.contains(level) }
    }
}
