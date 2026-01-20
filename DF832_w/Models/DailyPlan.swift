import Foundation

struct DailyPlan {
    let date: Date
    let drills: [PlannedDrill]
    
    struct PlannedDrill: Identifiable {
        let id = UUID()
        let drill: Drill
        let reason: PlanReason
        var isCompleted: Bool
    }
    
    enum PlanReason: String {
        case recommended = "Recommended for your track"
        case variety = "Build variety"
        case streakSaver = "Quick streak saver"
    }
}

struct PlanSprintTask: Identifiable, Equatable {
    let id: String
    let title: String
    let category: TaskCategory
    let energyLevel: EnergyLevel
    let duration: TaskDuration
    let prerequisites: [String]
    
    enum TaskCategory: String, Codable {
        case physical
        case mental
        case creative
        case organizational
    }
    
    enum EnergyLevel: Int, Codable, Comparable {
        case low = 1
        case medium = 2
        case high = 3
        
        static func < (lhs: EnergyLevel, rhs: EnergyLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    enum TaskDuration: Int, Codable {
        case quick = 1
        case medium = 2
        case long = 3
    }
    
    static func == (lhs: PlanSprintTask, rhs: PlanSprintTask) -> Bool {
        lhs.id == rhs.id
    }
}

struct PlanSprintRule: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let evaluate: ([PlanSprintTask]) -> Double
}
