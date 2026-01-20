import SwiftUI

struct DrillLibraryView: View {
    @EnvironmentObject var progressService: ProgressService
    @EnvironmentObject var dailyPlanService: DailyPlanService
    
    @State private var selectedTrackFilter: String? = nil
    @State private var selectedDurationFilter: Int? = nil
    @State private var selectedDifficultyFilter: DifficultyLevel? = nil
    @State private var navigationPath = NavigationPath()
    
    private var filteredDrills: [Drill] {
        SeedData.drills.filter { drill in
            if let trackFilter = selectedTrackFilter, drill.trackID != trackFilter {
                return false
            }
            if let durationFilter = selectedDurationFilter, !drill.durationOptions.contains(durationFilter) {
                return false
            }
            if let difficultyFilter = selectedDifficultyFilter, !drill.difficultyLevels.contains(difficultyFilter) {
                return false
            }
            return true
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppBackground(style: .primary)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        filterSection
                        drillsGrid
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Drill Library")
            .navigationBarTitleDisplayMode(.large)
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
    }
    
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Track filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ChipButton(
                        title: "All Tracks",
                        isSelected: selectedTrackFilter == nil
                    ) {
                        selectedTrackFilter = nil
                    }
                    
                    ForEach(SeedData.tracks) { track in
                        ChipButton(
                            title: track.title,
                            isSelected: selectedTrackFilter == track.id,
                            accentColor: track.accentColorName
                        ) {
                            selectedTrackFilter = track.id
                        }
                    }
                }
            }
            
            // Duration filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ChipButton(
                        title: "Any Time",
                        isSelected: selectedDurationFilter == nil,
                        accentColor: "AccentB"
                    ) {
                        selectedDurationFilter = nil
                    }
                    
                    ForEach([2, 3, 5], id: \.self) { duration in
                        ChipButton(
                            title: "\(duration) min",
                            isSelected: selectedDurationFilter == duration,
                            accentColor: "AccentB"
                        ) {
                            selectedDurationFilter = duration
                        }
                    }
                }
            }
            
            // Difficulty filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ChipButton(
                        title: "Any Level",
                        isSelected: selectedDifficultyFilter == nil,
                        accentColor: "AccentC"
                    ) {
                        selectedDifficultyFilter = nil
                    }
                    
                    ForEach(DifficultyLevel.allCases, id: \.rawValue) { level in
                        ChipButton(
                            title: level.displayName,
                            isSelected: selectedDifficultyFilter == level,
                            accentColor: "AccentC"
                        ) {
                            selectedDifficultyFilter = level
                        }
                    }
                }
            }
        }
    }
    
    private var drillsGrid: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredDrills) { drill in
                NavigationLink(value: DrillDestination(drill: drill)) {
                    DrillCardContent(
                        drill: drill,
                        track: SeedData.tracks.first { $0.id == drill.trackID },
                        bestScore: progressService.bestScore(for: drill.id)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            if filteredDrills.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(Color("TextMuted"))
                    
                    Text("No drills match your filters")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                    
                    SecondaryButton("Clear Filters") {
                        selectedTrackFilter = nil
                        selectedDurationFilter = nil
                        selectedDifficultyFilter = nil
                    }
                    .frame(width: 160)
                }
                .padding(.vertical, 40)
            }
        }
    }
}

struct DrillCardContent: View {
    let drill: Drill
    let track: Track?
    var bestScore: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(track?.accentColorName ?? "AccentA").opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: drill.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(track?.accentColorName ?? "AccentA"))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(drill.durationOptions, id: \.self) { duration in
                        Text("\(duration)m")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color("TextMuted"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color("BackgroundSecondary"))
                            )
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(drill.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                
                Text(drill.shortDescription)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            if let score = bestScore {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color("AccentC"))
                    Text("Best: \(score)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("AccentC"))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("StrokeSoft").opacity(0.5), lineWidth: 1)
        )
    }
}
