import Foundation
import Combine

@MainActor
class ProgressService: ObservableObject {
    @Published var progress: UserProgress
    @Published var badges: [Badge]
    
    private let progressKey = "user_progress"
    private let fileManager = FileManager.default
    
    init() {
        self.progress = UserProgress()
        self.badges = SeedData.badges
        loadProgress()
    }
    
    // MARK: - Persistence
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var progressFileURL: URL {
        documentsDirectory.appendingPathComponent("progress.json")
    }
    
    func loadProgress() {
        guard fileManager.fileExists(atPath: progressFileURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: progressFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            progress = try decoder.decode(UserProgress.self, from: data)
            updateBadgesFromProgress()
        } catch {
            print("Failed to load progress: \(error)")
        }
    }
    
    func saveProgress() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(progress)
            try data.write(to: progressFileURL)
        } catch {
            print("Failed to save progress: \(error)")
        }
    }
    
    // MARK: - Progress Updates
    
    func completeDrill(drillID: String, score: Int, duration: Int, difficulty: String, levelReached: Int, perfectLevel: Bool = false) {
        let entry = DrillHistoryEntry(
            drillID: drillID,
            score: score,
            duration: duration,
            difficulty: difficulty,
            levelReached: levelReached
        )
        
        progress.drillHistory.append(entry)
        progress.totalDrills += 1
        progress.totalMinutes += duration
        
        if let currentBest = progress.drillBestScores[drillID] {
            if score > currentBest {
                progress.drillBestScores[drillID] = score
            }
        } else {
            progress.drillBestScores[drillID] = score
        }
        
        progress.updateStreak()
        progress.updateHeatmap(minutes: duration)
        
        let xpEarned = calculateXP(score: score, duration: duration, difficulty: difficulty)
        progress.addXP(xpEarned)
        
        checkAndAwardBadges(
            drillID: drillID,
            score: score,
            levelReached: levelReached,
            perfectLevel: perfectLevel
        )
        
        saveProgress()
    }
    
    private func calculateXP(score: Int, duration: Int, difficulty: String) -> Int {
        var xp = score / 10
        xp += duration * 2
        
        switch difficulty {
        case "Hard": xp = Int(Double(xp) * 1.5)
        case "Medium": xp = Int(Double(xp) * 1.2)
        default: break
        }
        
        return max(5, xp)
    }
    
    // MARK: - Badge System
    
    private func updateBadgesFromProgress() {
        for i in 0..<badges.count {
            if progress.unlockedBadgeIDs.contains(badges[i].id) {
                badges[i].unlockedAt = Date()
            }
        }
    }
    
    func checkAndAwardBadges(drillID: String, score: Int, levelReached: Int, perfectLevel: Bool) {
        let drill = SeedData.drills.first { $0.id == drillID }
        
        for i in 0..<badges.count {
            guard !badges[i].isUnlocked else { continue }
            
            let criteria = badges[i].criteria
            var earned = false
            
            switch criteria.type {
            case .completeDrills:
                earned = progress.totalDrills >= criteria.value
                
            case .streakDays:
                earned = progress.streakDays >= criteria.value
                
            case .totalMinutes:
                earned = progress.totalMinutes >= criteria.value
                
            case .scoreInDrill:
                if let targetDrill = criteria.drillID {
                    if drillID == targetDrill && score >= criteria.value {
                        earned = true
                    } else if let best = progress.drillBestScores[targetDrill], best >= criteria.value {
                        earned = true
                    }
                }
                
            case .completeLevelInGame:
                if let gameType = criteria.gameType,
                   let drill = drill,
                   drill.gameType.rawValue == gameType,
                   levelReached >= criteria.value {
                    earned = true
                }
                
            case .weeklyDays:
                earned = progress.daysActiveThisWeek() >= criteria.value
                
            case .perfectLevel:
                earned = perfectLevel
                
            case .ritualLevel:
                earned = progress.ritualLevel >= criteria.value
            }
            
            if earned {
                badges[i].unlockedAt = Date()
                progress.unlockedBadgeIDs.append(badges[i].id)
            }
        }
    }
    
    // MARK: - Track Management
    
    func selectTrack(_ trackID: String) {
        progress.selectedTrackID = trackID
        saveProgress()
    }
    
    func completeOnboarding() {
        progress.hasCompletedOnboarding = true
        saveProgress()
    }
    
    func markTutorialSeen(_ tutorialID: String) {
        if !progress.tutorialsSeen.contains(tutorialID) {
            progress.tutorialsSeen.append(tutorialID)
            saveProgress()
        }
    }
    
    func hasSeen(tutorial tutorialID: String) -> Bool {
        progress.tutorialsSeen.contains(tutorialID)
    }
    
    // MARK: - Reset
    
    func resetProgress() {
        progress = UserProgress()
        badges = SeedData.badges
        saveProgress()
    }
    
    // MARK: - Helpers
    
    var unlockedBadges: [Badge] {
        badges.filter { $0.isUnlocked }
    }
    
    var lockedBadges: [Badge] {
        badges.filter { !$0.isUnlocked }
    }
    
    func bestScore(for drillID: String) -> Int? {
        progress.drillBestScores[drillID]
    }
    
    var currentTrack: Track? {
        SeedData.tracks.first { $0.id == progress.selectedTrackID }
    }
}
