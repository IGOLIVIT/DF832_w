import Foundation

struct UserProgress: Codable {
    var selectedTrackID: String
    var streakDays: Int
    var lastCompletedDate: Date?
    var totalMinutes: Int
    var totalDrills: Int
    var bestStreak: Int
    var weeklyHeatmap: [String: Int]
    var drillHistory: [DrillHistoryEntry]
    var drillBestScores: [String: Int]
    var unlockedBadgeIDs: [String]
    var ritualLevel: Int
    var ritualXP: Int
    var hasCompletedOnboarding: Bool
    var tutorialsSeen: [String]
    
    static let xpPerLevel = 100
    
    var xpToNextLevel: Int {
        UserProgress.xpPerLevel - (ritualXP % UserProgress.xpPerLevel)
    }
    
    var levelProgress: Double {
        Double(ritualXP % UserProgress.xpPerLevel) / Double(UserProgress.xpPerLevel)
    }
    
    init() {
        self.selectedTrackID = TrackID.focus.rawValue
        self.streakDays = 0
        self.lastCompletedDate = nil
        self.totalMinutes = 0
        self.totalDrills = 0
        self.bestStreak = 0
        self.weeklyHeatmap = [:]
        self.drillHistory = []
        self.drillBestScores = [:]
        self.unlockedBadgeIDs = []
        self.ritualLevel = 1
        self.ritualXP = 0
        self.hasCompletedOnboarding = false
        self.tutorialsSeen = []
    }
    
    mutating func addXP(_ amount: Int) {
        ritualXP += amount
        let newLevel = (ritualXP / UserProgress.xpPerLevel) + 1
        if newLevel > ritualLevel {
            ritualLevel = newLevel
        }
    }
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastCompletedDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 0 {
                return
            } else if daysDiff == 1 {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        
        lastCompletedDate = Date()
        
        if streakDays > bestStreak {
            bestStreak = streakDays
        }
    }
    
    mutating func updateHeatmap(minutes: Int) {
        let dateKey = Self.dateKey(for: Date())
        let currentMinutes = weeklyHeatmap[dateKey] ?? 0
        weeklyHeatmap[dateKey] = currentMinutes + minutes
    }
    
    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func heatmapValue(for date: Date) -> Int {
        let key = Self.dateKey(for: date)
        return weeklyHeatmap[key] ?? 0
    }
    
    func weeklyTotal() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var total = 0
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                total += heatmapValue(for: date)
            }
        }
        
        return total
    }
    
    func daysActiveThisWeek() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var count = 0
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                if heatmapValue(for: date) > 0 {
                    count += 1
                }
            }
        }
        
        return count
    }
}

struct DrillHistoryEntry: Identifiable, Codable {
    let id: UUID
    let drillID: String
    let completedAt: Date
    let score: Int
    let duration: Int
    let difficulty: String
    let levelReached: Int
    
    init(drillID: String, score: Int, duration: Int, difficulty: String, levelReached: Int) {
        self.id = UUID()
        self.drillID = drillID
        self.completedAt = Date()
        self.score = score
        self.duration = duration
        self.difficulty = difficulty
        self.levelReached = levelReached
    }
}
