import Foundation

struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let criteria: BadgeCriteria
    let rarity: BadgeRarity
    var unlockedAt: Date?
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
    
    static func == (lhs: Badge, rhs: Badge) -> Bool {
        lhs.id == rhs.id
    }
}

struct BadgeCriteria: Codable, Equatable {
    let type: BadgeCriteriaType
    let value: Int
    let drillID: String?
    let gameType: String?
    
    init(type: BadgeCriteriaType, value: Int, drillID: String? = nil, gameType: String? = nil) {
        self.type = type
        self.value = value
        self.drillID = drillID
        self.gameType = gameType
    }
}

enum BadgeCriteriaType: String, Codable {
    case completeDrills
    case streakDays
    case totalMinutes
    case scoreInDrill
    case completeLevelInGame
    case weeklyDays
    case perfectLevel
    case ritualLevel
}

enum BadgeRarity: String, Codable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var colorName: String {
        switch self {
        case .common: return "TextSecondary"
        case .uncommon: return "Success"
        case .rare: return "AccentB"
        case .epic: return "AccentA"
        case .legendary: return "AccentC"
        }
    }
}
