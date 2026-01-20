import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var progressService: ProgressService
    @StateObject private var dailyPlanService: DailyPlanService
    
    @State private var selectedTab = 0
    @State private var navigationPath = NavigationPath()
    
    init(progressService: ProgressService) {
        _dailyPlanService = StateObject(wrappedValue: DailyPlanService(progressService: progressService))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $navigationPath) {
                DashboardView(dailyPlanService: dailyPlanService, navigationPath: $navigationPath)
                    .navigationDestination(for: DrillDestination.self) { destination in
                        DrillDetailView(drill: destination.drill, navigationPath: $navigationPath)
                    }
                    .navigationDestination(for: GameDestination.self) { destination in
                        GameContainerView(
                            drill: destination.drill,
                            difficulty: destination.difficulty,
                            duration: destination.duration,
                            dailyPlanService: dailyPlanService
                        )
                    }
            }
            .tabItem {
                Label("Today", systemImage: "sun.max.fill")
            }
            .tag(0)
            
            DrillLibraryView()
            .tabItem {
                Label("Drills", systemImage: "square.grid.2x2.fill")
            }
            .tag(1)
            
            NavigationStack {
                ProgressScreen()
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.fill")
            }
            .tag(2)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(Color("AccentA"))
        .environmentObject(dailyPlanService)
    }
}

struct DrillDestination: Hashable {
    let drill: Drill
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(drill.id)
    }
    
    static func == (lhs: DrillDestination, rhs: DrillDestination) -> Bool {
        lhs.drill.id == rhs.drill.id
    }
}

struct GameDestination: Hashable {
    let drill: Drill
    let difficulty: DifficultyLevel
    let duration: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(drill.id)
        hasher.combine(difficulty.rawValue)
        hasher.combine(duration)
    }
    
    static func == (lhs: GameDestination, rhs: GameDestination) -> Bool {
        lhs.drill.id == rhs.drill.id && lhs.difficulty == rhs.difficulty && lhs.duration == rhs.duration
    }
}
