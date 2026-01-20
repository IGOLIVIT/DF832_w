import Foundation

struct Drill: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let trackID: String
    let gameType: GameType
    let durationOptions: [Int]
    let difficultyLevels: [DifficultyLevel]
    let shortDescription: String
    let longDescription: String
    let howItHelps: [String]
    let levels: [DrillLevel]
    let icon: String
    
    static func == (lhs: Drill, rhs: Drill) -> Bool {
        lhs.id == rhs.id
    }
}

enum GameType: String, Codable {
    case focusGrid = "focusGrid"
    case planSprint = "planSprint"
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var displayName: String { rawValue }
    
    var gridSize: Int {
        switch self {
        case .easy: return 4
        case .medium: return 5
        case .hard: return 6
        }
    }
    
    var sequenceLength: (min: Int, max: Int) {
        switch self {
        case .easy: return (3, 4)
        case .medium: return (4, 5)
        case .hard: return (5, 6)
        }
    }
    
    var previewDuration: Double {
        switch self {
        case .easy: return 0.6
        case .medium: return 0.45
        case .hard: return 0.3
        }
    }
    
    var timeLimit: Int {
        switch self {
        case .easy: return 20
        case .medium: return 15
        case .hard: return 12
        }
    }
    
    var allowedMistakes: Int {
        switch self {
        case .easy: return 2
        case .medium: return 1
        case .hard: return 0
        }
    }
    
    var scoreMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        }
    }
}

struct DrillLevel: Identifiable, Codable, Equatable {
    let id: Int
    let number: Int
    let target: Int
    let timeLimit: Int
    let allowedMistakes: Int
    let difficultyMultiplier: Double
    let sequenceLength: Int
    let gridSize: Int
    
    static func == (lhs: DrillLevel, rhs: DrillLevel) -> Bool {
        lhs.id == rhs.id && lhs.number == rhs.number
    }
}
