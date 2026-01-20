import Foundation
import Combine

@MainActor
class DailyPlanService: ObservableObject {
    @Published var todayPlan: DailyPlan?
    
    private let progressService: ProgressService
    
    init(progressService: ProgressService) {
        self.progressService = progressService
        generateTodayPlan()
    }
    
    func generateTodayPlan() {
        let today = Date()
        var plannedDrills: [DailyPlan.PlannedDrill] = []
        
        let selectedTrackID = progressService.progress.selectedTrackID
        let selectedTrack = SeedData.tracks.first { $0.id == selectedTrackID }
        
        // 1. Recommended drill from selected track
        if let track = selectedTrack,
           let recommendedID = track.recommendedDrillIDs.first,
           let drill = SeedData.drills.first(where: { $0.id == recommendedID }) {
            plannedDrills.append(DailyPlan.PlannedDrill(
                drill: drill,
                reason: .recommended,
                isCompleted: isDrillCompletedToday(drill.id)
            ))
        }
        
        // 2. Variety drill from another track
        let otherTracks = SeedData.tracks.filter { $0.id != selectedTrackID }
        if let varietyTrack = otherTracks.randomElement(),
           let varietyDrillID = varietyTrack.recommendedDrillIDs.first,
           let varietyDrill = SeedData.drills.first(where: { $0.id == varietyDrillID }),
           !plannedDrills.contains(where: { $0.drill.id == varietyDrill.id }) {
            plannedDrills.append(DailyPlan.PlannedDrill(
                drill: varietyDrill,
                reason: .variety,
                isCompleted: isDrillCompletedToday(varietyDrill.id)
            ))
        }
        
        // 3. Streak saver - short 2-min drill
        let shortDrills = SeedData.drills.filter { $0.durationOptions.contains(2) }
        if let streakSaver = shortDrills.first(where: { drill in !plannedDrills.contains(where: { pd in pd.drill.id == drill.id }) }) {
            plannedDrills.append(DailyPlan.PlannedDrill(
                drill: streakSaver,
                reason: .streakSaver,
                isCompleted: isDrillCompletedToday(streakSaver.id)
            ))
        }
        
        todayPlan = DailyPlan(date: today, drills: plannedDrills)
    }
    
    private func isDrillCompletedToday(_ drillID: String) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return progressService.progress.drillHistory.contains { entry in
            let entryDay = calendar.startOfDay(for: entry.completedAt)
            return entry.drillID == drillID && entryDay == today
        }
    }
    
    func markDrillCompleted(_ drillID: String) {
        guard let plan = todayPlan else { return }
        
        var updatedDrills = plan.drills
        if let index = updatedDrills.firstIndex(where: { $0.drill.id == drillID }) {
            var drill = updatedDrills[index]
            drill.isCompleted = true
            updatedDrills[index] = drill
        }
        
        todayPlan = DailyPlan(date: plan.date, drills: updatedDrills)
    }
    
    var completedCount: Int {
        todayPlan?.drills.filter { $0.isCompleted }.count ?? 0
    }
    
    var totalCount: Int {
        todayPlan?.drills.count ?? 0
    }
    
    var completionPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var hasCompletedAtLeastOne: Bool {
        completedCount > 0
    }
}
